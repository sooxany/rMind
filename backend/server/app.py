"""FastAPI entry point for RPPG Analyzer."""
from __future__ import annotations

import uuid
from pathlib import Path

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

from . import analyzer

# ---------------------------------------------------------------------------
# 경로 설정
# ---------------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent            # .../rppg_project/server
UPLOAD_DIR = BASE_DIR / "uploads"
CSV_DIR = BASE_DIR / "csvs"
STATIC_DIR = BASE_DIR / "static"

for d in (UPLOAD_DIR, CSV_DIR, STATIC_DIR):
    d.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# FastAPI 앱 초기화
# ---------------------------------------------------------------------------
app = FastAPI(title="RPPG Analyzer API")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# png 파일 서빙 (/static)
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")


# ---------------------------------------------------------------------------
# 라우터: /upload_video
# ---------------------------------------------------------------------------
@app.post("/upload_video")
async def upload_video(file: UploadFile = File(...)):
    """사용자가 업로드한 영상을 분석하고 결과 이미지를 반환한다."""
    # 파일명 검증
    if not file.filename:
        raise HTTPException(status_code=400, detail="No filename provided")

    # 허용되는 확장자
    allowed_ext = {".mp4", ".avi", ".mov", ".mkv"}
    file_suffix = Path(file.filename).suffix.lower()
    if file_suffix not in allowed_ext:
        raise HTTPException(status_code=400, detail="Unsupported file type")

    # UUID 기반 파일명 생성
    video_id = uuid.uuid4().hex
    video_filename = f"{video_id}{file_suffix}"
    video_path = UPLOAD_DIR / video_filename

    # 파일 저장
    try:
        with video_path.open("wb") as buffer:
            buffer.write(await file.read())
    except Exception as e:  # pragma: no cover
        raise HTTPException(status_code=500, detail=f"Failed to save video: {e}")

    # CSV 및 이미지 경로 설정
    rgb_csv_path = CSV_DIR / f"{video_id}_rgb.csv"
    blink_csv_path = CSV_DIR / f"{video_id}_blink.csv"
    bpm_img_path = STATIC_DIR / f"{video_id}_bpm.png"
    blink_img_path = STATIC_DIR / f"{video_id}_blink.png"
    motion_img_path = STATIC_DIR / f"{video_id}_motion.png"

    # 분석
    try:
        # 1. 영상에서 RGB/Blink 특징 추출
        analyzer.extract_features_from_video(
            video_path=str(video_path),
            rgb_csv_path=str(rgb_csv_path),
            blink_csv_path=str(blink_csv_path),
        )

        # 2. BPM 및 Blink 시각화
        analyzer.analyze_and_plot(
            rgb_csv_path=str(rgb_csv_path),
            blink_csv_path=str(blink_csv_path),
            bpm_img_path=str(bpm_img_path),
            blink_img_path=str(blink_img_path),
        )

        # 3. Motion 분석 및 시각화
        analyzer.analyze_motion(
            video_path=str(video_path),
            motion_img_path=str(motion_img_path),
        )
    except Exception as e:  # pragma: no cover
        raise HTTPException(status_code=500, detail=f"Analysis failed: {e}")

    # 응답 데이터 구성
    return {
        "video_id": video_id,
        "bpm_plot_url": f"/static/{bpm_img_path.name}",
        "blink_plot_url": f"/static/{blink_img_path.name}",
        "motion_plot_url": f"/static/{motion_img_path.name}",
    }


# ---------------------------------------------------------------------------
# 라우터: 이미지 다운로드
# ---------------------------------------------------------------------------
@app.get("/download/{image_type}/{video_id}")
async def download_image(image_type: str, video_id: str):
    """특정 비디오 ID의 분석 결과 이미지를 다운로드한다."""
    # 이미지 타입 검증
    allowed_types = {"bpm", "blink", "motion"}
    if image_type not in allowed_types:
        raise HTTPException(status_code=400, detail="Invalid image type")
    
    # 이미지 파일 경로 생성
    img_filename = f"{video_id}_{image_type}.png"
    img_path = STATIC_DIR / img_filename
    
    # 파일 존재 여부 확인
    if not img_path.exists():
        raise HTTPException(status_code=404, detail="Image not found")
    
    return FileResponse(
        path=str(img_path),
        media_type="image/png",
        filename=img_filename
    ) 
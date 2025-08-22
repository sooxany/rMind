from __future__ import annotations

import importlib.util
import sys
import os
import cv2
import dlib
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
from pathlib import Path
from types import ModuleType
from typing import Callable

BASE_DIR = Path(__file__).resolve().parent.parent  # backend/


def _load_module(module_name: str, file_path: Path) -> ModuleType:
    # 주어진 파일 경로에서 모듈을 동적으로 로드
    spec = importlib.util.spec_from_file_location(module_name, str(file_path))
    if spec is None or spec.loader is None:  # pragma: no cover
        raise ImportError(f"Unable to load module {module_name} from {file_path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module  # 캐시에 등록
    spec.loader.exec_module(module)
    return module


# ---------------------------------------------------------------------------
# 1) extract_features_from_video – test_data/save_data_demo.py
# ---------------------------------------------------------------------------
save_data_path = BASE_DIR / "test_data" / "save_data_demo.py"
_save_data_mod = _load_module("_save_data", save_data_path)
extract_features_from_video: Callable = _save_data_mod.extract_features_from_video


# ---------------------------------------------------------------------------
# 2) analyze_and_plot – RPPG-BPM-master/main.py
#    하이픈(-)이 포함된 디렉터리는 파이썬 패키지로 바로 임포트할 수 없으므로
#    파일 경로 기반 동적 로딩을 사용한다.
# ---------------------------------------------------------------------------
main_path = BASE_DIR / "RPPG-BPM-master" / "main.py"
_rppg_main_mod = _load_module("_rppg_main", main_path)
analyze_and_plot: Callable = _rppg_main_mod.analyze_and_plot


# ---------------------------------------------------------------------------
# 3) analyze_motion – Motion detection functionality
# ---------------------------------------------------------------------------
def analyze_motion(
    video_path: str,
    motion_img_path: str,
    stability_threshold: float = 2.0,
    second_interval: int = 1
) -> str:
    """
    Parameters
    ----------
    video_path : str
        분석할 영상 파일 경로
    motion_img_path : str
        저장할 움직임 그래프 이미지 경로
    stability_threshold : float
        안정성 임계값 (기본값: 2.0)
    second_interval : int
        초 단위 간격 (기본값: 1초)
    """
    # 스타일
    mpl.rcParams['font.family'] = 'DejaVu Sans'
    mpl.rcParams['axes.edgecolor'] = '#DDDDDD'
    mpl.rcParams['axes.linewidth'] = 0.8
    mpl.rcParams['axes.titlesize'] = 16
    mpl.rcParams['axes.labelsize'] = 13

    # 모델 불러오기
    predictor_local = BASE_DIR / "Eye_detection" / "shape_predictor_68_face_landmarks.dat"
    predictor_path = str(predictor_local) if predictor_local.exists() else "shape_predictor_68_face_landmarks.dat"
    
    detector = dlib.get_frontal_face_detector()
    predictor = dlib.shape_predictor(predictor_path)

    # 랜드마크 추출 함수
    def get_landmarks(gray, rect):
        shape = predictor(gray, rect)
        coords = np.zeros((68, 2), dtype="float")
        for i in range(68):
            coords[i] = (shape.part(i).x, shape.part(i).y)
        return coords

    # 영상 처리
    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)
    frame_interval = int(fps * second_interval)

    prev_landmarks = None
    motions_per_second = []
    frame_idx = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        if frame_idx % frame_interval == 0:
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = detector(gray)

            if len(faces) > 0:
                landmarks = get_landmarks(gray, faces[0])
                if prev_landmarks is not None:
                    motion = np.linalg.norm(landmarks - prev_landmarks, axis=1).mean()
                    motions_per_second.append(motion)
                else:
                    motions_per_second.append(0)
                prev_landmarks = landmarks
            else:
                motions_per_second.append(0)

        frame_idx += 1

    cap.release()

    # 시간축 데이터 만들기
    x = np.arange(len(motions_per_second))  # 1초 단위

    # 그래프 그리기
    plt.figure(figsize=(12, 5), dpi=120)
    plt.plot(x, motions_per_second, color='#FF6B6B', linewidth=2.2, label='Movement', alpha=0.9)
    plt.axhline(y=stability_threshold, color='gray', linestyle='--', linewidth=1.4, label='Threshold')

    # 스타일
    plt.title("Motion Intensity Over Time", pad=15)
    plt.xlabel("Time (seconds)")
    plt.ylabel("Avg Movement Intensity")
    if len(x) > 0:
        plt.xticks(x[::max(1, len(x)//10)])  # 최대 10개 눈금만 표시
    plt.grid(axis='y', linestyle='--', alpha=0.3)
    plt.legend(loc='upper right', frameon=False)
    plt.tight_layout()
    plt.savefig(motion_img_path, dpi=300)
    plt.close()

    return motion_img_path


__all__ = [
    "extract_features_from_video",
    "analyze_and_plot",
    "analyze_motion",
] 
# 프로젝트 간단 설명

2025-1 캡스톤 프로젝트. 아직 수정중 ...  
(아래는 간단 설명임. 미리 설치해야할 패키지는 따로 안적어둠.)

### 파일 트리 설명

```
Capstone/
├── backend/
│   ├── test_data/
│   │   ├── save_data.py          # 영상 파일을 분석하여 RGB 평균값과 눈깜빡임 정보를 CSV로 저장
│   │   ├── eye_bpm_v1.csv        # 테스트용 RGB 및 Blink 데이터 CSV
│   │   ├── test_data_main.csv    # 추가 테스트 데이터 CSV
│   │   └── test_data_v1.csv      # 추가 테스트 데이터 CSV
│   ├── server/
│   │   ├── app.py                # FastAPI 서버의 진입점
│   │   ├── analyzer.py           # 분석 기능을 제공하는 모듈
│   │   ├── __init__.py           # 패키지 초기화 파일
│   │   ├── static/               # 시각화 결과 이미지(.png)를 저장하는 폴더
│   │   ├── csvs/                 # 분석 후 생성된 CSV 파일 저장 폴더
│   │   └── uploads/              # 업로드된 영상이 저장될 폴더
│   ├── RPPG-BPM-master/
│   │   ├── main.py               # CSV 파일을 기반으로 BPM과 눈깜빡임 속도를 plot 이미지로 저장
│   │   ├── first_stage/          # 신호 처리 관련 모듈
│   │   └── second_stage/         # 분석 및 시각화 관련 모듈
│   └── Eye_detection/
│       ├── Eye_detection.py      # 얼굴 및 눈 탐지 관련 코드
│       └── shape_predictor_68_face_landmarks.dat # 얼굴 랜드마크 모델 데이터
├── .git/                         # Git 버전 관리 디렉토리
└── .gitignore                    # Git 무시 파일 목록
```

### 서버 실행 방법

1. 프로젝트 디렉토리로 이동:
   ```bash
   cd /path/to/Capstone
   ```
2. 서버를 실행:
   ```bash
   uvicorn rppg_project.server.app:app --reload
   ```
3. 웹 브라우저로 Swagger 통해서 확인 가능:  
   http://127.0.0.1:8000/docs 접속

### 전체적인 플로우

1. 영상 업로드:
   사용자가 /upload_video 엔드포인트로 영상을 업로드.
   업로드된 영상은 uploads/ 폴더에 UUID 기반 이름으로 저장.

2. 영상 분석:
   extract_features_from_video 함수가 호출되어 영상에서 RGB 평균값과 눈깜빡임 정보를 추출하여 csvs/ 폴더에 CSV 파일로 저장.

3. 데이터 시각화:
   analyze_and_plot 함수가 호출되어 CSV 데이터를 기반으로 BPM과 눈깜빡임 속도를 시각화하여 static/ 폴더에 PNG 이미지로 저장.

4. 결과 반환:
   API는 JSON 형태로 분석 결과의 URL을 반환합니다. 사용자는 이 URL을 통해 시각화된 결과를 확인 가능.

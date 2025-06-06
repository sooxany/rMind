import cv2
import numpy as np
import os
import dlib
from imutils import face_utils
from scipy.spatial import distance
from typing import Tuple, List


def _eye_aspect_ratio(eye: np.ndarray) -> float:
    """EAR(Eye-Aspect-Ratio) 계산 함수"""
    A = distance.euclidean(eye[1], eye[5])
    B = distance.euclidean(eye[2], eye[4])
    C = distance.euclidean(eye[0], eye[3])
    return (A + B) / (2.0 * C)


def extract_features_from_video(
    video_path: str,
    rgb_csv_path: str,
    blink_csv_path: str,
    fps: int = 15,
    blink_thresh: float = 0.25
) -> Tuple[str, str]:
    """
    저장된 영상을 입력받아 프레임 단위로
    1) 얼굴 ROI 의 RGB 평균값
    2) 눈깜박임 여부(0/1)
    를 추출하여 각각 CSV 로 저장한다.

    Returns
    -------
    Tuple[str, str]
        (rgb_csv_path, blink_csv_path)
    """

    # --- 초기화 -----------------------------------------------------------
    face_cascade = cv2.CascadeClassifier(
        cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
    )

    # dlib predictor 경로(프로젝트 내/전역 두 곳 모두 확인)
    predictor_local = os.path.join(
        os.path.dirname(__file__),
        "../Eye_detection/shape_predictor_68_face_landmarks.dat",
    )
    predictor_path = predictor_local if os.path.exists(predictor_local) else (
        "shape_predictor_68_face_landmarks.dat"
    )
    predictor = dlib.shape_predictor(predictor_path)
    detector_dlib = dlib.get_frontal_face_detector()
    (lStart, lEnd) = face_utils.FACIAL_LANDMARKS_68_IDXS["left_eye"]
    (rStart, rEnd) = face_utils.FACIAL_LANDMARKS_68_IDXS["right_eye"]

    # --- 비디오 열기 ------------------------------------------------------
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise FileNotFoundError(f"영상 파일을 열 수 없습니다: {video_path}")

    rgb_means: List[np.ndarray] = []
    blink_flags: List[int] = []

    # --- 프레임 분석 ------------------------------------------------------
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.3, 5)

        if len(faces):
            x, y, w, h = faces[0]  # 첫 번째 얼굴만 사용
            face_roi = frame[y : y + h, x : x + w]

            # 1) RGB 평균
            mean_bgr = np.mean(face_roi, axis=(0, 1))  # B,G,R
            rgb_means.append(mean_bgr[::-1])  # R,G,B 순으로 저장

            # 2) 눈깜박임(EAR) 계산
            rect = dlib.rectangle(int(x), int(y), int(x + w), int(y + h))
            shape = predictor(gray, rect)
            shape = face_utils.shape_to_np(shape)
            left_eye = shape[lStart:lEnd]
            right_eye = shape[rStart:rEnd]

            ear = (_eye_aspect_ratio(left_eye) + _eye_aspect_ratio(right_eye)) / 2.0
            blink_flags.append(1 if ear < blink_thresh else 0)

    cap.release()

    # --- CSV 저장 ---------------------------------------------------------
    if not rgb_means:
        raise RuntimeError("영상에서 얼굴을 검출하지 못해 저장할 데이터가 없습니다.")

    rgb_arr = np.array(rgb_means)
    blink_arr = np.array(blink_flags).reshape(-1, 1)

    np.savetxt(rgb_csv_path, rgb_arr, fmt="%.5f", delimiter="\t")
    np.savetxt(blink_csv_path, blink_arr, fmt="%d", delimiter="\t")

    return rgb_csv_path, blink_csv_path


# 단독 실행 시 CLI 기능 ----------------------------------------------------
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="영상 특징 추출")
    parser.add_argument("--video", required=True, help="분석할 영상 경로")
    parser.add_argument("--rgb_csv", default="./rgb.csv", help="RGB CSV 저장 경로")
    parser.add_argument("--blink_csv", default="./blink.csv", help="Blink CSV 저장 경로")
    args = parser.parse_args()

    extract_features_from_video(args.video, args.rgb_csv, args.blink_csv)
    print("CSV 저장 완료!")

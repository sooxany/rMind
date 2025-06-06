import os
import sys
import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import interp1d
from typing import Tuple


# RPPG-BPM 모듈이 상대경로에 있을 때를 대비한 경로 추가
CUR_DIR = os.path.dirname(__file__)
sys.path.append(CUR_DIR)

# first_stage / second_stage 모듈 import
from first_stage.chrom import chrom
from first_stage.pos import pos
from first_stage.ica import ica
from second_stage.fourier_analysis import fourier_analysis
from second_stage.interbeats_analysis import interbeats_analysis
from second_stage.wavelet_analysis import wavelet_analysis


def analyze_and_plot(
    rgb_csv_path: str,
    blink_csv_path: str,
    bpm_img_path: str,
    blink_img_path: str,
    fps: int = 15,
) -> Tuple[str, str]:
    """
    RGB / Blink CSV 를 읽어 BPM, Blink 그래프를 PNG 로 저장한다.

    Returns
    -------
    Tuple[str, str]
        (bpm_img_path, blink_img_path)
    """

    # --- 데이터 로드 ------------------------------------------------------
    BGR_data = np.loadtxt(rgb_csv_path, delimiter="\t")
    if BGR_data.ndim == 1:
        BGR_data = BGR_data.reshape(1, -1)

    # BGR → R,G,B 로 맞추기
    R = BGR_data[:, 0:1]
    G = BGR_data[:, 1:2]
    B = BGR_data[:, 2:3]

    blink_data = np.loadtxt(blink_csv_path, delimiter="\t")
    if blink_data.ndim:
        blink_data = blink_data.flatten()

    # 첫 21 프레임 제거(초기값 안정화)
    BGR_trim = BGR_data[21:]
    blink_trim = blink_data[21:]

    # --- 신호 생성 --------------------------------------------------------
    signal_chrom = chrom(BGR_trim, fps, 32)
    signal_pos = pos(BGR_trim, fps, 20)
    signal_ica = ica(BGR_trim, fps)

    # --- BPM 계산(Fourier) ------------------------------------------------
    hr_fourier_pos = fourier_analysis(signal_pos, fps) * 60
    print(f"POS + Fourier BPM : {hr_fourier_pos:.2f}")

    # --- BPM 시계열(슬라이딩 윈도) ---------------------------------------
    window_size = 10 * fps        # 10초
    step_size = 5                 # 프레임 간격
    bpm_series, time_axis = [], []

    for start in range(0, len(signal_pos) - window_size, step_size):
        window = signal_pos[start : start + window_size]
        bpm = fourier_analysis(window, fps) * 60
        if 40 <= bpm <= 180:      # 이상치 제거
            bpm_series.append(bpm)
            time_axis.append((start + window_size // 2) / fps)

    # 보간으로 부드럽게
    if len(time_axis) > 3:
        interp = interp1d(time_axis, bpm_series, kind="cubic", fill_value="extrapolate")
        fine_time = np.linspace(min(time_axis), max(time_axis), 600)
        smooth_bpm = interp(fine_time)
    else:
        fine_time, smooth_bpm = time_axis, bpm_series

    # --- 그래프 ① BPM ----------------------------------------------------
    plt.figure(figsize=(12, 5))
    plt.plot(fine_time, smooth_bpm, color="crimson", linewidth=2)
    plt.axhspan(60, 100, color="lightgreen", alpha=0.2, label="Normal range")
    plt.xlabel("Time (seconds)")
    plt.ylabel("Estimated BPM")
    plt.title("Continuous Heart Rate over Time")
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.savefig(bpm_img_path, dpi=200)
    plt.close()

    # --- 그래프 ② Blink ---------------------------------------------------
    blink_counts, time_blink = [], []
    for start in range(0, len(blink_trim), fps):
        window = blink_trim[start : start + fps]
        blink_counts.append(np.sum(window))
        time_blink.append(start / fps)

    plt.figure(figsize=(10, 4))
    plt.bar(time_blink, blink_counts, width=0.8, color="skyblue")
    plt.xlabel("Time (sec)")
    plt.ylabel("Blinks / sec")
    plt.title("Blink Frequency")
    plt.tight_layout()
    plt.savefig(blink_img_path, dpi=200)
    plt.close()

    return bpm_img_path, blink_img_path


# 단독 실행 시 CLI 기능 ----------------------------------------------------
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="BPM / Blink 분석 및 시각화")
    parser.add_argument("--rgb_csv", required=True, help="RGB CSV 경로")
    parser.add_argument("--blink_csv", required=True, help="Blink CSV 경로")
    parser.add_argument("--bpm_img", default="./bpm.png", help="BPM 이미지 저장 경로")
    parser.add_argument("--blink_img", default="./blink.png", help="Blink 이미지 저장 경로")
    args = parser.parse_args()

    analyze_and_plot(args.rgb_csv, args.blink_csv, args.bpm_img, args.blink_img)
    print("그래프 저장 완료!")
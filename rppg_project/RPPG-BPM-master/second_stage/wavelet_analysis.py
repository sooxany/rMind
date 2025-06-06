import numpy as np
import pywt # 라이브러리 설치 필요 (pip install PyWavelets)
from scipy.signal import find_peaks

# 웨이블릿 분석 (Wavelet Analysis)
def wavelet_analysis(ppg_signal, fps, wavelet=None):
    
    length_data = len(ppg_signal)
    if(length_data == 0):
        return None
    
    if (wavelet==None):
        wavelet = 'mexh'  # 기본 웨이블릿으로 Mexican Hat 사용
    else: wavelet = wavelet
    
    min_freq = 36  # 최소 bpm
    max_freq = 240  # 최대 bpm
    min_freq_hz = min_freq/60  # 최소 bpm을 Hz로 변환
    min_scale = min_freq_hz/2  # 스케일 하한 (Unakafov2018 2.2.5절 기준 계산)
    max_scale = fps/2  # 스케일 상한 (Unakafov2018 2.2.5절 기준 계산)
    sampling_period = 1/fps  # 샘플링 주기
    scales = np.arange(min_scale, max_scale, 2**0.03125)  # 스케일 배열 (Unakafov2018 참고)

    # 웨이블릿 변환 수행
    # 사용 가능한 웨이블릿 목록 출력하려면: print(pywt.wavelist())
    coef = pywt.cwt(data=ppg_signal, scales=scales, wavelet=wavelet, sampling_period=sampling_period)[0]
    
    # 웨이블릿 계수 합이 최대인 스케일 선택 (Huang2016 논문 공식 13 참고)
    max_sum = 0
    index_max = 0
    for i in range(len(coef)):
        sum_coef = 0
        for j in range(len(coef[i])):
            sum_coef = sum_coef + coef[i][j]
        if(sum_coef > max_sum):
            max_sum = sum_coef
            index_max = i
    
    # 선택된 웨이블릿 계수에 대해 피크 간 분석 적용 (Huang2016 논문 기반)
    length_data = len(coef[index_max])
    max_num_peaks = ((length_data/fps)/60)*max_freq  # 최대 예상 피크 수
    min_distance = length_data/max_num_peaks  # 피크 간 최소 거리
    peaks = find_peaks(coef[index_max], distance=min_distance-1, prominence=10)[0]  # 피크 인덱스 찾기
    distances = []  # 피크 간 거리 저장
    for i in range(len(peaks)-1):
        distances.append(peaks[i+1] - peaks[i])
        
    distances = sorted(distances)  # 거리 오름차순 정렬
    M = max(1, int(len(distances)*0.5))  # 거리 중간값 주변 평균 낼 개수
    # 중간 거리만 추려낸 배열 (이상치 제거 목적)
    distances_small = distances[int(len(distances)//2 - M//2) : int(len(distances)//2 - M//2 + M)]
    one_beat_time = (sum(distances_small)/len(distances_small))/fps  # 1박동 시간 계산
    hr_estimated = 1/one_beat_time  # 심박수(bpm) 추정
  
    return hr_estimated

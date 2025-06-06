from scipy.signal import find_peaks

# 피크 간 분석 (Interbeat Analysis)
def interbeats_analysis(ppg_signal, fps):
    
    length_data = len(ppg_signal)
    # min_freq = 45  # 최소 bpm (주석 처리됨)
    max_freq = 160  # 최대 bpm
    # min_num_peaks = ((length_data/fps)/60)*min_freq  # 최소 예상 피크 수 (주석 처리됨)
    max_num_peaks = ((length_data/fps)/60)*max_freq  # 최대 예상 피크 수
    min_distance = length_data/max_num_peaks  # 피크 간 최소 거리
    # max_distance = length_data/min_num_peaks  # 피크 간 최대 거리 (주석 처리됨)
    peaks = find_peaks(ppg_signal, distance=min_distance-1, prominence=10)[0]  # 피크 인덱스 찾기
    distances = []  # 피크 간 거리 저장
    for i in range(len(peaks)-1):
        distances.append(peaks[i+1] - peaks[i])   
    
    if(len(distances) == 0):
        return None
    else:
        distances = sorted(distances)  # 거리 오름차순 정렬
        M = max(1,int(len(distances)*0.5))  # 거리 중간값 기준 평균 낼 개수
        # 중간 거리만 추려낸 배열 (이상치 제거 목적)
        distances_small = distances[int(len(distances)//2 - M//2) : int(len(distances)//2 - M//2 + M)]
        one_beat_time = (sum(distances_small)/len(distances_small))/fps  # 1박동 시간 계산
        hr_estimated = 1/one_beat_time  # 심박수(bpm) 추정

        return hr_estimated

import numpy as np
from sklearn.decomposition import FastICA
from scipy.signal import butter, lfilter

# ICA 신호 계산 함수
def ica(BGR_signal, fps):
    
    # 원본 데이터의 프레임 수
    num_frames = len(BGR_signal)
    
    # 원본 데이터 유효성 검사
    if(num_frames==0):
        # 원본 데이터 배열이 비어 있음
        raise NameError('EmptyData')
    
    # fps 값 유효성 검사
    if(fps<9):
        # fps 값이 너무 낮음 (bandpass 필터를 위해 fps >= 9 필요)
        raise NameError('WrongFPS')
    
    # 원본 신호를 R, G, B (y1, y2, y3) 채널로 분리
    y1 = BGR_signal[:, 2]
    y2 = BGR_signal[:, 1]
    y3 = BGR_signal[:, 0]

    # 정규화
    y1_norm = np.zeros(num_frames)
    y2_norm = np.zeros(num_frames)
    y3_norm = np.zeros(num_frames)
    for i in range(num_frames):
        y1_norm[i] = (y1[i] - y1.mean())/y1.std()
        y2_norm[i] = (y2[i] - y2.mean())/y2.std()
        y3_norm[i] = (y3[i] - y3.mean())/y3.std()
    
    # 밴드패스 필터 함수
    def bandpass_filter(data, lowcut, highcut):
        fs = fps # 샘플링 주파수
        nyq = 0.5 * fs # 나이퀴스트 주파수
        low = float(lowcut) / float(nyq)
        high = float(highcut) / float(nyq)
        order = 6.0 # butter 필터 차수
        b, a = butter(order, [low, high], btype='band')
        bandpass = lfilter(b, a, data)
        return bandpass  
    
    # 채널별 밴드패스 필터링
    y1_filtered = bandpass_filter(y1_norm, 0.7, 4.0)
    y2_filtered = bandpass_filter(y2_norm, 0.7, 4.0)
    y3_filtered = bandpass_filter(y3_norm, 0.7, 4.0)
    y_filtered = []
    for i in range(num_frames):
        y_filtered.append([y1_filtered[i],y2_filtered[i],y3_filtered[i]])
    
    # ICA 신호 계산
    ica = FastICA(n_components=1, random_state=0)
    ICA = ica.fit_transform(y_filtered).reshape(1, -1)[0]
    
    return ICA

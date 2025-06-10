import numpy as np
from scipy.signal import butter, lfilter

# POS 신호 계산 함수
def pos(BGR_signal, fps, l):
    
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
        
    # 겹치는 구간 길이 l이 지정되지 않은 경우
    if(l == None):
        # 비율 유지를 위해 기본적으로 l = fps로 설정
        l = int(fps)
    elif(l>0):
        l = l//1
    else: 
        # 겹치는 구간 길이 값이 부적절함
        raise NameError('WrongLength')
        
    # 원본 데이터 길이 유효성 검사
    if(num_frames<l):
        # 데이터 길이가 겹치는 구간 길이보다 짧음
        raise NameError('NotEnoughData')
        
    # 원본 신호를 R, G, B 채널로 분리
    R = BGR_signal[:, 2]
    G = BGR_signal[:, 1]
    B = BGR_signal[:, 0]
    
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
    
    # POS가 처리할 데이터 배열 (초기에는 BGR, 이후 RGB로 변환)
    RGB = np.transpose(np.array([R,G,B]))
    
    H = np.zeros(num_frames)
    
    for n in range(num_frames-l):
        m=n-l+1
        # 원본 데이터의 일부 구간을 담은 배열 (m행부터 n행까지)
        C = RGB[m:n,:].T
        if m>=0:
            
            # 정규화
            mean_color = np.mean(C, axis=1)        
            diag_mean_color = np.diag(mean_color)
            diag_mean_color_inv = np.linalg.inv(diag_mean_color)
            Cn = np.matmul(diag_mean_color_inv,C)

            # Projection Matrix
            projection_matrix = np.array([[0,1,-1],[-2,1,1]])
            
            S = np.matmul(projection_matrix,Cn)
            
            # 밴드패스 필터 적용 (S[0,:]와 S[1,:]는 CHROM 방법의 Xs, Ys 역할)
            S[0,:] = bandpass_filter(S[0,:], 0.5, 4.0)
            S[1,:] = bandpass_filter(S[1,:], 0.5, 4.0)
            
            # 여기서 S[0,:]는 S1, S[1,:]는 S2
            std = np.array([1,np.std(S[0,:])/np.std(S[1,:])])
            h = np.matmul(std,S)
            
            # 최종 신호 계산
            # 평균 편차로 나누어주면 결과 신호의 스파이크 현상이 제거됨
            H[m:n] = H[m:n] + (h-np.mean(h))/np.std(h)
            
    return H

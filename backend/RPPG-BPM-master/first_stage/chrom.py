import numpy as np
from scipy.signal import butter, lfilter
from scipy.signal import get_window

# хром-시그널(chrom-signal) 계산 함수
def chrom(BGR_signal, fps, interval_length = None):
    
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
     
    # Hanning window 크기 설정
    if(interval_length == None):
        # 비율 유지 위해 32/20 배수 적용 (fps=20이면 창 32)
        interval_size = int(fps*(32.0/20.0))
    elif(interval_length>0):
        interval_size = interval_length//1
    else: 
        # Hanning window 크기가 부적절함 (32 이상이어야 함)
        raise NameError('WrongIntervalLength')
    
    # 원본 데이터 길이 유효성 검사
    if(num_frames<interval_size):
        # 원본 데이터 길이가 창 크기보다 작음
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

    # 구간(interval) 내 신호 S 계산 함수
    def S_signal_on_interval(low_limit,high_limit):
        
        # 구간의 R,G,B 신호 추출 및 정규화
        if (low_limit<0.0):
            num_minus = abs(low_limit)
            R_interval = np.append(np.zeros(num_minus), R[0:high_limit+1])
            R_interval_norm = R_interval/R_interval[num_minus:interval_size].mean()
            G_interval = np.append(np.zeros(num_minus), G[0:high_limit+1])
            G_interval_norm = G_interval/G_interval[num_minus:interval_size].mean()
            B_interval = np.append(np.zeros(num_minus), B[0:high_limit+1])
            B_interval_norm = B_interval/B_interval[num_minus:interval_size].mean()
        elif (high_limit>num_frames):
            num_plus = high_limit-num_frames
            R_interval = np.append(R[low_limit:num_frames], np.zeros(num_plus+1))
            R_interval_norm = R_interval/R_interval[0:interval_size-num_plus-1].mean()
            G_interval = np.append(G[low_limit:num_frames], np.zeros(num_plus+1))
            G_interval_norm = G_interval/G_interval[0:interval_size-num_plus-1].mean()
            B_interval = np.append(B[low_limit:num_frames], np.zeros(num_plus+1))
            B_interval_norm = B_interval/B_interval[0:interval_size-num_plus-1].mean()
        else:
            R_interval = R[low_limit:high_limit+1] 
            R_interval_norm = R_interval/R_interval.mean()
            G_interval = G[low_limit:high_limit+1] 
            G_interval_norm = G_interval/G_interval.mean()
            B_interval = B[low_limit:high_limit+1]
            B_interval_norm = B_interval/B_interval.mean()           
        
        # Xs, Ys 성분 계산
        Xs,Ys = np.zeros(interval_size), np.zeros(interval_size)
        Xs = 3.0*R_interval_norm - 2.0*G_interval_norm
        Ys = 1.5*R_interval_norm + G_interval_norm - 1.5*B_interval_norm
        
        # 밴드패스 필터 적용 (0.5~4 Hz 범위)
        Xf = bandpass_filter(Xs, 0.5, 4.0)
        Yf = bandpass_filter(Ys, 0.5, 4.0)
        
        # Hanning window 적용 전 신호 S 계산
        alpha = Xf.std()/Yf.std()
        S_before = Xf - alpha*Yf
        
        return S_before
        
    # 전체 프레임 수에 따른 구간 개수 계산
    number_interval = 2.0*num_frames/interval_size+1
    number_interval = int(number_interval//1)
    
    # 각 구간 경계 찾기 및 구간별 S 신호 계산
    intervals = []
    S_before_on_interval = []
    for i in range(int(number_interval)):
        i_low = int((i-1)*interval_size/2.0 + 1)
        i_high = int((i+1)*interval_size/2.0)
        intervals.append([i_low, i_high])
        S_before_on_interval.append(S_signal_on_interval(i_low,i_high))  
    
    # Hanning window 생성
    wh = get_window('hamming', interval_size)    
    
    # Hanning window가 적용되지 않는 구간 인덱스 찾기
    index_without_henning = []
    # 왼쪽
    for i in range(intervals[0][0], intervals[1][0], 1):
        if(i>=0): 
            index_without_henning.append(i)
    # 오른쪽
    for i in range(intervals[len(intervals)-2][1]+1, intervals[len(intervals)-1][1], 1):
        if(i<=num_frames): 
            index_without_henning.append(i)
    
    # 최종 rPPG 신호 S 계산
    S_after = np.zeros(num_frames)
    for i in range(num_frames):
        for j in intervals:
            if(i>=j[0] and i <=j[1]):
                num_interval = intervals.index(j)
                num_element_on_interval = i - intervals[num_interval][0]
                if(i not in index_without_henning):
                    S_after[i] += S_before_on_interval[num_interval][num_element_on_interval]*wh[num_element_on_interval]
                else: 
                    S_after[i] += S_before_on_interval[num_interval][num_element_on_interval]
                    
    return S_after

import numpy as np
import numpy.linalg as linalg

# 2SR 신호 계산 함수
def SSR(X, fps, l = None):
    
    # 원본 데이터의 프레임 수
    num_frames = len(X)

    # 분자와 분모에 추가할 작은 값 (0으로 나누기 방지용)
    eps = 1e-1
    
    # 원본 데이터 유효성 검사
    if(num_frames==0):
        # 원본 데이터 배열이 비어 있음
        raise NameError('EmptyData')
    
    # l - 시간 구간 길이
    if(l == None):
        l = 20
    
    # C - correlation matrix
    C = np.zeros([num_frames,3,3])
    # A - C 행렬의 고유값 (eigenvalues)
    A = np.zeros([num_frames,3])
    # U - C 행렬의 고유벡터 (eigenvectors)
    U = np.zeros([num_frames,3,3])
    # P - 최종 계산될 맥박 신호
    P = np.zeros(num_frames)
    
    for k in range(num_frames):
        # 상관행렬 C 계산 (dot = 두 배열의 행렬곱)
        C[k] = np.matmul( X[k].reshape(len(X[k]), -1), X[k].reshape(-1, len(X[k])) ) /num_frames
        # C 행렬의 고유값과 고유벡터 계산
        A[k], U[k] = linalg.eig(C[k])
        
        tau = k-l+1
        if (tau>0):
            # 서브스페이스 회전에 사용되는 행렬
            SR_array = []
            for t in range(tau,k,1):
                # numpy 특성상 벡터가 기본적으로 행으로 저장되어 있어 전치(transpose) 연산이 뒤바뀜
                first_term = (np.sqrt(abs((eps + A[t][0])/(eps + A[tau][1]))))*U[t][0]*(np.transpose(U[tau][1].reshape(len(U[tau][1]), -1)))*U[tau][1]
                second_term = (np.sqrt(abs((eps + A[t][0])/(eps + A[tau][2]))))*U[t][0]*(np.transpose(U[tau][2].reshape(len(U[tau][2]), -1)))*U[tau][2]
                # 두 항을 나눠서 표현
                SR = first_term + second_term
                #
                SR_array.append(SR[0])
    print(np.asarray(SR_array, dtype=np.float32))
    return P

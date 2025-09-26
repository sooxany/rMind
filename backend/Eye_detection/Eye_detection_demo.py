from scipy.spatial import distance
from imutils import face_utils
import imutils
import dlib
import cv2

def eye_aspect_ratio(eye):  # 눈의 특징적 비율을 계산하는 함수
    A = distance.euclidean(eye[1], eye[5])
    B = distance.euclidean(eye[2], eye[4])
    C = distance.euclidean(eye[0], eye[3])
    ear = (A + B) / (2.0 * C)
    return ear

thresh = 0.25  # threshold 값
frame_check = 20 
detect = dlib.get_frontal_face_detector()
predict = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")
(lStart, lEnd) = face_utils.FACIAL_LANDMARKS_68_IDXS["left_eye"]
(rStart, rEnd) = face_utils.FACIAL_LANDMARKS_68_IDXS["right_eye"]
cap = cv2.VideoCapture(0)
flag = 0 

while True:
    ret, frame = cap.read()
    frame = imutils.resize(frame, width=450)  # 프레임 크기 조정
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    subjects = detect(gray, 0)

    for subject in subjects:  # 검출된 얼굴마다 반복
        shape = predict(gray, subject)
        shape = face_utils.shape_to_np(shape)
		# 양쪽 눈 가로세로 비율
        leftEye = shape[lStart:lEnd]
        rightEye = shape[rStart:rEnd]
        leftEAR = eye_aspect_ratio(leftEye)
        rightEAR = eye_aspect_ratio(rightEye)
        ear = (leftEAR + rightEAR) / 2.0
        # 눈 모양 컨벡스 헐 그리기
        leftEyeHull = cv2.convexHull(leftEye)
        rightEyeHull = cv2.convexHull(rightEye)
        cv2.drawContours(frame, [leftEyeHull], -1, (0, 255, 0), 1)
        cv2.drawContours(frame, [rightEyeHull], -1, (0, 255, 0), 1)

        if ear < thresh:  # 눈을 감았을 때
            flag += 1  # 프레임 수 증가
            print(flag)
            if flag >= frame_check:  # 설정한 프레임 수 이상 눈을 감았을 때
                cv2.putText(frame, "ALARM", (10, 30), 
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
                cv2.putText(frame, "ALARM", (10, 325),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
                #print("Drowsy")
        else:
            flag = 0  # 눈을 뜨면 프레임 수 초기화

    cv2.imshow("Frame", frame)  # 프레임 화면에 출력
    key = cv2.waitKey(1) & 0xFF
    if key == ord("q"):  # 'q' 키를 누르면 종료됨
        break

cv2.destroyAllWindows()
cap.release()

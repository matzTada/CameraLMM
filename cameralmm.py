import numpy as np
import cv2
import time

cap = cv2.VideoCapture(0)
cap.set(3, 320) # width
cap.set(4, 240) # height

LMM_HEIGHT = 24
LMM_WIDTH = 32

lmmArray = [[0 for i in range(LMM_WIDTH)] for j in range(LMM_HEIGHT)]
past_lmmArray = [[0 for i in range(LMM_WIDTH)] for j in range(LMM_HEIGHT)]


import serial 
ser0 = serial.Serial('/dev/ttyUSB0', 9600)
ser1 = serial.Serial('/dev/ttyUSB1', 9600)


while(True):
    # Capture frame-by-frame
    ret, frame = cap.read()
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    frame = cv2.resize(frame, (LMM_WIDTH, LMM_HEIGHT))

    lmmArray = [[0 for i in range(LMM_WIDTH)] for j in range(LMM_HEIGHT)]

    imgW = len(frame[0])
    imgH = len(frame)

    for imgY in range(0, imgH, 1):
      for imgX in range(0, imgW, 1):
        imgR = frame[imgY][imgX][0]
        imgG = frame[imgY][imgX][1]
        imgB = frame[imgY][imgX][2]
        v = imgR * 0.298912 + imgG * 0.586611 + imgB * 0.114478
        threshold = 128
        if v < threshold:
          value = 0
          color = [0, 0, 0]
        else:
          value = 1
          color = [255, 255, 255]
        lmmArray[imgY][imgX] = value
        frame[imgY][imgX] = color


    for j in range(0, LMM_HEIGHT):
      diffFlag = 0
      for i in range(0, LMM_WIDTH):
        if lmmArray[j][i] != past_lmmArray[j][i]:
          diffFlag = 1
          past_lmmArray[j][i] = lmmArray[j][i]

      if diffFlag == 1:
        sendStr = "n";
        if j < 16 :
          sendStr += chr(j + ord('0'))
        else :
          sendStr += chr(j - 16 + ord('0'))

        for i in range(0, LMM_WIDTH):
          sendStr += str(lmmArray[j][i])

        # if j < 16:
        #   for k in range(0, len(sendStr)):
        #     ser0.write(sendStr.charAt(k))
        # else:
        #   for k in range(0, len(sendStr)):
        #     ser1.write(sendStr.charAt(k));

        print("wrote:" + str(j) + " " + sendStr);
        time.sleep(0.1)


    # Display the resulting frame
    cv2.imshow('frame', frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# When everything done, release the capture
cap.release()
cv2.destroyAllWindows()

ser0.close()
ser1.close()
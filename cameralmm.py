import numpy as np
import cv2
import time

cap = cv2.VideoCapture(0)
cap.set(3, 32) # width
cap.set(4, 24) # height

LMM_WIDTH = 32
LMM_HEIGHT = 24

lmmArray = [[0 for i in range(LMM_WIDTH)] for j in range(LMM_HEIGHT)]
past_lmmArray = [[0 for i in range(LMM_WIDTH)] for j in range(LMM_HEIGHT)]


import serial 
ser0 = serial.Serial('/dev/ttyACM0', 57600)
ser1 = serial.Serial('/dev/ttyACM1', 57600)


while(True):
    # Capture frame-by-frame
    ret, rawframe = cap.read()

    if ret == False:
      continue

    frame = cv2.cvtColor(rawframe, cv2.COLOR_BGR2RGB)

    frame = cv2.resize(frame, (LMM_WIDTH, LMM_HEIGHT))

    lmmArray = [[0 for i in range(LMM_WIDTH)] for j in range(LMM_HEIGHT)]

    imgW = len(frame[0])
    imgH = len(frame)

    print("next step")

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
      diffFlag = 1
#      for i in range(0, LMM_WIDTH):
#        if lmmArray[j][i] != past_lmmArray[j][i]:
#          diffFlag = 1
#          past_lmmArray[j][i] = lmmArray[j][i]

      if diffFlag == 1:
        sendStr = "n";
        if j < 16 :
          sendStr += chr(j + ord('0'))
        else :
          sendStr += chr(j - 16 + ord('0'))

        for i in range(0, LMM_WIDTH):
          sendStr += str(lmmArray[j][i])
        sendStr += "\n"

        if j < 16:
          for k in range(0, len(sendStr)):
            ser0.write(sendStr[k])
        else:
          for k in range(0, len(sendStr)):
            ser1.write(sendStr[k])

        print("wrote:" + str(j) + " " + sendStr)
#        time.sleep(0.1)

    ser0.write('o')
    ser0.write('\n')
    ser1.write('o')
    ser1.write('\n')

#    time.sleep(1)

    # Display the resulting frame
    cv2.imshow('frame', cv2.resize(frame, (160, 120)))
    cv2.imshow('rawframe', cv2.resize(rawframe, (160, 120)))

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# When everything done, release the capture
cap.release()
cv2.destroyAllWindows()

ser0.close()
ser1.close()

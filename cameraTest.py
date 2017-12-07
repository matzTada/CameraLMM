import numpy as np
import cv2

cap = cv2.VideoCapture(0)
cap.set(3, 320) # width
cap.set(4, 240) # height

while(True):
    # Capture frame-by-frame
    ret, frame = cap.read()
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    targetW = 32
    targetH = 24

    frame = cv2.resize(frame, (targetW, targetH))

    lmmarray = [[0 for i in range(targetW)] for j in range(targetH)]

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
        lmmarray[imgY][imgX] = value
        frame[imgY][imgX] = color

    # Display the resulting frame
    cv2.imshow('frame', frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# When everything done, release the capture
cap.release()
cv2.destroyAllWindows()
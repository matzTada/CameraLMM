import time

import serial 
ser0 = serial.Serial('/dev/ttyUSB0', 9600)
ser1 = serial.Serial('/dev/ttyUSB1', 9600)

LMM_HEIGHT = 24
LMM_WIDTH = 32

# send image

lmmArray = []
past_lmmArray = []

for j in range(0, LMM_HEIGHT):
  diffFlag = 0
  for i in range(0, LMM_WIDTH):
    if lmmArray[j][i] != past_lmmArray[j][i]:
      diffFlag = 1
      past_lmmArray[j][i] = lmmArray[j][i]

  if diffFlag == 1:
    sendStr = "n";
    if j < 16 :
      sendStr += char(j + int('0'))
    else :
      sendStr += char(j - 16 + int('0'))

    for i in range(0, LMM_WIDTH):
      sendStr += str(lmmArray[j][i])

    if j < 16:
      for k in range(0, len(sendStr)):
        ser0.write(sendStr.charAt(k))
    else:
      for k in range(0, len(sendStr)):
        ser1.write(sendStr.charAt(k));

    print("wrote:" + j + " " + sendStr);
    time.sleep(0.1)

ser0.close()
ser1.close()
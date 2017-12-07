// LMM 
import processing.serial.*;
Serial[] myPorts = new Serial[2];  // Create a list of objects from Serial class
int LMM_WIDTH = 32;
int LMM_HEIGHT = 32;
boolean[][] lmmArray = new boolean [LMM_WIDTH][LMM_HEIGHT];
boolean[][] past_lmmArray = new boolean [LMM_WIDTH][LMM_HEIGHT];
int walkX = 16, walkY = 16;

// Camera
import processing.video.*;
Capture cam;

void setup() {
  size(800, 800);
  frame.setResizable(true);

  // LMM
  // print a list of the serial ports:
  printArray(Serial.list());
  // On my machine, the first and third ports in the list
  // were the serial ports that my microcontrollers were 
  // attached to.
  // Open whatever ports ares the ones you're using.

  // get the ports' names:
  //String portOne = Serial.list()[0];
  //String portTwo = Serial.list()[1];
  //String portOne = "COM18";
  //String portTwo = "COM14";
  String portOne = "/dev/ttyACM1";
  String portTwo = "/dev/ttyACM0";
  // open the ports:
  myPorts[0] = new Serial(this, portOne, 9600);
  myPorts[1] = new Serial(this, portTwo, 9600);

  // Camera
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[0]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Start capturing the images from the camera
    cam.start();
  }
}


int boxWidth = width / LMM_WIDTH;
int boxHeight = height / LMM_HEIGHT;

void draw() {
  // camera
  if (cam.available() == true) {
    cam.read();
  }

  lmmArray = getDigitalizedImageMonotone_simple(cam, 32, 24, 32, 24);

  sendImage();
  putOnDisplay();

  // clear the screen:
  background(0);
  boxWidth = width / LMM_WIDTH;
  boxHeight = height / LMM_HEIGHT;

  for (int j = 0; j < LMM_HEIGHT; j++) {
    for (int i = 0; i < LMM_HEIGHT; i++) {
      stroke(127);
      if (lmmArray[i][j] == true) {
        fill(255);
      } else {
        fill(0);
      }
      rect(i * boxWidth, j *boxHeight, boxWidth, boxHeight);
    }
  }
  
  delay(1000);
}

/** 
 * When SerialEvent is generated, it'll also give you
 * the port that generated it.  Check that against a list
 * of the ports you know you opened to find out where
 * the data came from
 */
void serialEvent(Serial thisPort) {
  // variable to hold the number of the port:
  int portNumber = -1;

  // iterate over the list of ports opened, and match the 
  // one that generated this event:
  for (int p = 0; p < myPorts.length; p++) {
    if (thisPort == myPorts[p]) {
      portNumber = p;
    }
  }
  // read a byte from the port:
  int inByte = thisPort.read();
  if ('a' < inByte && inByte < 'z' || 'A' < inByte && inByte < 'Z') {
    // tell us who sent what:
    print(portNumber + " " + char(inByte) + " ");
  }
}

void keyPressed() {
  switch (key) {
  case 'n':
    sendImage();
    putOnDisplay();
    break;
  case 'r':
    resetArray();
    flashDisplay();
    break;
  case 'f':
    flashDisplay();
    break;
  case 'o':
    putOnDisplay();
    break;
  case 'x':
    //flashDisplay();
    walkX = (int)random(0, LMM_WIDTH);
    walkY = (int)random(0, LMM_HEIGHT);
    crossWalk(walkX, walkY);
    sendImage();
    putOnDisplay();
    break;
  default:
    sendCommand(key);
    break;
  }
}

void sendCommand(char chr) {
  myPorts[0].write(chr);
  myPorts[0].write('\n');
  myPorts[1].write(chr);
  myPorts[1].write('\n');
}

void sendImage() {
  println("---");
  println("start sending");
  println("---");
  for (int i = 0; i < LMM_HEIGHT; i++) {
    boolean diffFlag = false;
    for (int j = 0; j < LMM_WIDTH; j++) {
      if (lmmArray[j][i] != past_lmmArray[j][i]) {
        diffFlag = true;
        past_lmmArray[j][i] = lmmArray[j][i];
      }
    }

    if (diffFlag) { 
      String sendStr = "n";
      if (i< 16) {
        sendStr += char(i + int('0'));
      } else {
        sendStr += char(i - 16 + int('0'));
      }
      for (int j = 0; j < LMM_WIDTH; j++) {
        sendStr += (lmmArray[j][i]) ? "1" : "0";
      }
      sendStr += "\n";

      if (i < 16) {
        for (int k = 0; k < sendStr.length(); k++) {
          myPorts[0].write(sendStr.charAt(k));
        }
      } else {      
        for (int k = 0; k < sendStr.length(); k++) {
          myPorts[1].write(sendStr.charAt(k));
        }
      }
      print("wrote:" + i + " " + sendStr);
      //delay(100);

      //String sendStr = "n011110000111100001111000011110000\n";
      //for (int i = 0; i < sendStr.length(); i++) {
      //  myPorts[0].write(sendStr.charAt(i));
      //  myPorts[1].write(sendStr.charAt(i));
      //  delay(200);
      //}
    }
  }
  println("---");
  println("finish sending");
  println("---");
}

void flashDisplay() {
  sendCommand('f');
}

void putOnDisplay() {
  sendCommand('o');
}

void resetArray() {
  for (int j = 0; j < LMM_HEIGHT; j++) {
    for (int i = 0; i < LMM_HEIGHT; i++) {
      lmmArray[i][j] = false;
      past_lmmArray[i][j] = false;
    }
  }
  sendCommand('c');
}

void crossWalk(int posX, int posY) {
  //for (int j = 0; j < LMM_HEIGHT; j++) {
  //  for (int i = 0; i < LMM_WIDTH; i++) {
  //    lmmArray[i][j] = false;
  //  }
  //}

  int i, j;
  i = posX;
  j = posY;
  while (i >= 0 && j >= 0) {
    lmmArray[i][j] = true;
    i--; 
    j--;
  }
  i = posX;
  j = posY;
  while (i >= 0 && j < LMM_HEIGHT) {
    lmmArray[i][j] = true;
    i--; 
    j++;
  }
  i = posX;
  j = posY;
  while (i < LMM_WIDTH && j >= 0) {
    lmmArray[i][j] = true;
    i++; 
    j--;
  }
  i = posX;
  j = posY;
  while (i < LMM_WIDTH && j < LMM_HEIGHT) {
    lmmArray[i][j] = true;
    i++; 
    j++;
  }
}

boolean[][] getDigitalizedImageMonotone_simple(PImage _img, int _numX, int _numY, float _w, float _h) {
  int imgW = _img.width;
  int imgH = _img.height;
  int imgBlockW = _img.width/_numX;
  int imgBlockH = _img.height/_numY;

  boolean[][] rtArray = new boolean[(int)_w][(int)_h];

  for (int imgX = 0; imgX < imgW; imgX += imgBlockW) {
    for (int imgY = 0; imgY < imgH; imgY += imgBlockH) {
      //int imgLoc = imgX + imgY*imgW;
      //float imgR = red(_img.pixels[imgLoc]);
      //float imgG = green(_img.pixels[imgLoc]);
      //float imgB = blue(_img.pixels[imgLoc]);
      //float v = imgR * 0.298912 + imgG * 0.586611 + imgB * 0.114478;

      float sumV = 0.0;
      int cntV = 0;
      for (int imgBlockX = imgX; imgBlockX < imgX + imgBlockW; imgBlockX++) {
        for (int imgBlockY = imgY; imgBlockY < imgY + imgBlockH; imgBlockY++) {
          if (imgBlockX < 0 || imgW <= imgBlockX || imgBlockY < 0 || imgH <= imgBlockY) continue;
          int imgLoc = imgBlockX + imgBlockY * imgW;
          float imgR = red(_img.pixels[imgLoc]);
          float imgG = green(_img.pixels[imgLoc]);
          float imgB = blue(_img.pixels[imgLoc]);
          sumV += imgR * 0.298912 + imgG * 0.586611 + imgB * 0.114478;
          cntV++;
        }
      }
      float v = sumV / (float)cntV;

      float threshold = 128;

      int posX = (int)map(imgX, 0, imgW, 0, _w);
      int posY = (int)map(imgY, 0, imgH, 0, _h);

      boolean value;

      if (v < threshold) {
        value = false;
        //print("0 ");
      } else {
        value = true;
        //print("1 ");
      }
      rtArray[posX][posY] = value;

      //float blockSizeX = _w / _numX;
      //float blockSizeY = _h / _numY;
      //rect(_x + posX, _y + posY, blockSizeX, blockSizeY);
    }
    //println("");
  }

  return rtArray;
}
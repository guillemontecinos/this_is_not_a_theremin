//Invisible Theremin
//Hand tracking and OSC output
//Dec, 2018. Guillermo Montecinos
//based on Dan Shiffman example: https://www.youtube.com/watch?v=Kr4s5sLoROY&list=PLRqwX-V7Uu6ZMlWHdcy8hAGDy6IaoxUKf&index=4
//based on github.com/igoumeninja/1047694

//kinect capture
import org.openkinect.processing.*;

//import osc and network libraries
import oscP5.*;
import netP5.*;

// create kinect object
Kinect2 kinect2;

//osc and network creation
OscP5 oscP5;
NetAddress myRemoteLocation;

PImage img;
float minTresh = 430;
float maxTresh = 721;
int[][] buffer; //each pixel value for the last 5 frames
int[] currentFrame; //value of each pixel
int numFramesAv = 7;
int widthArea = 400;
int heightArea = 200;
int AreaCtrX; //center of the useful rect - X
int AreaCtrY; //center of the useful area - Y
int[] centroidRight = new int [2];
int[] centroidLeft = new int [2];
int numPixRightQuad; //num of pixels for the right side of the useful area
int numPixLeftQuad; //num of pixels for the left side of the useful area
int distX = 0;
int distY = 0;

void setup(){
  size(512, 424);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  buffer = new int[kinect2.depthWidth * kinect2.depthHeight][numFramesAv];
  currentFrame = new int[kinect2.depthWidth * kinect2.depthHeight];
  AreaCtrX = width/2;
  AreaCtrY = height/2;
  
  //osc and network attributes setup
  oscP5 = new OscP5(this, 12000);   //listening
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);  //  speak to
}

void draw(){
  background(0);
  img.loadPixels();
  centroidRight[0] = 0;
  centroidRight[1] = 0;
  centroidLeft[0] = 0;
  centroidLeft[1] = 0;
  numPixRightQuad = 1;
  numPixLeftQuad = 1;
  
  //get raw depth data
  int[] depth = kinect2.getRawDepth();
  
  for(int x = AreaCtrX - widthArea/2; x < AreaCtrX + widthArea/2; x++){
    for(int y = AreaCtrY - heightArea/2; y < AreaCtrY + heightArea/2; y++){
      
      //set pixel variables
      int offset = x + y * kinect2.depthWidth;
      
      //value = 0 if the pixel is not in the range & 1 if it is
      int d = depth[offset];
      int value;
      
      if(d > minTresh && d < maxTresh){
        value = 1;
      }
      else{
        value = 0;
      }
      
      //add current frame pixel value and shift other values
      for(int i = 0; i < buffer[offset].length; i++){
        if(i < buffer[offset].length - 1){
          buffer[offset][i] = buffer[offset][i + 1];
        }
        else{
          buffer[offset][i] = value;
        }
      }
      
      //calculate if the pixel is in the range considering the last numFramesAv frames
      int avg = 0;
      for(int i = 0; i < buffer[offset].length; i++){
        avg = avg + buffer[offset][i];
      }
      avg = avg/numFramesAv;
      
      if(avg > 0.5){
        img.pixels[offset] = color(255);
        if(x > AreaCtrX){
          centroidRight[0] += x;
          centroidRight[1] += y;
          numPixRightQuad++;
        }
        else{
          centroidLeft[0] += x;
          centroidLeft[1] += y;
          numPixLeftQuad++;
        }
      }
      else{
        img.pixels[offset] = color(0);
      }
    }
  }
  img.updatePixels();
  image(img,0,0);
  
  //draw a rect
  rectMode(CENTER);
  noFill();
  stroke(255,0,0);
  rect(AreaCtrX, AreaCtrY, widthArea, heightArea);
  
  //update centroids
  centroidRight[0] = int(centroidRight[0]/numPixRightQuad);
  centroidRight[1] = int(centroidRight[1]/numPixRightQuad);
  centroidLeft[0] = int(centroidLeft[0]/numPixLeftQuad);
  centroidLeft[1] = int(centroidLeft[1]/numPixLeftQuad);
  
  //draw centroides
  fill(255,0,0);
  noStroke();
  ellipse(centroidRight[0], centroidRight[1], 20, 20);
  ellipse(centroidLeft[0], centroidLeft[1], 20, 20);
  
  distX = AreaCtrX + widthArea/2 - centroidRight[0];
  distY = AreaCtrY + heightArea/2 - centroidLeft[1];
  println("distX: " + distX + ", distY: " + distY);
  
  OscMessage msg = new OscMessage("distx " + str(distX) + " disty " + str(distY));  
  oscP5.send(msg, myRemoteLocation);
}
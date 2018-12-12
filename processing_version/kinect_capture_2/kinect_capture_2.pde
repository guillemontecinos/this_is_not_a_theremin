//kinect capture
import org.openkinect.processing.*;

// create kinect object
Kinect2 kinect2;

PImage img;
float minTresh = 430;
float maxTresh = 721;
int[][] buffer; //each pixel value for the last 5 frames
int[] currentFrame; //value of each pixel
int numFramesAv = 7;
int widthArea = 250;
int heightArea = 200;
int AreaCtrX;
int AreaCtrY;

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
}

void draw(){
  background(0);
  img.loadPixels();
  //minTresh = map(mouseX, 0, width, 0, 4500);
  //maxTresh = map(mouseY, 0, height, 0, 4500);
  //println("minTresh: " + minTresh);
  //println("maxTresh: " + maxTresh);
  
  //get raw depth data
  int[] depth = kinect2.getRawDepth();
  
  for(int x = 0; x < kinect2.depthWidth; x++){
    for(int y = 0; y < kinect2.depthHeight; y++){
      //set pixel variables
      int offset = x + y * kinect2.depthWidth;
      
      //value = 0 if the pixel is not in the range & 1 if it is
      int d = depth[offset];
      int value;
      
      if(d > minTresh && d < maxTresh && AreaCtrX - widthArea/2 < x && AreaCtrX + widthArea/2 > x && AreaCtrY - heightArea/2 < y && AreaCtrY + heightArea/2 > y){
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
      
      if(avg > 0.5){
        img.pixels[offset] = color(255);
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
}
//kinect capture
import org.openkinect.processing.*;

// create kinect object
Kinect2 kinect2;

PImage img;
float minTresh = 430;
float maxTresh = 721;
int[][] buffer; //each pixel value for the last 5 frames
int[] currentFrame; //value of each pixel
int numFramesAv = 1;

void setup(){
  size(512, 424);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  buffer = new int[kinect2.depthWidth * kinect2.depthHeight][numFramesAv];
  currentFrame = new int[kinect2.depthWidth * kinect2.depthHeight];
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
      
      //add current frame pixel value and shift other values
      for(int i = 0; i < buffer[offset].length; i++){
        if(i < buffer[offset].length - 1){
          buffer[offset][i] = buffer[offset][i + 1];
        }
        else{
          buffer[offset][i] = depth[offset];
        }
      }
      
      //calculate the average of the last numFramesAv frames
      int aux = 0;
      for(int i = 0; i < buffer[offset].length; i++){
        aux = aux + buffer[offset][i];
      }
      
      int d = int(aux/numFramesAv);
      //int d = depth[offset];
      
      if(d > minTresh && d < maxTresh){
        img.pixels[offset] = color(255);
      }
      else{
        img.pixels[offset] = color(0);
      }
    }
  }
  img.updatePixels();
  image(img,0,0);
}
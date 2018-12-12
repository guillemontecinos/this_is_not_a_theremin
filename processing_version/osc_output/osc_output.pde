//osc message sending for Invisible Theremin
//based on github.com/igoumeninja/1047694
//Guillermo Montecinos
// Dec 2018

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

int widthArea = 250;
int heightArea = 200;
int AreaCtrX; //center of the useful rect - X
int AreaCtrY; //center of the useful area - Y
int distX = 0;
int distY = 0;

void setup(){
  size(512, 424);
  AreaCtrX = width/2;
  AreaCtrY = height/2;
  
  //setup osc 
  oscP5 = new OscP5(this, 12000);   //listening
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);  //  speak to
  // The method plug take 3 arguments. Wait for the <keyword>
  //oscP5.plug(this, "varName", "keyword");
}

void draw(){
  //draw a rect
  rectMode(CENTER);
  noFill();
  stroke(255,0,0);
  rect(AreaCtrX, AreaCtrY, widthArea, heightArea);
  
  distX = AreaCtrX + widthArea/2 - mouseX;
  distY = AreaCtrY + heightArea/2 - mouseY;
  println("distX: " + distX + ", distY: " + distY);
  
  
  OscMessage msg = new OscMessage("distx " + str(distX) + " disty " + str(distY));  
  //msg.add(distX);
  //msg.add("disty");
  //msg.add(distY);
  oscP5.send(msg, myRemoteLocation);
}
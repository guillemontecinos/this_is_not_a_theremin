// by Guillermo guillemontecinos
// for the Invisible Theremin
// based on ml5.js example
// Copyright (c) 2018 ml5
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

/* ===
ml5 Example
PoseNet example using p5.js
=== */

let video;
let poseNet;
let poses = [];
let modelLoaded = false;
let numFramesAv = 10;
let bufferDict = [6, 5, 10, 9];
var buffer = new Array(4); //this buffer will contain the last numFramesAv
for (var i = 0; i < buffer.length; i++) {
  buffer[i] = new Array(numFramesAv).fill(0);
}
var currentFrame = [[0,0],[0,0],[0,0],[0,0]]; //array used to calculate the time average position
//on both buffer and currentFrame the entries will be 0: right shoulder (6), 1: left shoulder (5), 2: right wrist (10), 3: left wrist (9)
let dShoulders = 0;
//dist variables sent to Max/Msp
let distX = 0;
let distY = 0;

function setup() {
  createCanvas(640, 480);
  video = createCapture(VIDEO);
  video.size(width, height);

  // Create a new poseNet method with a single detection
  poseNet = ml5.poseNet(video, {
   imageScaleFactor: 0.3,
   flipHorizontal: false,
   minConfidence: 0.15,
   maxPoseDetections: 1,
   detectionType: 'single',
   multiplier: 1.01,
  }, modelReady);
  // This sets up an event that fills the global variable "poses"
  // with an array every time new poses are detected
  poseNet.on('pose', function(results) {
    poses = results;
  });
  // Hide the video element, and just show the canvas
  video.hide();
}

function modelReady() {
  // select('#status').html('Model Loaded');
  console.log('Model Loaded');
  modelLoaded = true;
}

function draw() {
  translate(width,0);
  scale(-1,1);
  image(video, 0, 0, width, height);
  if (modelLoaded && currentFrame[0].x != NaN) {

    getKeypoints();
    // We can call both functions to draw all keypoints and the skeletons
    drawKeypoints();
    dShoulders = dist(currentFrame[0].x, currentFrame[0].y, currentFrame[1].x, currentFrame[1].y);
    // console.log(dShoulders);
    // draw reference rect
    rectMode(CENTER);
    noFill();
    strokeWeight(2);
    stroke(255,0,0);
    rect(currentFrame[0].x, currentFrame[0].y, 3 * dShoulders, 3 * dShoulders);
    distX = abs(currentFrame[0].x - 1.5 * dShoulders - currentFrame[2].x);
    distY = abs(currentFrame[0].y + 1.5 * dShoulders - currentFrame[3].y);
    console.log("distX: " + distX + ", distY: " + distY);
  }
}

// retrieves
function getKeypoints(){
  if (poses.length > 0) {
    let pose = poses[0].pose;
    // for any points of bufferDict
    for (let i = 0; i < bufferDict.length; i++) {
      // for each one of them shift data into the buffer tho the left
      for (let j = 0; j < numFramesAv; j++) {
        if (j < buffer[i].length - 1) {
          buffer[i][j] = buffer[i][j + 1];
        }
        else {
          buffer[i][j] = {x: pose.keypoints[bufferDict[i]].position.x, y: pose.keypoints[bufferDict[i]].position.y};
        }
      }
      // then calculate the position average and store it into the currentFrame array
      let avgX = 0;
      let avgY = 0;
      for (let j = 0; j < buffer[i].length; j++) {
        avgX += buffer[i][j].x;
        avgY += buffer[i][j].y;
      }
      currentFrame[i] = {x: avgX/numFramesAv, y: avgY/numFramesAv};
    }
  }
}

function drawKeypoints(){
  for (var i = 0; i < currentFrame.length; i++) {
    ellipse(currentFrame[i].x, currentFrame[i].y, 10, 10);
  }

  // console.log(currentFrame[0]);
}

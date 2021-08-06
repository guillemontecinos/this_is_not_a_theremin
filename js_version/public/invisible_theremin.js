// by Guillermo Montecinos & Sofía Suazo
// for "This is not a Theremin"
// based on ml5.js example
// Copyright (c) 2018 ml5
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
// Version with OSC implementation from [osc.js](https://github.com/colinbdclark/osc.js)

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
let centerX = 0; //Center of the reference area
let dShoulders = 0;
let distRef = 0;
//dist variables sent to Max/Msp
let distX = 0;
let distY = 0;

const url = 'ws://' + location.host
console.log(url)
// Open a new ws connection with the server
const socket = new WebSocket(url);

// var port = new osc.WebSocketPort({
//     url: "ws://localhost:8081"
// });

// port.on("message", function (oscMessage) {
//     $("#message").text(JSON.stringify(oscMessage, undefined, 2));
//     console.log("message", oscMessage);
// });

// port.open();

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
    distRef = 1.5 * dShoulders;
    // console.log(dShoulders);
    // draw reference rect
    rectMode(CENTER);
    noFill();
    strokeWeight(2);
    stroke(255,0,0);
    centerX = (currentFrame[0].x + currentFrame[1].x) / 2;
    rect(centerX, currentFrame[0].y, 3 * dShoulders, 3 * dShoulders);
    if (poses.length == 0) {
      distX = 0;
      distY = 0;
    }
    else {
      distX = abs(centerX - distRef - currentFrame[2].x);
      distY = abs(currentFrame[0].y + distRef - currentFrame[3].y);
    }

    // console.log("distX: " + distX + ", distY: " + distY);
    // sendOsc();
    if(distX && distY && distRef) {
        sendMessage(JSON.stringify({address: '/distX', args: distX}));
        sendMessage(JSON.stringify({address: '/distY', args: distY}));
        sendMessage(JSON.stringify({address: '/distRef', args: distRef}))
        // sendMessage(JSON.stringify({address: '/theremin', args: [distX, distY, distRef]}))
    }
  }
}

// retrieves
function getKeypoints(){
  console.log(poses.length);
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
}

function sendMessage(data){
    if(socket.readyState === WebSocket.OPEN){
        socket.send(data)
    }
}

// function sendOsc(arg1, arg2){
//   port.send({
//       address: "/theremin",
//       args: [distX, distY, distRef]
//   });
// }

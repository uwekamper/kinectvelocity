// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import ddf.minim.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;
int DEPTHWINDOW = 40;
boolean showVideo = true;

// sound stuff

Minim minim;
AudioSample exampleSound;
AudioSample exampleSoundTwo;

long lastTriggerTime = 0;

void setup() {
  size(640, 520);
  
  minim = new Minim(this);
  // setup sounds
  // Put soundfiles in sketchbook/kinectvelocity/data/ 
  exampleSound = minim.loadSample( "bum2.wav", // filename
                            512      // buffer size
                         );
  exampleSoundTwo = minim.loadSample( "exampleSound.wav", // filename
                            512      // buffer size
                         );
                         
  kinect = new Kinect(this);
  tracker = new KinectTracker();
}

void draw() {
  background(255);

  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();

  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  fill(50, 100, 250, 200); //<>//
  noStroke();
  ellipse(v1.x, v1.y, 20, 20);

  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  fill(100, 250, 50, 200);
  noStroke();
  ellipse(v2.x, v2.y, 20, 20);

  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  double v = tracker.getVelocity();
  text("v: "+ v + " threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 500);
    
   if (v > 6.0 && v < 10.0) {
     doTrigger(exampleSound);
   }
   else if (v >= 10.0) {
     doTrigger(exampleSoundTwo);
   }
}

void doTrigger(AudioSample sample) {
  if (millis() - lastTriggerTime > 500) {
    sample.trigger();
    lastTriggerTime = millis();
  }
}

// Adjust the threshold with key presses
void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t, t + DEPTHWINDOW);
    } else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t, t + DEPTHWINDOW);
    }
  }
}
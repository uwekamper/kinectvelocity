// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

class KinectTracker {

  // Depth threshold
  int thresholdBegin = 940;//745;
  int thresholdEnd = thresholdBegin + 40;
  // Raw location
  PVector loc;

  // Interpolated location
  PVector lerpedLoc;
  PVector lastLerpedLoc;
  
  // Depth data
  int[] depth;
  
  // What we'll show the user
  PImage display;
  
  Measurement measure;
  Measurement lastMeasure;
  double velocity;
  
  KinectTracker() {
    // This is an awkard use of a global variable here
    // But doing it this way for simplicity
    kinect.initDepth();
    kinect.enableMirror(true);
    // Make a blank image
    display = createImage(kinect.width, kinect.height, RGB);
    // Set up the vectors
    loc = new PVector(0, 0);
    lerpedLoc = new PVector(0, 0);
  }

  void track() {
    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;

    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {
        
        int offset =  x + y*kinect.width;
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against threshold
        if (thresholdBegin < rawDepth && rawDepth < thresholdEnd) {
          sumX += x;
          sumY += y;
          count++;
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count, sumY/count);
    }
    
    // Store the last location
      
    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f);
    
    lastMeasure = measure;
    measure = new Measurement(millis(), new PVector(lerpedLoc.x, lerpedLoc.y));
    velocity = calculateVelocity(lastMeasure, measure);
  }
  
  double calculateVelocity(Measurement last, Measurement current) {
    if (last == null || current == null) {
      return 0.0;
    }
    long timeDelta = current.time - last.time;
    double dist = PVector.dist(current.loc, last.loc);
    double velocity = dist / timeDelta;
    return dist;
  }

  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }
  
  double getVelocity() {
    return velocity;
  }

  void display() {
    PImage img = kinect.getDepthImage();

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset = x + y * kinect.width;
        // Raw depth
        int rawDepth = depth[offset];
        int pix = x + y * display.width;
        if (rawDepth > thresholdBegin && rawDepth < thresholdEnd) {
          // A red color instead
          display.pixels[pix] = color(150, 50, 50);
        } else {
          display.pixels[pix] = img.pixels[offset];
        }
      }
    }
    display.updatePixels();

    // Draw the image
    image(display, 0, 0);
  }

  int getThreshold() {
    return thresholdBegin;
  }

  void setThreshold(int b, int e) {
    thresholdBegin =  b;
    thresholdEnd = e;
  }
}
// P_4_2_2_01.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * simple overview of a video file.
 * 
 * KEYS
 * s                  : save png
 */

import processing.video.*;
import java.util.Calendar;

Movie movie;

// horizontal and vertical grid count
// take care of the aspect ratio ... here 4:3
int tileCountX = 16;
int tileCountY = 16;
float tileWidth, tileHeight;
int imageCount = tileCountX*tileCountY; 
int currentImage = 0;
int gridX = 0;
int gridY = 0;


void setup() {
  size(720, 720);
  smooth();
  background(0); 

  // specify a path or use selectInput() to load a video
  // or simply put it into the data folder
  String path = sketchPath()+"\\data\\1.mov";
  // 打开movie
  movie = new Movie(this, path);
  movie.play();
  // 瓷砖尺寸
  tileWidth = width / (float)tileCountX;
  tileHeight = height / (float)tileCountY;
}


void draw() {
  if (movie.available()){  //读取到了新的帧,才开始画
    float posX = tileWidth*gridX;
    float posY = tileHeight*gridY;
  
    // calculate the current time in movieclip
    float moviePos = map(currentImage, 0,imageCount, 0,movie.duration());
    // Jumps to a specific location within a movie. The parameter where is in terms of seconds. 
    movie.jump(moviePos);
  // Reads the current frame of the movie.
    movie.read();
    image(movie, posX, posY, tileWidth, tileHeight);
  
    // new grid position
    gridX++;
    if (gridX >= tileCountX) {
      gridX = 0;
      gridY++;
    }
  
    currentImage++;
    if (currentImage >= imageCount) noLoop();
  }
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

// P_2_2_2_01.pde
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
 * draw the path of an intelligent agent
 * 
 * MOUSE
 * position x          : composition speed of the picture
 *
 * KEYS
 * Delete/Backspace    : clear display
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;

//方向只有四个
int NORTH = 0;
int EAST = 1;
int SOUTH = 2;
int WEST = 3;

float posX, posY;
float posXcross, posYcross;

int direction = SOUTH;
float angleCount = 7;    // 每个方向角度数量
float angle = getRandomAngle(direction);
float stepSize = 3;
int minLength = 10;


void setup(){
  size(600, 600);
  colorMode(HSB, 360, 100, 100, 100);
  smooth();
  background(360);

  posX = int(random(0, width));
  posY = 5;
  posXcross = posX;
  posYcross = posY;
}


void draw(){
  for (int i=0; i<=mouseX; i++) {

    // ------ draw dot at current position ------
    if (!recordPDF) {
      strokeWeight(1);
      stroke(180);
      //这是每一步都做的事情,画点
      point(posX, posY);
    }

    // ------ make step ------
    //获取下个点的位置
    posX += cos(radians(angle)) * stepSize;
    posY += sin(radians(angle)) * stepSize;


    // ------ check if agent is near one of the display borders ------
    boolean reachedBorder = false;
    //到达边界改变方向,置到达边界标记为true
    if (posY <= 5) {
      direction = SOUTH;
      reachedBorder = true;
    } 
    else if (posX >= width-5) {
      direction = WEST;
      reachedBorder = true;
    }
    else if (posY >= height-5) {
      direction = NORTH;
      reachedBorder = true;
    }
    else if (posX <= 5) {
      direction = EAST;
      reachedBorder = true;
    }

    // ------ if agent is crossing his path or border was reached ------
    int px = (int) posX;
    int py = (int) posY;
    //在像素里已经有了用于标记是否被访问过的颜色,不需要设置其他数组
    if (get(px, py) != color(360) || reachedBorder) {
      //获取随机方向
      angle = getRandomAngle(direction);
      //计算距离
      float distance = dist(posX, posY, posXcross, posYcross);
      //有最短长度限制,不至于黑色黏在一起
      if (distance >= minLength) {
        strokeWeight(3);
        stroke(0);
        line(posX, posY, posXcross, posYcross);
      }
      //画完实线后,终点即新的起点
      posXcross = posX;
      posYcross = posY;
    }
  }
}


//此函数用于根据方向获取一个随机的角度,以后在这个角度上运动
float getRandomAngle(int theDirection) {
  //floor 取下整数, 这个a取值与-pi+0.5 ~ pi+0.5
  //不清楚+0.5的作用,这导致有可能反弹回去
  //random(-angleCount, angleCount) 而不是各自/2开始,是因为一个方向可被认为占据180°
  float a = (floor(random(-angleCount, angleCount)) + 0.5) * 90.0/angleCount;
  //其他各个方向转相应角度即可
  if (theDirection == NORTH) return (a - 90);
  if (theDirection == EAST) return (a);
  if (theDirection == SOUTH) return (a + 90);
  if (theDirection == WEST) return (a + 180);
  return 0;
}



void keyReleased(){
  if (key == DELETE || key == BACKSPACE) background(360);
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == ' ') noLoop();

  // ------ pdf export ------
  // press 'r' to start pdf recording and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+".pdf");
      println("recording started");
      recordPDF = true;
      colorMode(HSB, 360, 100, 100, 100);
      background(360); 
      smooth();
      posX = int(random(0, width));
      posY = 5;
      posXcross = posX;
      posYcross = posY;
    }
  } 
  else if (key == 'e' || key =='E') {
    if (recordPDF) {
      println("recording stopped");
      endRecord();
      recordPDF = false;
      background(360); 
    }
  }  
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

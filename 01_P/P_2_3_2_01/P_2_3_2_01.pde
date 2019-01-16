// P_2_3_2_01.pde
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
 * draw tool. shows how to work with relations between elements. 
 * 
 * MOUSE
 * drag                : draw
 * 
 * KEYS
 * 1                   : draw mode 1 - fixed distance
 * 2                   : draw mode 2 - distance threshold 
 * del, backspace      : clear screen
 * arrow up            : line length +
 * arrow down          : line length -
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;

int drawMode = 1;

color col = color(random(255),random(255),random(255),random(100));
float x = 0, y = 0;
//float newX = 0, newY = 0;
float stepSize = 5.0;
// 默认线长25
float lineLength = 25;


void setup() {
  // use full screen size 
  size(displayWidth, displayHeight);
  background(255);
  smooth();
  x = mouseX;
  y = mouseY;
  // 鼠标显示为交叉的十字
  cursor(CROSS);
}


void draw() {
  if (mousePressed) {
    float d = dist(x,y, mouseX,mouseY);
    // 仅当距离大于步进才画图
    if (d > stepSize) {
      // 旋角 原来点到鼠标点的向量 与x轴正方向的夹角
      float angle = atan2(mouseY-y, mouseX-x); 

      pushMatrix();
      translate(x,y);
      rotate(angle);
      stroke(col);
      // 隔一帧就会有一帧填充为灰色
      if (frameCount % 2 == 0) stroke(150);
      // 线长和距离 正相关的
      line(0,0,0,lineLength*random(0.95,1.0)*d/10);
      popMatrix();
      // 下一帧位置的获得, 根据角度计算或者直接使用鼠标坐标
      if (drawMode == 1) {
        x = x + cos(angle) * stepSize;
        y = y + sin(angle) * stepSize; 
      } 
      else {
        x  = mouseX;
        y  = mouseY; 
      }
    }
  }
}

void mousePressed() {
  x = mouseX;
  y = mouseY;
  col = color(random(255),random(255),random(255),random(100));
  //lineLength = random(15,50);
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == DELETE || key == BACKSPACE) background(255);

  if (key == '1') drawMode = 1;
  if (key == '2') drawMode = 2;

  // ------ pdf export ------
  // press 'r' to start pdf recording and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+"_.pdf");
      println("recording started");
      recordPDF = true;
    }
  } 
  else if (key == 'e' || key =='E') {
    if (recordPDF) {
      println("recording stopped");
      endRecord();
      recordPDF = false;
      background(255); 
    }
  } 
}

void keyPressed() {
  // lineLength ctrls arrowkeys up/down 
  if (keyCode == UP) lineLength += 5;
  if (keyCode == DOWN) lineLength -= 5; 
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

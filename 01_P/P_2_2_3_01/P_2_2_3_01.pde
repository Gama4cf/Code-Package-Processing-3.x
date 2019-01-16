// P_2_2_3_01.pde
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
 * form mophing process by connected random agents
 * 
 * MOUSE
 * click               : start a new circe
 * position x/y        : direction of floating
 * 
 * KEYS
 * 1-2                 : fill styles
 * f                   : freeze. loop on/off
 * Delete/Backspace    : clear display
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;
//图形的分辨率,有多少个点组成
int formResolution = 15;
//每一步的大小
int stepSize = 2;
//扭曲因数
float distortionFactor = 1;
//初始半径
float initRadius = 150;
float centerX, centerY;
//记录图形上的每一个点
float[] x = new float[formResolution];
float[] y = new float[formResolution];

boolean filled = false;
boolean freeze = false;


void setup(){
  //屏幕大小
  size(displayWidth, displayHeight);
  smooth();

  // 初始的形状:圆
  centerX = width/2; 
  centerY = height/2;
  float angle = radians(360/float(formResolution));
  for (int i=0; i<formResolution; i++){
    x[i] = cos(angle*i) * initRadius;
    y[i] = sin(angle*i) * initRadius;  
  }
  
  stroke(0, 50);
  background(255);
}


void draw(){
  // floating towards mouse position 向鼠标方向游离
  if (mouseX != 0 || mouseY != 0) {
    centerX += (mouseX-centerX) * 0.01;
    centerY += (mouseY-centerY) * 0.01;
  }

  // 新点是在原来点的基础上增加随机值
  for (int i=0; i<formResolution; i++){
    x[i] += random(-stepSize,stepSize);
    y[i] += random(-stepSize,stepSize);
    // ellipse(x[i], y[i], 5, 5);
  }
  //控制线宽和填充色
  strokeWeight(0.75);
  if (filled) fill(random(255));  //填上的是灰度...很诡异
  else noFill();
  //绘出图形
  beginShape();
  // start controlpoint
  // curveVertex: Specifies vertex coordinates for curves.
  curveVertex(x[formResolution-1]+centerX, y[formResolution-1]+centerY);

  // only these points are drawn
  for (int i=0; i<formResolution; i++){
    curveVertex(x[i]+centerX, y[i]+centerY);
  }
  //仅仅以上,再 CLOSE ,也可以形成闭合图形,但是有一条线并非曲线
  //因为最开始的点用于控制弧线
  //Adding a fifth point with curveVertex() will draw the curve between the second, third, and fourth points.
  curveVertex(x[0]+centerX, y[0]+centerY);
  // end controlpoint
  curveVertex(x[1]+centerX, y[1]+centerY);
  endShape();
}


// events
void mousePressed() {
  //将位置初始化到点击处
  centerX = mouseX; 
  centerY = mouseY;
  //角度的平的
  float angle = radians(360/float(formResolution));
  //半径是在原始半径+随机值
  float radius = initRadius * random(0.5,1.0);
  //为新的图形计算每个点的坐标
  for (int i=0; i<formResolution; i++){
    x[i] = cos(angle*i) * radius;
    y[i] = sin(angle*i) * radius;
  }
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == DELETE || key == BACKSPACE) background(255);

  if (key == '1') filled = false;
  if (key == '2') filled = true;

  // ------ pdf export ------
  // press 'r' to start pdf recording and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+".pdf");
      println("recording started");
      recordPDF = true;
      stroke(0, 50);
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

  // switch draw loop on/off
  if (key == 'f' || key == 'F') freeze = !freeze;
  if (freeze == true) noLoop();
  else loop();
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

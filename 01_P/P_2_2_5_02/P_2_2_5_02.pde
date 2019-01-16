// P_2_2_5_02.pde
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
 * pack as many cirlces as possible together
 * 
 * MOUSE
 * press + position x/y : move area of interest
 * 
 * KEYS
 * 1                    : show/hide svg modules
 * 2                    : show/hide lines
 * 3                    : show/hide circles
 * arrow up/down        : resize area of interest
 * f                    : freeze process. on/off
 * s                    : save png
 * p                    : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;
boolean freeze = false;

int maxCount = 5000; //max count of the cirlces
int currentCount = 1;
float[] x = new float[maxCount];
float[] y = new float[maxCount];
float[] r = new float[maxCount]; //radius
//存储最近的圆环的坐标数组
int[] closestIndex = new int[maxCount]; //index
//半径的最大最小值
float minRadius = 3;
float maxRadius = 50;

// mouse and arrow up/down interaction
float mouseRect = 30;

// svg vector import
PShape module1, module2;

// style selector, hotkeys 1,2,3
boolean showSvg = true;
boolean showLine = false;
boolean showCircle = false;

void setup() {
  size(800, 800);
  noFill();
  smooth();
  //Sets the cursor(光标) to a predefined symbol or an image, or makes it visible if already hidden.
  cursor(CROSS);
  //两种图案,一黄一黑
  module1 = loadShape("01.svg");
  module2 = loadShape("02.svg");

  // first circle
  x[0] = 200;
  y[0] = 100;
  r[0] = 50;
  closestIndex[0] = 0;
}

void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  shapeMode(CENTER);
  ellipseMode(CENTER);
  background(255);

  for (int j = 0; j < 40; j++) {
    // 创建一组随机参数
    float tx = random(0+maxRadius,width-maxRadius);
    float ty = random(0+maxRadius,height-maxRadius);
    float tr = minRadius;

    // 如果鼠标按下了,那就根据鼠标创建一组随机位置
    // 这组位置波动的范围是 正方形mouseRect 中
    if (mousePressed == true) {
      tx = random(mouseX-mouseRect/2,mouseX+mouseRect/2);
      ty = random(mouseY-mouseRect/2,mouseY+mouseRect/2);
      //半径非常小,仅为1
      tr = 1;
    }

    boolean insection = true;
    // 找一个和已存在圆 互斥的位置
    for(int i=0; i < currentCount; i++) {
      float d = dist(tx,ty, x[i],y[i]);
      //println(d);
      if (d >= (tr + r[i])) insection = false;     
      else {
        insection = true; 
        //交叉的话直接跳出
        break;
      }
    }

    // stop process by pressing hotkey 'F'
    if (freeze) insection = true;

    // 不交叉的情况下,就创建一个新圆
    if (insection == false) {
      // get closest neighbour and closest possible radius
      float tRadius = width;
      // 有点乱了... 
      // 记录最近圆在数组中的序号
      // 但大体思路是, 与最近圆的距离-最近圆的半径=新圆半径
      for(int i=0; i < currentCount; i++) {
        float d = dist(tx,ty, x[i],y[i]);
        if (tRadius > d-r[i]) {
          tRadius = d-r[i];
          closestIndex[currentCount] = i;
        }
      }
      if (tRadius > maxRadius) tRadius = maxRadius;  // 不超过半径最大值

      x[currentCount] = tx;
      y[currentCount] = ty;
      r[currentCount] = tRadius;
      currentCount++;
    }
  }

  // draw them
  for (int i=0 ; i < currentCount; i++) {
    pushMatrix();
    translate(x[i],y[i]);
    // 我们 滥用 半径 作为 随机 角度 :) 
    // 转不转有区别?
    rotate(radians(r[i]));

    if (showSvg) {
      // draw SVGs
      // 最大半径的画成黄色的圆
      if (r[i] == maxRadius) shape(module1, 0, 0, r[i]*2,r[i]*2);
      else shape(module2, 0, 0, r[i]*2,r[i]*2);
    }
    if (showCircle) {
      // draw circles
      stroke(0);
      strokeWeight(1.5);
      ellipse(0,0, r[i]*2,r[i]*2);
    }
    popMatrix();

    if (showLine) {
      // draw connection-lines to the nearest neighbour
      stroke(150);
      strokeWeight(1);
      int n = closestIndex[i];
      line(x[i],y[i], x[n],y[n]); 
    }
  } 

  // visualize the random range of the new positions
  // 鼠标框
  if (mousePressed == true) {
    stroke(255,200,0);
    strokeWeight(2);
    rect(mouseX-mouseRect/2,mouseY-mouseRect/2,mouseRect,mouseRect);
  } 

  if (currentCount >= maxCount) noLoop();

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}

void keyReleased()  {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;

  // freeze process, toggle on/off
  if (key == 'f' || key == 'F') freeze = !freeze;

  // skin style, toggle on/off
  if (key == '1') showSvg = !showSvg;
  if (key == '2') showLine = !showLine;
  if (key == '3') showCircle = !showCircle;
}

void keyPressed(){
  // mouseRect ctrls arrowkeys up/down 
  if (keyCode == UP) mouseRect += 4;
  if (keyCode == DOWN) mouseRect -= 4; 
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

// P_2_2_4_01.pde
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
 * limited diffusion aggregation 
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int maxCount = 5000; //max count of the cirlces
int currentCount = 1;
//生成数组用来保存每一个圆的位置
//后面方便计算距离,使用像素数组会慢很多 600*600=360000
float[] x = new float[maxCount];
float[] y = new float[maxCount];
float[] r = new float[maxCount]; // 半径

void setup() {
  size(600,600);
  smooth();
  //frameRate(10);

  // first circle
  x[0] = width/2;
  y[0] = height/2;
  r[0] = 10;
  //r[0] = 400; 
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  background(255);

  strokeWeight(0.5);
  //noFill();

  // create a radom set of parameters
  float newR = random(1, 7);
  //保证了圆可以在画布中完整呈现
  float newX = random(0+newR, width-newR);
  float newY = random(0+newR, height-newR);
  //指示最近的距离和最近的圆在数组中的位置
  float closestDist = 100000000;
  int closestIndex = 0;
  // 循环求出最近的
  for(int i=0; i < currentCount; i++) {
    float newDist = dist(newX,newY, x[i],y[i]);
    if (newDist < closestDist) {
      closestDist = newDist;
      closestIndex = i; 
    } 
  }

  // show random position and line
  // fill(230);
  // ellipse(newX,newY,newR*2,newR*2); 
  // line(newX,newY,x[closestIndex],y[closestIndex]);

  // aline it to the closest circle outline
  // atan2():Calculates the angle (in radians) 
  //         from a specified point to the coordinate origin as measured from the positive x-axis.
  // 书上清晰描绘了这是一个和x轴正方向的夹角
  float angle = atan2(newY-y[closestIndex], newX-x[closestIndex]);
  // 使用三角函数公式计算出 线性平移之后的位置
  x[currentCount] = x[closestIndex] + cos(angle) * (r[closestIndex]+newR);
  y[currentCount] = y[closestIndex] + sin(angle) * (r[closestIndex]+newR);
  r[currentCount] = newR;
  currentCount++;

  // draw them, 到目前为止,全部画出
  for (int i=0 ; i < currentCount; i++) {
    //fill(50,150);
    fill(50);
    ellipse(x[i],y[i], r[i]*2,r[i]*2);  
  }

  if (currentCount >= maxCount) noLoop();

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

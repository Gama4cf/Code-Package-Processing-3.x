// M_2_1_01.pde
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
// 谐波振荡
/**
 * draws an oscillator
 *
 * KEYS
 * a                 : toggle oscillation animation
 * 1/2               : frequency -/+
 * arrow left/right  : phi -/+
 * s                 : save png
 * p                 : save pdf
 */


import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int pointCount;
int freq = 1;
float phi = 0;

float angle;
// 没有定义x参数, 整个过程是描点的方式画图的
float y;

boolean doDrawAnimation = true;


void setup() {
  size(800, 400);
  smooth();
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  background(255);
  stroke(0);
  strokeWeight(2);
  noFill();
  // 动画判断
  if (doDrawAnimation) {
    // 留出空来放圆那个动画
    pointCount = width-250;
    // 原点位置在 X 轴 250 处
    translate(250, height/2);
  }
  else {
    pointCount = width;
    // 原点位置在 x = 0 处
    translate(0, height/2);
  }

  // draw oscillator curve
  beginShape();
  for (int i=0; i<=pointCount; i++) {
    // 当前角度
    angle = map(i, 0,pointCount, 0,TWO_PI);
    y = sin(angle*freq + radians(phi));
    // 半径为100
    y = y * 100;
    // 因为每个点都画,所以仅仅描点就好了
    vertex(i, y);
  }
  endShape();

  if (doDrawAnimation) {
    drawAnimation();
  }

  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
  }
}

void drawAnimation() {
  // draw circle, dots and lines
  // 在圆上 一帧画一个点 画到结束从头开始
  // t 指示 这一圈进行程度
  float t = ((float)frameCount/pointCount) % 1;
  angle = map(t, 0,1, 0,TWO_PI);
  // 根据角度, 计算出坐标
  float x = cos(angle*freq + radians(phi));
  x = x*100 - 125;
  y = sin(angle*freq + radians(phi));
  y = y * 100;
  // circle
  strokeWeight(1);
  ellipse(-125, 0, 200, 200);  // 默认是长短轴
  // lines
  stroke(0, 128);
  // y 轴
  line(0, -100, 0, 100);
  // x 轴
  line(0, 0, pointCount, 0);
  // 圆的两条直径
  line(-225, 0, -25, 0);
  line(-125, -100, -125, 100);
  // 当前角度的线
  line(x, y, -125, 0);
  // dot on circle
  ellipse(x, y, 10, 10);
  // 画 振荡上的点到x轴的垂线
  stroke(0, 130, 164);
  strokeWeight(2);
  line(t*pointCount, y, t*pointCount, 0);
  line(x, y, x, 0);
  // dot on curve
  ellipse(t*pointCount, y, 10, 10);
  // 画初相对应的 线
  float phiX = cos(radians(phi))*100-125;
  float phiY = sin(radians(phi))*100;
  // phi line
  strokeWeight(1);
  stroke(0, 128);
  line(-125, 0, phiX, phiY);
  // phi dots
  fill(0);
  stroke(255);
  strokeWeight(2);
  ellipse(0, phiY, 8, 8);
  ellipse(phiX, phiY, 8, 8);
}


void keyPressed(){
  if(key == 's' || key == 'S') saveFrame(timestamp()+".png");
  if(key == 'p' || key == 'P') {
    savePDF = true;
    println("saving to pdf - starting");
  }
  // 动画开关快捷键 A
  if (key == 'a' || key == 'A') doDrawAnimation = !doDrawAnimation;
  // 控制频率
  if(key == '1') freq--;
  if(key == '2') freq++;
  freq = max(freq, 1);
  // 快进快退
  if (keyCode == LEFT) phi -= 15;
  if (keyCode == RIGHT) phi += 15;

  println("freq: " + freq + ", phi: " + phi);
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}

// M_2_3_02.pde
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
 * draws a modulated lissajous curve
 *
 * MOUSE
 * position x        : number of points
 *
 * KEYS
 * d                 : draw mode
 * 1/2               : frequency x -/+
 * 3/4               : frequency y -/+
 * arrow left/right  : phi -/+
 * 7/8               : modulation frequency x -/+
 * 9/0               : modulation frequency y -/+
 * s                 : save png
 * p                 : save pdf
 */


import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int pointCount = 500;
int freqX = 1;
int freqY = 4;
//  度
float phi = 60;

int modFreqX = 2;
int modFreqY = 1;
float modulationPhi = 0;

float angle;
float x, y;
float w, maxDist;
float oldX, oldY;
// 初始为 模式2
int drawMode = 2;


void setup() {
  size(600, 600);
  smooth();
  strokeCap(ROUND);
  // 最大距离
  maxDist = sqrt(sq(width/2-50) + sq(height/2-50));
}


void draw() {
  // if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  if (savePDF) beginRecord(PDF, freqX+"_"+freqY+"_"+int(phi)+"_"+modFreqX+"_"+modFreqY+".pdf");
  // 刷新背景
  background(255);
  // 平移坐标远点到坐标系最中间
  translate(width/2, height/2);
  //点的数量根据鼠标横坐标位置控制
  pointCount = mouseX*2+200;

  if (drawMode == 1) {
    stroke(0);
    // 比较细的线
    strokeWeight(1);
    // 这个图形是首尾相连的 仅仅描点!!
    beginShape();
    for (int i=0; i<=pointCount; i++){
      angle = map(i, 0,pointCount, 0,TWO_PI);
      // 什么???
      x = sin(angle * freqX + radians(phi)) * cos(angle * modFreqX);
      y = sin(angle * freqY) * cos(angle * modFreqY);

      x = x * (width/2-50);
      y = y * (height/2-50);
      // 连接点
      vertex(x, y);
    }
    endShape(); // 自动闭合 CLOSE 了...
  }
  else if (drawMode == 2) {
    strokeWeight(8);

    for (int i=0; i<=pointCount; i++){
      angle = map(i, 0,pointCount, 0,TWO_PI);

      // amplitude modulation
      x = sin(angle * freqX + radians(phi)) * cos(angle * modFreqX);
      y = sin(angle * freqY) * cos(angle * modFreqY);

      x = x * (width/2-50);
      y = y * (height/2-50);

      if (i > 0) {
        // Alpha通道和 坐标与原点距离 负相关
        w = dist(x, y, 0, 0);
        float lineAlpha = map(w, 0,maxDist, 255,0);
        // 线的灰度 0, 2, 4 受什么区别???
        stroke(i%2*2, lineAlpha);
        // 画线
        line(oldX, oldY, x, y);
      }

      oldX = x;
      oldY = y;
    }
  }


  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
  }
}



void keyPressed(){
  if(key == 's' || key == 'S') saveFrame(timestamp()+".png");
  if(key == 'p' || key == 'P') {
    savePDF = true;
    println("saving to pdf - starting");
  }
  // 模式切换开关
  if (key=='d' || key=='D') {
    if (drawMode == 1) drawMode = 2;
    else drawMode = 1;
  }

  if(key == '1') freqX--;
  if(key == '2') freqX++;
  freqX = max(freqX, 1);

  if(key == '3') freqY--;
  if(key == '4') freqY++;
  freqY = max(freqY, 1);

  if (keyCode == LEFT) phi -= 15;
  if (keyCode == RIGHT) phi += 15;

  if(key == '7') modFreqX--;
  if(key == '8') modFreqX++;
  modFreqX = max(modFreqX, 1);

  if(key == '9') modFreqY--;
  if(key == '0') modFreqY++;
  modFreqY = max(modFreqY, 1);

  println("freqX: " + freqX + ", freqY: " + freqY + ", phi: " + phi + ", modFreqX: " + modFreqX + ", modFreqY: " + modFreqY);
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}

// P_2_1_2_01.pde
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
 * changing size and position of circles in a grid
 * 	 
 * MOUSE
 * position x          : circle position
 * position y          : circle size
 * left click          : random position
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

float tileCount = 20;
color circleColor = color(0);
int circleAlpha = 180;
int actRandomSeed = 0;

void setup(){
  size(600, 600);
}

void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  //平移坐标到小瓷砖的中间：
  //这样后面每个坐标求出来不平移直接就是想要的中间位置
  translate(width/tileCount/2, height/tileCount/2);

  background(255);
  smooth();
  noFill();
  
  randomSeed(actRandomSeed);
  //边缘的颜色
  stroke(circleColor, circleAlpha);
  //边缘的宽度是和 mouseY 正相关的
  strokeWeight(mouseY/60);

  for (int gridY=0; gridY<tileCount; gridY++) {
    for (int gridX=0; gridX<tileCount; gridX++) {
      //posX和posY是每个小圆形的位置，这里是已经评议坐标之后的位置
      float posX = width/tileCount * gridX;
      float posY = height/tileCount * gridY;
      //伪随机数喂了种子，但是为什么每次random后画面感觉不到juggle？？？
      float shiftX = random(-mouseX, mouseX)/20;
      float shiftY = random(-mouseX, mouseX)/20;      
      if(gridX == 0 && gridY == 0){
        println(shiftX, shiftY);  //这里竟然可以保持一致不动，为什么？？？
      }
      /*原因：
      *在draw当中设置Seed，这样每次画图之前都会有相同的设置种子的过程
      *即使画了很多图，每次也都会仅仅使用前20×20×2个随机数，而这些数都是相同的
      */
      //位置：原始的位置+变换位置决定，大小和mouseY正相关
      ellipse(posX+shiftX, posY+shiftY, mouseY/15, mouseY/15);
    }
  }
  
  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}

void mousePressed() {
  actRandomSeed = (int) random(100000);
}

void keyReleased(){
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

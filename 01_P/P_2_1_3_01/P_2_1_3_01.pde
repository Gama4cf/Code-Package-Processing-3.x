// P_2_1_3_01.pde
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
 * changing circle amount, size and position in a grid
 * 	 
 * MOUSE
 * position x          : circle amount and size
 * position y          : circle position
 * left click          : random position
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;
//x,y两轴瓷砖总数
float tileCountX = 10;
float tileCountY = 10;
float tileWidth, tileHeight;
//
int count = 0;
int colorStep = 15;
int circleCount;
float endSize, endOffset;

int actRandomSeed = 0;


void setup() {
  //画布尺寸随便修改,后面有scale()可以改变图形以适应尺寸
  size(800, 800);
  //瓷砖的宽度和高度
  tileWidth = width / tileCountX;
  tileHeight = height / tileCountY;
} 


void draw() { 
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  //颜色的填充和背景色
  noFill();
  stroke(0, 128);
  background(255); 
  randomSeed(actRandomSeed);
  //将坐标转换到 左上第一瓷砖 中心位置
  translate((width/tileCountX)/2, (height/tileCountY)/2);
  //每块瓷砖的环的数量
  circleCount = mouseX/30 + 1;
  //endSize 最后一个圆环的直径,注意:最大仅为瓷砖宽度的一半
  endSize = map(mouseX, 0,width, tileWidth/2.0,0);
  //最后一个圆环的偏移,
  endOffset = map(mouseY, 0,height, 0,(tileWidth-endSize)/2);

  for (int gridY=0; gridY<=tileCountY; gridY++) {
    for (int gridX=0; gridX<=tileCountX; gridX++) {  
      pushMatrix();  //将以前的坐标状态放入Matrix中
      translate(tileWidth*gridX, tileHeight*gridY);
      //放缩原图像,x轴上不变,y轴上变为瓷砖的 高/宽, 
      //这里实际上相当于没有放缩,对于不同的长宽,就会起到效果
      scale(1, tileHeight/tileWidth);
      //四个角度,随机旋转
      int toggle = (int) random(0,4);
      if (toggle == 0) rotate(-HALF_PI);  
      if (toggle == 1) rotate(0);  
      if (toggle == 2) rotate(HALF_PI);  
      if (toggle == 3) rotate(PI);  
      
      // draw module
      for(int i=0; i<circleCount; i++) {
        //计算每个圆环的半径和偏移
        float diameter = map(i, 0,circleCount-1, tileWidth,endSize);
        float offset = map(i, 0,circleCount-1, 0,endOffset);
        //本来的偏移在x上,偏移的大小由
        ellipse(offset, 0, diameter,diameter);
      }
      popMatrix();  //还原以前的坐标状态
    }
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
} 

//点击鼠标生成随机数种子,获取新的方向
void mousePressed() {
  actRandomSeed = (int) random(100000);
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

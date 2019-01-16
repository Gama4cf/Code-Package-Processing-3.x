// P_1_2_1_01.pde
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
 * shows how to interpolate colors in different styles/ color modes
 * 
 * MOUSE
 * left click          : new random color set
 * position x          : interpolation resolution
 * position y          : row count
 * 
 * KEYS
 * 1-2                 : switch interpolation style
 * s                   : save png
 * p                   : save pdf
 * c                   : save color palette
 */
 
import generativedesign.*;  //导入了自带库
import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int tileCountX = 2;  //tile 瓷砖
int tileCountY = 10;

color[] colorsLeft = new color[tileCountY];
color[] colorsRight = new color[tileCountY];
color[] colors;

boolean interpolateShortest = true; //interpolate 插入


void setup() { 
  size(800, 800);
  colorMode(HSB,360,100,100,100); 
  noStroke();
  shakeColors();
} 


void draw() { 
  if (savePDF) {
    beginRecord(PDF, timestamp()+".pdf");
    noStroke();
    colorMode(HSB,360,100,100,100);
  } 
  //此处map映射到2开始，1不可以，原因没理解！！！
  //计算瓷砖的数量以及每一块瓷砖的宽和长
  tileCountX = (int) map(mouseX,0,width,1,100);
  tileCountY = (int) map(mouseY,0,height,2,10);
  float tileWidth = width / (float)tileCountX;
  float tileHeight = height / (float)tileCountY;
  color interCol;
  
  // just for ase export
  colors = new color[tileCountX*tileCountY];
  int i = 0;
  //开始循环的创建瓷砖填充颜色
  for (int gridY=0; gridY< tileCountY; gridY++) {
    //记录边界的颜色值，以方便用于分割
    color col1 = colorsLeft[gridY];
    color col2 = colorsRight[gridY];

    for (int gridX=0; gridX< tileCountX ; gridX++) { 
      //根据 lerp() 函数，需要一个 0-1 之间的数字表示增量
      float amount = map(gridX,0,tileCountX-1,0,1);
      //填充颜色以及填充 Color 的模式
      if (interpolateShortest) {
        // switch to rgb
        colorMode(RGB,255,255,255,255);
        //Calculates a number between two numbers at a specific increment. 
        //The amt parameter is the amount to interpolate between the two values
        //上面是 lerp() 函数的介绍，使用 lerpColor() 函数的时候，有相同的结论
        interCol = lerpColor(col1,col2, amount); 
        // switch back
        colorMode(HSB,360,100,100,100);
      } 
      else {
        interCol = lerpColor(col1,col2, amount); 
      }
      fill(interCol);
      //绘制此色块的瓷砖
      float posX = tileWidth*gridX;
      float posY = tileHeight*gridY;      
      rect(posX, posY, tileWidth, tileHeight); 
    
      // just for ase export
      colors[i] = interCol;
      i++;
    }
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
} 

//shakeColors() 用来初始化边界的颜色
void shakeColors() {
  for (int i=0; i<tileCountY; i++) {
    colorsLeft[i] = color(random(0,60), random(0,100), 100);
    colorsRight[i] = color(random(160,190), 100, random(0,100));
  }
}


void mouseReleased() {
  shakeColors();
}


void keyReleased() {
  if (key == 'c' || key == 'C') GenerativeDesign.saveASE(this, colors, timestamp()+".ase");
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
  
  if (key == '1') interpolateShortest = true;
  if (key == '2') interpolateShortest = false;
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

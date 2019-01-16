// P_2_3_6_01.pde
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
 * draw tool. draws a specific module according to 
 * its east, south, west and north neighbours. 
 * 
 * MOUSE
 * drag left           : draw new module
 * drag right          : delete a module
 * 
 * KEYS
 * del, backspace      : clear screen
 * g                   : toogle. show grid
 * d                   : toogle. show module values
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;
// 设置debug模式字体
PFont font;
// 模块形状 数组
PShape[] modules;
// 瓷砖尺寸
float tileSize = 30;
int gridResolutionX, gridResolutionY;
char[][] tiles;
// 网格模式和debug模式
boolean drawGrid = true;
boolean debugMode = false;


void setup() {
  // use full screen size 
  size(displayWidth, displayHeight);
  //size(720, 540);
  smooth();
  cursor(CROSS);
  font = createFont("sans-serif",8);
  textFont(font,8);
  textAlign(CENTER,CENTER);
  // 网格数量
  gridResolutionX = round(width/tileSize)+2;
  gridResolutionY = round(height/tileSize)+2;
  // 为每一个网格生成一个char
  // 后面用这个 char 来画图, 考虑使用 boolean
  tiles = new char[gridResolutionX][gridResolutionY];
  // 初始化titles数组
  initTiles();

  // load svg modules
  modules = new PShape[16]; 
  for (int i=0; i< modules.length; i++) { 
    modules[i] = loadShape(nf(i,2)+".svg");
  }
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  background(255);
  // 左键表示填充此瓷砖
  if (mousePressed && (mouseButton == LEFT)) setTile();
  // 右键表示移除填充
  if (mousePressed && (mouseButton == RIGHT)) unsetTile();
  // 网格开关
  if (drawGrid) drawGrid();
  // 画出模块
  drawModules();

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}


void initTiles() {
  for (int gridY=0; gridY< gridResolutionY; gridY++) {
    for (int gridX=0; gridX< gridResolutionX; gridX++) {  
      tiles[gridX][gridY] = '0';
    }
  }
}

void setTile() {
  // 将鼠标的坐标 转换为 网格坐标; 并限制网格坐标大小
  int gridX = floor((float)mouseX/tileSize) + 1;
  gridX = constrain(gridX, 1, gridResolutionX-2);
  int gridY = floor((float)mouseY/tileSize) + 1;
  gridY = constrain(gridY, 1, gridResolutionY-2);
  // 瓷砖标记
  tiles[gridX][gridY] = '1';
}

void unsetTile() {
  int gridX = floor((float)mouseX/tileSize) + 1;
  gridX = constrain(gridX, 1, gridResolutionX-2);
  int gridY = floor((float)mouseY/tileSize) + 1;
  gridY = constrain(gridY, 1, gridResolutionY-2);
  // 瓷砖标记
  tiles[gridX][gridY] = '0';
}

void drawGrid() {
  rectMode(CENTER);
  for (int gridY=0; gridY< gridResolutionY; gridY++) {
    for (int gridX=0; gridX< gridResolutionX; gridX++) {  
      float posX = tileSize*gridX - tileSize/2;
      float posY = tileSize*gridY - tileSize/2;
      strokeWeight(0.15);
      fill(255);
      // 把填充换成更亮一点的
      if (debugMode) {
        if (tiles[gridX][gridY] == '1') fill(220);
      }
      rect(posX, posY, tileSize, tileSize);
    }
  }
}

void drawModules() {
  shapeMode(CENTER);
  for (int gridY=1; gridY< gridResolutionY-1; gridY++) {  
    for (int gridX=1; gridX< gridResolutionX-1; gridX++) { 
      // use only active tiles
      if (tiles[gridX][gridY] == '1') {
        // 下面的组合方式精彩绝伦
		// 一共四个位置,东西南北,每个位置有两种状态,一共有2^4=16种状态,每种对应一张svg
        // check the four neighbours, each can be 0 or 1
        String east = str(tiles[gridX+1][gridY]);
        String south = str(tiles[gridX][gridY+1]);
        String west = str(tiles[gridX-1][gridY]);
        String north = str(tiles[gridX][gridY-1]);
        // create a binary result out of it, eg. 1011  组合成4位2进制
        String binaryResult = north + west + south + east;
        // convert the binary string to a decimal value from 0-15  转化为整数
        int decimalResult = unbinary(binaryResult);
        
        float posX = tileSize*gridX - tileSize/2;
        float posY = tileSize*gridY - tileSize/2;
        // decimalResult is the also the index for the shape array
        if(decimalResult != 14)
          shape(modules[decimalResult],posX, posY, tileSize, tileSize);
        else  //可能因为14号图像有问题or图像解析的问题, 需要平移一下才能正常显示
          shape(modules[decimalResult],posX+12, posY+tileSize, tileSize, tileSize);

        if (debugMode) {
          fill(150);
          text(decimalResult+"\n"+binaryResult,posX, posY);
        }
      }
    }
  }
}




void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;

  if (key == DELETE || key == BACKSPACE) initTiles();
  // 网格显示快捷键
  if (key == 'g' || key == 'G') drawGrid = !drawGrid;
  // svg图号标记显示快捷键
  if (key == 'd' || key == 'D') debugMode = !debugMode;
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

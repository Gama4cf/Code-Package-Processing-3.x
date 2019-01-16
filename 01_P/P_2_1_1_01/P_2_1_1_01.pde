// P_2_1_1_01.pde
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
 * changing strokeweight and strokecaps on diagonals in a grid
 * 	 
 * MOUSE
 * position x          : left diagonal strokeweight
 * position y          : right diagonal strokeweight
 * left click          : new random layout
 * 
 * KEYS
 * 1                   : round strokecap
 * 2                   : square strokecap
 * 3                   : project strokecap
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int tileCount = 20;
int actRandomSeed = 0;

int actStrokeCap = ROUND;


void setup() {
  size(600, 600);
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  background(255);
  smooth();
  noFill();
  strokeCap(actStrokeCap);

  randomSeed(actRandomSeed);

  for (int gridY=0; gridY<tileCount; gridY++) {
    for (int gridX=0; gridX<tileCount; gridX++) {
      //计算左上点的坐标
      int posX = width/tileCount*gridX;
      int posY = height/tileCount*gridY;

      int toggle = (int) random(0,2);

      if (toggle == 0) {
        //反向斜线：宽度和mouseX相关
        strokeWeight(mouseX/20);
        //宽度是width/tileCount，高度是height/tileCount
        line(posX, posY, posX+width/tileCount, posY+height/tileCount);
      }
      if (toggle == 1) {
        //正向斜线：宽度和mouseY相关
        strokeWeight(mouseY/20);
        line(posX, posY+width/tileCount, posX+height/tileCount, posY);
      }
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
  //改变线尾型
  if (key == '1'){
    //端点椭圆，与其他线段连接处正常过渡
    actStrokeCap = ROUND;
  }
  if (key == '2'){
    //端点方正，无法与其他线段正常过渡
    actStrokeCap = SQUARE;
  }
  if (key == '3'){
    //端点方正，与其他线段连接处正常过渡
    actStrokeCap = PROJECT;
  }
}



// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

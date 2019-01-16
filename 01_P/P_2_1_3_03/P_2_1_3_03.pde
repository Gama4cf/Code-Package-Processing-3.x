// P_2_1_3_03.pde
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
 * changing positions of stapled circles in a grid
 * 	 
 * MOUSE
 * position x          : module detail
 * position y          : module parameter
 * 
 * KEYS
 * 1-3                 : draw mode
 * arrow left/right    : number of tiles horizontally
 * arrow up/down       : number of tiles vertically
 * s                   : save png
 * p                   : save pdf
 */


import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;
//默认瓷砖数量
float tileCountX = 6;
float tileCountY = 6;
int count = 0;
//绘图模式
int drawMode = 1;


void setup() { 
  size(600, 600);
} 


void draw() { 
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  colorMode(HSB, 360, 100, 100); 
  //中心画矩形
  rectMode(CENTER);
  smooth();
  //noStroke();
  stroke(0);
  noFill();
  background(360); 

  //数量和mouseX正相关
  count = mouseX/20 + 5;
  //中心偏移和mouseY正相关,mouseY相对于画布高度的比值-0.5
  //这样的话,鼠标 在中间,para=0,偏下>0,偏上<0
  float para = (float)mouseY/height - 0.5;

  for (int gridY=0; gridY<= tileCountY; gridY++) {
    for (int gridX=0; gridX<= tileCountX; gridX++) {  
      //计算瓷砖宽高,瓷砖中心坐标
      float tileWidth = width / tileCountX;
      float tileHeight = height / tileCountY;
      float posX = tileWidth*gridX + tileWidth/2;
      float posY = tileHeight*gridY + tileHeight/2;

      pushMatrix();
      //平移坐标到当前瓷砖中心
      translate(posX, posY);

      // switch between modules
      switch (drawMode) {
      case 1:
        //原点转移到了左上角
        translate(-tileWidth/2, -tileHeight/2);
        for(int i=0; i< count; i++) {
          //从左上角出发的线
          line(0, (para+0.5)*tileHeight, tileWidth, i*tileHeight/count);
          //从左边的边上的点出发的线
          line(0, i*tileHeight/count, tileWidth, tileHeight-(para+0.5)*tileHeight);
        }
        break;
      case 2:
        for(float i=0; i<=count; i++) {
          //(para*tileWidth, para*tileHeight)随鼠标Y坐标由上到下,也映射到在一个瓷砖当中由上到下
          //相同的道理  (i/count-0.5)*tileHeight 就对应于整个Y坐标从上到下,
          //每两个点之间纵坐标Y差距 1/count*titleHeight
          line(para*tileWidth, para*tileHeight, tileWidth/2, (i/count-0.5)*tileHeight);
          line(para*tileWidth, para*tileHeight, -tileWidth/2, (i/count-0.5)*tileHeight);
          line(para*tileWidth, para*tileHeight, (i/count-0.5)*tileWidth, tileHeight/2);
          line(para*tileWidth, para*tileHeight, (i/count-0.5)*tileWidth, -tileHeight/2);
        }
        break;
      case 3:
        for(float i=0; i<=count; i++) {
          //从 竖立的中线上的点 到 另外四条边上点 连接而成的线
          line(0, para*tileHeight, tileWidth/2, (i/count-0.5)*tileHeight);
          line(0, para*tileHeight, -tileWidth/2, (i/count-0.5)*tileHeight);
          line(0, para*tileHeight, (i/count-0.5)*tileWidth, tileHeight/2);
          line(0, para*tileHeight, (i/count-0.5)*tileWidth, -tileHeight/2);
        }
        break;
      }

      popMatrix();

    }
  }
  if (savePDF) {
    savePDF = false;
    endRecord();
  }
} 


void keyReleased(){
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
  
  if (key == '1') drawMode = 1;
  if (key == '2') drawMode = 2;
  if (key == '3') drawMode = 3;
  //上下左右key控制瓷砖数量
  if (keyCode == DOWN) tileCountY = max(tileCountY-1, 1);
  if (keyCode == UP) tileCountY += 1;
  if (keyCode == LEFT) tileCountX = max(tileCountX-1, 1);
  if (keyCode == RIGHT) tileCountX += 1;

}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

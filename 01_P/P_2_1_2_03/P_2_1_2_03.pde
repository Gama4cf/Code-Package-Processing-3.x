// P_2_1_2_03.pde
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
 * changing size of circles in a rad grid depending the mouseposition
 * 	 
 * MOUSE
 * position x/y        : module size and offset z
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 */
 
import processing.opengl.*;
import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;
//瓷砖数量20
float tileCount = 20;
//模块颜色亮色,alpha=180
color moduleColor = color(0);
int moduleAlpha = 180;
int actRandomSeed = 0;
//默认最远距离500
//当超过这个距离的时候根据此数值 计算出来的 矩形长宽 会比默认最大值更大
int max_distance = 500; 
//P3D渲染
void setup(){
  size(600, 600, P3D);
}
//这个效果的设计更加巧妙一些
void draw() {
  if (savePDF) beginRaw(PDF, timestamp()+".pdf");

  background(255);
  smooth();
  //不填充
  noFill();
  //draw()内部设置种子
  randomSeed(actRandomSeed);
  //边缘颜色宽度
  stroke(moduleColor, moduleAlpha);
  strokeWeight(3);
  //对应默认最大距离500的默认最大尺寸
  int initMax = 40;
  for (int gridY=0; gridY<width; gridY+=25) {
    for (int gridX=0; gridX<height; gridX+=25) {

      float diameter = dist(mouseX, mouseY, gridX, gridY);
      //将原来的距离变为更合适的大小,其实是缩小了
      //默认最大距离的矩形尺寸就是initMax
      //更大距离产生更大尺寸,最大距离 sqrt(sq(width)+sq(height)) > max_distance
      diameter = diameter/max_distance * initMax;
      //绘图
      pushMatrix();
      // z 轴变换为diameter*5,因为距离越远会感觉上下两层隔得越远
      translate(gridX, gridY, diameter*5);
      rect(0, 0, diameter, diameter);    //// also nice: ellipse(...)
      popMatrix(); 
    }
  }

  if (savePDF) {
    savePDF = false;
    endRaw();
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

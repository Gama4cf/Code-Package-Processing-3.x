// M_1_2_01.pde
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
 * order vs random! 
 * how to interpolate beetween a free composition (random) and a circle shape (order)
 * 
 * MOUSE
 * position x          : fade between random and circle shape
 * 
 * KEYS
 * p                   : save pdf
 * s                   : save png
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int actRandomSeed = 0;
int count = 150;

void setup() {
  size(800,800); 
  cursor(CROSS);
  smooth();
}

void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  background(255);
  noStroke();
  // 生成用作迭代步进的, 这个值很无关紧要了
  float faderX = (float)mouseX/width;
  // 尽管看起来是随机的,但因为每次都是相同的种子,所以每次随机点位置也都是相同的
  randomSeed(actRandomSeed);
  float angle = radians(360/float(count));
  for (int i=0; i<count; i++){
    // 位置是随机的
    float randomX = random(0,width);  
    float randomY = random(0,height);
    // 改成半径和mouse坐标相关更好玩,哈哈
    float circleX = width/2 + cos(angle*i)*mouseX/2;
    float circleY = height/2 + sin(angle*i)*mouseY/2;
    // 目标位置是固定的  以中心点为圆心,以mouseX/2 mouseY/2 为两轴
    float x = lerp(randomX,circleX, faderX);
    float y = lerp(randomY,circleY, faderX);

    fill(0,130,164);
    ellipse(x,y,11,11);
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}

void mouseReleased() {
  actRandomSeed = (int) random(100000);
}

void keyReleased() {  
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_####.png");
  if (key == 'p' || key == 'P') savePDF = true;
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

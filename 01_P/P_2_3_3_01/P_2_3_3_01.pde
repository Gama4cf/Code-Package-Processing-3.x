// P_2_3_3_01.pde
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
 * draw tool. shows how to draw with dynamic elements. 
 * 
 * MOUSE
 * drag                : draw with text
 * 
 * KEYS
 * del, backspace      : clear screen
 * arrow up            : angle distortion +
 * arrow down          : angle distortion -
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;

float x = 0, y = 0;
// 步进
float stepSize = 5.0;
// 字体实例
PFont font;
String letters = "Sie hören nicht die folgenden Gesänge, Die Seelen, denen ich die ersten sang, Zerstoben ist das freundliche Gedränge, Verklungen ach! der erste Wiederklang.";
// 最小字号
int fontSizeMin = 3;
// 弯曲角
float angleDistortion = 0.0;

int counter = 0;


void setup() {
  // use full screen size 
  size(displayWidth, displayHeight);
  background(255);
  smooth();
  cursor(CROSS);

  x = mouseX;
  y = mouseY;
  // 初始字体的设置
  font = createFont("American Typewriter",10);
  //font = createFont("ArnhemFineTT-Normal",10);
  textFont(font,fontSizeMin);
  textAlign(LEFT);
  fill(0);


  /*
  // load an image in background
   PImage img = loadImage(selectInput("select a background image"));
   image(img, 0, 0, width, height);
   */
}


void draw() {
  if (mousePressed) {
    float d = dist(x,y, mouseX,mouseY);
    // 文本的字号 = 半径的一半加上最小字号
    textFont(font,fontSizeMin+d/2);
    // 新的字符
    char newLetter = letters.charAt(counter);
    // 新的步进 = 新字符的字号相同
    stepSize = textWidth(newLetter);
    // 生成文字
    if (d > stepSize) {
      // 计算 原来点到鼠标点向量 与 x轴正方向 夹角
      float angle = atan2(mouseY-y, mouseX-x); 

      pushMatrix();
      translate(x, y);
      // 给每一个字符一个随机的 弯曲角度: 
      // 每个字符并非按照鼠标方向排列,而是有了自己的旋角
      rotate(angle + random(angleDistortion));
      text(newLetter, 0, 0);
      popMatrix();
      // 在letters文本中循环
      counter++;
      if (counter > letters.length()-1) counter = 0;
      // 按 有角度的步进 获取下一字符的点
      x = x + cos(angle) * stepSize;
      y = y + sin(angle) * stepSize; 
    }
  }
}


void mousePressed() {
  x = mouseX;
  y = mouseY;
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == DELETE || key == BACKSPACE) background(255);

  // ------ pdf export ------
  // press 'r' to start pdf recordPDF and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+".pdf");
      println("recording started");
      recordPDF = true;
      textAlign(LEFT);
      fill(0);
    }
  } 
  else if (key == 'e' || key =='E') {
    if (recordPDF) {
      println("recording stopped");
      endRecord();
      recordPDF = false;
      background(255); 
    }
  }
}

void keyPressed() {
  // angleDistortion ctrls arrowkeys up/down 
  if (keyCode == UP) angleDistortion += 0.1;
  if (keyCode == DOWN) angleDistortion -= 0.1; 
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

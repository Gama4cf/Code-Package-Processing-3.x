// P_3_1_1_01.pde
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
 * typewriter. time reactive. 
 * 
 * MOUSE
 * position y           : adjust spacing (line height)
 * 
 * KEYS
 * a-z                  : text input (keyboard)
 * backspace            : delete last typed letter
 * ctrl                 : save png + pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean doSave = false;

String textTyped = "Type slow and fast!";
float[] fontSizes = new float[textTyped.length()];
float minFontSize = 15;
float maxFontSize = 800;
float newFontSize = 0;

int pMillis;
float maxTimeDelta = 5000.0;  //最大时间增量

float spacing = 2; // line height, 行高
float tracking = 0; // between letters, 字符间距
PFont font;



void setup() {
  size(800, 600);
  // make window resizable
  surface.setResizable(true);

  font = createFont("Arial",10);

  smooth();
  noCursor();

  // init fontSizes, 初始化的字体大小为最小值
  for (int i = 0; i < textTyped.length(); i++) {
    fontSizes[i] = minFontSize;
  }
  // 记录前一个时间
  pMillis = millis();
}


void draw() {
  if (doSave) beginRecord(PDF, timestamp()+".pdf");
  background(255);
  textAlign(LEFT);
  fill(0);
  noStroke();
  // 行高和纵坐标相关,这样鼠标上移,字符聚集在一起
  spacing = map(mouseY, 0,height, 0,120);
  // 坐标平移到最开始输入的位置
  translate(0, 200+spacing);

  float x = 0, y = 0, fontSize = 20;

  for (int i = 0; i < textTyped.length(); i++) {
    // 从列表中获取字体大小和字符
    fontSize = fontSizes[i];
    textFont(font, fontSize);
    char letter = textTyped.charAt(i);
    // 间距为字体宽度+字符间距
    float letterWidth = textWidth(letter) + tracking;
    
    if (x+letterWidth > width) {
      // 从新的一行开始,增加行高
      x = 0;
      y += spacing; 
    }
    
    // draw letter
    text(letter, x, y);
    // 更新下一个字符的x坐标
    x += letterWidth;
  }

  // blinking cursor after text
  float timeDelta = millis() - pMillis;  // 时间增量
  newFontSize = map(timeDelta, 0,maxTimeDelta, minFontSize,maxFontSize);  // 映射到字符大小
  newFontSize = min(newFontSize, maxFontSize);  //限制字符大小
  // 绘出 输入提示符 ,一闪一闪的显示
  fill(200, 30, 40);
  if (frameCount/10 % 2 == 0) fill(255);
  rect(x, y, newFontSize/2, newFontSize/20);


  if (doSave) {
    doSave = false;
    endRecord();
    saveFrame(timestamp()+"_##.png");
  }
}



void keyReleased() {
  // export pdf and png
  if (keyCode == CONTROL) doSave = true;
}


void keyPressed() {
  if (key != CODED) {
    switch(key) {
    case DELETE:
    case BACKSPACE:
      if (textTyped.length() > 0) {
        // 删掉最后一个: 取除最后一个字符的子字符串
        textTyped = textTyped.substring(0,max(0,textTyped.length()-1));
        // Decreases an array by one element and returns the shortened array. 
        fontSizes = shorten(fontSizes);
      }
      break;
      // disable those keys
    case TAB:
    case ENTER:
    case RETURN:
    case ESC:
      break;
    default:
      // 字符串数组中加入新键入的字符
      textTyped += key;
      // 将新字号增加到 字符大小数组 中
      fontSizes = append(fontSizes, newFontSize);
    }

    // reset timer
    pMillis = millis();
  }
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

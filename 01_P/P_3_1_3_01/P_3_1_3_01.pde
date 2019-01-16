// P_3_1_3_01.pde
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
 * analysing and sorting the letters of a text 
 * changing the letters alpha value in relation to frequency
 *
 * MOUSE
 * position x          : interpolate between normal text and sorted position
 *
 * KEYS
 * 1                   : toggle alpha mode
 * s                   : save png
 * p                   : save pdf
 */


import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

PFont font;
String joinedText;

String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß,.;:!? ";
int[] counters = new int[alphabet.length()];

float charSize;
color charColor = 0;
int posX, posY;

boolean drawAlpha = true;


void setup() {
  size(670, 600);
  // 读取文本,并拼接到一起
  String[] lines = loadStrings("faust_kurz.txt");
  joinedText = join(lines, " ");

  font = createFont("Courier", 10);

  countCharacters();
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  
  textFont(font);
  background(255);
  noStroke();
  smooth();

  posX = 20;
  posY = 40;

  // go through all characters in the text to draw them  
  // 每一次draw 都会产生文本中位置 但随着鼠标x的运动 这个文本中位置并不会画出来
  // 真正画出来的是 中间的插值位置 所以是鼠标左右移动 对应 是否排序 是可逆的
  for (int i = 0; i < joinedText.length(); i++) {
    // again, find the index of the current letter in the alphabet
    String s = str(joinedText.charAt(i)).toUpperCase();
    char uppercaseChar = s.charAt(0);
    int index = alphabet.indexOf(uppercaseChar);
    if (index < 0) continue;

    if (drawAlpha) fill(87, 35, 129, counters[index]*3);  //数量越多不透明度越大
    else fill(87, 35, 129);
    textSize(18);
    // 用来排序
    float sortY = index*20+40;  //每个字符的Y都以固定,这样排完序一行都是一个字母
    float m = map(mouseX, 50,width-50, 0,1);  //求步进
    m = constrain(m, 0, 1);  //步进限制在0-1之间
    float interY = lerp(posY, sortY, m);  // 求中间状态下Y坐标值

    text(joinedText.charAt(i), posX, interY);  //显示中间状态文字
    //下一个字符的 x坐标 位置
    posX += textWidth(joinedText.charAt(i));
    // 判断是否需要另起一行
    if (posX >= width-150 && uppercaseChar == ' ') {
      posY += 30;
      posX = 20;
    }
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}

// 统计各个字符的数量
void countCharacters(){
  for (int i = 0; i < joinedText.length(); i++) {
    // get one char from the text, convert it to a string and turn it to uppercase
    char c = joinedText.charAt(i);
    String s = str(c);
    s = s.toUpperCase();
    // convert it back to a char
    char uppercaseChar = s.charAt(0);
    // get the position of this char inside the alphabet string
    int index = alphabet.indexOf(uppercaseChar);
    // increase the respective counter
    if (index >= 0) counters[index]++;
  }
}




void keyReleased(){
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key=='p' || key=='P') savePDF = true;

  if (key == '1') drawAlpha = !drawAlpha;
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

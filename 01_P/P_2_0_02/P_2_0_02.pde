// P_2_0_02.pde
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
 * drawing with a changing shape by draging the mouse.
 * 	 
 * MOUSE
 * position x          : length
 * position y          : thickness and number of lines
 * drag                : draw
 * 
 * KEYS
 * del, backspace      : erase
 * s                   : save png
 * r                   : start pdf record
 * e                   : end pdf record
 */

import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;

void setup(){
  size(720, 720);
  //smooth()默认执行
  smooth();
  noFill();
  background(255);
}

void draw(){
  if(mousePressed){
    pushMatrix();
    //坐标系原点 tarnslate 到中心位置
    // the transformation is reset when the loop begins again. 
    translate(width/2,height/2);
    //内接 circleResolution 边形。map注意 mouseY＋100
    //mouseY控制边的数量
	//另注意：书上此处代码有误
    int circleResolution = (int)map(mouseY+100,0,height,2, 10);
    //mouseX控制半径长度，这里算出来的值可以是 负数 
    //因为后面无论正负对圆上点的求解都没有影响。
    float radius = mouseX-width/2 + 0.5;
    float angle = TWO_PI/circleResolution;

    strokeWeight(2);
    stroke(0, 25);   //透明度不高，浅灰

    beginShape();
    for (int i=0; i<=circleResolution; i++){
      float x = 0 + cos(angle*i) * radius;
      float y = 0 + sin(angle*i) * radius;
      vertex(x, y);
    }
    endShape();
    
    popMatrix();
  }
}

void keyReleased(){
  //重置画布key
  if (key == DELETE || key == BACKSPACE) background(255);
  if (key=='s' || key=='S') saveFrame(timestamp()+"_##.png");

  // ------ pdf export ------
  // press 'r' to start pdf recording and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+".pdf");
      println("recording started");
      recordPDF = true;
      smooth();
      noFill();
      background(255);
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

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

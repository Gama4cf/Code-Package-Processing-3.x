// M_1_1_01.pde
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
 * draws a random chart and shows how to use randomSeed.
 * 
 * MOUSE
 * click               : new random line
 * 
 * KEYS
 * p                   : save pdf
 * s                   : save png
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int actRandomSeed = 42;

void setup() {
  size(1024, 256);
  smooth();
}

void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  background(255); 


  // line
  stroke(0,130,164);
  strokeWeight(1);
  strokeJoin(ROUND);
  noFill();
  // 及时每次都random() 但是因为每次的种子都强制置于相同, 所以图形并不会变化
  randomSeed(actRandomSeed);
  beginShape();
  for (int x = 0; x < width; x+=10) {
    float y = random(0,height);   
    vertex(x,y);
  }
  endShape();


  // dots
  noStroke();
  fill(0);
  // 连描点的时候都在使用一遍...明明可以一次搞定
  randomSeed(actRandomSeed);
  for (int x = 0; x < width; x+=10) {
    float y = random(0,height);   
    ellipse(x,y,3,3);
  }


  if (savePDF) {
    savePDF = false;
    endRecord();
  }

}
// 只有当鼠标按下的时候,才会生成一个新的种子
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

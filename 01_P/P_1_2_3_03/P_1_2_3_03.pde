/**
 * generates a specific color palette and some random "rect-tilings"
 * 与 P_1_2_3_02 处绘制图形部分非常相似
 * MOUSE
 * left click          : new composition
 * 
 * KEYS
 * s                   : save png
 * c                   : save color palette
 */

import generativedesign.*;
import processing.opengl.*;
import java.util.Calendar;

int colorCount = 20;
int[] hueValues = new int[colorCount];
int[] saturationValues = new int[colorCount];
int[] brightnessValues = new int[colorCount];
//增加了α通道，这样下层的颜色在上面也可以看到
int alphaValue = 27;
//伪随机数的种子
int actRandomSeed = 0;

void setup() {
  size(800,800,P3D); 
  colorMode(HSB,360,100,100,100);
  noStroke();
}

void draw() { 
  background(0,0,0);
  randomSeed(actRandomSeed);

  // ------ colors ------
  // create palette
  for (int i=0; i<colorCount; i++) {
    if (i%2 == 0) {
      hueValues[i] = (int) random(0,360);
      saturationValues[i] = 100;
      brightnessValues[i] = (int) random(0,100);
    } 
    else {
      hueValues[i] = 195;
      saturationValues[i] = (int) random(0,100);
      brightnessValues[i] = 100;
    }
  }

  // ------ area tiling ------
  // count tiles
  int counter = 0;
  // row count and row height
  int rowCount = (int)random(5,30);
  float rowHeight = (float)height/(float)rowCount;

  // seperate each line in parts  
  for(int i=rowCount; i>=0; i--) {
    // how many fragments
    int partCount = i+1;
    float[] parts = new float[0];

    for(int ii=0; ii<partCount; ii++) {
      // sub fragments or not?
      if (random(1.0) < 0.075) {
        // take care of big values     
        int fragments = (int)random(2,20);
        partCount = partCount + fragments; 
        for(int iii=0; iii<fragments; iii++) {
          parts = append(parts, random(2));
        }              
      }  
      else {
        parts = append(parts, random(2,20));   
      }
    }

    // add all subparts
    float sumPartsTotal = 0;
    for(int ii=0; ii<partCount; ii++) sumPartsTotal += parts[ii];
    //↑以上可参照P_1_2_3_02，极其类似
    // 绘制瓷砖
    float sumPartsNow = 0;
    for(int ii=0; ii<parts.length; ii++) {
      sumPartsNow += parts[ii];
      //使用当前行 前面块总宽度 映射到 宽度
      float x = map(sumPartsNow, 0,sumPartsTotal, 0,width);
      float y = rowHeight*i;
      //宽度：因为 x 的映射的值位于图形右上角，×-1 表示向左方向画
      float w = map(parts[ii], 0,sumPartsTotal, 0,width)*-1;
      //高度是行宽的1.5倍
      float h = rowHeight*1.5;
      
      beginShape();  
      //一开始填充的是黑的？？？
      //效果：每个瓷砖的上面一部分会更暗一些，会有点层叠的效果
      //在另一个标签中可以看到效果
      fill(0,0,0);
      vertex(x,y);
      vertex(x+w,y);
      // get component color values + aplha
      int index = counter % colorCount;
      fill(hueValues[index],saturationValues[index],brightnessValues[index],alphaValue);
      vertex(x+w,y+h);
      vertex(x,y+h);
      endShape(CLOSE);

      counter++;
    }
  }  
} 

void mouseReleased() {
  actRandomSeed = (int) random(100000);
}

void keyReleased() {  
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_####.png");
  if (key == 'c' || key == 'C') {
    // ------ save an ase file (adobe swatch export) ------
    // create palette
    color[] colors = new color[colorCount];
    for (int i=0; i<colorCount; i++) {
      colors[i] = color(hueValues[i],saturationValues[i],brightnessValues[i]);
    }
    GenerativeDesign.saveASE(this, colors, timestamp()+".ase");
  }
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

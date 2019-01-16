/**
 * generates a specific color palette and some random "rect-tilings"
 * 
 * MOUSE
 * left click          : new composition
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 * c                   : save color palette
 */

import generativedesign.*;
import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;
//颜色数组中一共颜色的数量=20
int colorCount = 20;
int[] hueValues = new int[colorCount];
int[] saturationValues = new int[colorCount];
int[] brightnessValues = new int[colorCount];


void setup() {
  size(600,600); 
  colorMode(HSB,360,100,100,100);
  noStroke();
}


void draw() { 
  if (savePDF) {
    beginRecord(PDF, timestamp()+".pdf");
    noStroke();
    colorMode(HSB,360,100,100,100);
  } 
  
  // ------ colors ------
  // create palette，给调色板中给一个颜色生成随机数
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
  int rowCount = (int)random(20,40);
  float rowHeight = (float)height/(float)rowCount;

  for(int i=0; i<rowCount; i++) {
    // seperate each line in parts  
    // how many fragments
    int partCount = i+1;  //随着行号的增加，每行块数＋1
    //用来存储当前行中每个块的宽度
    float[] parts = new float[0];

    for(int ii=0; ii<partCount; ii++) {
      // 根据生成值判断是否为 子块 
      if (random(1.0) < 0.075) {
        // 慎重使用大数，会导致：后面映射为宽度的时候宽度太小
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

    // 计算所有快的宽度
    float sumPartsTotal = 0;
    for(int ii=0; ii<partCount; ii++) sumPartsTotal += parts[ii];

    // draw rects
    float sumPartsNow = 0;
    for(int ii=0; ii<parts.length; ii++) {
      // 循环填充颜色
      int index = counter % colorCount;
      fill(hueValues[index],saturationValues[index],brightnessValues[index]);

      sumPartsNow += parts[ii];
      //使用映射将 random 的宽度变为 实际像素宽度
      rect(map(sumPartsNow, 0,sumPartsTotal, 0,width),rowHeight*i, 
        map(parts[ii], 0,sumPartsTotal, 0,width)*-1,rowHeight);

      counter++;
    }
  }  

  if (savePDF) {
    savePDF = false;
    endRecord();
  }

  noLoop();
} 


void mouseReleased() {
  //鼠标释放一次，就产生一列新的
  loop();
}


void keyReleased() {  
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
  if (key == 'c' || key == 'C') {
    // ------ save an ase file (adobe swatch export) ------
    // 创建新调色板，并且保存ASE
    color[] colors = new color[colorCount];
    for (int i=0; i<colorCount; i++) {
      colors[i] = color(hueValues[i], saturationValues[i], brightnessValues[i]);
    }
    GenerativeDesign.saveASE(this, colors, timestamp()+".ase");
  }
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

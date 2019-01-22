// M_4_3_01_TOOL.pde
// GUI.pde, TileSaver.pde
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
 * play around with a 2d grid of nodes and draw them in different ways
 *
 * MOUSE
 * left click          : apply attractor force (repulsion)
 * shift + left click  : apply attractor force (attraction)
 * right click + drag  : move canvas
 *
 * KEYS
 * 1-9                 : choose layer to affect
 * 0                   : affect all layers
 * space               : freeze all
 * m                   : menu open/close
 * r                   : reset grid points
 * s                   : save png
 * p                   : save pdf
 */


// ------ imports ------

import generativedesign.*;
import processing.opengl.*;
import processing.pdf.*;
import java.util.Calendar;


// ------ initial parameters and declarations ------

color[] defaultColors = {
  color(0)};

color[] colors;
int actLayer = 0;

boolean freeze = false;

int maxCount = 150;
int xCount;
int yCount;
int layerCount;
int oldXCount;
int oldYCount;
int oldLayerCount;
float gridStepX;
float gridStepY;
float oldGridStepX;
float oldGridStepY;

boolean attractorSmooth = true;
boolean attractorTwirl = false;
float attractorRadius = 150;
float attractorStrength = 3;
float attractorRamp = 1;
float nodeDamping = 0.1;

boolean invertBackground = false;
float lineWeight = 1;
float lineAlpha = 50;
boolean drawX = true;
boolean drawY = false;
boolean lockX = true;
boolean lockY = false;

boolean drawLines = true;
boolean drawCurves = false;

// nodes array,三维Node数组???
// 第一维: 存储各个layer 第二维: 存储y轴坐标 第三维: 存储x轴坐标
// Node 和 Attractor 都是 generativedesign.* 的类
// maxCount*2+1 中间一个, 两边各有maxCount个点
Node[][][] nodes = new Node[9][maxCount*2+1][maxCount*2+1];

// attraktor
Attractor myAttractor;


// ------ mouse interaction ------
// 鼠标拖拽
boolean dragging = false;
float offsetX = 0, offsetY = 0, clickX = 0, clickY = 0, clickOffsetX = 0, clickOffsetY = 0;
boolean mouseInWindow = false;


// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
boolean GUI = false;
boolean guiEvent = false;
Slider[] sliders;
Range[] ranges;
Toggle[] toggles;
Bang[] bangs;
Bang infoBang;


// ------ image output ------

boolean saveOneFrame = false;
boolean savePDF = false;



void setup() {
  size(1000,720,P2D);

  // make window resizable
  surface.setResizable(true);

  setupGUI();

  // init attractor
  myAttractor = new Attractor();
  // Attractor function with a smooth transition at the attractor radius
  // M_4_2_03 中的公式
  myAttractor.setMode(Attractor.SMOOTH);

  // init grid
  reset();
  guiEvent = false;

  frameRate(30);
}


void draw() {

  // ------ image output ------

  if (savePDF) {
    beginRecord(PDF, timestamp()+".pdf");
  }


  // ------ white/black background ------

  color bgColor = color(255);
  color circleColor = color(0);
  if (invertBackground) {
    bgColor = color(0);
    circleColor = color(255);
  }
  background(bgColor);


  // ------ setup drawing style ------

  colorMode(RGB, 255, 255, 255, 100);
  noFill();
  smooth();
  stroke(0, 100);
  strokeWeight(lineWeight);
  // Sets the resolution at which Beziers display. The default value is 20.
  // This function is only useful when using the P3D renderer;
  // the default P2D renderer does not use this information.
  //bezierDetail(10);


  // ------ canvas dragging ------

  if (dragging) {
    offsetX = clickOffsetX + (mouseX - clickX);
    offsetY = clickOffsetY + (mouseY - clickY);
  }


  // ------ set view ------

  pushMatrix();
  // 平移坐标到中心点+鼠标拖拽偏移
  translate(width/2 + offsetX, height/2 + offsetY);


  // ------ set parameters ------
  // 更新数量
  if (xCount != oldXCount || yCount != oldYCount || layerCount != oldLayerCount) {
    oldXCount = xCount;
    oldYCount = yCount;
    oldLayerCount = layerCount;
  }
  // 更新阻尼
  if (nodes[0][0][0].damping != nodeDamping) {
    // tell all nodes the new damping values
    updateDamping();
  }
  // 改变磁力公式
  if (attractorSmooth) {
    myAttractor.setMode(Attractor.SMOOTH);
  }
  else {
    myAttractor.setMode(Attractor.TWIRL);
  }
  // 设置 Attractor 的参数
  myAttractor.radius = attractorRadius;
  myAttractor.ramp = attractorRamp;
  if (mousePressed && mouseButton==LEFT && !guiEvent) {
    if (!keyPressed) {
      // attraction, if left click
      myAttractor.strength = -attractorStrength;
    }
    else if (keyPressed && keyCode == SHIFT) {
      // repulsion, if shift + left click
      myAttractor.strength = attractorStrength;
    }
  }
  else {
    // otherwise no attraction or repulsion
    // 也就是没有按下鼠标左键,也并没有进行guiEvent的时候, 没有磁力, 也就维持了原状
    myAttractor.strength = 0;
  }

  // set attractor at the mouse position
  myAttractor.x = (mouseX-width/2-offsetX);
  myAttractor.y = (mouseY-height/2-offsetY);
  myAttractor.z = 0;


  // ------ attract and update node positions ------
  // 尽管只显示一层, 其他层却也都计算出来了
  for (int iz = 0; iz < layerCount; iz++) {
    if (iz == actLayer || actLayer == (-1)) {
      for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
        for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
          myAttractor.attract(nodes[iz][iy][ix]);
          //  void	update(boolean theLockX, boolean theLockY, boolean theLockZ)
          //  The buttons “Lock X” and “Lock Y” are used to limit the nodes’ directions of movement.
          nodes[iz][iy][ix].update(lockX, lockY, false);
        }
      }
    }
  }


  // ------ draw lines ------

  int stepI = 1;
  boolean lineDrawn = false;

  // x
  if (drawX && xCount > 0) {
    for (int iz = layerCount-1; iz >= 0; iz--) {
      color c = colors[iz % colors.length];
      stroke(red(c), green(c), blue(c), lineAlpha);
      // 这个地方需要注意: 现在坐标已经平移了, 以后从中心位置左边偏移 yCount 处开始画
      for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
        drawLine(nodes[iz][iy], xCount, drawCurves);

        if (savePDF) {
          println("saving to pdf – step " + (stepI++));
        }
      }
    }
    lineDrawn = true;
  }

  // y
  if (drawY && yCount > 0) {
    for (int iz = layerCount-1; iz >= 0; iz--) {
      color c = colors[iz % colors.length];
      stroke(red(c), green(c), blue(c), lineAlpha);
      for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
        // 生成一个新的Pvector数组,用来记录ix,iz相同的所有向量, 然后交给drawLine
        PVector[] pts = new PVector[maxCount*2+1];
        int ii = 0;
        for (int iy = 0; iy < maxCount*2+1; iy++) {
          pts[ii++] = nodes[iz][iy][ix];
        }
        drawLine(pts, yCount, drawCurves);
        if (savePDF) {
          println("saving to pdf – step " + (stepI++));
        }
      }
    }
    lineDrawn = true;
  }

  // if no lines were drawn, draw dots
  if (!lineDrawn) {
    for (int iz = layerCount-1; iz >= 0; iz--) {
      color c = colors[iz % colors.length];
      stroke(red(c), green(c), blue(c), lineAlpha);
      for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
        for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
          Node n = nodes[iz][iy][ix];
          if (savePDF) {
            println("saving to pdf – step " + (stepI++));
            ellipse(n.x, n.y, lineWeight/2, lineWeight/2);
          }
          else {
            point(n.x, n.y);
          }
        }
      }
    }
  }

  popMatrix();


  // ------ draw attractor radius ------

  if (!guiEvent && mouseInWindow && !saveOneFrame && !savePDF) {
    noFill();
    strokeWeight(1);
    stroke(circleColor, 20);
    ellipse(mouseX, mouseY, myAttractor.radius*2, myAttractor.radius*2);
  }


  // ------ image output ------

  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
    println("saving to pdf – done");
  }

  if(saveOneFrame) {
    saveFrame(timestamp()+".png");
  }


  // ------ draw gui ------

  drawGUI();


  // ------ image output ------

  if(saveOneFrame) {
    if (controlP5.getGroup("menu").isOpen()) {
      saveFrame(timestamp()+"_menu.png");
    }
    saveOneFrame = false;
  }
}


// ------ subroutines ------

void drawLine(PVector[] points, int len, boolean curves) {
  // this funktion draws a line from an array of PVectors
  // len    : number of points to each side of the center index of the array
  //          example: array-length=21, len=5 -> points[5] to points[15] will be drawn
  // curves : if true, points will be connected with curves (a bit like curveVertex,
  //          not as accurate, but faster)

  PVector d1 = new PVector();
  PVector d2 = new PVector();
  float l1, l2, q0, q1, q2;

  // first and last index to be drawn
  int i1 = (points.length-1) / 2 - len;
  int i2 = (points.length-1) / 2 + len;

  // draw first point
  beginShape();
  vertex(points[i1].x, points[i1].y);
  q0 = 0.5;

  for (int i = i1+1; i <= i2; i++) {
    if (curves) {
      if (i < i2) {
        // distance to previous and next point
        l1 = PVector.dist(points[i], points[i-1]);
        l2 = PVector.dist(points[i], points[i+1]);
        // vector form previous to next point
        d2 = PVector.sub(points[i+1], points[i-1]);
        // shortening of this vector
        d2.mult(0.333);
        // how to distribute d2 to the anchors
        q1 = l1 / (l1+l2);
        q2 = l2 / (l1+l2);
      }
      else {
        // special handling for the last index
        l1 = PVector.dist(points[i], points[i-1]);
        l2 = 0;
        d2.set(0, 0, 0);
        q1 = l1 / (l1+l2);
        q2 = 0;
      }
      // draw bezierVertex
      // Specifies vertex coordinates for Bezier curves.
      // Each call to bezierVertex() defines the position of two control points
      //   and one anchor point of a Bezier curve, adding a new segment to a line or shape.
      bezierVertex(points[i-1].x+d1.x*q0, points[i-1].y+d1.y*q0,
      points[i].x-d2.x*q1, points[i].y-d2.y*q1,
      points[i].x, points[i].y);
      // remember d2 and q2 for the next iteration
      d1.set(d2);
      q0 = q2;
    }
    else {
      vertex(points[i].x, points[i].y);
    }
  }

  endShape();
}


void initGrid() {
  float xPos, yPos;
  Node n;

  for (int iz = 0; iz < 9; iz++) {
    for (int iy = 0; iy < maxCount*2+1; iy++) {
      for (int ix = 0; ix < maxCount*2+1; ix++) {
        xPos = (ix-maxCount)*gridStepX;
        yPos = (iy-maxCount)*gridStepY;

        if (nodes[iz][iy][ix] == null) {
          n = new Node(xPos, yPos, 0);
          n.minX = -20000;
          n.maxX = 20000;
          n.minY = -20000;
          n.maxY = 20000;
          n.minZ = 0;
          n.maxZ = 0;
        }
        else {
          n = nodes[iz][iy][ix];
          n.x = xPos;
          n.y = yPos;
          n.z = 0;
          n.velocity.x = 0;
          n.velocity.y = 0;
          n.velocity.z = 0;
        }

        n.damping = nodeDamping;

        nodes[iz][iy][ix] = n;
      }
    }
  }
}



// 放缩网格
void scaleGrid(float theFactorX, float theFactorY, float theFactorZ) {
  for (int iz = 0; iz < 9; iz++) {
    for (int iy = 0; iy < maxCount*2+1; iy++) {
      for (int ix = 0; ix < maxCount*2+1; ix++) {
        // 放大所有点的三个坐标
        nodes[iz][iy][ix].x *= theFactorX;
        nodes[iz][iy][ix].y *= theFactorY;
        nodes[iz][iy][ix].z *= theFactorZ;
      }
    }
  }
}

// 更新阻尼
void updateDamping() {
  for (int iz = 0; iz < 9; iz++) {
    for (int iy = 0; iy < maxCount*2+1; iy++) {
      for (int ix = 0; ix < maxCount*2+1; ix++) {
        nodes[iz][iy][ix].damping = nodeDamping;
      }
    }
  }
}



// ------ functions for reset and presets ------
// 重置颜色,GUI,网格,偏移,活动层为1
void reset() {
  colors = defaultColors;
  setParas(60, 150, 1, 10, 2, 250, 3, 1, 0.05, false, 1, 50, true, false, false, false, true, false);

  initGrid();

  offsetX = 0;
  offsetY = 0;

  setActLayer(0);
}

// 四个颜色集
void set1() {
  colors = new color[9];
  colors[0] = color(0, 130, 164);
  colors[1] = color(181, 157, 0);
  colors[2] = color(45, 137, 123);
  colors[3] = color(90, 144, 82);
  colors[4] = color(135, 150, 41);
  colors[5] = color(22, 133, 143);
  colors[6] = color(67, 140, 102);
  colors[7] = color(112, 147, 61);
  colors[8] = color(158, 153, 20);

  setParas(120, 120, 2, 3, 3, 150, 3, 1, 0.1, false, 1, 50, true, false, false, false, false, false);
  initGrid();
}

void set2() {
  colors = new color[1];
  colors[0] = color(0, 130, 164);

  setParas(100, 100, 1, 4, 4, 100, 3, 1, 0.1, true, 2, 75, true, false, false, true, false, false);
  initGrid();
}

void set3() {
  colorMode(HSB, 360, 100, 100, 100);
  colors = new color[3];
  for (int i = 0; i < 3; i++) {
    colors[i] = color(255);
  }
  colorMode(RGB, 255, 255, 255, 100);

  setParas(4, 150, 3, 70, 3.5, 400, 5, 1, 0.1, true, 1, 50, true, true, false, false, false, false);
  initGrid();
}

void set4() {
  colorMode(HSB, 360, 100, 100, 100);
  colors = new color[3];

  colors[0] = color(273, 73, 51);
  colors[1] = color(52, 100, 71);
  colors[2] = color(192, 100, 64);

  colorMode(RGB, 255, 255, 255, 100);

  setParas(130, 3, 3, 4, 100, 600, 3, 1, 0.1, false, 1, 50, false, true, false, false, false, false);
  initGrid();
}

// 设置 GUI 的初始化值
void setParas(int theXCount, int theYCount, int theLayerCount, float theGridStepX, float theGridStepY,
float theAttractorRadius, float theAttractorStrength, float theAttractorRamp, float theNodeDamping,
boolean theInvertBackground, float theLineWeigth, float theLineAlpha, boolean theDrawX, boolean theDrawY, boolean theDrawCurves, boolean theAttractorTwirl,
boolean theLockX, boolean theLockY) {

  Toggle t;

  controlP5.getController("xCount").setValue(theXCount);
  controlP5.getController("yCount").setValue(theYCount);
  controlP5.getController("layerCount").setValue(theLayerCount);
  oldXCount = theXCount;
  oldYCount = theYCount;
  oldLayerCount = layerCount;

  controlP5.getController("gridStepX").setValue(theGridStepX);
  controlP5.getController("gridStepY").setValue(theGridStepY);

  controlP5.getController("attractorRadius").setValue(theAttractorRadius);
  controlP5.getController("attractorStrength").setValue(theAttractorStrength);
  controlP5.getController("attractorRamp").setValue(theAttractorRamp);
  controlP5.getController("nodeDamping").setValue(theNodeDamping);

  if (invertBackground != theInvertBackground) {
    t = (Toggle) controlP5.getController("invertBackground");
    t.setState(theInvertBackground);
  }
  controlP5.getController("lineWeight").setValue(theLineWeigth);
  controlP5.getController("lineAlpha").setValue(theLineAlpha);
  if (drawX != theDrawX) {
    t = (Toggle) controlP5.getController("drawX");
    t.setState(theDrawX);
  }
  if (drawY != theDrawY) {
    t = (Toggle) controlP5.getController("drawY");
    t.setState(theDrawY);
  }

  if (lockX != theLockX) {
    t = (Toggle) controlP5.getController("lockX");
    t.setState(theLockX);
  }
  if (lockY != theLockY) {
    t = (Toggle) controlP5.getController("lockY");
    t.setState(theLockY);
  }


  boolean theDrawLines = !theDrawCurves;
  if (drawLines != theDrawLines) {
    t = (Toggle) controlP5.getController("drawLines");
    t.setState(theDrawLines);
    drawLines = theDrawLines;
  }
  if (drawCurves != theDrawCurves) {
    t = (Toggle) controlP5.getController("drawCurves");
    t.setState(theDrawCurves);
    drawCurves = theDrawCurves;
  }

  boolean theAttractorSmooth = !theAttractorTwirl;
  if (attractorSmooth != theAttractorSmooth) {
    t = (Toggle) controlP5.getController("attractorSmooth");
    t.setState(theAttractorSmooth);
    attractorSmooth = theAttractorSmooth;
  }
  if (attractorTwirl != theAttractorTwirl) {
    t = (Toggle) controlP5.getController("attractorTwirl");
    t.setState(theAttractorTwirl);
    attractorTwirl = theAttractorTwirl;
  }
}


void setActLayer(int theLayer) {
  actLayer = theLayer;
  // -1 的话就显示取值-1可能是考虑: 0x0000 - 0x0001 = 0xffff
  if (theLayer == -1) {
    infoBang.setLabel("Currently affected layer: all");
    for (int i = 0; i < 9; i++) {
      freezeLayer(i);
    }
  }
  else {
    // 右上角的提示信息
    infoBang.setLabel("Currently affected layer: " + (theLayer+1));
    freezeLayer(actLayer);
  }
}

// 冻结某一层
void freezeLayer(int iz) {
  Node n;
  for (int iy = 0; iy < maxCount*2+1; iy++) {
    for (int ix = 0; ix < maxCount*2+1; ix++) {
      // 指向 PVector 的指针
      n = nodes[iz][iy][ix];
      // velocity 个方向设为0, 也就是不再变化
      n.velocity.x = 0;
      n.velocity.y = 0;
      n.velocity.z = 0;
    }
  }
}


// ------ key and mouse events ------

void keyPressed(){
  if(key=='m' || key=='M') {
    GUI = controlP5.getGroup("menu").isOpen();
    GUI = !GUI;
  }
  if (GUI) controlP5.getGroup("menu").open();
  else controlP5.getGroup("menu").close();

  if(key=='r' || key=='R') {
    // reset();
    initGrid();
    guiEvent = false;
  }
  if(key=='s' || key=='S') {
    saveOneFrame = true;
  }
  if(key=='p' || key=='P') {
    savePDF = true;
    saveOneFrame = true;
    println("saving to pdf - starting (this may take some time)");
  }
  // 空格键 控制冻结
  if(key==' ') {
    freeze = !freeze;
    if (freeze) noLoop();
    else loop();
  }
  // 激活某一层
  int k = int(key)-49;
  if (k>=0 && k<9 && k<layerCount) {
    setActLayer(k);
  }
  if (key=='0') {
    setActLayer(-1);
  }
}


void mousePressed(){
  if (mouseButton==RIGHT) {
    dragging = true;
    clickX = mouseX;
    clickY = mouseY;
    clickOffsetX = offsetX;
    clickOffsetY = offsetY;
  }
}


void mouseReleased() {
  guiEvent = false;
  dragging = false;
}



void mouseEntered(MouseEvent e) {
  mouseInWindow = true;
  loop();
}

void mouseExited(MouseEvent e) {
  mouseInWindow = false;
  noLoop();
}



String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}

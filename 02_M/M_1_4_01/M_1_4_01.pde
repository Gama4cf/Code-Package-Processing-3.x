// M_1_4_01.pde
// TileSaver.pde
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
 * creates a terrain like mesh based on noise values.
 *
 * MOUSE
 * position x/y + left drag   : specify noise input range
 * position x/y + right drag  : camera controls
 *
 * KEYS
 * l                          : toogle display strokes on/off
 * arrow up                   : noise falloff +
 * arrow down                 : noise falloff -
 * arrow left                 : noise octaves -
 * arrow right                : noise octaves +
 * space                      : new noise seed
 * +                          : zoom in
 * -                          : zoom out
 * s                          : save png
 * p                          : high resolution export (please update to processing 1.0.8 or
 *                              later. otherwise this will not work properly)
 */

import processing.opengl.*;
import java.util.Calendar;


// ------ 网 ------
int tileCount = 1;
// Z 轴放缩尺度
int zScale = 150;

// ------ 噪声 ------
int noiseXRange = 10;
int noiseYRange = 10;
int octaves = 4;
float falloff = 0.5;

// ------ 网格颜色 ------
color midColor, topColor, bottomColor;
color strokeColor;

// 噪声阈值
float threshold = 0.30;

// ------ 鼠标交互 ------
int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0, zoom = -280;
// 鼠标控制旋转 X Z 两轴方向
// 初始旋转角度: X 轴转 -PI/3
float targetRotationX = -PI/3, targetRotationZ = 0, clickRotationX, clickRotationZ;
// 这两个参数省略, 参数太多有些乱了, 实在想减慢速度可以考虑扩大(-PI/2, PI/2)限制范围
// float rataionX = 0, rotationZ = 0;

// ------ 图像输出 ------
int qualityFactor = 4;
TileSaver tiler;
boolean showStroke = true;


void setup() {
  size(700, 700, P3D);
  colorMode(HSB, 360, 100, 100);
  tiler = new TileSaver(this);
  cursor(CROSS);

  // colors
  topColor = color(0, 0, 100);
  midColor = color(191, 99, 63);
  bottomColor = color(0, 0, 0);

  strokeColor = color(0, 0, 0);
}


void draw() {
  if (tiler==null) return;
  tiler.pre();
  // 是否显示边
  if (showStroke) stroke(strokeColor);
  else noStroke();

  background(0, 0, 100);
  // Sets the default ambient light, directional light, falloff, and specular values.
  // The defaults are ambientLight(128, 128, 128) and directionalLight(128, 128, 128, 0, 0, -1),
  //   lightFalloff(1, 0, 0), and lightSpecular(0, 0, 0).
  lights();


  // ------ set view ------
  pushMatrix();
  translate(width*0.5, height*0.5, zoom);
  // 如果鼠标右键按下了 那么计算新的旋转角
  if (mousePressed && mouseButton==RIGHT) {
    // 这个偏移计算的是 点击鼠标的位置 和 现在鼠标位置 之间的偏移
    offsetX = mouseX-clickX;
    offsetY = mouseY-clickY;
    // 计算目标旋转角度: 需要注意的是 这个目标旋转角度 是相对于最初始状态的, 也就是不旋转状态的
    // X 轴方向上限制最大转 HALF/PI , 最小转 -HALF/PI
    targetRotationX = min(max(clickRotationX + offsetY/float(width) * TWO_PI, -HALF_PI), HALF_PI);
    // Z 轴方向上旋转角度 跟随鼠标
    targetRotationZ = clickRotationZ + offsetX/float(height) * TWO_PI;
  }
  // *0.25 的作用在于 鼠标控制速度不宜过快不然手抖看不清
  // 先减后加看起来没有意义, 还是有必要的
  //    (targetRotationX-rotationX)*0.25 是在上次旋转基础上再次旋转的幅度
  // rotationX += (targetRotationX-rotationX)*0.25;
  // rotationZ += (targetRotationZ-rotationZ)*0.25;
  // 直接省略上面的计算, 用 targetRotationXZ 也能达到目的
  rotateX(-targetRotationX);
  rotateZ(-targetRotationZ);


  // ------ mesh noise ------
  // 鼠标左键控制噪声的幅度
  if (mousePressed && mouseButton==LEFT) {
    noiseXRange = mouseX/10;
    noiseYRange = mouseY/10;
  }
  // 噪声生成的初始值
  noiseDetail(octaves, falloff);
  float noiseYMax = 0;

  float tileSizeY = (float)height/tileCount;
  // 噪声的步进, 越大那么峰越陡, 越小那峰越缓
  float noiseStepY = (float)noiseYRange/tileCount;

  for (int meshY=0; meshY<=tileCount; meshY++) {
    // 每一行是一个 Shape ,这个 Shape 由很多个三角形组成条状
    beginShape(TRIANGLE_STRIP);
    for (int meshX=0; meshX<=tileCount; meshX++) {
      // 每个瓷砖左上角点的坐标
      float x = map(meshX, 0, tileCount, -width/2, width/2);
      float y = map(meshY, 0, tileCount, -height/2, height/2);
      // 根据原本 X Y 两轴的影响, 生成 Z 轴中噪声
      float noiseX = map(meshX, 0, tileCount, 0, noiseXRange);
      float noiseY = map(meshY, 0, tileCount, 0, noiseYRange);
      float z1 = noise(noiseX, noiseY);
      // 在这里增加 noiseStepY , 这样
      float z2 = noise(noiseX, noiseY+noiseStepY);

      noiseYMax = max(noiseYMax, z1);
      color interColor;
      colorMode(RGB);
      // 颜色根据高度生成
      if (z1 <= threshold) {
        float amount = map(z1, 0, threshold, 0.15, 1);
        interColor = lerpColor(bottomColor, midColor, amount);
      }
      else {
        float amount = map(z1, threshold, noiseYMax, 0, 1);
        interColor = lerpColor(midColor, topColor, amount);
      }
      colorMode(HSB, 360, 100, 100);
      fill(interColor);
      // 这里只有两个点, 这两个点是: 左上角点和与左上角相邻的下面的点
      // 根据柏林噪声, 传入相同的参数,生成相同的值
      vertex(x, y, z1*zScale);
      // 这个点, 在第二次绘制的时候 绘制的位置是重合的
      vertex(x, y+tileSizeY, z2*zScale);
    }
    endShape();
  }
  popMatrix();

  tiler.post();
}
// 鼠标按下之后的触发事件
void mousePressed() {
  // 点击位置设置为鼠标位置
  clickX = mouseX;
  clickY = mouseY;
  // 保存点击时刻的旋转角度 前面加上click
  // 其实参数 clickRotationX, clickRotationZ 用处不大,都换成 rotationX, rotationZ 也是可以的...
  clickRotationX = targetRotationX;
  clickRotationZ = targetRotationZ;
}

void keyPressed() {
  if (keyCode == UP) falloff += 0.05;
  if (keyCode == DOWN) falloff -= 0.05;
  if (falloff > 1.0) falloff = 1.0;
  if (falloff < 0.0) falloff = 0.0;
  // 八度音阶 增减
  if (keyCode == LEFT) octaves--;
  if (keyCode == RIGHT) octaves++;
  if (octaves < 0) octaves = 0;
  // 镜头 拉近和推远
  if (key == '+') zoom += 20;
  if (key == '-') zoom -= 20;
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_####.png");
  if (key == 'p' || key == 'P') tiler.init(timestamp()+".png", qualityFactor);
  if (key == 'l' || key == 'L') showStroke = !showStroke;
  if (key == ' ') noiseSeed((int) random(100000));
}

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}

// M_1_6_01_TOOL.pde
// Agent.pde, GUI.pde, Ribbon3d.pde, TileSaver.pde
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

class Agent {
  boolean isOutside = false;
  PVector p;
  float offset, stepSize, angleY, angleZ;
  // 每个中间件都有一个 Ribbon3d 对象, 用这个它来画线
  Ribbon3d ribbon;

  Agent() {
    p = new PVector(0, 0, 0);
    setRandomPostition();
    offset = 10000;
    stepSize = random(1, 8);
    // how many points has the ribbon: 随机数
    ribbon = new Ribbon3d(p, (int)random(50, 300));
  }

  void update(){
    // 使用噪声 生成一个 Y Z 轴角度
    angleY = noise(p.x/noiseScale, p.y/noiseScale, p.z/noiseScale) * noiseStrength;
    // 加一个偏移, 防止生成相同的noise
    angleZ = noise(p.x/noiseScale+offset, p.y/noiseScale, p.z/noiseScale) * noiseStrength;

    /* convert polar to cartesian coordinates
     stepSize is distance of the point to the last point
     angleY is the angle for rotation around y-axis
     angleZ is the angle for rotation around z-axis
     */
    p.x += cos(angleZ) * cos(angleY) * stepSize;
    p.y += sin(angleZ) * stepSize;
    p.z += cos(angleZ) * sin(angleY) * stepSize;

    // boundingbox wrap
    if (p.x<-spaceSizeX || p.x>spaceSizeX ||
      p.y<-spaceSizeY || p.y>spaceSizeY ||
      p.z<-spaceSizeZ || p.z>spaceSizeZ) {
      // 出了范围 产生一个随机位置
      setRandomPostition();
      // 标记已出边界
      isOutside = true;
    }

    // 更新 ribbon
    ribbon.update(p,isOutside);
    isOutside = false;
  }

  void draw() {
    // 仅画线
    ribbon.drawLineRibbon(agentColor,2.0);
    //ribbon.drawMeshRibbon(agentColor,10.0);
  }
  // 生成一个随机位置
  void setRandomPostition() {
    p.x=random(-spaceSizeX,spaceSizeX);
    p.y=random(-spaceSizeY,spaceSizeY);
    p.z=random(-spaceSizeZ,spaceSizeZ);
  }
}

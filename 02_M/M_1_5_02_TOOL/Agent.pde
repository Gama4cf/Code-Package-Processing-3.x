// M_1_5_02_TOOL.pde
// Agent.pde, GUI.pde
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
  // PVector: A class to describe a two or three dimensional vector 在欧式空间
  PVector p, pOld;
  float stepSize, angle;
  boolean isOutside = false;

  Agent() {
    // p 和 pOld  相同的随机向量
    p = new PVector(random(width),random(height));
    pOld = new PVector(p.x,p.y);
    // 步进 1-5 之间
    stepSize = random(1,5);
  }

  void update1(){
    // 角度根据坐标生成, 相同位置生成相同的角度  容易汇聚成流
    angle = noise(p.x/noiseScale,p.y/noiseScale) * noiseStrength;
    // 计算新的向量终点
    p.x += cos(angle) * stepSize;
    p.y += sin(angle) * stepSize;
    // 检测是否出了边界
    if(p.x<-10) isOutside = true;
    else if(p.x>width+10) isOutside = true;
    else if(p.y<-10) isOutside = true;
    else if(p.y>height+10) isOutside = true;
    // 出了边界的 放回
    if (isOutside) {
      p.x = random(width);
      p.y = random(height);
      // 并且新的向量的起点pOld 依然设置为和 p 相同
      pOld.set(p);
    }

    strokeWeight(strokeWidth*stepSize);
    // 新旧两点连成线
    line(pOld.x,pOld.y, p.x,p.y);
    // 新点变旧点 向量终点变为起点
    pOld.set(p);

    isOutside = false;
  }

  void update2(){
    // 这种计算角度的方法 导致 有些位置 角度一直为 0
    // 当有向量走到这个位置的时候 便会驻留下来
    angle = noise(p.x/noiseScale,p.y/noiseScale) * 24;
    angle = (angle - int(angle)) * noiseStrength;

    p.x += cos(angle) * stepSize;
    p.y += sin(angle) * stepSize;

    if(p.x<-10) isOutside = true;
    else if(p.x>width+10) isOutside = true;
    else if(p.y<-10) isOutside = true;
    else if(p.y>height+10) isOutside = true;

    if (isOutside) {
      p.x = random(width);
      p.y = random(height);
      pOld.set(p);
    }

    strokeWeight(strokeWidth*stepSize);
    line(pOld.x,pOld.y, p.x,p.y);

    pOld.set(p);

    isOutside = false;
  }
}

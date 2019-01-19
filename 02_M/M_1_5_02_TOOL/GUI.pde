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

void setupGUI(){
  color activeColor = color(0,130,164);
  // Create a new instance of controlP5.
  // java.lang.Object controlP5.ControlP5Legacy.ControlP5Base.ControlP5
  controlP5 = new ControlP5(this);
  //controlP5.setAutoDraw(false);
  // 设置颜色
  controlP5.setColorActive(activeColor);
  controlP5.setColorBackground(color(170));
  controlP5.setColorForeground(color(50));
  controlP5.setColorCaptionLabel(color(50));
  controlP5.setColorValueLabel(color(255));
  // Group	addGroup(java.lang.String theName, int theX, int theY, int theW)
  // java.lang.Object.controlP5.ControllerGroup<T>.ControlGroup<Group>.Group
  ControlGroup ctrl = controlP5.addGroup("menu",15,25,35);
  ctrl.setColorLabel(color(255));
  ctrl.close();
  // 初始化滑杆, 在这里的滑杆还都没有加入到 controlP5 中
  sliders = new Slider[10];
  // 各种坐标参数
  int left = 0;
  int top = 5;
  int len = 300;

  int si = 0;
  int posY = 0;
  // Slider	addSlider(java.lang.String theName, float theMin, float theMax, int theX, int theY, int theWidth, int theHeight)
  // java.lang.String theName 都是已经定义的变量名
  sliders[si++] = controlP5.addSlider("agentsCount",1,10000,left,top+posY+0,len,15);
  posY += 30;
  sliders[si++] = controlP5.addSlider("noiseScale",1,1000,left,top+posY+0,len,15);
  sliders[si++] = controlP5.addSlider("noiseStrength",0,100,left,top+posY+20,len,15);
  posY += 50;
  sliders[si++] = controlP5.addSlider("strokeWidth",0,10,left,top+posY+0,len,15);
  posY += 30;
  sliders[si++] = controlP5.addSlider("agentsAlpha",0,255,left,top+posY+0,len,15);
  sliders[si++] = controlP5.addSlider("overlayAlpha",0,255,left,top+posY+20,len,15);

  for (int i = 0; i < si; i++) {
    // public final T setGroup(ControllerGroup<?> theGroup)
    // 滑杆在这里循环加入 controlP5 中的 ControlGroup ctrl
    sliders[i].setGroup(ctrl);
    // 在类 Label 中
    sliders[i].getCaptionLabel().toUpperCase(true);
    // R G B alpha 
    sliders[i].getCaptionLabel().setColorBackground(0x99ffffff);
    // 在类 ControllerStyle 中
    sliders[i].getCaptionLabel().getStyle().padding(4,3,3,3);
    sliders[i].getCaptionLabel().getStyle().marginTop = -4;
    sliders[i].getCaptionLabel().getStyle().marginLeft = 0;
    sliders[i].getCaptionLabel().getStyle().marginRight = -14;
  }

}

void drawGUI(){
  // shows all controllers and tabs in your sketch.
  controlP5.show();
  // call draw() from your program when autoDraw is disabled.
  controlP5.draw();
}

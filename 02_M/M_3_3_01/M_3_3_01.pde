// M_3_3_01.pde
// Mesh.pde
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
 * example how to use the mesh class
 */

import processing.opengl.*;
import java.util.Calendar;


void setup() {
  size(720, 720,P3D);

  // setup drawing style
  background(255);
  noStroke();
  fill(0);

  // setup lights
  // Sets the specular color for lights.
  // Like fill(), it affects only the elements which are created after it in the code.
  lightSpecular(230, 230, 230);
  // Adds a directional light. Directional light comes from one direction:
  //  it is stronger when hitting a surface squarely, and weaker if it hits at a gentle angle.
  directionalLight(200, 200, 200, -0.25, -0.25, 1);
  directionalLight(200, 200, 200, 0.25, 0.25, -1);
  // Sets the specular color of the materials used for shapes drawn to the screen, which sets the color of highlights.
  specular(color(200));
  // Sets the amount of gloss in the surface of shapes.
  //  Used in combination with ambient(), specular(), and emissive() in setting the material properties of shapes.
  shininess(5.0);

  // setup view
  translate(width*0.5, height*0.5);
  rotateX(-0.2);
  rotateY(-0.5);
  scale(100);


  // setup Mesh, set colors and draw
  // Mesh(int theForm, int theUNum, int theVNum, float theUMin, float theUMax, float theVMin, float theVMax)
  // Steinbach Screw: http://mathworld.wolfram.com/SteinbachScrew.html
  Mesh myMesh = new Mesh(Mesh.STEINBACHSCREW, 200, 200, -3, 3, -PI, PI);
  myMesh.setColorRange(192, 192, 50, 50, 50, 50, 100);
  myMesh.draw();


  // save image
  saveFrame(timestamp()+".png");
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}

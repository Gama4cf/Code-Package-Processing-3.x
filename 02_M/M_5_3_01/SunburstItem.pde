// M_5_3_01.pde
// FileSystemItem.pde, SunburstItem.pde
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

class SunburstItem {
  File file;

  // relations
  int depth;
  int index;
  int indexToParent;
  int childCount;

  // meta file informations
  String name;
  boolean isDir;
  int lastModified; // age of the file in days
  float fileSize;
  float folderMinFilesize; // biggest an smallest file in the same folder
  float folderMaxFilesize;

  // arc and lines drawing vars
  color col;
  float lineWeight;
  float angleStart, angleCenter, angleEnd;
  float extension;
  float radius;
  float depthWeight; // stroke weight of the arc
  float x,y;
  float arcLength;
  float c1X,c1Y,c2X,c2Y; // bezier controlpoints

  // ------ constructor ------
  SunburstItem( int theIndex, int theIndexToParent, int theChildCount,
                int theDepth, float theFileSize, int theLastModified,
                File theFile, float theAngle, float theExtension,
                float theFolderMinFilesize, float theFolderMaxFilesize) {

    this.depth = theDepth;
    this.index = theIndex;
    this.indexToParent = theIndexToParent;

    this.file = theFile;
    this.name = file.getName();
    this.isDir = file.isDirectory();
    this.lastModified = theLastModified;
    this.fileSize = theFileSize;
    this.childCount = theChildCount;
    this.folderMinFilesize = theFolderMinFilesize;
    this.folderMaxFilesize = theFolderMaxFilesize;

    // sunburst angles and extension
    this.angleStart = theAngle;
    this.extension = theExtension;
    this.angleCenter = theAngle + theExtension/2;
    this.angleEnd = theAngle + theExtension;
  }



  // ------ update function, called only when the input files are changed ------
  void update(int theMappingMode) {
    if (indexToParent > -1) {
      radius = calcEqualAreaRadius(depth,depthMax);
      depthWeight = calcEqualAreaRadius(depth+1,depthMax) - radius;
      x  = cos(angleCenter) * radius;
      y  = sin(angleCenter) * radius;

      // chord
      float startX  = cos(angleStart) * radius;
      float startY  = sin(angleStart) * radius;
      float endX  = cos(angleEnd) * radius;
      float endY  = sin(angleEnd) * radius;
      arcLength = dist(startX,startY, endX,endY);

      // color mapings
      float percent = 0;
      switch(theMappingMode) {
      case 1:
        percent = norm(lastModified, lastModifiedOldest, lastModifiedYoungest);
        break;
      case 2:
        percent = norm(fileSize, fileSizeMin, fileSizeMax);
        break;
      case 3:
        percent = norm(fileSize, folderMinFilesize, folderMaxFilesize);
        break;
      }

      // colors for files and folders
      if (isDir) {
        float bright = lerp(folderBrightnessStart,folderBrightnessEnd,percent);
        col = color(0,0,bright);
      }
      else {
        color from = color(hueStart, saturationStart, brightnessStart);
        color to = color(hueEnd, saturationEnd, brightnessEnd);
        col = lerpColor(from, to, percent);
      }
    }
  }


  // ------ draw functions ------
  void drawArc(float theFolderScale, float theFileScale) {
    float arcRadius;
    if (depth > 0 ) {
      if (isDir) {
        strokeWeight(depthWeight * theFolderScale);
        arcRadius = radius + depthWeight*theFolderScale/2;
      }
      else {
        strokeWeight(depthWeight * theFileScale);
        arcRadius = radius + depthWeight*theFileScale/2;
      }
      stroke(col);
      // print("0 "+"0 "+arcRadius+" "+arcRadius+" "+angleStart+" "+ angleEnd+" \n");
      // In some cases, the arc() function isn't accurate enough for smooth drawing.
      // For example, the shape may jitter on screen when rotating slowly.
      // If you're having an issue with how arcs are rendered,
      // you'll need to draw the arc yourself with beginShape()/endShape() or a PShape.
      // 在这里, 当文件非常多且占比很低的时候, 出现了奇怪的状况???
      arc(0,0, arcRadius,arcRadius, angleStart, angleEnd);
    }
  }



}

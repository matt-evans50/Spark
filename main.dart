library SparkProject;

import 'dart:html';
import 'dart:math';
//import "package:json_object/json_object.dart";
import 'dart:convert';
import 'dart:core';
import 'package:intl/intl.dart'; //this is for number format for AR tags
import 'dart:web_audio';

part 'darts/Touch.dart';
part 'darts/toolbar.dart';
part 'darts/model.dart';
part 'darts/sounds.dart';
part 'darts/slider.dart';
part 'darts/help.dart';
part 'darts/Lens.dart';
part 'darts/connectServer.dart';

part 'circuitAnalysis/Circuit.dart';
//part 'circuitAnalysis/GraphNode.dart';
part 'circuitAnalysis/Matrix.dart';
part 'circuitAnalysis/LUDecomposition.dart';
part 'circuitAnalysis/QRDecomposition.dart';
part 'circuitAnalysis/KVLSolver.dart';

part 'components/ControlPoint.dart';
part 'components/Component.dart';
part 'components/Wire.dart';
part 'components/Battery.dart';
part 'components/Resistor.dart';
part 'components/Bulb.dart';

App theApp;


void main() {
  // Load sound effects
  Sounds.loadSound("crunch");
  Sounds.loadSound("ping");
  Sounds.loadSound("ding");
  
  new App();
   //test();  
    /* update the valuse of the generic slider, whenever it is changed */
    InputElement slider = document.querySelector("#generic-slider");
    if (slider != null) {
      slider.onChange.listen((e) => genericChangeValue(double.parse(slider.value)));
      slider.onTouchMove.listen((e) => genericSliderTouch(e));
      slider.onTouchEnd.listen((e) => genericChangeValue(double.parse(slider.value)));
    }
  
}


class App extends TouchManager {

   CanvasRenderingContext2D ctx;
   CanvasElement canvas;

   int width;
   int height;
  
   String id = "circuit";
   List<Component> components;
   List<ControlPoint> controlPoints;
   int ARTagCounter;
   ImageElement deleteBox;
   Circuit circuit;
   Toolbar selectionBar; 
   Toolbar editionBar;
   Model model1;
   Component genericSliderComponent;
   Help help;
   
   int canvasMargin = 5;
   Rectangle workingBox;
   Rectangle containerBox;
   bool gridsOn;
   
   Lens lens;
   
   App() {
     
     theApp = this;
     /* size of the monitor */
     width = window.innerWidth;
     height = window.innerHeight;
     canvas = document.querySelector("#foreground");
     canvas.width = width;
     canvas.height = height;
     ctx = canvas.getContext("2d");
     
     registerEvents(canvas);     
     window.onResize.listen((evt) => resizeScreen());
     // Add the app itself as a touchable object
     new Screen();
     circuit = new Circuit();
     components = new List<Component>();
     controlPoints = new List<ControlPoint>();
     //selectionBar = new Toolbar(this, "div#${this.id}-toolbar"); this is older version for index.html "circuit-toolbar"
     selectionBar = new Toolbar(this, "div#selection-toolbar");
     editionBar = new Toolbar(this, "div#edition-toolbar");
     
     model1 = new Model(this, "div#model1");

     
     lens = new Lens(690, 690);
     help = new Help(1100, 420);

     ARTagCounter = 0;
     gridsOn = false;
     
     /* delete box */
     deleteBox = new ImageElement();
     deleteBox.src = "images/trash-bin.png";
     deleteBox.onLoad.listen((event) { draw(); });

     num centerX = (width - 530)/2;
     num centerY = height/2;
     InputElement slider = querySelector("#battery-slider");
     var voltage = double.parse(slider.value);
     components.add(new Battery(centerX - 50, centerY, centerX + 50, centerY, voltage));
    
     var t = 65;
   }
   /* Resize the window
    */
   void resizeScreen() {
     width = window.innerWidth;
     height = window.innerHeight;
     
//     CssRect toolbarRect = document.query("#selection-toolbar").borderEdge; 
//     canvas.width = width - (2*canvasMargin);
//     canvas.height = toolbarRect.top.toInt() -(2*canvasMargin);
     canvas.width = width;
     canvas.height = height;
     
    repaint();
   }

   
   /*
    * Reset the application
    */
   void reset() {
     ARTagCounter = 0;
     components.clear();
     controlPoints.clear();
     circuit.edges.clear();
     circuit.nodes.clear();
     circuit.updateComponents();
     circuit.sendDataToServer();
     document.querySelector("#model1").style.display = "none";
     document.querySelector("#generic-slider").style.display = "none";
     model1.component = null;
     help.visible = false;
     lens.x = 690;
     lens.y = 690;
     //toolbar.update();
     //draw();

     num centerX = workingBox.width/2;
     num centerY = workingBox.height/2;
     /* create the first battery */
     InputElement slider = querySelector("#battery-slider");
     var voltage = double.parse(slider.value);
     components.add(new Battery(centerX - 50, centerY, centerX + 50, centerY, voltage));
   }


   void draw() {
     CssRect toolbarRect = document.querySelector("#selection-toolbar").borderEdge; 
     containerBox = new Rectangle(canvasMargin, canvasMargin,width - (4*canvasMargin), toolbarRect.top -(3*canvasMargin));
     workingBox = new Rectangle(canvasMargin, canvasMargin,width - 530, toolbarRect.top -(3*canvasMargin));
     
     ctx.clearRect(0, 0, canvas.width, canvas.height);
     //ctx.save();
//     ctx.fillStyle = "rgba(250,250,250,0.8)";
//     ctx.textAlign = 'left';
//     ctx.textBaseline = 'top';
//     ctx.font = '34px sans-serif'; /* other fonts: verdana */
//     ctx.fillText("SPARK", 20, 20);
     
     ctx.strokeStyle = 'black';
     
//     ctx.strokeRect(0, 0, canvas.width, canvas.height);
//     ctx.fillRect(0, 0, canvas.width, canvas.height);
     ctx.lineWidth = 3;
     ctx.fillStyle = "rgba(255,255,255,0)";
     //ctx.strokeRect(containerBox.left, containerBox.top, containerBox.width, containerBox.height);
     ctx.fillRect(containerBox.left, containerBox.top, containerBox.width, containerBox.height);
     ctx.lineWidth = 2;
     ctx.fillStyle = "rgba(255,255,255,0.2)";
     ctx.strokeRect(workingBox.left, workingBox.top, workingBox.width, workingBox.height);
     ctx.fillRect(workingBox.left, workingBox.top, workingBox.width, workingBox.height);
     /*
     if (this.gridsOn == true) {
       drawGrids (margin, margin, width - (3*margin), rect.top.toInt() - (2*margin));
     }
     */
     

     
     num boxW = deleteBox.width / 7;
     num boxH = deleteBox.height / 7;
     //ctx.drawImageScaled(deleteBox, width - (3 * canvasMargin + boxW) , 2*canvasMargin, boxW, boxH);
     ctx.drawImageScaled(deleteBox, 2 * canvasMargin, 2*canvasMargin, boxW, boxH);
     
     /* redraw the components */
     for (Component c in components) {
       if (c.visible) c.draw(ctx);
     }
     lens.draw(ctx);
     help.draw(ctx);
     //ctx.restore();
     
   }
   
   void drawGrids (int sx, int sy, int w, int h) {
     int x = sx + 20;
     int y = sy + 20;
     while (h - y > 0) {
       while (w - x > 0) {
         drawGridNode(x, y);
         x = x + 100;
       }
       x = sx + 20;
       y = y + 100; 
     }
     //ctx.restore();
   }
   
   void drawGridNode (int x, int y) {
     ctx.beginPath();
     ctx.moveTo(x, y);
     ctx.fillStyle = "white";
     ctx.arc(x, y, 3, 0, PI * 2, true);
     ctx.fill();
     ctx.arc(x, y, 5, 0, PI * 2, true);
     ctx.fillStyle = "rgba(255,255,255,0.5)";
     ctx.fill();
   }


   static void repaint() {
     /* make sure that the lens is always on top of all other touchables */
     theApp.removeTouchable(theApp.lens);
     theApp.addTouchable(theApp.lens);
     theApp.draw();
   }
   
}

class GridNode {
  
  int row, column;
  int x, y;
  //App app;
  
  GridNode (int r, int c) {
    this.row = r;
    this.column = c;
    //this.app = app;
    theApp.drawGridNode(x, y);
  }
  
}



class Screen implements Touchable {

   Screen() {
      theApp.addTouchable(this);
   }

   bool containsTouch(Contact event) {
     return true;
   }

   bool touchDown(Contact event) {
//     //TOUCH MODE
//     if (event.tag) {
//       num ty = event.touchY;
//       num tx = event.touchX;
//       if (event.tagId == Wire.TAG) {
//         theApp.components.add(new Wire(tx - 50, ty, tx + 50, ty));
//       }
//       else if (event.tagId == Battery.TAG) {
//         theApp.components.add(new Battery(tx - 50, ty, tx + 50, ty));         
//         
//       }
//       else if (event.tagId == Bulb.TAG){
//         theApp.components.add(new Bulb(tx - 50, ty, tx + 50, ty));         
//       }
//       else if (event.tagId == Resistor.TAG){
//         theApp.components.add(new Resistor(tx - 50, ty, tx + 50, ty));         
//       } 
//
//     }
     // MOUSE MODE
//     num ty = event.touchY;
//     num tx = event.touchX;
//     if (theApp.components.length %2 == 1) {
//       theApp.components.add(new Bulb(tx - 50, ty, tx + 50, ty));
//     }
//     else {
//       theApp.components.add(new Resistor(tx - 50, ty, tx + 50, ty));// THIS 50 CAN BE REPLACED WITH A CONT. VARIABLE.
//     }
     document.querySelector("#generic-slider").style.display = "none";
     App.repaint();
     return true;
   }

   void touchUp(Contact event) {
     //App.repaint();
   }

   void touchDrag(Contact event) {
   }

   void touchSlide(Contact event) {

   }

}





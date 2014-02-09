import 'dart:html';
import 'dart:math';
import 'NetTangoJS/core/ntango.dart';
import 'core/spark.dart';
import 'package:intl/intl.dart'; //this is for number format for AR tags

void main() {

  /* get the input values from the url */
  String querystring = window.location.search.replaceFirst("?", "");
  List<String> list = querystring.split("&");
  num v;
  num r;
  num i;
  for (String param in list) {
    if (param.startsWith("v=")) {
      v = double.parse(param.substring(2));
      //window.alert("Set voltage to v");
    }
    else if (param.startsWith("r=")) {
      r = double.parse(param.substring(2));
    }
    else if (param.startsWith("i=")) {
      i = double.parse(param.substring(2));
    }
  }
  
  var iFormated = new NumberFormat("#0.00").format(i);
  var vFormated = new NumberFormat("#0.00").format(v);
  var rFormated = new NumberFormat("#0.0").format(r);
  
  ParagraphElement p = new ParagraphElement();
  p = document.querySelector("#voltage-value");
  p.text = "Voltage Drop = ${vFormated}";
  
  p = document.querySelector("#current-value");
  p.text = "Current = ${iFormated}";
  
  p = document.querySelector("#resistance-value");
  p.text = "Resistance = ${rFormated}";
 
  ResistorModel model = new ResistorModel(v, r);
  model.restart();
  model.play(1);
  
}

class ResistorModel extends SparkModel { 
  num resistance;
  int resistivity;
  ResistorModel(num voltage, num resistance) : super('Resistor', 'resistor'){ 
    initE = 0.1;
    decE = 0.01;
    
    this.voltage = voltage / 100;
    this.resistance = resistance;
    //resistivity = resistance + 1; 
    diameter = 3;
    incE = 0.04;
    /*
    if (resistance < 2) {
      diameter = 5;
      incE = 0.03;
    }
    else if (resistance < 3) {
      diameter = 3;
      incE = 0.04;
    }
    else {
      diameter = 2;
      incE = 0.05;
    }
    */

    
    patchSize = 20;
    resize(width, height);
  }
  
  void setupPatches() {
    /* initialize all patches as insulators */
    /*
    for (Patch patch in patches) {
      patch.color.setColor(0, 114, 143, 255);
      //patch.fieldDirection = -90.0;
    }
    */
    
    int start = 4;
    int distH = 6;
    int distW = 2;
    int period = 2 * (distW + diameter);
    // define our conductor patches
    for (int i=0; i<worldWidth; i++) {
      Patch patch;
      int px = i + minPatchX;
      int py = -1 * diameter;
      
      
      // lead wire
      if (i < start - 1 || i > (worldWidth - 3)) { 
        for (int j = -2; j < diameter + 2; j++) {
          setupConductorPatch(px, py + j, -90.0, "bottom");
        }
      }  

      else if (i == start - 1) { 
        for (int j = 0; j < diameter; j++) {
          setupConductorPatch(px, py + j, -90.0, "bottom");
        }
      }    
      
      // up wires and part of top wire
      else if ((i - start) % period >= 0 && (i - start) % period < diameter) {
        for (py = -1 * diameter; py < distH; py++) {
          setupConductorPatch(px, py, 0.0, "up");
          //Patch p = patchAt(px, py);
          //p.color.setColor(0, 250, 0, 50);
        }
        for (py = distH; py < diameter + distH; py++) {
          setupConductorPatch(px, py, -90.0, "top");
          //Patch p = patchAt(px, py);
          //p.color.setColor(250,0, 0, 50);
        }
      }
      
      // top wires
      else if ((i - start) % period >= diameter && (i - start) % period < (diameter + distW)) {
        for (py = distH; py < diameter + distH; py++) {
            setupConductorPatch(px, py, -90.0, "top");
            //Patch p = patchAt(px, py);
            //p.color.setColor(250, 0, 0, 50);                    
        }
      }
      
      // down wires
      else if ((i - start) % period >= (diameter + distW) && (i - start) % period < (distW + 2 * diameter)) {
        for (py = 0; py < diameter + distH; py++) {
          setupConductorPatch(px, py, 180.0, "down");
          //Patch p = patchAt(px, py);
          //p.color.setColor(0, 0, 250, 50);       
        } 
        for (py = -1 * diameter; py < 0; py++) {
          setupConductorPatch(px, py, -90.0, "bottom");
          //Patch p = patchAt(px, py);
          //p.color.setColor(250, 0, 250, 50);       
        } 
      }
      
      // bottom wires
      else if ((i - start) % period >= (distW + 2 * diameter) && (i-start) % period < 2 * (distW + diameter)) {
        for (py = -1 * diameter; py < 0; py++) {
          setupConductorPatch(px, py, -90.0, "bottom");
          //Patch p = patchAt(px, py);
          //p.color.setColor(250, 0, 250, 50);
        }
      }
    }
  }
  
  void sproutIons() {
    
    for (Patch p in conductors) {
      if ((p.x + p.y) % (5 - resistance) == 0 ) {
        sproutIon(p.x, p.y);
      }
    }
  }

 
}
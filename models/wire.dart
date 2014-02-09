import 'dart:html';
import 'dart:math';
import 'NetTangoJS/core/ntango.dart';
import 'core/spark.dart';
import 'package:intl/intl.dart'; //this is for number format for AR tags

void main() {
//  WireModel model = new WireModel();
//  model.restart();

  /*
  /* get the input values from the url */
  String querystring = window.location.search.replaceFirst("?", "");
  List<String> list = querystring.split("&");

  for (String param in list) {
    if (param.startsWith("v=")) {
      model.voltage = double.parse(param.substring(2));
      window.alert("Set voltage to ${model.voltage}");
    }
  }
*/

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
  var vFormated = new NumberFormat("#0.0000").format(v);
  var rFormated = new NumberFormat("#0.000").format(r);
  
  ParagraphElement p = new ParagraphElement();
  p = document.querySelector("#voltage-value");
  p.text = "Voltage Drop = ${vFormated}";
  
  p = document.querySelector("#current-value");
  p.text = "Current = ${iFormated}";
  
  p = document.querySelector("#resistance-value");
  p.text = "Resistance = ${rFormated}";
 
  //v = 0.002; // input voltage
  WireModel model = new WireModel(v);
  model.restart();
  model.play(1);
  
 /* 
  // An old attempt to get the input values from the html file
  SpanElement s = new SpanElement();
  s = document.querySelector("#resistance");
  var res = double.parse(s.text);
  */
}

class WireModel extends SparkModel {
  
  WireModel(num v) : super('Wire', 'wire'){

    initE = 0.08;
    decE = 0.005;
    incE = 0.04;

    diameter = 7;
    voltage = v * 10;
    patchSize = 20;
    resize(width, height);
    //fullscreen();
  }

  void setupPatches(){
    /* initialize all patches as insulators */
    for (Patch patch in patches) {
      //patch.color.setColor(255, 240, 245, 255);
      //patch.color.setColor(0, 114, 143, 255);
      //patch.color.setColor(155, 210, 155, 200); // to match the highlight color
      //patch.fieldDirection= -90.0;
    }
    /* define our conductor patches */
    for (int i=0; i<worldWidth; i++) {
      // the wire is "diameter" patches width
      for (int j=- (diameter ~/ 2 + 2); j < (1 + diameter ~/ 2 - 2); j++) {
        int px = i + minPatchX;
        int py = j;
        setupConductorPatch(px, py, 270, "bottom");
      }
    }

  }
  
  void sproutIons() {
    
    for (Patch p in conductors) {
      if (conductors.indexOf(p) % 3 == 0 && p.x % 2 == 0 ) {
        sproutIon(p.x, p.y);
      }
    }
    /* random ions */
//    List<Patch> shuffled = shuffle(conductors);
//    shuffled = shuffled.sublist(0, number~/2);
//    for (Patch p in shuffled) sproutIon(p.x, p.y);
  }

}

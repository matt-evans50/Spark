import 'dart:html';
//import 'dart:math';
import 'package:intl/intl.dart'; //this is for number format for AR tags

void main() {

  /* get the input values from the url */
  String querystring = window.location.search.replaceFirst("?", "");
  List<String> list = querystring.split("&");

  num v;
  num r;
  num i;
  String type;
  
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
    else if (param.startsWith("type=")) {
      type = param.substring(5);
      
    }
  }
  
  var iFormated = new NumberFormat("#0.00").format(i);
  var vFormated = new NumberFormat("#0.0000").format(v);
  var rFormated = new NumberFormat("#0.000").format(r);
  
  ParagraphElement p = new ParagraphElement();
  
  p = document.querySelector("#component-type");
  p.text = "${type}";
  
  p = document.querySelector("#voltage-value");
  p.text = "Voltage Drop = ${vFormated}";
  
  p = document.querySelector("#current-value");
  p.text = "Current = ${iFormated}";
  
  p = document.querySelector("#resistance-value");
  p.text = "Resistance = ${rFormated}";
  

  
  ImageElement img;
  img = new ImageElement();
  //setImage("images/resistor2t.png");
  img.src = "images/resistor2t.png";
  //img.onLoad.listen((event) { draw(); }); 
  //draw();
  
}

void draw() {
  CanvasElement canvas = document.querySelector("#component-canvas");
  CanvasRenderingContext2D ctx = canvas.getContext("2d");
  
//  ctx.fillStyle = "rgba(250,250,250,0.8)";
//  ctx.textAlign = 'left';
//  ctx.textBaseline = 'top';
//  ctx.font = '34px sans-serif'; /* other fonts: verdana */
//  ctx.fillText("SPARK", 20, 20);
  
  ImageElement img = new ImageElement();
  img.src = "images/battery3t.png";
  ctx.drawImageScaled(img, 20, 20, img.width/3, img.height/3);
}

void draw2(CanvasRenderingContext2D ctx, ImageElement img, CanvasElement canvas) {
  //ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.beginPath();
  ctx.fillStyle = "rgb(255,0,0)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.strokeRect(0, 0, canvas.width, canvas.height);
  ctx.drawImageScaled(img, 20, 20, img.width, img.height);
}

/*
void draw(CanvasRenderingContext2D ctx) { 
    ctx.beginPath(); 
    ctx.save();
//    ctx.translate(this.x, this.y);
    iw = img.width / 2.5;
    ih = img.height / 2.5;
    ctx.drawImageScaled(theApp.help.img, 5, 0, iw, ih);
    ctx.restore();
}

void setImage(String src) {
  img.src = src;
  /* load the image right away */
  img.onLoad.listen((event) { App.repaint(); }); 
}
*/

part of SparkProject;

class Bulb extends Component  {

  static int TAG = 0x08;
  bool isOn;
  bool isOff;
  
  ImageElement onbulb = new ImageElement();
  ImageElement coil = new ImageElement();

  Bulb(num x0, num y0, num x1, num y1, num r) : super("Bulb",x0, y0, x1, y1) {
    setImage("images/bulb-off.png");
    onbulb.src = "images/bulb-on.png";
    coil.src = "images/coil.png";
    current = 0.0;
    resistance = 3.0;
    voltageDrop = 0.0;
    
    isOn = false;
    
    theApp.circuit.addNewBranch(this); 
    
  }
  
  //bool get isOn => img.src == "images/bulb-on.png";
  //bool get isOff => img.src == "images/bulb-off.png";
  
  void turnOn() {
    //img.src = "images/bulb-on.png";
    isOn = true;
  }
  
  void turnOff() {
    img.src = "images/bulb-off.png";
    isOn = false;
  }
  
  CanvasRenderingContext2D drawComponent(CanvasRenderingContext2D ctx) {
    iw = img.width / 2.2;
    ih = img.height / 2.2;
    
    num coilW = coil.width / 6;
    num coilH = coil.height / 6;
    ctx.drawImageScaled(img, -iw/2, -ih, iw, ih);
 
//    ctx.globalAlpha = 0.8;
    if (this.current < theApp.circuit.maxCurrent) {
      var base = theApp.circuit.maxCurrent;
      var power = (this.current.abs() + 1) * (this.current.abs() + 1); // max I = 10 => power is between 0 and 100
      var powerScaled = log(power)/log(base); // calculate log base 100 of power 
      ctx.globalAlpha = powerScaled;
      //ctx.globalAlpha = 1.0;
      //print(ctx.globalAlpha);
    }
    ctx.drawImageScaled(onbulb, -iw/2, -ih, iw, ih);
    ctx.globalAlpha = 1.0;
    //ctx.drawImageScaled(coil, -coilW/2, -coilH - 3, coilW, coilH);
    return ctx;
    }
    
  bool containsTouch(Contact event) {
    num tx = event.touchX;
    num ty = event.touchY;
    num cx = screenToComponentX(tx, ty);
    num cy = screenToComponentY(tx, ty);
    num cw = sqrt((start.x - end.x)*(start.x - end.x) + (start.y - end.y)*(start.y - end.y)) - 20;
    num ch = ih;
    
    num mx = (start.x + end.x) / 2;
    num my = (start.y + end.y) / 2;
    num cy2 = sqrt(((tx-mx)*(tx-mx) + (ty-my)*(ty-my)) - cx*cx);
    return (cx.abs() <= cw/2 && (cy <= ch/2 && -ch <= cy)); // ch/4 is just a margin
  }
  
}

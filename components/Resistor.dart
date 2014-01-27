part of SparkProject;

class Resistor extends Component {

  static int TAG = 0x03;

  Resistor(num x0, num y0, num x1, num y1, num r) : super("Resistor", x0, y0, x1, y1) {
    setImage("images/resistor2t.png");
    
    current = 0.0;
    resistance = r;
    voltageDrop = 0.0;
    
    //addSlider(x0, y0);
    theApp.circuit.addNewBranch(this); 
  }
  
  CanvasRenderingContext2D drawComponent(CanvasRenderingContext2D ctx) {
    iw = img.width / 4;
    ih = img.height / 4;
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
    //ctx.fillStyle = "rgba(120,180,35,250)";
    //ctx.fillRect(-5, -10, 40, 20);
    ctx.fillStyle = "rgb(0, 0, 0)";
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';
    ctx.font = '12px sans-serif'; /* other fonts: verdana */
    
    ctx.fillText("R = ${resistance}", -20,-22);

    return ctx;
    }
}

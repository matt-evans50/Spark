part of SparkProject;

class Wire extends Component {

  static int TAG = 0x01;

  Wire(num x0, num y0, num x1, num y1) : super("Wire", x0, y0, x1, y1) {
    setImage("images/wire.jpg");
    current = 0.0;
    resistance = 0.001;
    voltageDrop = 0.0;
    
    theApp.circuit.addNewBranch(this); 
    }
  
  void drawComponent(CanvasRenderingContext2D ctx) {
    iw = sqrt(pow((start.x - end.x), 2) + pow((start.y - end.y), 2));
    ih = img.height / 3;
    /* no image to be drawn */
    }
}
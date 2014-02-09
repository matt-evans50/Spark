part of Spark;

class Ion extends Turtle {
  num energy;
  SparkModel sparkModel;
  
  Ion(SparkModel model) : super(model) {
    this.sparkModel = model;
    size = 0.3;
  }
  
  void tick() {
    if (energy > this.sparkModel.initE) {
      energy -= this.sparkModel.decE;
    }
  }
  
  void draw(CanvasRenderingContext2D ctx) {
    int c = (energy * 1000).toInt();
    //ctx.fillStyle = "rgba($c, 50, 50, 255)";
    ctx.fillStyle = "rgba(255, 50, 50, 255)";
    ctx.beginPath();
    ctx.arc(0, 0, size / 2, 0, PI * 2, true);
    ctx.fill();
    ctx.strokeStyle = 'black';
    ctx.lineWidth=0.01;
    ctx.stroke();
  }
}


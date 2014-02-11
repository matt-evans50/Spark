/*
* Spark: Agent-based electrical circuit environment
* Copyright (c) 2013 Elham Beheshti
*
*       Elham Beheshti (beheshti@u.northwestern.edu)
*       Northwestern University, Evanston, IL
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License (version 2) as
* published by the Free Software Foundation.
*
* This program is distributed in the hope that it will be useful, but
* WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/
part of Spark;

class Electron extends Turtle {
  SparkModel sparkModel;
  num vx; // velocity in x direction
  num vy;
  
  int diameter;
  
  Electron(SparkModel model) : super(model) {
    this.sparkModel = model;
    size = 0.15;
    diameter = sparkModel.diameter;
  }
  
  void tick() {
    move();
  }
  
  void move() {
    Ion i = ionHere();
    if (i == null) { /* no collision, continue */
      Patch p = model.patchAt(x, y);
      vx += p.forceX;
      vy += p.forceY;
    }
    else { /* if collision occurs */
      i.energy += sparkModel.incE;
      heading = bounceBackHeading(this, i);
      // a.energy is the initial velocity (v0)
      vx = i.energy*cos(heading + PI / 2);
      vy = i.energy*sin(heading + PI / 2);
    }
    
    Patch patchNext = model.patchAt(x + vx, y + vy);
    if (!sparkModel.conductors.contains(patchNext)) {// if it is out of wire, wrap it.
      Patch patchHere = model.patchAt(x, y);
      //wrapResistorElectrons();
      
      if (this.sparkModel.name == 'Wire') wrapWireElectrons(patchHere);
      else wrapResistorElectrons();
      
    }
    else {
      if ((x+vx > sparkModel.maxWorldX) || (x+vx < sparkModel.minWorldX)) {
//        var startPatches = sparkModel.conductors.where((p) => (p.x == sparkModel.minWorldX));
//        // Pick a pseudorandom number according to the list length
//        var n = Model.rnd.nextInt(startPatches.length - 1);
//        sparkModel.sproutElectron(startPatches[n].x, startPatches[n].y);
        //this.die();
        this.setHeading(Model.rnd.nextInt(360)); // a random heading, in radians
        
      }
//      else if (x+vx < sparkModel.minWorldX) {
//        var endPatches = sparkModel.conductors.where((p) => (p.x == sparkModel.maxWorldX));
//        // Pick a pseudorandom number according to the list length
//        var n = Model.rnd.nextInt(endPatches.length - 1);
//        sparkModel.sproutElectron(endPatches[n].x, endPatches[n].y);
//      }
      setXY(x + vx, y + vy); // it is in the wire, so move it forward
    }

  }
  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = "rgba(100, 100, 245, 255)";
    ctx.beginPath();
    ctx.arc(0, 0, size / 2, 0, PI * 2, true);
    ctx.fill();
    ctx.strokeStyle = 'black';
    ctx.lineWidth=0.01;
    ctx.stroke();
  }
  
  Ion ionHere() {
    for (Ion i in (model as SparkModel).ions) {
        num dist = (i.x - x) * (i.x - x) + (i.y - y) * (i.y - y);
        num r = (i.size / 2) + (size / 2);
        //r += size / 2; // to repulse before touching the ion
        if (dist <= r * r) {
          return i;
        }
    }
    return null;
  }
  
  num bounceBackHeading(Electron e, Ion a) {
    var vectorA = [a.x - e.x, a.y - e.y];
    var vectorB = [cos(heading + PI / 2), sin(heading + PI / 2)];
    /* find the angle between the two vectors using the cross product of the two vectors */
    num absA = sqrt(vectorA[0]*vectorA[0] + vectorA[1]*vectorA[1]);
    num absB = sqrt(vectorB[0]*vectorB[0] + vectorB[1]*vectorB[1]);
    num crossProduct = vectorA[0]*vectorB[1] - vectorA[1]*vectorB[0];
    num sinAlfa = crossProduct/(absA*absB);
    num alfa = asin(sinAlfa); // in radians, between -PI/2 and PI/2  
    return (heading + PI - 2 * alfa); // this is the bounce back heading
  }
  
  /*
   * Set the heading
   @ gets heading in degrees and sets the electron's heading in radian
   */
  void setHeading(num degrees) {
    heading = (degrees / 180.0) * PI;
  }


  
  void wrapWireElectrons(Patch patchHere) {
//    if (p.y > 0) setXY(x, wrapY(y + model.worldHeight - sparkModel.diameter));
//    else setXY(x, wrapY(y + model.worldHeight + sparkModel.diameter));
    if (patchHere.y > 0) setXY(x + vx, y + vy - sparkModel.diameter);
    else setXY(x + vx, y + vy + sparkModel.diameter);
  }
  
  void wrapResistorElectrons() {
    setHeading(Model.rnd.nextInt(360));
    vx = sparkModel.initE * cos(heading + PI/2);
    vy = sparkModel.initE * sin(heading + PI/2);
    //move();
  }
  /*
  void wrapResistorElectrons(Patch patchHere) {
    num d = sparkModel.diameter;
    if (patchHere.region == "up" || patchHere.region == "down") {
      if (patchHere.y >= 0 && patchHere.y < sparkModel.diameter) {
        if (vx > 0) setXY(x + vx - d, y + vy);
        else setXY(x +vx + d, y + vy);
      }
      else {
        setHeading(Model.rnd.nextInt(360));
        vx = sparkModel.initE * cos(heading + PI/2);
        vy = sparkModel.initE * sin(heading + PI/2);
        move();
      }
    }
    else { // region is either top or bottom
      int i = patchHere.x - sparkModel.minPatchX;
      if (((i - start) % period >= 0 && (i - start) % period < diameter) 
          || ((i - start) % period >= (diameter + 2) && (i - start) % period < (2 + 2 * diameter))) {
        setHeading(Model.rnd.nextInt(360));
        this.vx = sparkModel.initE * cos(this.heading + PI/2);
        this.vy = sparkModel.initE * sin(this.heading + PI/2);
        move();
      }
      else {
        if (vy > 0) setXY(x + vx, y + vy - d);
        else setXY(x + vx, y +vy + d);
      }

    }

//      sparkModel.sproutElectron(tempP.x, tempP.y);
//      sparkModel.turtles.remove(this);
//      sparkModel.electrons.remove(this);
//      this.die();
  }
*/ 
  
  double distance(Turtle t1, Turtle t2) {
    return sqrt ((t1.x - t2.x) * (t1.x - t2.x) + (t1.y - t2.y) * (t1.y - t2.y));    
  }
}

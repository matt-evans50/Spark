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

abstract class SparkModel extends Model { 
  
  num initE;
  num decE;
  num incE;
  
  num voltage;
  var diameter;
  
  List<Ion> ions;
  List<Electron> electrons;
  List<Patch> conductors;
  
  
  SparkModel(String name, String id) : super(name, id) {
    ions = new List<Ion>();
    electrons = new List<Electron>();
    
    conductors = new List<Patch>();
  }
  
  void setup() {
    clearTurtles();
    initPatches();
    setupPatches();
  }
  
  void setupPatches();
  
  void setupConductorPatch(int px, int py, num heading, String r) { // r is region (top, up, bottom, down)
    heading = heading * PI / 180.0 ;
    Patch patch = patchAt(px, py);
    conductors.add(patch);
    patch.fieldDirection = heading;
    patch.region = r;
    patch.forceX = this.voltage * cos ( heading + PI / 2 );
    patch.forceY = this.voltage * sin ( heading + PI / 2 );
    patch.color.setColor(212, 212, 212, 50);
    //patch.color.setColor(Model.rnd.nextInt(255), 0, 0, 50);
    
    /* sprout electrons */
    sproutIons();
    
    for (int i=0; i < 2; i++) {
      if (Model.rnd.nextDouble() > 0.7) {
        sproutElectron(px, py);
      }
    }
    
  }
  
  void sproutElectron(int patchX, int patchY) {
      Electron electron = new Electron(this);
      electron.setXY(
          patchX + Model.rnd.nextDouble() - 0.5,
          patchY + Model.rnd.nextDouble() - 0.5);
      electron.setHeading(Model.rnd.nextInt(360)); // a random initial heading, in radians
      electron.vx = initE * cos(electron.heading + PI/2);
      electron.vy = initE * sin(electron.heading + PI/2);
      addTurtle(electron);
      electrons.add(electron);
  }
  
  void sproutIon(int patchX, int patchY) {
    Ion ion = new Ion(this);
    ion.energy = 0.1;
    ion.setXY(patchX, patchY);
    addTurtle(ion);
    ions.add(ion);
  }
  
  void sproutIons() {}
  
  List<Patch> shuffle(List<Patch> ps) {
    List<Patch> shuffled = new List<Patch>();
    shuffled.addAll(ps);
    var random = new Random();

    // Go through all elements.
    for (var i = ps.length - 1; i > 0; i--) {

      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(ps.length);

      var temp = shuffled[i];
      shuffled[i] = shuffled[n];
      shuffled[n] = temp;
    }

    return shuffled;
  }

}


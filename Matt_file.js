// ~100 electrons
// initial random directions
// constrained by wire





//
//==============================================================================
// Vertex shader program:
var VSHADER_SOURCE =
  'precision highp float;\n' +        // req'd in OpenGL ES if we use 'float'
  //
  'attribute vec4 a_Position; \n' +
  'attribute vec4 a_Color; \n' +
  'attribute vec3 a_fireColor; \n' +
  'attribute float a_diam; \n' +
  'attribute vec4 a_firePos; \n' +
  'varying vec4 v_Color; \n' +
  'uniform bool u_isPart; \n' +
  'uniform int renderMode; \n' +
  'uniform mat4 u_ViewMatrix; \n' +
  'uniform mat4 u_ProjMatrix; \n' +
  'void main() {\n' +
  ' if (u_isPart) { \n' +
  '  gl_PointSize = a_diam;\n' +
  '}\n ' +
  '  gl_Position = u_ProjMatrix * u_ViewMatrix * a_Position;  \n' + 
  '  v_Color = a_Color; \n' +
  /*'  } else if (renderMode == 1) {\n' +
  '   gl_Position = u_ProjMatrix * u_ViewMatrix * a_firePos;\n' +
  '   v_Color = vec4(a_fireColor, 1.0); \n' + 
  '  }\n' +*/
  '} \n';
// Each instance computes all the on-screen attributes for just one VERTEX,
// The program gets all its info for that vertex through the 'attribute vec4' 
// variable a_Position, which feeds it values for one vertex taken from from the 
// Vertex Buffer Object (VBO) we created inside the graphics hardware by calling 
// the 'initVertexBuffers()' function. 

//==============================================================================// Fragment shader program:
var FSHADER_SOURCE =
  
  'precision mediump float;\n' +
  'varying vec4 v_Color; \n' +
  'void main() {\n' +
  '    float dist = distance(gl_PointCoord, vec2(0.5, 0.5)); \n' +
  '    if(dist < 0.5) { \n' + 
  '       gl_FragColor = vec4((1.0 - 1.5*dist)*v_Color.rgb, v_Color.a);\n' +
  '    } else { discard; }\n' +
  '} \n';
  /*
  'float dist = distance(gl_PointCoord, vec2(2.0, 2.0)); \n' +
  '  if(dist < 2.0) { \n' + 
  '   gl_FragColor = vec4((1.0 - 0.3*dist)*v_Color.rgb, 1.0);\n' +
  '  } else { discard; }\n' +
  '}\n';
  */
// --Each instance computes all the on-screen attributes for just one PIXEL.
// --Draw large POINTS primitives as ROUND instead of square.  HOW?
//   See pg. 377 in  textbook: "WebGL Programming Guide".  The vertex shaders' 
// gl_PointSize value sets POINTS primitives' on-screen width and height, and
// by default draws POINTS as a square on-screen.  In the fragment shader, the 
// built-in input variable 'gl_PointCoord' gives the fragment's location within
// that 2D on-screen square; value (0,0) at squares' lower-left corner, (1,1) at
// upper right, and (0.5,0.5) at the center.  The built-in 'distance()' function
// lets us discard any fragment outside the 0.5 radius of POINTS made circular.
// (CHALLENGE: make a 'soft' point: color falls to zero as radius grows to 0.5)?
// -- NOTE! gl_PointCoord is UNDEFINED for all drawing primitives except POINTS;
// thus our 'draw()' function can't draw a LINE_LOOP primitive unless we turn off
// our round-point rendering.  
// -- All built-in variables: http://www.opengl.org/wiki/Built-in_Variable_(GLSL)

function Force (forcetype, part1, part2) {
  // 0 = gravity, 
  this.forceType = forcetype;
  circuitResistance = 10.0;
  this.gravConst = 1.81;
  this.dragConst = 0.975;
  this.springConstant = 10.0;
  this.voltage = 10.0;
  this.pt1 = part1;
  this.pt2 = part2;
  this.heatForce = 0.01;
  this.BoidSep = 1000.0;
  this.BoidAli = 500.0;
  this.BoidCoh = 0.5;
} 

  var DRAG_CONST = 0.975;
  //var VOLTAGE = 100.0;


const P_MASS = 0;
const P_SIZE = 1;
const P_POSX = 2;
const P_POSY = 3;
const P_POSZ = 4;
const P_VELX = 5;
const P_VELY = 6;
const P_VELZ = 7;
const P_FORX = 8;
const P_FORY = 9;
const P_FORZ = 10;
const P_CRED = 11;
const P_CGRN = 12;
const P_CBLU = 13;
const P_TPRT = 14;


// include circOn condition for initializing particle positions
var BOID_DISTANCE = 0.3;
var circOn = 1;
var dragOn = 1;
var g_EyeRadius = 2.0, g_EyeZrot = 0.0, g_EyeXrot = 25;
var floatsPerVertex = 6.0;
var numParticles = 500;
var numForces = 1;
var PartEleCount = 15;
var s = new Float32Array(numParticles*PartEleCount);
var f = new Array(numForces);
f[0] = new Force(2, 0, 0);
//f[1] = new Force(3, 0, 1); // fire force
//f[0] = new Force(5, 0, 0); // boid forces
var RenderMode = 0; // 0 -> circuit, 1-> who knows, 2-> spring/mass, 3-> fire, 4-> boids
var isPart = true;
var Solver = 0; // 0 for Euler


// i've got a lovely bunch of coconuts!!!
// for loop to build particle system

function initParticles() {
  if (RenderMode == 0) {
    for (var i = 0; i< numParticles; i++) {
      var offset = i*PartEleCount;
      s[offset+P_MASS] = 10;
      s[offset+P_SIZE] = 5 + 10*Math.random();
      if (circOn) {
        s[offset+P_POSX] = (0.8 + 0.2*Math.random())*Math.pow(-1, Math.floor(Math.random()*3.999)); // +- [0.9 - 1.0]
        s[offset+P_POSY] = (0.8 + 0.2*Math.random())*Math.pow(-1, Math.floor(Math.random()*3.999));
        s[offset+P_POSZ] = 0.1*Math.random() - 0.1*Math.random();
      }
      else {
        s[offset+P_POSX] = -0.9*Math.random() + 0.9*Math.random();
        s[offset+P_POSY] = -0.9*Math.random() + 0.9*Math.random();
        s[offset+P_POSZ] = Math.random() - Math.random();  
      }
      s[offset+P_VELX] = -Math.random() + Math.random();
      s[offset+P_VELY] = -Math.random() + Math.random();
      s[offset+P_VELZ] = 0;
      s[offset+P_FORX] = 0;
      s[offset+P_FORY] = 0;
      s[offset+P_FORZ] = 0;
      s[offset+P_CRED] = Math.random();
      s[offset+P_CBLU] = Math.random();
      s[offset+P_CGRN] = Math.random();
      s[offset+P_TPRT] = 1.0;
    }
  } else 
  if (RenderMode == 3) {
    for (var i = 0; i < numParticles; i++) {
      var offset = i*PartEleCount;
      s[offset+P_MASS] = 10;
      s[offset+P_SIZE] = 2+5*Math.random();
      s[offset+P_POSX] = 0;
      s[offset+P_POSY] = 0;
      s[offset+P_POSZ] = 0;  
      s[offset+P_VELX] = -0.5*Math.random() + 0.5*Math.random();
      s[offset+P_VELY] = -0.5*Math.random() + 0.5*Math.random();
      s[offset+P_VELZ] = 2*Math.random();
      s[offset+P_FORX] = 0;
      s[offset+P_FORY] = 0;
      s[offset+P_FORZ] = 0;
      s[offset+P_CRED] = 1.0;
      s[offset+P_CBLU] = 0.1*Math.random();
      s[offset+P_CGRN] = 0;
      s[offset+P_TPRT] = 1.0;
    }
  }
  else if (RenderMode == 2) {
    for (var i = 0; i < numParticles; i++) {
      var offset = i*PartEleCount;
      s[offset+P_MASS] = 20;
      s[offset+P_SIZE] = 10;
      s[offset+P_POSX] = 0;
      s[offset+P_POSY] = 0;
      s[offset+P_POSZ] = 0;  
      s[offset+P_VELX] = -0.5*Math.random() + 0.5*Math.random();
      s[offset+P_VELY] = -0.5*Math.random() + 0.5*Math.random();
      s[offset+P_VELZ] = -0.5*Math.random() + 0.5*Math.random();
      s[offset+P_FORX] = 0;
      s[offset+P_FORY] = 0;
      s[offset+P_FORZ] = 0;
      s[offset+P_CRED] = Math.random();
      s[offset+P_CBLU] = Math.random();
      s[offset+P_CGRN] = Math.random();
      s[offset+P_TPRT] = 1.0;
      //if (i != numParticles -1) {
        f[i] = new Force(3, i, i+1);
      //}
    }
  }
  else if (RenderMode == 4) {
    for (var i = 0; i < numParticles; i++) {
      var offset = i*PartEleCount;
      s[offset+P_MASS] = 10;
      s[offset+P_SIZE] = 10;
      s[offset+P_POSX] = 0.4*Math.random() - 0.4*Math.random();
      s[offset+P_POSY] = 0.4*Math.random() - 0.4*Math.random();
      s[offset+P_POSZ] = 0.4*Math.random() - 0.4*Math.random();  
      s[offset+P_VELX] = 0;
      s[offset+P_VELY] = 0;
      s[offset+P_VELZ] = 0;
      s[offset+P_FORX] = 0;
      s[offset+P_FORY] = 0;
      s[offset+P_FORZ] = 0;
      s[offset+P_CRED] = Math.random();
      s[offset+P_CBLU] = Math.random();
      s[offset+P_CGRN] = Math.random();
      s[offset+P_TPRT] = 1.0;
    }
  }
}


var FSIZE = s.BYTES_PER_ELEMENT;
var timeStep = 1.0/30.0;
var g_last = Date.now();

function main() {
//==============================================================================
  // Retrieve <canvas> element
  var canvas = document.getElementById('webgl');

  // Get the rendering context for WebGL
  var gl = getWebGLContext(canvas);
  if (!gl) {
    console.log('Failed to get the rendering context for WebGL');
    return;
  }
  gl.viewportWidth = canvas.width;
  gl.viewportHeight = canvas.height;
  gl.viewportDepth = canvas.height;

  // Initialize shaders
  if (!initShaders(gl, VSHADER_SOURCE, FSHADER_SOURCE)) {
    console.log('Failed to intialize shaders.');
    return;
  }
  
  // Get the storage locations of u_ViewMatrix and u_ProjMatrix variables
  var u_ViewMatrix = gl.getUniformLocation(gl.program, 'u_ViewMatrix');
  var u_ProjMatrix = gl.getUniformLocation(gl.program, 'u_ProjMatrix');
  if (!u_ViewMatrix || !u_ProjMatrix) { 
    console.log('Failed to get u_ViewMatrix or u_ProjMatrix');
    return;
  }
  isPartID = gl.getUniformLocation(gl.program, 'u_isPart');
  if (!isPartID) {
    console.log('failed to get isPart location');
  }
  gl.uniform1i(isPartID, isPart); //
  // set render mode to control what gets displayed
  var u_renderModeLoc = gl.getUniformLocation(gl.program, 'u_renderMode');
  if (u_renderModeLoc) { 
    console.log('Failed to get render mode variable location');
    return;
  }
  gl.uniform1i(u_renderModeLoc, RenderMode);

  initParticles();

  var viewMatrix = new Matrix4();
  var projMatrix = new Matrix4();

  // registers left and right keys to adjust camera
  document.onkeydown = function(ev){ keydown(ev, gl, u_ViewMatrix, viewMatrix); };


  projMatrix.setPerspective(30, canvas.width/canvas.height, 1, 100); // this never changes
  // set the GLSL u_ProjMatrix to the value I have set
  gl.uniformMatrix4fv(u_ProjMatrix, false, projMatrix.elements);


  // bind and set up array buffer for particles
  var myVerts = initVertexBuffersNew(gl);
  if (myVerts < 0) {
    console.log('Failed to set the positions of the vertices');
    return;
  }

  // Specify the color for clearing <canvas>
  gl.clearColor(0, 0, 0, 1);

  // Start drawing
  var tick = function() {
    timeStep = animate(timeStep);  // Update the statespace
    draw(gl, myVerts, timeStep, u_ViewMatrix, viewMatrix);
    requestAnimationFrame(tick, canvas);  // Request browser to ?call tick()?
  };
  tick();


}


function initVertexBuffers(gl) {
//==============================================================================
  /*
  // bind shit for 'fire' particles
  fireBuffer = gl.createBuffer();
  firePosLoc = gl.getAttribLocation(gl.program, 'a_firePos');
  gl.bindBuffer(gl.ARRAY_BUFFER, firePosLoc);
  gl.vertexAttribPointer(firePosLoc, 3, gl.FLOAT, false, FSIZE*PartEleCount, P_POSX*FSIZE);
                          // shader location, vars to read, type of vars, normalized, stride, offset
  gl.enableVertexAttribArray(firePosLoc);

  // also enable fire color
  fireColorBuffer = gl.createBuffer();
  fireColLoc = gl.getAttribLocation(gl.program, 'a_fireColor');
  gl.bindBuffer(gl.ARRAY_BUFFER, fireColLoc);
  gl.vertexAttribPointer(fireColLoc, 3, gl.FLOAT, false, FSIZE*PartEleCount, P_CRED*FSIZE);
                          // shader location, vars to read, type of vars, normalized, stride, offset
  gl.enableVertexAttribArray(fireColLoc);
*/
  vertexBufferID = gl.createBuffer();
  // Create a buffer object
   if (!vertexBufferID) {
    console.log('Failed to create the buffer object');
    return -1;
  }

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexBufferID);
  // Write date into the buffer object
  gl.bufferData(gl.ARRAY_BUFFER, s, gl.STATIC_DRAW);

  // Assign the buffer object to a_Position variable
  a_PositionID = gl.getAttribLocation(gl.program, 'a_Position');
  if (!a_PositionID) {
    console.log('could not get a_position attribute location');
    return;
  }
  
  gl.vertexAttribPointer(a_PositionID, 3, gl.FLOAT, false, FSIZE*PartEleCount, P_POSX*FSIZE);
                          // shader location, vars to read, type of vars, normalized, stride, offset
  gl.enableVertexAttribArray(a_PositionID);


  // set up color
  a_ColorID = gl.getAttribLocation(gl.program, 'a_Color');
  if(a_ColorID < 0) {
    console.log('Failed to get the gfx storage location of a_Color');
    return -1;
  }
  
  gl.vertexAttribPointer(
    a_ColorID,    //index == attribute var. name used in the shader pgm.
    3,            // size == how many dimensions for this attribute: 1,2,3 or 4?
    gl.FLOAT,     // type == what data type did we use for those numbers?
    false,        // isNormalized == are these fixed-point values that we need
                  //                  normalize before use? true or false
    PartEleCount * FSIZE,// stride == #bytes (of other, interleaved data) between 
                      // separating OUR values?
    P_CRED * FSIZE);
  gl.enableVertexAttribArray(a_ColorID);


  // set up particle size
  a_diamID = gl.getAttribLocation(gl.program, 'a_diam');
  if(a_diamID < 0) {
    console.log('Failed to get the storage location of scalar a_diam');
    return -1;
  }
  gl.vertexAttribPointer(
    a_diamID,     //index == attribute var. name used in the shader pgm.
    1,            // size == how many dimensions for this attribute: 1,2,3 or 4?
    gl.FLOAT,     // type == what data type did we use for those numbers?
    false,        // isNormalized == are these fixed-point values that we need
                  //                  to normalize before use? true or false
    PartEleCount*FSIZE,// stride == #bytes (of other, interleaved data) between 
                      // separating OUR values?
    P_SIZE*FSIZE); // Offset -- how many bytes from START of buffer to the
                      // value we will actually use?  We start with position.
  // Enable this assignment of the a_Position variable to the bound buffer:
  gl.enableVertexAttribArray(a_diamID);

  
  // set up walls - this is never going to work
  /*
  wallsVertexBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, wallsVertexBuffer);
  // Write date into the buffer object
  wallVs = new Float32Array([0.8,  0.8,  0.0,
                             0.8, -0.8,  0.0,
                            -0.8, -0.8,  0.0,
                            -0.8,  0.8,  0.0]);


  gl.bufferData(gl.ARRAY_BUFFER, wallVs, gl.STATIC_DRAW);

  a_wallPosID = gl.getAttribLocation(gl.program, 'a_wallPos'); 
  gl.vertexAttribPointer(a_wallPosID, 3, gl.FLOAT, false, FSIZE*3, 0);
                          // shader location, vars to read, type of vars, normalized, stride, offset
  gl.enableVertexAttribArray(a_wallPosID);
  */
  return numParticles;
}








function draw(gl, n, timeStep, u_ViewMatrix, viewMatrix) {
//==============================================================================  // Set the rotation matrix
 // apply constraints and impose drag
  applyConstraints();
  gl.clear(gl.COLOR_BUFFER_BIT);
  // update state space
  calcForces();
  applyForces(0, timeStep); // 0 for Euler

  var xpos, ypos, zpos;
  xpos = g_EyeRadius * Math.cos(g_EyeZrot/2);
  ypos = g_EyeRadius * Math.cos(g_EyeXrot/2) + g_EyeRadius * Math.sin(g_EyeZrot/2);
  zpos = g_EyeRadius * Math.sin(g_EyeXrot/2);
  viewMatrix.setLookAt(xpos, ypos, zpos,  // eye position
                          0, 0, 0,                // look-at point (origin)
                          0, 0, 1);               // up vector (+y)
  gl.uniformMatrix4fv(u_ViewMatrix, false, viewMatrix.elements);


  Render(gl, n, u_ViewMatrix, viewMatrix);

}



function calcForces() {
  for (var i = 0; i < numParticles; i++) {
    var offset = i*PartEleCount;
    var fxtot, fytot, fztot;
    fxtot = fytot = fztot = 0; // position forces
    frcol = fgcol = fbcol = 0; // color 'forces'
    fmass = 0; // mass-changing force
    //console.log('there are ', f.length, 'forces here\n');
    // iterate through each force, adding relevant forces to s[i]
    for (var j = 0; j < numForces; j++) {
      switch(f[j].forceType) {
        case 0:
          // no force
          break;
        case 1:
          // gravity force
          fztot -= f[j].gravConst;
          break;
        case 2:
          // circuit force
          //console.log('CIRCUIT FORCE WOOO')
          // if in top section, force right
          if (s[offset+P_POSX] <= 0.8 && s[offset+P_POSY] > 0.8) {
            fxtot += f[j].voltage;
          }
          // if in right section, force down
          else if (s[offset+P_POSX] > 0.8 && s[offset+P_POSY] >= -0.8) {
            fytot -= f[j].voltage;
          }
          // if in bottom section, force left
          else if (s[offset+P_POSX] > -0.8 && s[offset+P_POSY] <= -0.8) {
            fxtot -= f[j].voltage;
          }
          // if in left section, force up
          else if (s[offset+P_POSX] <= -0.8 && s[offset+P_POSY] < 0.8) {
            fytot += f[j].voltage;
          }
          break;
        case 3:
          // spring force where f[j].pt1 and f[j].pt2 connected
          // first, find the beginning of each particle's location in s
          if (f[j].pt1 == i) {
            pt1Start = f[j].pt1*PartEleCount, pt2Start = f[j].pt2*PartEleCount;
            fxtot += (s[pt2Start+P_POSX] - s[pt1Start+P_POSX])*f[j].springConstant;
            fytot += (s[pt2Start+P_POSY] - s[pt1Start+P_POSY])*f[j].springConstant;
            fztot += (s[pt2Start+P_POSZ] - s[pt1Start+P_POSZ])*f[j].springConstant;
          } else
          if (f[j].pt2 == i) {
            pt1Start = f[j].pt1*PartEleCount, pt2Start = f[j].pt2*PartEleCount;
            fxtot += (s[pt1Start+P_POSX] - s[pt2Start+P_POSX])*f[j].springConstant;
            fytot += (s[pt1Start+P_POSY] - s[pt2Start+P_POSY])*f[j].springConstant;
            fztot += (s[pt1Start+P_POSZ] - s[pt2Start+P_POSZ])*f[j].springConstant;
          }
          break;
        case 4:
          // fire/heat force
          if (s[offset+P_POSZ] < 0.8) {
            fztot += f[j].heatForce/(s[offset+P_POSZ] + 0.01);
          }
          // heat force up
          // mass-changing force down
          fmass = 0.95;
          // change color from red->yellow->grey 
          if (s[offset+P_POSZ] < 0.5) {
            fgcol = (0.9+0.1*Math.random())*(2*s[offset+P_POSZ]); // ranges from 0->~1 at z = 0.5
          }
          else if (s[offset+P_POSZ] > 0.5) {
            fgcol = (0.9+0.1*Math.random())*(2*s[offset+P_POSZ]) - 1.5*(s[offset+P_POSZ] - 0.5);
            fbcol = (0.7+0.1*Math.random())*(2*(s[offset+P_POSZ] - 0.5));
          }
          s[offset+P_MASS] *= fmass;
          s[offset+P_CGRN] = fgcol;
          s[offset+P_CBLU] = fbcol;
          // if the particle goes off the screen, re-initialize it to keep the fire going
          if (s[offset+P_POSZ] > 1.0) {
            s[offset+P_MASS] = 10;
            s[offset+P_SIZE] = 2+5*Math.random();
            s[offset+P_POSX] = 0;
            s[offset+P_POSY] = 0;
            s[offset+P_POSZ] = 0;  
            s[offset+P_VELX] = -0.2*Math.random() + 0.2*Math.random();
            s[offset+P_VELY] = -0.2*Math.random() + 0.2*Math.random();
            s[offset+P_VELZ] = Math.random();
            s[offset+P_FORX] = 0;
            s[offset+P_FORY] = 0;
            s[offset+P_FORZ] = 0;
            s[offset+P_CRED] = 1.0;
            s[offset+P_CBLU] = 0.1*Math.random();
            s[offset+P_CGRN] = 0;
            s[offset+P_TPRT] = 1.0;
          }
          break;
        case 5:
          // boid flocking force
          // for each particle, see if it is in the neighborhood
          var velxtot, velytot, velztot, posxtot, posytot, posztot; // variables used to find the average velocities and positions of neighbors
          var counter = 0;
          velxtot = velytot = velztot = posxtot = posytot = posztot = 0.0;
          for (var k = 0; k < numParticles; k++) {
            var xdist = s[offset+P_POSX] - s[k*PartEleCount + P_POSX];
            var ydist = s[offset+P_POSY] - s[k*PartEleCount + P_POSY];
            var zdist = s[offset+P_POSZ] - s[k*PartEleCount + P_POSZ];
            var distance = Math.sqrt(Math.pow(xdist, 2) +
                                     Math.pow(ydist, 2) +
                                     Math.pow(zdist, 2));
            if (distance <= BOID_DISTANCE) {
              counter ++;
              // separation force - what prevents them from hitting one another
              
              if (distance < 0.1) {
                fxtot += xdist*f[j].BoidSep;
                fytot += ydist*f[j].BoidSep;
                fztot += zdist*f[j].BoidSep;
              }
              // alignment force - what keeps them going in relatively the same direction
              velxtot += s[k*PartEleCount + P_VELX];
              velytot += s[k*PartEleCount + P_VELY];
              velztot += s[k*PartEleCount + P_VELZ];

              // cohesion force - what keeps them from drifting apart
              posxtot += s[k*PartEleCount + P_POSX];
              posytot += s[k*PartEleCount + P_POSY];
              posztot += s[k*PartEleCount + P_POSZ];
            }
          }
          // calculate the average position of neighbors, and construct a cohesion force towards it
          var x_avg = posxtot / counter;
          var y_avg = posytot / counter;
          var z_avg = posztot / counter;

          fxtot += (s[offset+P_POSX] + x_avg)*f[j].BoidCoh;
          fytot += (s[offset+P_POSY] + y_avg)*f[j].BoidCoh;
          fztot += (s[offset+P_POSZ] + z_avg)*f[j].BoidCoh;
          // calculate an average velocity of neighbors, and construct an alignment force in that direction

          fxtot += ((velxtot / counter) - s[offset+P_VELX])*f[j].BoidAli;
          fytot += ((velytot / counter) - s[offset+P_VELY])*f[j].BoidAli;
          fztot += ((velztot / counter) - s[offset+P_VELZ])*f[j].BoidAli;
          //fxtot += (posxtot / counter);
          break;
        default:
          console.log('uh oh! force of type !=0');
      }
    }
    // set the state var force values to the calculated totals
    s[offset+P_FORX] = fxtot;
    s[offset+P_FORY] = fytot;
    s[offset+P_FORZ] = fztot;
  }
}

function applyForces(solvertype, timeStep) {
  //console.log('entered applyforces');
  switch(solvertype) {
    case 0:
      // basic Euler solver
      for (var i = 0; i < numParticles; i++) {
        var offset = i*PartEleCount;
        // apply velocities
        //console.log('previous positions: ', s[offset+P_POSX], s[offset+P_POSY], s[offset+P_POSZ]);
        if (Solver == 0) {
          s[offset+P_POSX] += s[offset+P_VELX]*timeStep;
          s[offset+P_POSY] += s[offset+P_VELY]*timeStep;
          s[offset+P_POSZ] += s[offset+P_VELZ]*timeStep;

          // apply changes in velocities due to forces - careful of div by 0!
          s[offset+P_VELX] += (s[offset+P_FORX] * timeStep) / s[offset+P_MASS];
          s[offset+P_VELY] += (s[offset+P_FORY] * timeStep) / s[offset+P_MASS];
          s[offset+P_VELZ] += (s[offset+P_FORZ] * timeStep) / s[offset+P_MASS];
        }
        
        else if (Solver == 1) {
          var x_mov = (s[offset+P_VELX]*timeStep)*0.5;
          var y_mov = (s[offset+P_VELY]*timeStep)*0.5;
          var z_mov = (s[offset+P_VELZ]*timeStep)*0.5;
          // apply changes in velocities due to forces - careful of div by 0!
          var x_vel = (s[offset+P_FORX] * timeStep) / s[offset+P_MASS];
          var y_vel = (s[offset+P_FORY] * timeStep) / s[offset+P_MASS];
          var z_vel = (s[offset+P_FORZ] * timeStep) / s[offset+P_MASS];

          x_mov += x_vel*timeStep*0.5;
          y_mov += y_vel*timeStep*0.5;
          z_mov += z_vel*timeStep*0.5;

          s[offset+P_POSX] += x_mov;
          s[offset+P_POSY] += y_mov;
          s[offset+P_POSZ] += z_mov;
        }
        
        // apply changes in velocities due to drag
        if (dragOn) {
          s[offset+P_VELX] *= DRAG_CONST;
          s[offset+P_VELY] *= DRAG_CONST;
          s[offset+P_VELZ] *= DRAG_CONST;
        }
      }
      break;
      default:
        console.log('error in solver! invalid solvertype');
  }
}


function Render(mygl, n, myu_ViewMatrix, myViewMatrix) {


  //myViewMatrix.rotate(-90.0, 1,0,0);  // new one has "+z points upwards",
                                      // made by rotating -90 deg on +x-axis.
                                      // Move those new drawing axes to the 
                                      // bottom of the trees:
  mygl.uniformMatrix4fv(myu_ViewMatrix, false, myViewMatrix.elements);
  if (RenderMode == 4) {
    s[P_MASS] = 50;
    s[P_SIZE] = 40;
    s[P_POSX] = 0.8*Math.cos(Date.now()/500.0);
    s[P_POSY] = 0.8*Math.sin(Date.now()/500.0);
    s[PartEleCount+P_VELX] = s[P_POSX] - s[PartEleCount + P_POSX]; // set the second particle's velocity vector to toward the ball
    s[PartEleCount+P_VELY] = s[P_POSY] - s[PartEleCount + P_POSY];
    s[PartEleCount+P_VELZ] = s[P_POSZ] - s[PartEleCount + P_POSZ];
  }

  mygl.bufferSubData(mygl.ARRAY_BUFFER, 0, s);
  if (RenderMode == 2) {
   mygl.drawArrays(mygl.LINES, 0, n);
  }
  else {
    mygl.drawArrays(mygl.POINTS, 0, n);
  }
  /*
  myPartID = mygl.getAttribLocation(mygl.program, 'u_isPart');
  if (!myPartID) {
    console.log('shit is whack yo');
  }
  */
  mygl.uniform1i(isPartID, false);


  mygl.drawArrays(mygl.LINES,             // use this drawing primitive, and
                  s.length/PartEleCount, // start at this vertex number, and
                  (circVerts.length)/PartEleCount);   // draw this many vertices
 // now try to draw something else
 // vertexBufferID2 = gl.createBuffer();
  mygl.uniform1i(isPartID, true);
}

function animate() {
//==============================================================================  // Calculate the elapsed time
  var now = Date.now();                       
  var elapsed = now - g_last;               
  g_last = now;
  // Return the amount of time passed.
  return elapsed / 1000.0;
}

// circuitOn set to 1 imposes circuit-constraints
function applyConstraints() {
   for (var i = 0; i < numParticles; i++) {
    var offset = i*PartEleCount;
    // particle motion
    // calc z - constraint
    if (RenderMode == 1 || RenderMode == 0) {
      if (s[offset+P_POSX] > 1.0 && s[offset+P_POSY] > 0.8) {
        s[offset+P_POSX] = 0.99;

        var temp = s[offset+P_VELX];
        s[offset+P_VELX] = s[offset+P_VELY];
        s[offset+P_VELY] = -temp;
      }
      // bottom right corner
      if (s[offset+P_POSX] > 0.8 && s[offset+P_POSY] < -1.0) {
        s[offset+P_POSY] = -0.99;

        var temp = s[offset+P_VELY];
        s[offset+P_VELY] = s[offset+P_VELX];
        s[offset+P_VELX] = temp;
      }
      // bottom left corner
      if (s[offset+P_POSX] < -1.0 && s[offset+P_POSY] < -0.8) {
        s[offset+P_POSX] = -0.99;

        var temp = s[offset+P_VELX];
        s[offset+P_VELX] = s[offset+P_VELY];
        s[offset+P_VELY] = -temp;
      }
      // top left corner
      if (s[offset+P_POSX] < -0.8 && s[offset+P_POSY] > 1.0) {
        s[offset+P_POSY] = 0.99;

        var temp = s[offset+P_VELY];
        s[offset+P_VELY] = s[offset+P_VELX];
        s[offset+P_VELX] = temp;
      }
      if (s[offset+P_POSX] > 1.0) {
        s[offset+P_POSX] = 0.81;
        s[offset+P_VELX] += (0.2*Math.random() - 0.2*Math.random());
      }
      if (s[offset+P_POSX] < -1.0) {
        s[offset+P_POSX] = -0.81;
        s[offset+P_VELX] += (0.2*Math.random() - 0.2*Math.random());
      }
      if (s[offset+P_POSY] > 1.0) {
        s[offset+P_POSY] = 0.81;
        s[offset+P_VELY] += (0.2*Math.random() - 0.2*Math.random());
      }
      if (s[offset+P_POSY] < -1.0) {
        s[offset+P_POSY] = -0.81;
        s[offset+P_VELY] += (0.2*Math.random() - 0.2*Math.random());
      }
    }
    /*
    // constraint to prevent infinite bouncing (when gravity on)
    if (s[offset+P_POSY] < -0.95 && Math.abs(s[offset+P_VELY]) < 0.11) {
      s[offset+P_VELY] = 0;
    }
    */

    
    if (circOn) {
      // check if beyond some boundary AND in some range (in the other dimension)
      // the ___ wall of the () section
      // bottom (top) wall
      if (s[offset+P_POSY] < 0.8 && s[offset+P_POSY] > 0.6 && s[offset+P_POSX] < 0.79 && s[offset+P_POSX] > -0.8) {
        s[offset+P_POSY] = 0.99;
        s[offset+P_VELY] += (0.2*Math.random() - 0.2*Math.random());
      }
      // right (left) wall
      if (s[offset+P_POSX] > -0.8 && s[offset+P_POSX] < -0.6 && s[offset+P_POSY] < 0.79 && s[offset+P_POSY] > -0.8) {
        s[offset+P_POSX] = -0.99;
        s[offset+P_VELX] += (0.2*Math.random() - 0.2*Math.random());
      }
      // left (right) wall
      if (s[offset+P_POSX] < 0.8 && s[offset+P_POSX] > 0.6 && s[offset+P_POSY] < 0.8 && s[offset+P_POSY] > -0.79) {
        s[offset+P_POSX] = 0.99;
        s[offset+P_VELX] += (0.2*Math.random() - 0.2*Math.random());
      }
      // top (bottom) wall
      if (s[offset+P_POSY] > -0.8 && s[offset+P_POSY] < -0.6 && s[offset+P_POSX] < 0.8 && s[offset+P_POSX] > -0.79) {
        s[offset+P_POSY] = -0.99;
        s[offset+P_VELY] += (0.2*Math.random() - 0.2*Math.random());
      }
    }
  }
}



// user input handlers
function circuitOn() {
//==============================================================================
  for (var i = 0; i < f.length; i++) {
    f[i].voltage = 10.0;
    dragOn = 1;
  }
}

function circuitOff() {
//==============================================================================
  for (var i = 0; i < f.length; i++) {
    f[i].voltage = 0;
    dragOn = 0;
  }
}

function Euler() {
  Solver = 0;
}

function Midpoint() {
  Solver = 1;
}

function keydown(ev, gl, u_ViewMatrix, viewMatrix) {
//------------------------------------------------------
//HTML calls this'Event handler' or 'callback function' when we press a key:

    if(ev.keyCode == 39) { // The right arrow key was pressed
        g_EyeZrot += 0.1;    // INCREASED for perspective camera)
    } else 
    if (ev.keyCode == 37) { // The left arrow key was pressed
        g_EyeZrot -= 0.1;    // INCREASED for perspective camera)
    } else
    if(ev.keyCode == 38) { // The up arrow key was pressed
        g_EyeXrot += 0.1;    // INCREASED for perspective camera)
    } else
    if(ev.keyCode == 40) { // The down arrow key was pressed
        g_EyeXrot -= 0.1;    // INCREASED for perspective camera)
    } else
    if(ev.keyCode == 33) { // The "page up" key was pressed
        g_EyeRadius += 0.1;    // INCREASED for perspective camera)
    } else
    if(ev.keyCode == 34) { // The "page down" key was pressed
        g_EyeRadius -= 0.1;    // INCREASED for perspective camera)
    } else  { return; } // Prevent the unnecessary drawing
}

function makeGroundGrid() {
//==============================================================================
// Create a list of vertices that create a large grid of lines in the x,y plane
// centered at x=y=z=0.  Draw this shape using the GL_LINES primitive.

  var xcount = 100;     // # of lines to draw in x,y to make the grid.
  var ycount = 100;   
  var xymax = 50.0;     // grid size; extends to cover +/-xymax in x and y.
  

  // Create an (global) array to hold this ground-plane's vertices:
  gndVerts = new Float32Array(PartEleCount*2*(xcount+ycount)); // makes 14 fields for each vertex
            // draw a grid made of xcount+ycount lines; 2 vertices per line.
            
  var xgap = xymax/(xcount-1);    // HALF-spacing between lines in x,y;
  var ygap = xymax/(ycount-1);    // (why half? because v==(0line number/2))

  // First, step thru x values as we make vertical lines of constant-y:
  for(v=0, j=0; v<2*xcount; v++, j+= PartEleCount) {
    if(v%2==0) {  // put even-numbered vertices at (xnow, -xymax, 0)
      gndVerts[j+P_POSX] = -xymax + (v)*xgap;  // x
      gndVerts[j+P_POSY] = -xymax;               // y
      gndVerts[j+P_POSZ] = 0.0;                  // z
    }
    else {        // put odd-numbered vertices at (xnow, +xymax, 0).
      gndVerts[j+P_POSX] = -xymax + (v-1)*xgap;  // x
      gndVerts[j+P_POSY] = xymax;                // y
      gndVerts[j+P_POSZ] = 0.0;                  // z
    }
      gndVerts[j+P_CRED] = 1.0;
      gndVerts[j+P_CGRN] = 1.0;
      gndVerts[j+P_CBLU] = 0.3;
  }
  // Second, step thru y values as wqe make horizontal lines of constant-y:
  // (don't re-initialize j--we're adding more vertices to the array)
  for(v=0; v<2*ycount; v++, j+= PartEleCount) {
    if(v%2==0) {    // put even-numbered vertices at (-xymax, ynow, 0)
      gndVerts[j+P_POSX] = -xymax;               // x
      gndVerts[j+P_POSY] = -xymax + (v  )*ygap;  // y
      gndVerts[j+P_POSZ] = 0.0;                  // z
    }
    else {          // put odd-numbered vertices at (+xymax, ynow, 0).
      gndVerts[j+P_POSX] = xymax;                // x
      gndVerts[j+P_POSY] = -xymax + (v-1)*ygap;  // y
      gndVerts[j+P_POSZ] = 0.0;                  // z
    }
    gndVerts[j+P_CRED] = 0.5;     // red
    gndVerts[j+P_CGRN] = 1.0;     // grn
    gndVerts[j+P_CBLU] = 0.5;     // blu
  }
}

function makeCircuit() {
//==============================================================================
// Create a list of vertices that create a large grid of lines in the x,y plane
// centered at x=y=z=0.  Draw this shape using the GL_LINES primitive.
  var numPts = 100;
  var numZcols = 4;
  var zSpacing = 0.2/(numZcols);
  console.log('zspacing =', zSpacing);
  var spacing = 1.8/(numPts/4 + 1);
  circVerts = new Float32Array(PartEleCount * numPts * numZcols); // makes 14 fields for each vertex
            // draw a grid made of xcount+ycount lines; 2 vertices per line.
  for (var j = 0; j < numZcols; j++) {
    console.log('j =', j);
    for (var i = 0; i < numPts; i++) {
      var offset = i*PartEleCount + (j * PartEleCount * numPts);
      var side = Math.floor(i/(numPts/4));
      //console.log('side', side);
      circVerts[offset+P_MASS] = 10000;
      circVerts[offset+P_SIZE] = 5;
      if (side == 0) { // top side
        //console.log('top side');
        if (j % 3 == 0) { // place electron in middle
          circVerts[offset+P_POSX] = -0.9 + i*spacing;
          circVerts[offset+P_POSY] = 0.9;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing;  
        }
        else if (j % 3 == 1) {
          circVerts[offset+P_POSX] = -0.9 + i*spacing;
          circVerts[offset+P_POSY] = 0.95;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing;  
        }
        else if (j % 3 == 2) {
          circVerts[offset+P_POSX] = -0.9 + i*spacing;
          circVerts[offset+P_POSY] = 0.85;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing;  
        }
      } else if (side == 1) { // right side
        //console.log('right side');
        if (j % 3 == 0) { // place electron in middle
          circVerts[offset+P_POSX] = 0.9;
          circVerts[offset+P_POSY] = 0.9 - (i - (numPts/4)) * spacing;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing;  
        }
        else if (j % 3 == 1) {
          circVerts[offset+P_POSX] = 0.95;
          circVerts[offset+P_POSY] = 0.9 - (i - (numPts/4)) * spacing;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing; 
        }
        else if (j % 3 == 2) {
          circVerts[offset+P_POSX] = 0.85;
          circVerts[offset+P_POSY] = 0.9 - (i - (numPts/4)) * spacing;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing; 
        }
      } else if (side == 2) { // bottom side
        //console.log('bottom side');
        if (j % 3 == 0) { // place electron in middle
          circVerts[offset+P_POSX] = 0.9 - (i - 2*(numPts/4)) * spacing;
          circVerts[offset+P_POSY] = -0.9;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing;  
        }
        else if (j % 3 == 1) {
          circVerts[offset+P_POSX] = 0.9 - (i - 2*(numPts/4)) * spacing;
          circVerts[offset+P_POSY] = -0.95;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing;  
        }
        else if (j % 3 == 2) {
          circVerts[offset+P_POSX] = 0.9 - (i - 2*(numPts/4)) * spacing;
          circVerts[offset+P_POSY] = -0.85;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing;    
        }
      } else if (side == 3) { // left side
        //console.log('left side');
        if (j % 3 == 0) { // place electron in middle
          circVerts[offset+P_POSX] = -0.9;
          circVerts[offset+P_POSY] = -0.9 + (i - 3*(numPts/4)) * spacing;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing;  
        }
        else if (j % 3 == 1) {
          circVerts[offset+P_POSX] = -0.95;
          circVerts[offset+P_POSY] = -0.9 + (i - 3*(numPts/4)) * spacing;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing; 
        }
        else if (j % 3 == 2) {
          circVerts[offset+P_POSX] = -0.85;
          circVerts[offset+P_POSY] = -0.9 + (i - 3*(numPts/4)) * spacing;
          circVerts[offset+P_POSZ] = -0.1 + j*zSpacing; 
        }  
      }
      circVerts[offset+P_VELX] = 0;
      circVerts[offset+P_VELY] = 0;
      circVerts[offset+P_VELZ] = 0;
      circVerts[offset+P_FORX] = 0;
      circVerts[offset+P_FORY] = 0;
      circVerts[offset+P_FORZ] = 0;
      circVerts[offset+P_CRED] = 1.0;
      circVerts[offset+P_CBLU] = 0;
      circVerts[offset+P_CGRN] = 0;
      circVerts[offset+P_TPRT] = 1.0;
      }
    }     
}

function initVertexBuffersNew(gl) {
//==============================================================================

  makeCircuit();

  // How much space to store all the shapes in one array?
  // (no 'var' means this is a global variable)
  mySiz = s.length + circVerts.length;

  // How many vertices total?
  var nn = mySiz / PartEleCount;
  console.log('nn is', nn, 'mySiz is', mySiz, 'floatsPerVertex is', PartEleCount);

  // Copy all shapes into one big Float32 array:
  var verticesColors = new Float32Array(mySiz);
  // Copy them:  remember where to start for each shape:
  particleStart = 0;              // we store the particles.
  for(i=0; i< s.length; i++) {
    verticesColors[i] = s[i];
  } 
  circStart = i;           // next we'll store the ground-plane;
  for(j=0; j< circVerts.length; i++, j++) {
    verticesColors[i] = circVerts[j];
    }
    // Create a buffer object
  var vertexColorbuffer = gl.createBuffer();  
  if (!vertexColorbuffer) {
    console.log('Failed to create the buffer object');
    return -1;
  }

  // Write vertex information to buffer object
  gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorbuffer);
  gl.bufferData(gl.ARRAY_BUFFER, verticesColors, gl.DYNAMIC_DRAW);

  var FSIZE = verticesColors.BYTES_PER_ELEMENT;
  // Assign the buffer object to a_Position and enable the assignment
  var a_PositionID = gl.getAttribLocation(gl.program, 'a_Position');
  if(a_PositionID < 0) {
    console.log('Failed to get the storage location of a_Position');
    return -1;
  }
  gl.vertexAttribPointer(a_PositionID, 3, gl.FLOAT, false, FSIZE*PartEleCount, P_POSX*FSIZE);
                          // shader location, vars to read, type of vars, normalized, stride, offset
  gl.enableVertexAttribArray(a_PositionID);
  // Assign the buffer object to a_Color and enable the assignment
  var a_Color = gl.getAttribLocation(gl.program, 'a_Color');
  if(a_Color < 0) {
    console.log('Failed to get the storage location of a_Color');
    return -1;
  }
  gl.vertexAttribPointer(a_Color, 4, gl.FLOAT, false, FSIZE * PartEleCount, P_CRED*FSIZE);
  gl.enableVertexAttribArray(a_Color);

  // point diameters
  a_diamID = gl.getAttribLocation(gl.program, 'a_diam');
  if(a_diamID < 0) {
    console.log('Failed to get the storage location of scalar a_diam');
    return -1;
  }
  gl.vertexAttribPointer(
    a_diamID,     //index == attribute var. name used in the shader pgm.
    1,            // size == how many dimensions for this attribute: 1,2,3 or 4?
    gl.FLOAT,     // type == what data type did we use for those numbers?
    false,        // isNormalized == are these fixed-point values that we need
                  //                  to normalize before use? true or false
    PartEleCount*FSIZE,// stride == #bytes (of other, interleaved data) between 
                      // separating OUR values?
    P_SIZE*FSIZE); // Offset -- how many bytes from START of buffer to the
                      // value we will actually use?  We start with position.
  // Enable this assignment of the a_Position variable to the bound buffer:
  gl.enableVertexAttribArray(a_diamID);



  return mySiz/PartEleCount; // return # of vertices
}
/*
function onPlusButtonY() {
//==============================================================================
  yacc += 0.1; 
}

function onMinusButtonY() {
//==============================================================================
  yacc -= 0.1; 
}

function onPlusButtonD() {
//==============================================================================
  DAMPING_CONSTANT -= 0.02;
}

function onMinusButtonD() {
//==============================================================================
  DAMPING_CONSTANT += 0.02; 
}

*/

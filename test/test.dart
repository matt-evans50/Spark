part of SparkProject;

//library CircuitInPieces;
//
//import 'dart:html';
//import 'dart:math';
//import 'dart:core';
//import 'dart:json' as json;
//
//part '../circuitAnalysis/Matrix.dart';
//part '../circuitAnalysis/LUDecomposition.dart';
//part '../circuitAnalysis/QRDecomposition.dart';

//part '../../SPARK-project/circuit-web/circuitAnalysis/KVLSolver.dart';
//part '../../SPARK-project/circuit-web/circuitAnalysis/Circuit.dart';

void test () {
  ControlPoint cp = new ControlPoint(0,0);
  Circuit circuit = new Circuit();
  Component battery = new Battery(0, 0, 100, 0, 1.0);
  battery.voltageDrop = 4.0;
  Component wire = new Wire(0, 0, 100, 0);
  Component resistor = new Resistor(0, 0, 100, 0, 1.0);
  resistor.resistance = 1.0;
  
  List<Node> nodes = new List<Node>();
  for (int i=0; i < 7; i++) {
    nodes.add(new Node());
  }
  List<Edge> edges = new List<Edge>();
  edges.add(new Edge(nodes[0], nodes[1])); // edge 0
  edges.add(new Edge(nodes[1], nodes[2])); // edge 1
  edges.add(new Edge(nodes[2], nodes[3])); // edge 2
  edges.add(new Edge(nodes[3], nodes[4])); // edge 3
  edges.add(new Edge(nodes[4], nodes[5])); // edge 4
  edges.add(new Edge(nodes[5], nodes[6])); // edge 5
  edges.add(new Edge(nodes[6], nodes[0])); // edge 6
  edges.add(new Edge(nodes[0], nodes[4])); // edge 7
  
  edges[0].component = new Wire(0, 0, 100, 0);
  edges[3].component = new Wire(0, 0, 100, 0);
  edges[4].component = new Wire(0, 0, 100, 0);
  edges[6].component = new Wire(0, 0, 100, 0);
  
  edges[1].component = new Resistor(0, 0, 100, 0, 1.0);
  edges[2].component = new Resistor(0, 0, 100, 0, 1.0);
  edges[5].component = new Resistor(0, 0, 100, 0, 1.0);
      
  edges[7].component = new Battery(0, 0, 100, 0, 1.0);
  
  nodes[0].adjacents.add(nodes[1]);
  nodes[0].adjacents.add(nodes[4]);
  nodes[0].adjacents.add(nodes[6]);
  
  nodes[1].adjacents.add(nodes[0]);
  nodes[1].adjacents.add(nodes[2]);

  nodes[2].adjacents.add(nodes[1]);
  nodes[2].adjacents.add(nodes[3]);

  nodes[3].adjacents.add(nodes[2]);
  nodes[3].adjacents.add(nodes[4]);

  nodes[4].adjacents.add(nodes[3]);
  nodes[4].adjacents.add(nodes[5]);
  nodes[4].adjacents.add(nodes[0]);
  
  nodes[5].adjacents.add(nodes[4]);
  nodes[5].adjacents.add(nodes[6]);

  nodes[6].adjacents.add(nodes[0]);
  nodes[6].adjacents.add(nodes[5]);

  
/*
  List<Node> nodes = new List<Node>();
  for (int i=0; i < 13; i++) {
    nodes.add(new Node(cp));
    nodes[i].index = i;
  }
  List<Edge> edges = new List<Edge>();
  edges.add(new Edge(nodes[0], nodes[1])); // edge 0
  edges.add(new Edge(nodes[1], nodes[2])); // edge 1
  edges.add(new Edge(nodes[2], nodes[3])); // edge 2
  edges.add(new Edge(nodes[3], nodes[4])); // edge 3
  edges.add(new Edge(nodes[4], nodes[5])); // edge 4
  edges.add(new Edge(nodes[5], nodes[6])); // edge 5
  edges.add(new Edge(nodes[6], nodes[7])); // edge 6
  edges.add(new Edge(nodes[7], nodes[8])); // edge 7
  edges.add(new Edge(nodes[0], nodes[7])); // edge 8
  edges.add(new Edge(nodes[7], nodes[1])); // edge 9
  edges.add(new Edge(nodes[2], nodes[8])); // edge 10
  edges.add(new Edge(nodes[6], nodes[8])); // edge 11
  edges.add(new Edge(nodes[2], nodes[5])); // edge 12
  edges.add(new Edge(nodes[3], nodes[5])); // edge 13

  edges.add(new Edge(nodes[9], nodes[10])); // edge 14
  edges.add(new Edge(nodes[10], nodes[11])); // edge 15
  edges.add(new Edge(nodes[11], nodes[9])); // edge 16
  edges.add(new Edge(nodes[11], nodes[12])); // edge 17
  
  nodes[0].adjacents.add(nodes[1]);
  nodes[0].adjacents.add(nodes[7]);

  nodes[1].adjacents.add(nodes[0]);
  nodes[1].adjacents.add(nodes[2]);
  nodes[1].adjacents.add(nodes[7]);

  nodes[2].adjacents.add(nodes[1]);
  nodes[2].adjacents.add(nodes[3]);
  nodes[2].adjacents.add(nodes[5]);
  nodes[2].adjacents.add(nodes[8]);

  nodes[3].adjacents.add(nodes[2]);
  nodes[3].adjacents.add(nodes[4]);
  nodes[3].adjacents.add(nodes[5]);

  nodes[4].adjacents.add(nodes[3]);
  nodes[4].adjacents.add(nodes[5]);

  nodes[5].adjacents.add(nodes[2]);
  nodes[5].adjacents.add(nodes[3]);
  nodes[5].adjacents.add(nodes[4]);
  nodes[5].adjacents.add(nodes[6]);

  nodes[6].adjacents.add(nodes[5]);
  nodes[6].adjacents.add(nodes[7]);
  nodes[6].adjacents.add(nodes[8]);

  nodes[7].adjacents.add(nodes[0]);
  nodes[7].adjacents.add(nodes[1]);
  nodes[7].adjacents.add(nodes[6]);
  nodes[7].adjacents.add(nodes[8]);

  nodes[8].adjacents.add(nodes[2]);
  nodes[8].adjacents.add(nodes[6]);
  nodes[8].adjacents.add(nodes[7]);
  
  nodes[9].adjacents.add(nodes[10]);
  nodes[9].adjacents.add(nodes[11]);
  
  nodes[10].adjacents.add(nodes[9]);
  nodes[10].adjacents.add(nodes[11]);
  
  nodes[11].adjacents.add(nodes[9]);
  nodes[11].adjacents.add(nodes[10]);
  nodes[11].adjacents.add(nodes[12]);
  
  nodes[12].adjacents.add(nodes[11]);
*/
  circuit.nodes = nodes;
  circuit.edges = edges;
  print(nodes.length);

  //findSpanningTree(graph);
  circuit.solve();
  print(circuit.solution.getArray());
//  var backEdges = edges.where((e) => e.label != 'tree'); //note: backEdges is a "lazy" iterable
//  List<Loop> loops = new List<Loop>();
//  for (Edge b in backEdges) {
//    loops.add(new Loop(b));
//  }


  var obj = [];
  var s;
  for (Node n in nodes) {

    if (nodes.indexOf(n) == 0 || nodes.indexOf(n) == 9) {
      s = {
               'node': nodes.indexOf(n),
               'visited': n.visited,
               'discover time': n.discoverTime,
               'parent': 'null',
               'CG label': n.graphLabel

      };
    }
    else {
      s = {
               'node': nodes.indexOf(n),
               'visited': n.visited,
               'discover time': n.discoverTime,
               'parent':nodes.indexOf(n.parent),
               'CG label': n.graphLabel
      };
      }

    obj.add(s);
  }
/*
  for (Edge e in edges) {
    s = {
               'edge label': e.label,
               'first': e.nodes[0].index,
               'second': e.nodes[1].index
      };
    obj.add(s);
    }
    */
  for (int i=0; i < circuit.loops.length; i++) {
    
    for (Edge e in circuit.loops[i].path) {
      s = {
                 'loop': i,
                 'edge label': e.label,
                 'first': nodes.indexOf(e.nodes[0]),
                 'second': nodes.indexOf(e.nodes[1]),
                 'component': e.component.type
        };
      obj.add(s);
    }
  }

  print(JSON.encode(obj));
  
  List<int> list1 = [1, 2, 3];
  List<int> list2 = [1, 2, 3];
  bool test = identical(list1, list2);
  print(test.toString());
}




/*
void main() {
  Matrix test = new Matrix(3, 3);

  //test.A = [[4, 3, 2], [6, 3, 2], [4, 2, 1]];
  //test.A = [[12, -51, 4], [6, 167, -68], [-4, 24, -41]];
  //test.A = [[1, 3, -2], [3, 5, 6], [2, 4, 3]];
  test.A = [[11, -8, -3], [-8, 14, -6], [-3, -6, 13]];
  Matrix rh = new Matrix(3,1);
  rh.A = [[12], [6], [0]];
  //rh.A = [[1], [1], [1]];
  //rh.A = [[5], [7], [8]];
//  test.set(0, 0, 4.0);
//  test.set(0, 1, 3.0);
//  test.set(1, 0, 6.0);
//  test.set(1, 1, 3.0);

  print(test.getArray());
  print(test.det());

  print(rh.getArray());
  print(test.solve(rh).getArray());


//  print(test.qr().getQ().getArray());
//  print(test.qr().getR().getArray());
//  print(test.qr().getH().getArray());

  //print(test.inverse().getArray());
//  print(test.lu().getL().getArray());
//  print(test.lu().getU().getArray());
//  print(test.lu().getDoublePivot());


//  test.set(1, 2, 1.2);
//  test.set(3, 3, 3.3);
//  test.set(5,3, 4.9);
  //test.set(4,3, 10.0);
//  print(test.getArray());
//  print(test.getMatrix4(1, 3, 1, 3).getArray());
//  print(test.transpose().getArray());
//  print(test.norm1());
//  print(test.normInf());
//  print(test.uminus().getArray());
//  print(test.uminus().normInf());
//  print(test.times(3.0).getArray());
//  print(test.times(3.0).minus(test).getArray());





//  double m, x;
//  int n;
//  List<List<double>> b;
//  List<double> c = new List<double>.filled(4, 1.2);
//
//  print(c);
//
//  m = test.A[1][1];
//  test.set(1, 1, 3.4);
//  m = test.get(1, 1);
//  print(test.get(1, 1));
//  n = test.getColumnDimension();
//  print(n);
//  b = test.getArray();
//  print(b);
}

*/
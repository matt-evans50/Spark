/*
 * Spark Models
 * Northwestern University
 * beheshti@u.northwestern.edu
 */
library Spark;

import 'dart:html';
import 'dart:math';
import '../NetTangoJS/core/ntango.dart';


part 'electron.dart';
part 'ion.dart';
part 'sparkModel.dart';

//part '../models/wire.dart';

WebSocket socket;
//void initWebSocket() {
//  socket = new WebSocket('ws://127.0.0.1:8887');
//  socket.onOpen.listen((evt) { print("socket opened."); });
//  socket.onError.listen((evt) { print("socket error."); });
//  socket.onMessage.listen((evt) { 
//    print(evt.data);
//    if (evt.data.startsWith("@ntango WIRE")) {
//      window.location.href = "wire.html";
//    } else if (evt.data.startsWith("@ntango RESISTOR")) {
//      window.location.href = "resistor.html";
//    }
//  });
//}




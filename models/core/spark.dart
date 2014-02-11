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




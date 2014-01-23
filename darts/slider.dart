part of SparkProject;

void genericSliderTouch(TouchEvent tframe) {
//    String who = c + "-slider";
//    String value = c + "-value";
//    print(value);
  InputElement slider = document.query("#generic-slider");
  Rectangle box = slider.getBoundingClientRect();
  num left = box.left + window.pageXOffset;
  num top = box.top + window.pageYOffset;
  num width = box.width;
  num tx = tframe.changedTouches[0].client.x - left;
  num ty = tframe.changedTouches[0].client.y - top;
  var min = double.parse(slider.min);
  var step = double.parse(slider.step);
  if (tx < width / 5.0) {
    slider.value = min.toString();
  } else if (tx < width * 2 / 5) {
    slider.value = ( min + step ).toString();
  } else if (tx < width * 3 / 5) {
    slider.value = (min + 2 * step).toString();
  } else if (tx < width * 4 / 5) {
    slider.value = (min + 3 * step).toString();
  } else {
    slider.value = (min + 4 * step).toString();
  }
  //genericChangeValue(int.parse(slider.value));

}

void genericChangeValue(num value) {
  Component c = theApp.genericSliderComponent; 
  switch (c.type) {
    case 'Battery':
      if (!(c as Battery).isBurnt) {
        c.voltageDrop = value;
        theApp.circuit.solve();
        App.repaint();
      }
      break;
    case 'Wire':
      break;
    case 'Resistor':
      c.resistance = value;
      theApp.circuit.solve();
      App.repaint();
      break;
    case 'Bulb':
      //query("#bulb-value").text = "${value} ohm";
      break;
  }

}
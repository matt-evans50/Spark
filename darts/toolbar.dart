
part of SparkProject;


class Toolbar {

  
  App app;
  String id; // html id for toolbar div tag
  Random rand = new Random();
   
  Toolbar(this.app, String id) {
    
    num centerX = app.width / 2;
    num centerY = app.height / 2;
    
    num w = app.width;
    num h = app.height;
    
    ButtonElement button;
    //InputElement slider;
    
    button = document.querySelector("$id #battery-button");
    if (button != null) {
      CssRect rect = button.borderEdge;
      button.onMouseDown.listen((evt) => createComponent(rect, "Battery"));
      button.onTouchStart.listen((evt) => createComponent(rect, "Battery"));
      //button.onTouchMove.listen((e) => createComponent(rect, "Battery"));
      //button.onMouseDown.listen((e) => window.onMouseUp.listen((evt) => createComponent(rect, "Battery")));
      
      
    }
  
    button = document.querySelector("$id #wire-button"); /* do not remove $id, it causes some errors! */
    if (button != null) {
      CssRect rect = button.borderEdge;
      button.onMouseDown.listen((evt) => createComponent(rect, "Wire"));
      button.onTouchStart.listen((evt) => createComponent(rect, "Wire"));
    }
    
    button = document.querySelector("$id #resistor-button");
    if (button != null) {
      CssRect rect = button.borderEdge;
      button.onMouseDown.listen((evt) => createComponent(rect, "Resistor"));
      button.onTouchStart.listen((evt) => createComponent(rect, "Resistor"));
    }
    
    button = document.querySelector("$id #bulb-button");
    if (button != null) {
      CssRect rect = button.borderEdge;
      button.onMouseDown.listen((evt) => createComponent(rect, "Bulb"));
      button.onTouchStart.listen((evt) => createComponent(rect, "Bulb"));
    }
    
    button = document.querySelector("$id #grid-button");
    if (button != null) button.onClick.listen((evt) => switchMode());
    
    button = document.querySelector("$id #reset-button");
    if (button != null) button.onClick.listen((evt) => this.app.reset());
     
//    button = document.querySelector("$id #help-button");
//    if (button != null) button.onClick.listen((evt) => this.app.help.show());
//     
    
    /* update the valuse of sliders, whenever it is changed */
    InputElement slider1 = document.querySelector("#battery-slider");
    if (slider1 != null) {
      changeValue("battery-value", double.parse(slider1.value)); /* initiate the slider value */
      //slider1.onChange.listen((e) => changeValue("battery-value", double.parse(slider1.value)));
      slider1.onTouchMove.listen((e) => sliderTouch(e, "#battery-slider"));
      slider1.onTouchEnd.listen((e) => changeValue("battery-value", double.parse(slider1.value)));
    }

    
    InputElement slider2 = document.querySelector("#wire-slider");
    //changeValue("wire-value", double.parse(slider.value));
    //slider.onChange.listen((evt) => changeValue("wire-value", double.parse(slider.value)));

    
    InputElement slider3 = document.querySelector("#resistor-slider");
    if (slider3 != null) {
    changeValue("resistor-value", double.parse(slider3.value));
    //slider3.onChange.listen((evt) => changeValue("resistor-value", double.parse(slider3.value)));
    slider3.onTouchMove.listen((e) => sliderTouch(e, "#resistor-slider"));
    slider3.onTouchEnd.listen((e) => changeValue("resistor-value", double.parse(slider3.value)));
    }
    
    InputElement slider4 = document.querySelector("#bulb-slider");
    if (slider4 != null) {
    changeValue("bulb-value", double.parse(slider4.value));
    slider4.onChange.listen((evt) => changeValue("bulb-value", double.parse(slider4.value)));
    slider4.onTouchMove.listen((e) => sliderTouch(e, "#bulb-slider"));
    slider4.onTouchEnd.listen((e) => changeValue("bulb-value", double.parse(slider4.value)));
    }
  }
  
  void test(Rectangle rect, Event e) {
    e.stopImmediatePropagation();
    window.onMouseUp.listen((evt) => createComponent(rect, "Battery"));
    
    print('stop please');
  }
  

  void switchMode () {
   app.gridsOn == true ? app.gridsOn = false : app.gridsOn = true;
   App.repaint();
   //print(this.app.gridsOn);
    
  }
  
  void createComponent(CssRect rect, String type) {
    num cx = rect.left + rect.width / 2 + rand.nextInt(24) - 12;
    num cy = rect.top + rect.height / 2 - rand.nextInt(24);
    switch (type) {
      case 'Battery':
        InputElement slider = querySelector("#battery-slider");
        var voltage = double.parse(slider.value);        
        theApp.components.add(new Battery(cx - 50, cy - 100, cx + 50, cy - 100, voltage));
        break;
      case 'Wire':
        theApp.components.add(new Wire(cx - 50, cy - 100, cx + 50, cy - 100));
        break;
      case 'Resistor':
        InputElement slider = querySelector("#resistor-slider");
        var resistance = double.parse(slider.value);
        theApp.components.add(new Resistor(cx - 50, cy - 100, cx + 50, cy - 100, resistance));
        break;
      case 'Bulb':
        InputElement slider = querySelector("#bulb-slider");
        var resistance = double.parse(slider.value);
        //var resistance = 1.0;
        theApp.components.add(new Bulb(cx - 50, cy - 100, cx + 50, cy - 100, resistance));
        break;
    }
  }

/*  
  void createWire(num w, num h) {
    num ex = App.rnd.nextInt(w - 100);
    num ey = App.rnd.nextInt(h - 150);
    theApp.components.add(new Wire(ex, ey, ex + 100, ey)); 
  }
*/  

}

void sliderTouch(TouchEvent tframe, String who) {
//    String who = c + "-slider";
//    String value = c + "-value";
//    print(value);
  InputElement slider = document.querySelector(who);
  Rectangle box = slider.getBoundingClientRect();
  num left = box.left + window.pageXOffset;
  num top = box.top + window.pageYOffset;
  num width = box.width;
  num tx = tframe.changedTouches[0].client.x - left;
  num ty = tframe.changedTouches[0].client.y - top;
  if (tx < width / 5.0) {
    slider.value = "1.0";
  } else if (tx < width * 2 / 5) {
    slider.value = "1.5";
  } else if (tx < width * 3 / 5) {
    slider.value = "2";
  } else if (tx < width * 4 / 5) {
    slider.value = "2.5";
  } else {
    slider.value = "3.0";
  }

}

void changeValue(String who, num value) {
  switch (who) {
    case 'battery-value':
      querySelector("#battery-value").text = "Voltage = ${value}";
      break;
    case 'wire-value':
      break;
    case 'resistor-value':
      querySelector("#resistor-value").text = "Resistance = ${value}";
      break;
    case 'bulb-value':
      //query("#bulb-value").text = "${value} ohm";
      break;
  }

}

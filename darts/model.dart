part of SparkProject;


class Model {
  
  App app;
  String id; // html id for toolbar div tag
  Random rand = new Random();
  Component component;
   
  Model(this.app, String id) {
    
    ButtonElement button;
    button = document.query("$id .close-button");
    if (button != null) button.onClick.listen((e) => closeModel());
    
    button = document.query("$id .help-button");
    if (button != null) button.onClick.listen((e) => theApp.help.show());
    
  }
  
  void closeModel() {
    document.query("#model1").style.display = "none";
    theApp.model1.component = null;
    theApp.help.close();    
  }
  
  void launchModel(Component c) {
    
    theApp.model1.component = c;
    String i = c.current.toString();
    String r = c.resistance.toString();
    String v = c.voltageDrop.toString();
    
    IFrameElement frame = document.query("div#model1 #model-frame");
//    if (c is Wire) frame.src = "models/wire.html?i=${i}&r=${r}&v=${v}";
//    else frame.src = "models/resistor.html?i=${i}&r=${r}&v=${v}";
    if (c is Wire) frame.src = "http://spark-project.appspot.com/Wire?i=${i}&r=${r}&v=${v}";
    else frame.src = "http://spark-project.appspot.com/Resistor?i=${i}&r=${r}&v=${v}";
    //frame.src = "http://spark-project.appspot.com/Wire?i=${i}&r=${r}&v=${v}";
    
    document.query("#model1").style.display = "block";
    theApp.help.initiate();
  }
  
  /** update the model if it is open 
   */ 
  updateModel() {
    Component c = theApp.model1.component;
    if (document.query("#model1").style.display == "block" && !(c is Battery)) {
      
      String i = c.current.toString();
      String r = c.resistance.toString();
      String v = c.voltageDrop.toString();
      //frame.src = "http://spark-project.appspot.com/Resistor?i=${i}&r=${r}&v=${v}";
      IFrameElement frame = document.query("div#model1 #model-frame");
      String frameSource;
      if (c is Wire) {
        frameSource = "http://spark-project.appspot.com/Wire?i=${i}&r=${r}&v=${v}";
      }
      else { // resistor or bulb
        frameSource = "http://spark-project.appspot.com/Resistor?i=${i}&r=${r}&v=${v}";
      }
      print(frame.src);
      if (!frame.src.endsWith(frameSource)) frame.src = frameSource; // update only if it is updated!
    }
  }

}
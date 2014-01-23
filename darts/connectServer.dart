part of SparkProject;

void sendJSONData(String components) {
  HttpRequest request = new HttpRequest(); // create a new XHR

  // add an event handler that is called when the request finishes
  request.onReadyStateChange.listen((_) {
    if (request.readyState == HttpRequest.DONE &&
        (request.status == 200 || request.status == 0)) {
      // data saved OK.
      print("succesfully posted json data");
      print(request.responseText); // output the response from the server
    }
  });

  // POST the data to the server
  var url = "http://spark-project.appspot.com/";
  request.open("POST", url, async: false);
  request.setRequestHeader("Content-type","application/x-www-form-urlencoded");
  //request.send("components="+components); // perform the async POST
  
}
  

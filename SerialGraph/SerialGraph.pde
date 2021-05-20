import processing.serial.*;
boolean running = false; 
boolean fauxdata;

Serial myPort;  
int val; 
String number = "0";
int[] redvals;
int[] greenvals;
int[] xvals;
int[] bytes;
int byteCount;
int graphHeight;
int graphWidth;
int divisor;
int maxDivisor;
PrintWriter output;
PImage resetImage;
int startTime;
int currentTime;
int buttonHeight;
int buttonWidth;
int space;
int startX;
int startY;
int baselineX;
int baselineY;
int plusX;
int plusY;
int minusX;
int minusY;
int maxGreenX;
int maxGreenY;
int maxRedX;
int maxRedY;
int averageGreenX;
int averageGreenY;
int averageRedX;
int averageRedY;
int maxResetX;
int maxResetY;
int scalarWidth;
int gapWidth;
PFont f;
PFont exitFont;
PFont resetFont;
int baseRed = 0;
int baseGreen = 0;
int labelWidth;
int labelHeight;
int resetWidth;
int resetHeight;
int divisionHeight;
int greenMax = 0;
int redMax = 0;
int greenAverage = 0;
int redAverage = 0;



void setup() 
{
  fauxdata=true;
  fullScreen();
  space = 10;
  gapWidth = 75;
  graphHeight = height/2;
  graphWidth = width-75;
  buttonHeight = (height-graphHeight-6*space)/3;
  buttonWidth = (width-gapWidth-6*space)*2/3;
  scalarWidth = (buttonWidth-10)/2;
  labelWidth = (width-buttonWidth-6*space)/2;
  labelHeight = (height-graphHeight-6*space)*3/7;
  resetWidth = (width-buttonWidth-5*space);
  resetHeight = (height-graphHeight-6*space)/7;
  startX = space*2;
  startY = 12+graphHeight+space;
  baselineX = space*2;
  baselineY = startY+buttonHeight+space;
  plusX = space*2;
  plusY = baselineY+buttonHeight+space;
  minusX = plusX+scalarWidth+space;
  minusY = baselineY+buttonHeight+space;
  maxGreenX = startX+buttonWidth+space;
  maxGreenY = 12+graphHeight+space;
  maxRedX = maxGreenX+labelWidth+space;
  maxRedY = 12+graphHeight+space;
  maxResetX = startX+buttonWidth+space;
  maxResetY = maxGreenY+labelHeight+space;
  averageGreenX = startX+buttonWidth+space;
  averageGreenY = maxResetY+resetHeight+space;
  averageRedX = averageGreenX+labelWidth+space;
  averageRedY = maxResetY+resetHeight+space;
  divisionHeight= graphHeight/5;
  divisor = 16384/graphHeight;
  maxDivisor = 16384/graphHeight;
  background(100);
  bytes = new int[graphWidth*4];
  redvals = new int[graphWidth];
  greenvals = new int[graphWidth];
  xvals = new int[graphWidth];
  if (!fauxdata){
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 115200);
    myPort.clear();
    myPort.write('A');
  }
  byteCount=0;
  f=createFont("Helvetica",buttonHeight*.9,true);
  textFont(f);
  textAlign(CENTER, CENTER);
  exitFont=createFont("Helvetica",40,true);
  resetFont=createFont("Helvetica",labelHeight*.3,true);
  drawButtons();
  
}

void draw()
{
  if(byteCount%4==0){
    for (int i=0; i<graphWidth; i++){
      redvals[i] = (bytes[4*i]*256 + bytes[4*i+1]);
      greenvals[i] = (bytes[4*i+2]*256 + bytes[4*i+3]);
    }
    greenAverage=0;
    redAverage=0;
    for (int i=0; i<10; i++){
    greenAverage=greenAverage+greenvals[graphWidth-11+i];
    redAverage=redAverage+greenvals[graphWidth-11+i];
    }
    greenAverage=greenAverage/10;
    redAverage=redAverage/10;
    if(redMax<redvals[graphWidth-1]) redMax = redvals[graphWidth-1];
    if(greenMax<greenvals[graphWidth-1]) greenMax = greenvals[graphWidth-1];
    clear();
    fill(0);
    rect(10,10,graphWidth, graphHeight+2);
    stroke(255,100,100);
    line(75, graphHeight+12-baseRed/divisor,75+graphWidth, graphHeight+12-baseRed/divisor);
    stroke(100,255,200);
    line(75, graphHeight+12-baseGreen/divisor,75+graphWidth, graphHeight+12-baseGreen/divisor);
    stroke(255, 0, 0);
    for (int i = 0; i < graphWidth-1;i++){
      line(i+75, graphHeight+12-redvals[i]/divisor, i+76, graphHeight+12-redvals[i+1]/divisor);
    }
    stroke(0,255,0);
    for (int i = 0; i < graphWidth-1;i++){
      line(i+75, graphHeight+12-greenvals[i]/divisor, i+76, graphHeight+12-greenvals[i+1]/divisor);
    }
    drawButtons();

  }
  if (fauxdata & running){
    int val = int(random(64));
    for (int i = 0; i < 4*graphWidth-1; i++){
      bytes[i]=bytes[i+1];
     }
    bytes[4*graphWidth-1] = val;
    byteCount++;
    if(byteCount%4==0){
       currentTime = millis()-startTime;
      for (int i = 0; i < graphWidth-1; i++){
        xvals[i]=xvals[i+1];
       }
      xvals[graphWidth-1] = currentTime;
      output.println(currentTime+","+(bytes[4*graphWidth-4]*256+bytes[4*graphWidth-3])+","+(bytes[4*graphWidth-2]*256+val));
    }
  }
}

void serialEvent(Serial myPort) {  
  int val = myPort.read();
  for (int i = 0; i < 4*graphWidth-1; i++){
    bytes[i]=bytes[i+1];
  }
  bytes[4*graphWidth-1] = val;
  byteCount++;
  if(byteCount%4==0){
    currentTime = millis()-startTime;
    for (int i = 0; i < graphWidth-1; i++){
      xvals[i]=xvals[i+1];
    }
    xvals[graphWidth-1] = currentTime;
    output.println(currentTime+","+(bytes[4*graphWidth-4]*256+bytes[4*graphWidth-3])+","+(bytes[4*graphWidth-2]*256+val));
    
  }
}

void mousePressed(){
  if ((mouseY > startY) && (mouseY < startY+buttonHeight)){//change of state button commands
    if ((mouseX > startX) && (mouseX <startX+buttonWidth)){
      running = !running;
      if (running){
        String writerName = "Data/Serial_Graph_Data_" + year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second()+ ".csv";
        output= createWriter(writerName);
        output.println("Partice Sizer Data from "+year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second());
        startTime = millis();
        if (!fauxdata) myPort.write('1');
      }
      else{
        if (!fauxdata) myPort.write('0');
        output.flush();
        output.close();
      }
    }
  }
    if ((mouseY > minusY) && (mouseY < minusY+buttonHeight)){//increase divisor button (zoom out)
    if ((mouseX > minusX) && (mouseX <minusX+scalarWidth)){
       divisor = 2*divisor;
       if (divisor>maxDivisor)divisor=maxDivisor;
      }
    }
    if ((mouseY > plusY) && (mouseY < plusY+buttonHeight)){//decrease divisor button (zoom in)
    if ((mouseX > plusX) && (mouseX <plusX+scalarWidth)){
       divisor = divisor/2;
       if (divisor==0)divisor=1;
      }
    }
    if ((mouseY > baselineY) && (mouseY < baselineY + buttonHeight)){//Baseline button
    if ((mouseX > baselineX) && (mouseX < baselineX + buttonWidth)){
       baseRed = 0;
       baseGreen = 0;
       int averages = 10;
       for (int i=0; i<averages; i++){
       baseRed=baseRed+redvals[graphWidth-1-i];
       baseGreen=baseGreen+greenvals[graphWidth-1-i];
       }
       baseRed=baseRed/averages;
       baseGreen=baseGreen/averages;
      }
    }
    if ((mouseY > 0) && (mouseY < 50)){
    if ((mouseX > 0) && (mouseX < 50)){
    exit();
    }
    }
    if ((mouseY > maxResetY) && (mouseY < maxResetY+resetHeight)){
    if ((mouseX > maxResetX) && (mouseX < maxResetX+resetWidth)){
    greenMax = 0;
    redMax = 0;
    }
    }
}

void drawButtons(){
  fill(255);
  stroke(0);
  rect(startX, startY, buttonWidth, buttonHeight, 7);//start button
  rect(baselineX, baselineY, buttonWidth, buttonHeight, 7);//baseline button
  rect(plusX, plusY, scalarWidth, buttonHeight, 7);//plus button (zoom in)
  rect(minusX, minusY, scalarWidth, buttonHeight, 7);//minus button (zoom out)
  rect(maxGreenX, maxGreenY, labelWidth, labelHeight, 7);//max green
  rect(maxRedX, maxRedY, labelWidth, labelHeight, 7);//max red
  rect(maxResetX, maxResetY, resetWidth, resetHeight, 7);//reset button
  rect(averageGreenX, averageGreenY, labelWidth, labelHeight, 7);//Green average
  rect(averageRedX, averageRedY, labelWidth, labelHeight, 7);
  rect(0,0,50,50);//close button
  rect(0, 0, width, space);
  rect(width-space, 0, space, height);
  rect(0, height-space, width, space);
  rect(0, 0, space, height);
  fill(0);
  textFont(f);
  if(running) text("STOP",startX+buttonWidth/2,startY+buttonHeight/2-space*2);
  else text("START",startX+buttonWidth/2,startY+buttonHeight/2-space*2);
  text("ZOOM +", plusX+scalarWidth/2,plusY+buttonHeight/2-space*2);
  text("ZOOM -", minusX+scalarWidth/2,minusY+buttonHeight/2-space*2);
  text("BASELINE", baselineX+buttonWidth/2, baselineY+buttonHeight/2-space*2);
  textFont(f,labelHeight*.4);
  text(greenMax, maxGreenX+labelWidth/2, maxGreenY+labelHeight/2);
  text(redMax, maxRedX+labelWidth/2, maxRedY+labelHeight/2);
  text(greenAverage, averageGreenX+labelWidth/2, averageGreenY+labelHeight/2);
  text(redAverage, averageRedX+labelWidth/2, averageRedY+labelHeight/2);
  textFont(resetFont);
  text("Max Reset", maxResetX+resetWidth/2, maxResetY+resetHeight/2-space);
  textFont(resetFont, labelHeight*.15);
  text("Green Max (nm)", maxGreenX+labelWidth/2, maxGreenY+15);
  text("Red Max (nm)", maxRedX+labelWidth/2, maxRedY+15);
  text("Green Average (nm)", averageGreenX+labelWidth/2, averageGreenY+15);
  text("Red Average (nm)", averageRedX+labelWidth/2, averageRedY+15);
  fill(255,0,0);
  textFont(exitFont);
  text("X",30,25);
}
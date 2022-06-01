// importing libraries
import controlP5.*;
import meter.*;
import grafica.*;
import processing.serial.*;
import processing.sound.*;

// variable declaration
PImage img, img2, img3;
ControlP5 cp5;
Button start_button, settings_button, homescreen_button, logs_button, back_button, set_bang;
// Bang set_bang;
Slider audio_slider;
float audioValue;
boolean meter_view, fahrenheit, error;
Icon meter_view_icon, temp_scale_icon;
Meter m;

GPlot plot;
GPointsArray points;
Textfield thr_textField;
Serial myPort;
String textValue;

AudioSample sample;

String button_start_name = "Start";
String button_settings_name = "Settings";
String button_homescreen_name = "Homescreen";
String button_logs_name = "Logs";
String button_back_name = "Back";
String bang_set_name = "Set";
String check;
String val;

int page = 1; //define the current page (0: settings, 1: homescreen, 2: current values, 3: trend over time)
int k = 0 , l = 1000;
float temp, thr_C = 30.0, thr_F = 86.0;
int humidity;

void setup()
{
  size(1200, 800);
  windowResize(600,800);
  surface.setResizable(true);

  myPort = new Serial(this, "COM3", 9600); 
  
  createControls();
  createPlot();
  createAlarmSound();
}

void draw()
{
  switch(page)
  {
    case 0:
      settingsPage();
      break;
    case 1:
      homePage();
      break;
    case 2:
      valuesPage();
      break;
    case 3:
      trendPage();
      break;
  }
}

void homePage()
{
  windowResize(600, 800);
  background(255);
  
  start_button.show();
  settings_button.show();

  img = loadImage("img/logo.png");
  imageMode(CENTER);
  image(img, width/2, height/4, width*0.5, height*0.35);

  fill(0);
  textFont(createFont("arial bold", 60));
  textAlign(CENTER);
  text("Welcome", width/2, height*0.55);

  
}

void valuesPage()
{

  windowResize(700,800);
  background(255);

  read_data();

  imageMode(CORNER);
  img = loadImage("img/logo1.png");
  image(img, 0, 0, 100, 100);

  homescreen_button
    .setPosition(width*0.65,height*0.9)
    .show();

  logs_button
    .setPosition(width*0.65,height*0.8)
    .show();


  if (fahrenheit == false)
  {
    if (meter_view == false)
    {
      if (!inThrRange(temp, 'C'))
        img2 = loadImage("img/thermo_red.png");
      else
        img2 = loadImage("img/thermo.png");
      image(img2, -30, 140, 400,600);
      Draw_Thermometer_C(temp);
      textSize(30);
      text("°C", 168, 145);
    }
    else
    {
      Draw_Meter_C(temp);
      Draw_Meter_H(humidity);
    }

    textSize(50);
    if (inThrRange(temp, 'C'))
    { 
      fill(0);
      text(str(temp)+" °C", 500, 250);
    }
    else
    {
      fill(255,0,0);
      text(str(temp)+" °C", 500, 250);
    }

  }
  else
  {
    if (meter_view == false)
    {
      if (!inThrRange(temp, 'F'))
        img2 = loadImage("img/thermo_red.png");
      else
        img2 = loadImage("img/thermo.png");
      
      image(img2, -30, 140, 400,600);
      Draw_Thermometer_F(temp);
      textSize(30);
      text("°F", 168, 145);
    }
    else
    {
      Draw_Meter_F(temp);
      Draw_Meter_H(humidity);
    }

    textSize(50);

    if (inThrRange(temp, 'F'))
    { 
      fill(0);
      text(str(temp)+" °F", 500, 250);
    }
    else
    {
      fill(255,0,0);
      text(str(temp)+" °F", 500, 250);
    }
  }

  img3 = loadImage("img/drop2.png");
  image(img3, 340, 350, 660*0.3, 380*0.3);

  textSize(45);
  fill(0);
  text(str(humidity) + " %", 550, 425);

  if (!fahrenheit)
  {
    if (inThrRange(temp, 'C'))
      stopAlarm();
    else
      activateAlarm();
  }
  else
  {
    if (inThrRange(temp, 'F'))
      stopAlarm();
    else
      activateAlarm();
  }

}

void trendPage()
{
  
  windowResize(1200,800);
  background(255);
  
  read_data(); 
  
  textSize(45);
  textAlign(LEFT);
  if (!fahrenheit)
  {
    text("Temperature: " + str(temp) + " °C", 75, 150);
    text("Current thr: " + str(thr_C) + " °C", 700, 150);
  }
  else
  {
    text("Temperature: " + str(temp) + " °F", 75, 150);
    text("Current thr: " + str(thr_F) + " °F", 700, 150);
  }
  
  text("Humidity: " + str(humidity) + " %", 75, 225);

  thr_textField
    .setPosition(700, 200)
    .show();

  set_bang
    .setPosition(950, 200)
    .show();



  plot.beginDraw();
  plot.drawBackground();
  //plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.setPoints(points);
  plot.drawPoints();
  plot.drawLines();
  plot.endDraw();
  

  homescreen_button
    .setPosition(950, 700)
    .show();

  back_button
    .setPosition(950, 630)
    .show();

  if (fahrenheit)
    errorMessage_F();
  else
    errorMessage_C();
  
}

public void settingsPage()
{
  surface.setSize(600,800);
  background(255);
  
  homescreen_button
    .setPosition(width*0.6,height*0.9)
    .show();
  
  audio_slider
    .setPosition(width*0.4,height*0.35)
    .show();

  textSize(25);
  textAlign(LEFT);
  text("Alarm level",width*0.1,height*0.37);
  
  temp_scale_icon
    .setPosition(230,335)
    .show();

  textAlign(LEFT);
  text("Fahrenheit", width*0.1, 367);

  meter_view_icon
    .setPosition(230,410)
    .show();
  
  textAlign(LEFT);
  text("Meters View", width*0.1, 442);

 



  img = loadImage("img/logo.png");
  imageMode(CENTER);
  image(img, width/2, height*0.15, 160, 160);

}

public void Start()
{
  page = 2;
  start_button.hide();
  settings_button.hide();

}

public void Settings()
{
  page = 0;
  start_button.hide();
  settings_button.hide();


}

public void Homescreen()
{
  page = 1;
  homescreen_button.hide();
  audio_slider.hide();
  temp_scale_icon.hide();
  meter_view_icon.hide();
  logs_button.hide();
}

public void Logs()
{
  page = 3;
  k = 0;
  points = new GPointsArray(20);
  for (int j=-20; j<0; j++)
  {
    points.add(j,0);
  }
  homescreen_button.hide();
  logs_button.hide();
  if (fahrenheit)
  {
    plot.getYAxis().setAxisLabelText("T (°F)");
    plot.setYLim(75, 105);
  }
  else
  {
    plot.getYAxis().setAxisLabelText("T (°C)");
    plot.setYLim(25, 40);
  }
}

public void Back()
{
  page = 2;
  homescreen_button.hide();
  back_button.hide();
}

void Draw_Thermometer_C(float temp)
{
  int max_T = 40; //y = 200
  int min_T = 25; // y = 580
  int y = 0;
  for (int i = 0; i <= max_T-min_T; i++)
  {
    y = 200 + int(((580-200)/(max_T-min_T))*i);
    if (i%5 == 0)
    {
      fill(0);
      strokeWeight(9);
      stroke(0,0,0);
      line(200,y,230,y);
      textSize(25);
      text(str(max_T - i),255,y+9);
    }
    else
    {
      fill(0);
      stroke(0,0,0);
      strokeWeight(7);
      line(200,y,215,y);
    }
  }

  if (inThrRange(temp, 'C'))
  {
    fill(0);
    stroke(0, 0, 0);
  }
  else
  {
    fill(color(255,0,0));
    stroke(255, 0, 0);
  }

  int rect_temp = int((200-580)*(temp - min_T)/(max_T-min_T)+580);

  rectMode(CORNERS);  
  if (temp == 25)
    rect(163,640, 177, 580, 20);
  else
  {
    rect(163,640, 177, 580);
    rect(163,580,177,rect_temp, 20);
  }
}

void Draw_Thermometer_F(float temp)
{
  int max_T = 105; //y = 200
  int min_T = 75; // y = 580
  int y = 0;
   for (int i = 0; i <= max_T-min_T; i++)
  {
    y = 200 + int(((580-200)/(max_T-min_T))*i);
    if (i%5 == 0)
    {
      fill(0);
      strokeWeight(9);
      stroke(0,0,0);
      line(200,y,230,y);
      textSize(25);
      text(str(max_T - i),255,y+9);
    }
    else
    {
      fill(0);
      stroke(0,0,0);
      strokeWeight(7);
      line(200,y,215,y);
    }
  }

  if (inThrRange(temp, 'F'))
  {
    fill(0);
    stroke(0, 0, 0);
  }
  else
  {
    fill(color(255,0,0));
    stroke(255, 0, 0);
  }

  int rect_temp = int((200-580)*(temp - 75)/(105-75)+580);

  rectMode(CORNERS);  
  if (temp == C_to_F(25))
    rect(163,640, 177, 580, 20);
  else
  {
    rect(163,640, 177, 580);
    rect(163,580,177,rect_temp, 20);
  }
}

float C_to_F(float temp)
{
  return float(nf(temp*9/5 + 32, 0, 1));
}

float F_to_C(float temp)
{
  return float( nf((temp-32)*5/9, 0, 1) );
}

void Draw_Meter_C(float temp)
{
   m=new Meter(this, 15, 150, false);
   m.setMeterWidth(350);

   m.setTitleFontSize(30);
   m.setTitleFontName("Times new roman bold");
   m.setTitle("Temperature °C");
   
   m.setMaxScaleValue(40);
   m.setMinInputSignal(25);
   m.setMaxInputSignal(40);

   String[] scaleLabels= { "25", "30", "35", "40"};
   m.setScaleLabels(scaleLabels);
   m.setScaleFontSize(20);
   m.setScaleFontColor(color(0, 0, 0));

   m.setDisplayDigitalMeterValue(false);
   m.setArcColor(color(0, 0, 0));
   m.setArcThickness(6);
   m.setNeedleColor(color(0,0,0));
   m.setTicMarkThickness(5);

   m.setNeedleThickness(3);
   m.setFrameColor(color(255,255,255));

   m.updateMeter(int(temp));

}

void Draw_Meter_F(float temp)
{
   m=new Meter(this, 15, 150, false);
   m.setMeterWidth(350);

   m.setTitleFontSize(30);
   m.setTitleFontName("Times new roman bold");
   m.setTitle("Temperature °F");
   
   m.setMaxScaleValue(105);
   m.setMinInputSignal(75);
   m.setMaxInputSignal(105);

   String[] scaleLabels= { "75", "80", "85", "90", "95", "100", "105"};
   m.setScaleLabels(scaleLabels);
   m.setScaleFontSize(20);
   m.setScaleFontColor(color(0, 0, 0));

   m.setDisplayDigitalMeterValue(false);
   m.setArcColor(color(0, 0, 0));
   m.setArcThickness(6);
   m.setNeedleColor(color(0,0,0));
   m.setTicMarkThickness(5);

   m.setNeedleThickness(3);
   m.setFrameColor(color(255,255,255));

   m.updateMeter(int(temp));

}

void Draw_Meter_H(int humidity)
{
   m=new Meter(this, 15, 430, false);
   m.setMeterWidth(350);

   m.setTitleFontSize(30);
   m.setTitleFontName("Times new roman bold");
   m.setTitle("Humidity %");

   m.setMaxScaleValue(100);
   m.setMinInputSignal(0);
   m.setMaxInputSignal(100);
   

   String[] scaleLabels= { "0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"};
   m.setScaleLabels(scaleLabels);
   m.setScaleFontSize(20);
   m.setScaleFontColor(color(0, 0, 0));

   m.setDisplayDigitalMeterValue(false);
   m.setArcColor(color(0, 0, 0));
   m.setArcThickness(6);
   m.setNeedleColor(color(0,0,0));
   m.setTicMarkThickness(5);

   m.setNeedleThickness(3);
   m.setFrameColor(color(255,255,255));

   m.updateMeter(humidity);


}

void read_data()
{
  try {
  
    if (myPort.available()>0)
    {
        val = myPort.readStringUntil('\n');
        if (val.charAt(0) == 'T')
        {
          if (!fahrenheit)
            temp = float(val.substring(1));
          else
            temp = C_to_F(float(val.substring(1)));
          
          points.remove(0);
          points.add(k, temp);
          k++;
        }
        else if (val.charAt(0) == 'H')
        {
          humidity = int(float(val.substring(1)));
        }
    }
  }
  catch (Exception e){}
}

public void Set() {
  check = cp5.get(Textfield.class, "textValue").getText();
  if (!fahrenheit)
  {
    if (isValid_C(check))
    {
      thr_C = float(cp5.get(Textfield.class, "textValue").getText());
      myPort.write(str(thr_C));
      error = false;
    }
    else
    { 
      error = true;
    }
  }
  else
  {
    if (isValid_F(check))
    {
      thr_F = float(cp5.get(Textfield.class, "textValue").getText());
      myPort.write(str(F_to_C(thr_C)));
      error = false;
    }
    else
    { 
      error = true;
    }
  }

  cp5.get(Textfield.class, "textValue").clear();
}

boolean isValid_C(String str)
{
  if (str.matches("[2][5-9](\\.\\d+)?|[3][0-9](\\.\\d+)?|[4][0](\\.[0])?"))
    return true;
  else  
    return false;
}

boolean isValid_F(String str)
{
  if (str.matches("[7][5-9](\\.\\d+)?|[8-9][0-9](\\.\\d+)?|[10][0-5](\\.[0])?"))
    return true;
  else  
    return false;
}

void errorMessage_C()
{
  if (error)
  {
    textSize(15);
    textAlign(LEFT);
    text("The thr needs to be a positive number in the range [25,40] °C", 720, 280);
  }
}

void errorMessage_F()
{
  if (error)
  {
    textSize(15);
    textAlign(LEFT);
    text("The thr needs to be a positive number in the range [75,105] °F", 720, 280);
  }
}

void createControls()
{
  cp5 = new ControlP5(this);
  start_button = cp5.addButton(button_start_name)
     .setPosition(width*0.38,height*0.65)
     .setSize(int(width*0.24),50)
     .setFont(createFont("arial bold", 25))
     .setColorBackground(color(0,0,0))
     .setColorForeground(color(20,20,20))
     .hide()
     ;

  
  settings_button = cp5.addButton(button_settings_name)
     .setPosition(width*0.38,height*0.75)
     .setSize(int(width*0.24),50)
     .setFont(createFont("arial bold", 25))
     .setColorBackground(color(0,0,0))
     .setColorForeground(color(20,20,20))
     .hide()
     ;
  

  homescreen_button = cp5.addButton(button_homescreen_name)
     .setSize(int(width*0.35),50)
     .setFont(createFont("arial bold", 25))
     .setColorBackground(color(0,0,0))
     .setColorForeground(color(20,20,20))
     .hide()
     ;
  

  audio_slider = cp5.addSlider("audioValue")
     .setWidth(300)
     .setHeight(20)
     .setRange(0,1) 
     .setColorBackground(color(0,0,0))
     .setColorForeground(color(255,255,255))
     .setValue(0.4)
     .setNumberOfTickMarks(6)
     .setSliderMode(Slider.FLEXIBLE)
     .setColorActive(color(255,255,255))
     .hide()
     ;


  
  temp_scale_icon = cp5.addIcon("fahrenheit",10)
     .setSize(70,50)
     .setRoundedCorners(20)
     .setFont(createFont("font/fontawesome-webfont.ttf", 40))
     .setFontIcons(#00f205,#00f204)
     .setSwitch(true)
     .setColorBackground(color(0,0,0))
     .setColorForeground(color(0,0,0))
     .setColorActive(color(0,0,0)) 
     .hideBackground()
     .hide();
     ;

  
  meter_view_icon = cp5.addIcon("meter_view",10)
     .setSize(70,50)
     .setRoundedCorners(20)
     .setFont(createFont("font/fontawesome-webfont.ttf", 40))
     .setFontIcons(#00f205,#00f204)
     .setSwitch(true)
     .setColorBackground(color(0,0,0))
     .setColorForeground(color(0,0,0))
     .setColorActive(color(0,0,0)) 
     .hideBackground()
     .hide();
     ;

  
  logs_button = cp5.addButton(button_logs_name)
     .setSize(int(width*0.35),50)
     .setFont(createFont("arial bold", 25))
     .setColorBackground(color(0,0,0))
     .setColorForeground(color(20,20,20))
     .hide()
     ;

  back_button = cp5.addButton(button_back_name)
     .setSize(int(width*0.35),50)
     .setFont(createFont("arial bold", 25))
     .setColorBackground(color(0,0,0))
     .setColorForeground(color(20,20,20))
     .hide()
     ;

  thr_textField = cp5.addTextfield("textValue")
    .setSize(200, 40)
    .setFont(createFont("arial bold", 25))
    .setAutoClear(true)
    .setColorBackground(color(0, 0, 0))
    .setFocus(true)
    .setColorActive(color(0, 0, 0))
    .hide()
    ;


  set_bang = cp5.addButton(bang_set_name)
    .setSize(int(width*0.2),40)
    //.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
    .setFont(createFont("arial bold", 25))
    .setColorBackground(color(0,0,0))
  //  .setColorForeground(color(20,20,20))
    .hide()
    ;
}

void createPlot()
{
  plot = new GPlot(this);
  plot.setPos(10,320);
  plot.setDim(800,350);
  plot.getXAxis().setNTicks(20);
  plot.getXAxis().setLineWidth(3);
  plot.getXAxis().setTickLength(5);
  plot.getXAxis().setFontProperties("arial bold",color(0), 15);
  plot.getYAxis().setFontProperties("arial bold",color(0), 15);
  plot.getXAxis().getAxisLabel().setFontProperties("arial bold",color(0), 20);
  plot.getYAxis().getAxisLabel().setFontProperties("arial bold",color(0), 20);
  plot.getYAxis().setTickLength(5);
  plot.getYAxis().setLineWidth(3);
  plot.getYAxis().setAxisLabelText("T (°C)");
  plot.setYLim(25, 40);
  plot.getXAxis().setAxisLabelText("Time (s)");
  plot.setBgColor(color(255));
  plot.setBoxBgColor(color(255));
  plot.setBoxLineColor(color(255));

  points = new GPointsArray(20);
  for (int j=-20; j<0; j++)
  {
    points.add(j,0);
  }
}

void createAlarmSound()
{
  int resolution = 1000;
  float[] sinewave = new float[resolution];
  for (int i = 0; i < resolution; i++) 
  {
    sinewave[i] = sin(TWO_PI*i/resolution);
  }
  sample = new AudioSample(this, sinewave, 1200 * resolution);
}

void activateAlarm()
{
  sample.amp(audioValue);
  sample.loop();
}

void stopAlarm()
{
  sample.stop();
}

boolean inThrRange(float temp, char t)
{
  if (t == 'C')
  {
      if ((temp < thr_C - 2) || (temp > thr_C + 2))
        return false;
      else
        return true;
  }
  else
  {
      if ((temp < C_to_F(F_to_C(thr_F)-2)) || (temp > C_to_F(F_to_C(thr_F)-2)))
      {
        return false;
      }
      else
      {
        return true;
      }
  }

}

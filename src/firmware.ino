
#include <Wire.h>
#include <LiquidCrystal_I2C.h> // libreria per LCD
#include <DHT.h>
#include <DHT_U.h>
#define DHTTYPE DHT11

#define SENSOR A0  // PORTE
#define ON 12
#define PAD 7
#define LEDWARNING 3
#define LEDON 4
#define DHTPIN 2
DHT dht(DHTPIN, DHTTYPE);

#define RT0 10000   //DEFINE CARATTERISTICHE CIRCUITO
#define B 3600
#define T0 298  //temperatura per cui R0=10000
#define R1 10000 //resistenza in serie al sensore

LiquidCrystal_I2C lcd(0x27, 20, 4);

int k = 0;
float tot = 0.0;
float threshold = 30;
float range = 0.5;
boolean state = 0; //sistema spento
String myString;

void setup() {
  Wire.begin();
  Serial.begin(9600);

  dht.begin();

  lcd.init();
  lcd.backlight();

  pinMode(SENSOR, INPUT);
  pinMode(ON, INPUT);
  pinMode(PAD, OUTPUT);
  pinMode(LEDON, OUTPUT);
  pinMode(LEDWARNING, OUTPUT);
}

void loop() {

  if (digitalRead(ON) == HIGH && state == 0) { //sistema da off a on
    state = 1;
    delay(500);
  }
  if (digitalRead(ON) == HIGH && state == 1) { //sistema da on a off
    state = 0;
    delay(500);
  }


  float VSens = analogRead(SENSOR) / 1023.0 * 5; //CALCOLO TEMPERATURA, FORMULA??
  float RSens = (R1 / VSens) * (5 - VSens);
  float T = B / (log(RSens / RT0) + (B / T0)) - 273.15;

  int H = dht.readHumidity();

  Serial.print("T");
  Serial.println(T, 1);
  delay(500);
  Serial.print("H");
  Serial.println(H, 1);
  delay(500);

  lcd.setCursor(0, 0); //Print Temperatura LCD
  lcd.print("T:");
  lcd.print(T, 1);
  lcd.print((char) 223);
  lcd.print("C");
  lcd.setCursor (10, 0);
  lcd.print("H:");
  lcd.print(H);
  lcd.print("%");
  lcd.setCursor(0, 1);
  lcd.print("Threshold:");
  lcd.print(threshold, 1);
  lcd.print((char) 223);
  lcd.print("C");

  if (Serial.available() > 0) { //lettura threshold
    myString = Serial.readString();
    threshold = myString.toFloat();
  }

  if (state == 1) {
    digitalWrite(LEDON, HIGH);
    if (T < threshold + range) { //temperature minore della soglia - tolleranza
      analogWrite(PAD, 250);
    }
    if (T > threshold - range) { //temperatura superiore alla soglia - tolleranza
      analogWrite(PAD, 0);
    }
    if (T < threshold - 2 || T > threshold + 2) {
      digitalWrite(LEDWARNING, HIGH);
    } else {
      digitalWrite (LEDWARNING, LOW);
    }
  }
  else {
    analogWrite(PAD, 0);
    digitalWrite(LEDON, LOW);
    digitalWrite(LEDWARNING, LOW);
  }
}

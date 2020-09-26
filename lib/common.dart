import 'dart:math';

import 'package:flutter/material.dart';

class MyIcons {
  static const IconData power_plug = IconData(0xF06A5, fontFamily: 'maticons');
  static const IconData power_plug_off = IconData(0xF06A6, fontFamily: 'maticons');
  static const IconData lightbulb_on = IconData(0xF06E8, fontFamily: 'maticons');
  static const IconData lightbulb_off = IconData(0xF0E4F, fontFamily: 'maticons');
  static const IconData audio_video = IconData(0xF093D, fontFamily: 'maticons');
  static const IconData desktop = IconData(0xF01C4, fontFamily: 'maticons');
  static const IconData tv = IconData(0xF0839, fontFamily: 'maticons');
  static const IconData youtube = IconData(0xF05C3, fontFamily: 'maticons');
  static const IconData spotify = IconData(0xF04C7, fontFamily: 'maticons');
  static const IconData hbo_go = IconData(0xF0C02, fontFamily: 'maticons');
  static const IconData netflix = IconData(0xF0746, fontFamily: 'maticons');
  static const IconData cast = IconData(0xF0118, fontFamily: 'maticons');
  static const IconData cast_off = IconData(0xF078A, fontFamily: 'maticons');
  static const IconData progress = IconData(0xF0995, fontFamily: 'maticons');
  static const IconData account_plus = IconData(0xF0014, fontFamily: 'maticons');
  static const IconData close_circle_outline = IconData(0xF015A, fontFamily: 'maticons');
  static const IconData candle = IconData(0xF05E2, fontFamily: 'maticons');
  static const IconData sunny = IconData(0xF05A8, fontFamily: 'maticons');
  static const IconData laptop = IconData(0xF0322, fontFamily: 'maticons');
  static const IconData desk_lamp = IconData(0xF095F, fontFamily: 'maticons');
  static const IconData floor_lamp = IconData(0xF08DD, fontFamily: 'maticons');
  static const IconData bed_lamp = IconData(0xF06B5, fontFamily: 'maticons');
  static const IconData down = IconData(0xF091D, fontFamily: 'maticons');
  static const IconData up = IconData(0xF041C, fontFamily: 'maticons');
  static const IconData shelf_lamp = IconData(0xF05A7, fontFamily: 'maticons');
  static const IconData fire = IconData(0xF0238, fontFamily: 'maticons');
  static const IconData r = IconData(0xF0AFF, fontFamily: 'maticons');
  static const IconData g = IconData(0xF0AF4, fontFamily: 'maticons');
  static const IconData b = IconData(0xF0AEF, fontFamily: 'maticons');
  static const IconData strip_led = IconData(0xF07D6, fontFamily: 'maticons');
  static const IconData star = IconData(0xF04D2, fontFamily: 'maticons');
  static const IconData twitch = IconData(0xF0543, fontFamily: 'maticons');
  static const IconData palette = IconData(0xF03D8, fontFamily: 'maticons');
  static const IconData temperature = IconData(0xF050F, fontFamily: 'maticons');
}

const Map<String, String> APP_PACKAGE_NAME = {
  "youtube": "com.google.android.youtube",
  "spotify": "com.spotify.music",
  "netflix": "com.netflix.mediaclient",
  "hbo_go": "eu.hbogo.android"
};

class ColorSliderData {
  IconData icon;
  double value;
  Color color;

  ColorSliderData(this.icon, this.value, this.color);
}

class ColorModeData {
  static const String color = "Color";
  static const String temp = "Temperature";
  int colorMode;

  ColorModeData(this.colorMode);
}

class Light {
  int id;
  String name;
  IconData icon;
  int power;

  Light(this.id, this.name, this.icon, this.power);
}

Color kelvinToColor(double temperature) {
  temperature /= 100;
  temperature *= 1.5;

  // Compute each color in turn.
  int red, green, blue;
  // First: red
  if (temperature <= 66)
    red = 255;
  else
  {
    // Note: the R-squared value for this approximation is .988
    red = (329.698727446 * (pow(temperature - 60, -0.1332047592))).toInt();
    red = red.clamp(0, 255);
  }

  // Second: green
  if (temperature <= 66)
    // Note: the R-squared value for this approximation is .996
    green = (99.4708025861 * log(temperature) - 161.1195681661).toInt();
  else
    // Note: the R-squared value for this approximation is .987
    green = (288.1221695283 * (pow(temperature - 60, -0.0755148492))).toInt();

  green = green.clamp(0, 255);

  // Third: blue
  if (temperature >= 66)
    blue = 255;
  else if (temperature <= 19)
    blue = 0;
  else
  {
    // Note: the R-squared value for this approximation is .998
    blue = (138.5177312231 * log(temperature - 10) - 305.0447927307).toInt();

    blue = blue.clamp(0, 255);
  }

  return Color.fromRGBO(red, green, blue, 1);
}
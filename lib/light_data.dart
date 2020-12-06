class LightData {
  int red = 255;
  int green = 255;
  int blue = 255;
  int brightness = 100;
  int ct = 4000;
  bool colorMode = false;
  bool powerMode = false;
  LightData secondLight;

  LightData(this.secondLight);

  LightData.fromJson(Map<String, dynamic> json) {
    red = json['red'];
    green = json['green'];
    blue = json['blue'];
    brightness = json['brightness'];
    ct = json['ct'];
    colorMode = json['color_mode'];
    powerMode = json['power_mode'];
    secondLight = json['second_light'] != null
        ? new LightData.fromJson(json['second_light'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['red'] = this.red;
    data['green'] = this.green;
    data['blue'] = this.blue;
    data['brightness'] = this.brightness;
    data['ct'] = this.ct;
    data['color_mode'] = this.colorMode;
    data['power_mode'] = this.powerMode;
    if (this.secondLight != null) {
      data['second_light'] = this.secondLight.toJson();
    }
    return data;
  }
}
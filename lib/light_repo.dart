import 'dart:convert';
import 'dart:ui';

import 'package:homeassistant/common.dart';
import 'package:homeassistant/light_data.dart';
import 'package:http/http.dart' as http;

class LightRepo {
  List<Light> repo = [];
  bool power = false;

  void addLight(Light light) {
    repo.add(light);
  }

  Light getLightById(String id) {
    return repo.firstWhere((element) => element.id == id);
  }

  bool isAnyPowered() {
    bool power = false;
    repo.forEach((light) {
      power = power ||
          light.data.powerMode ||
          (light.data.secondLight?.powerMode ?? false);
    });
    this.power = power;
    return power;
  }

  Future<LightRepo> updateLightData() async {
    var url = "${Config.API_PATH}v2/lights";

    final response = await http.get(url, headers: Config.HEADERS);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      Map.from(data).forEach(
          (key, value) => getLightById(key).data = LightData.fromJson(value));
      isAnyPowered();
    }
    return this;
  }

  Future<LightRepo> turnOffAllLights() async {
    var url = "${Config.API_PATH}v2/lights";

    final response = await http.delete(url, headers: Config.HEADERS);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      Map.from(data).forEach(
              (key, value) => getLightById(key).data = LightData.fromJson(value));
      isAnyPowered();
    }
    return this;
  }

  Future<LightRepo> setScene(String name) async {
    var url = "${Config.API_PATH}v2/scene/$name";

    final response = await http.post(url, headers: Config.HEADERS);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      Map.from(data).forEach(
              (key, value) => getLightById(key).data = LightData.fromJson(value));
      isAnyPowered();
    }
    return this;
  }
}

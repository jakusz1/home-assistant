import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'common.dart';
import 'package:http/http.dart' as http;


abstract class Device {
  bool power;
  String name;
  String source;


  Future<Device> switchPower();
  Future<Device> update();
}

class ProjectorDevice implements Device {
  @override
  String source = "";
  @override
  bool power = false;
  @override
  String name = "Projector";

  ProjectorDevice();

  ProjectorDevice.fromJson(Map<String, dynamic> json) {
    power = json['power'];
  }

  Future<ProjectorDevice> update() async {
    var url = "${Config.API_PATH}v2/projector";

    final response = await http.get(url, headers: Config.HEADERS);
    if (response.statusCode == 200) {
      ProjectorDevice updatedDev = ProjectorDevice.fromJson(json.decode(response.body));
      this.power = updatedDev.power;
    }
    return this;
  }

  @override
  Future<ProjectorDevice> switchPower() async {
    var url = "${Config.API_PATH}v2/projector";

    final response = await http.post(url, headers: Config.HEADERS);
    if (response.statusCode == 200) {
      ProjectorDevice updatedDev = ProjectorDevice.fromJson(json.decode(response.body));
      this.power = updatedDev.power;
    }
    return this;
  }
}

class DenonDevice implements Device {
  @override
  String source = "";
  @override
  bool power = false;
  @override
  String name = "Amplifier";

  DenonDevice();

  DenonDevice.fromJson(Map<String, dynamic> json) {
    power = json['power'];
    source = json['active_input'];
  }

  Future<DenonDevice> update() async {
    var url = "${Config.API_PATH}v2/denon";

    final response = await http.get(url, headers: Config.HEADERS);
    if (response.statusCode == 200) {
      DenonDevice updatedDev = DenonDevice.fromJson(json.decode(response.body));
      this.source = updatedDev.source;
      this.power = updatedDev.power;
    }
    return this;
  }

  @override
  Future<DenonDevice> switchPower() async {
    var url = "${Config.API_PATH}v2/denon/amp_power";

    final response = await http.post(url, headers: Config.HEADERS, body: json.encode({'count': 6}));
    if (response.statusCode == 200) {
      DenonDevice updatedDev = DenonDevice.fromJson(json.decode(response.body));
      this.source = updatedDev.source;
      if (updatedDev.power) {
        // wait for init
        await new Future.delayed(const Duration(seconds: 7));
      }
      this.power = updatedDev.power;
    }
    return this;
  }

  Future<DenonDevice> sendAction(String action) async {
    var url = "${Config.API_PATH}v2/denon/$action";

    final response = await http.post(url, headers: Config.HEADERS, body: json.encode({'count': action.contains("volume") ? 3 : 6}));
    if (response.statusCode == 200) {
      DenonDevice updatedDev = DenonDevice.fromJson(json.decode(response.body));
      this.source = updatedDev.source;
      this.power = updatedDev.power;
    }
    return this;
  }
}

class SamsungDevice implements Device {
  @override
  String source = "";
  @override
  bool power = false;
  @override
  String name = "TV";

  SamsungDevice();

  SamsungDevice.fromJson(Map<String, dynamic> json) {
    power = json['power'];
    source = json['visible_app'] ?? SourceEnum.PC;
  }

  Future<SamsungDevice> update() async {
    var url = "${Config.API_PATH}v2/tv";

    final response = await http.get(url, headers: Config.HEADERS);
    if (response.statusCode == 200) {
      SamsungDevice updatedDev = SamsungDevice.fromJson(json.decode(response.body));
      this.power = updatedDev.power;
      this.source = updatedDev.source;
    }
    return this;
  }

  @override
  Future<SamsungDevice> switchPower() async {
    var url = "${Config.API_PATH}v2/tv/power/${power ? 'off' : 'on'}";

    final response = await http.post(url, headers: Config.HEADERS);
    if (response.statusCode == 200) {
      SamsungDevice updatedDev = SamsungDevice.fromJson(json.decode(response.body));
      this.source = updatedDev.source;
      this.power = !this.power;
    }
    return this;
  }
  
  Future<SamsungDevice> setSource(String source) async {
    var url = "${Config.API_PATH}v2/tv/apps/$source/on";

    final response = await http.post(url, headers: Config.HEADERS);
    if (response.statusCode == 200) {
      SamsungDevice updatedDev = SamsungDevice.fromJson(json.decode(response.body));
      this.source = updatedDev.source;
      this.power = updatedDev.power;
    }
    return this;

  }

}

class SourceEnum {
  static const String YOUTUBE = "youtube";
  static const String HBO_GO = "hbo_go";
  static const String SPOTIFY  = "spotify";
  static const String NETFLIX  = "netflix";
  static const String TWITCH  = "twitch";
  static const String PC = "pc";
}

class DenonEnum {
  static const String POWER = "amp_power";
  static const String MUTE = "amp_mute";
  static const String VOL_UP = "key_volumeup";
  static const String VOL_DOWN = "key_volumedown";
  static const String INPUT_TV = "amp_cd";
  static const String INPUT_PC = "amp_tuner";
  static const String INPUT_PC2 = "amp_aux";
}
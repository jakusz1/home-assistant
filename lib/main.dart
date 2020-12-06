import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homeassistant/common.dart';
import 'package:homeassistant/light_data.dart';
import 'package:homeassistant/light_repo.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'common.dart';
import 'devices.dart';
import 'package:flutter/foundation.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double temp = 4000;
  double brightness = 100;
  ColorSliderData red = ColorSliderData(MyIcons.r, 255.0, Colors.redAccent);
  ColorSliderData green = ColorSliderData(MyIcons.g, 255.0, Colors.greenAccent);
  ColorSliderData blue = ColorSliderData(MyIcons.b, 255.0, Colors.blueAccent);
  Color rgbColor = Colors.white;
  Color tempColor = Colors.white;
  Color currentColorForeground = Colors.black;
  ColorModeData colorMode = ColorModeData(1);
  LightRepo lightRepo = LightRepo();
  DenonDevice amp = DenonDevice();
  SamsungDevice tv = SamsungDevice();
  bool ampPowerBtnEnabled = true;

  void updateRGB() {
    rgbColor = Color.fromRGBO(
        red.value.toInt(), green.value.toInt(), blue.value.toInt(), 1);
  }

  void updateTempColor() {
    tempColor = kelvinToColor(temp);
  }

  void updateForegroundColor() {
    Color activeColor = colorMode.colorMode == 1 ? rgbColor : tempColor;
    currentColorForeground =
        activeColor.computeLuminance() > 0.3 ? Colors.black : Colors.white;
  }

  Future<void> switchLight(Light light, {bool secondLight: false}) async {
    String state;
    if (secondLight) {
      state = light.data.secondLight.powerMode ? "second_off" : "second_on";
    } else {
      state = light.data.powerMode ? "off" : "on";
    }
    var url = "${Config.API_PATH}v2/lights/${light.id}/$state";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.post(url, headers: headers);
    setState(() {
      light.data = LightData.fromJson(json.decode(response.body));
      lightRepo.isAnyPowered();
    });
  }

  Widget getLightSwitch(Light light, {bool secondLight: false}) {
    bool power =
        secondLight ? light.data.secondLight.powerMode : light.data.powerMode;
    return IconButton(
      icon: power
          ? Icon(
              MyIcons.lightbulb_on,
              color: Colors.white,
            )
          : Icon(
              MyIcons.lightbulb_off,
              color: Colors.white54,
            ),
      onPressed: () {
        switchLight(light, secondLight: secondLight);
      },
    );
  }

  Widget getAllLightOffButton() {
    return FlatButton(
      onPressed: lightRepo.power
          ? () {
              lightRepo.turnOffAllLights().then((result) {
                setState(() {
                  lightRepo = result;
                });
              });
            }
          : null,
      child: Row(
        children: <Widget>[
          Text("ALL "),
          lightRepo.power
              ? Icon(MyIcons.all_lightbulbs_on)
              : Icon(MyIcons.all_lightbulbs_off)
        ],
      ),
    );
  }

  Widget getAmpPowerButton(DenonDevice device) {
    return FlatButton(
      onPressed: () {
        device.switchPower().then((result) {
          setState(() {
            device = result;
          });
        });
      },
      child: Row(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          device.power
              ? Text(
                  "ON ",
                  style: TextStyle(color: Colors.tealAccent),
                )
              : Text("OFF "),
          device.power
              ? Icon(MyIcons.power_plug, color: Colors.tealAccent)
              : Icon(MyIcons.power_plug_off)
        ],
      ),
    );
  }

  Widget getPowerButton(Device device) {
    return FlatButton(
      onPressed: device.name == "TV" || ampPowerBtnEnabled
          ? () {
              if (device.name == "Amplifier" && !device.power) {
                setState(() {
                  ampPowerBtnEnabled = false;
                });
              }
              device.switchPower().then((result) {
                setState(() {
                  device = result;
                  if (device.name == "Amplifier") {
                    ampPowerBtnEnabled = true;
                  }
                });
              });
            }
          : null,
      child: Row(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          device.power
              ? Text(
                  "ON ",
                  style: TextStyle(color: Colors.tealAccent),
                )
              : Text("OFF "),
          device.power
              ? Icon(MyIcons.power_plug, color: Colors.tealAccent)
              : Icon(MyIcons.power_plug_off)
        ],
      ),
    );
  }

  Card getTempCard() {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    thumbColor: tempColor,
                    activeTrackColor: tempColor,
                    inactiveTrackColor: Colors.grey,
                    overlayColor: Colors.transparent,
                    trackHeight: 6),
                child: Slider(
                    onChanged: colorMode.colorMode == 0
                        ? (double value) {
                            setState(() {
                              temp = value;
                              updateTempColor();
                              updateForegroundColor();
                            });
                          }
                        : null,
                    value: temp,
                    min: 1700,
                    divisions: (65 - 17),
                    max: 6500),
              ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  MyIcons.fire,
                  color: kelvinToColor(1700),
                ),
              ),
              Text("${temp.round()} K"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  MyIcons.sunny,
                  color: kelvinToColor(6500),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Row getColorSlider(ColorSliderData sliderData) {
    return Row(
      children: <Widget>[
        Expanded(
            child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
              thumbColor: rgbColor,
              activeTrackColor: sliderData.color,
              inactiveTrackColor: Colors.grey,
              overlayColor: Colors.transparent,
              trackHeight: 6),
          child: Slider(
              onChanged: colorMode.colorMode == 1
                  ? (double newValue) {
                      setState(() {
                        sliderData.value = newValue;
                        updateRGB();
                        updateForegroundColor();
                      });
                    }
                  : null,
              value: sliderData.value,
              min: 0,
              max: 255),
        ))
      ],
    );
  }

  Card getRGBCard() {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          getColorSlider(red),
          getColorSlider(green),
          getColorSlider(blue)
        ],
      ),
    );
  }

  Card getSpotifyCard() {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  onPressed: colorMode.colorMode == 1 ? () {} : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(MyIcons.spotify),
                      Text("get album color")
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Card getBrightnessCard() {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Slider(
                      onChanged: (double value) {
                        setState(() {
                          brightness = value;
                        });
                      },
                      value: brightness,
                      min: 0,
                      max: 100))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(MyIcons.lightbulb_off),
              ),
              Text("${brightness.round()} %"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(MyIcons.lightbulb_on),
              )
            ],
          ),
        ],
      ),
    );
  }

  Card getVolumeCard() {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                onPressed: amp.power
                    ? () {
                        amp.sendAction(DenonEnum.VOL_DOWN).then((result) {
                          setState(() {
                            amp = result;
                          });
                        });
                      }
                    : null,
                child: Icon(Icons.volume_down),
              ),
              FlatButton(
                onPressed: amp.power
                    ? () {
                        amp.sendAction(DenonEnum.VOL_UP).then((result) {
                          setState(() {
                            amp = result;
                          });
                        });
                      }
                    : null,
                child: Icon(Icons.volume_up),
              ),
            ],
          )
        ],
      ),
    );
  }

  Card getDenonInputsCard() {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                  child: FlatButton(
                onPressed: amp.power
                    ? () {
                        amp.sendAction(DenonEnum.INPUT_TV).then((result) {
                          setState(() {
                            amp = result;
                          });
                        });
                      }
                    : null,
                child: Icon(MyIcons.tv,
                    color: getSourceBtnColor(amp, DenonEnum.INPUT_TV)),
              )),
              Flexible(
                  child: FlatButton(
                onPressed: amp.power
                    ? () {
                        amp.sendAction(DenonEnum.INPUT_PC).then((result) {
                          setState(() {
                            amp = result;
                          });
                        });
                      }
                    : null,
                child: Icon(MyIcons.desktop,
                    color: getSourceBtnColor(amp, DenonEnum.INPUT_PC)),
              )),
              Flexible(
                  child: FlatButton(
                onPressed: amp.power
                    ? () {
                        amp.sendAction(DenonEnum.INPUT_PC2).then((result) {
                          setState(() {
                            amp = result;
                          });
                        });
                      }
                    : null,
                child: Icon(
                  MyIcons.laptop,
                  color: getSourceBtnColor(amp, DenonEnum.INPUT_PC2),
                ),
              )),
            ],
          )
        ],
      ),
    );
  }

  Color getSourceBtnColor(Device device, String source) {
    if (device.power) {
      if (device.source == source) {
        return Colors.tealAccent;
      }
      return Colors.white;
    }
    return Colors.white54;
  }

  Card getTVAppsCard() {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                  child: FlatButton(
                onPressed: tv.power
                    ? () {
                        tv.setSource(SourceEnum.YOUTUBE).then((result) {
                          setState(() {
                            tv = result;
                          });
                        });
                      }
                    : null,
                child: Icon(MyIcons.youtube,
                    color: getSourceBtnColor(tv, SourceEnum.YOUTUBE)),
              )),
              Flexible(
                  child: FlatButton(
                onPressed: tv.power
                    ? () {
                        tv.setSource(SourceEnum.SPOTIFY).then((result) {
                          setState(() {
                            tv = result;
                          });
                        });
                      }
                    : null,
                child: Icon(MyIcons.spotify,
                    color: getSourceBtnColor(tv, SourceEnum.SPOTIFY)),
              )),
              Flexible(
                  child: FlatButton(
                onPressed: tv.power
                    ? () {
                        tv.setSource(SourceEnum.NETFLIX).then((result) {
                          setState(() {
                            tv = result;
                          });
                        });
                      }
                    : null,
                child: Icon(MyIcons.netflix,
                    color: getSourceBtnColor(tv, SourceEnum.NETFLIX)),
              )),
              Flexible(
                  child: FlatButton(
                onPressed: tv.power
                    ? () {
                        tv.setSource(SourceEnum.HBO_GO).then((result) {
                          setState(() {
                            tv = result;
                          });
                        });
                      }
                    : null,
                child: Icon(MyIcons.hbo_go,
                    color: getSourceBtnColor(tv, SourceEnum.HBO_GO)),
              )),
              Flexible(
                  child: FlatButton(
                onPressed: tv.power
                    ? () {
                        tv.setSource(SourceEnum.TWITCH).then((result) {
                          setState(() {
                            tv = result;
                          });
                        });
                      }
                    : null,
                child: Icon(MyIcons.twitch,
                    color: getSourceBtnColor(tv, SourceEnum.TWITCH)),
              )),
              Flexible(
                  child: FlatButton(
                onPressed: tv.power
                    ? () {
                        tv.setSource(SourceEnum.PC).then((result) {
                          setState(() {
                            tv = result;
                          });
                        });
                      }
                    : null,
                child: Icon(MyIcons.desktop,
                    color: getSourceBtnColor(tv, SourceEnum.PC)),
              )),
            ],
          )
        ],
      ),
    );
  }

  Card getLampCard(Light light) {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          if (light.secondLightIcon != null)
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      onPressed: light.data.secondLight.powerMode
                          ? () {
                              light
                                  .setLight(colorMode, temp, red, green, blue,
                                      brightness,
                                      secondLight: true)
                                  .then((result) {
                                setState(() {
                                  light = result;
                                });
                              });
                            }
                          : null,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                light.secondLightIcon,
                                color:
                                    getLightIconColor(light, secondLight: true),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(light.name,
                                    style: TextStyle(fontSize: 25)),
                              ),
                            ],
                          ))),
                ),
                getLightSwitch(light, secondLight: true)
              ],
            ),
          Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: light.data.powerMode
                        ? () {
                            light
                                .setLight(colorMode, temp, red, green, blue,
                                    brightness)
                                .then((result) {
                              setState(() {
                                light = result;
                              });
                            });
                          }
                        : null,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(light.icon, color: getLightIconColor(light)),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(light.name,
                                  style: TextStyle(fontSize: 25)),
                            ),
                          ],
                        ))),
              ),
              getLightSwitch(light)
            ],
          )
        ],
      ),
    );
  }

  Card _buildCard() {
    return Card(
        elevation: 0,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text("Card"),
                )
              ],
            )
          ],
        ));
  }

  Row getGroupContent(List<List<Widget>> columnsOfBlocks) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var blocks in columnsOfBlocks)
          Expanded(
            child: Column(
              children: blocks,
            ),
          )
      ],
    );
  }

  Row getDeviceTitle(Device device) {
    return Row(children: <Widget>[
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(device.name, style: TextStyle(fontSize: 40)),
      )),
      getPowerButton(device)
    ]);
  }

  Row getLightsTitle() {
    return Row(children: <Widget>[
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Lights", style: TextStyle(fontSize: 40)),
      )),
      getAllLightOffButton()
    ]);
  }

  Row getColorGroupTitle(ColorModeData colorMode) {
    return Row(children: <Widget>[
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Pick", style: TextStyle(fontSize: 40)),
      )),
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ToggleSwitch(
          initialLabelIndex: colorMode.colorMode,
          labels: ['TEMP', 'COLOR'],
          inactiveBgColor: Colors.white10,
          activeBgColors: [tempColor, rgbColor],
          activeFgColor: currentColorForeground,
          inactiveFgColor: Colors.white30,
          minWidth: 100.0,
          icons: [MyIcons.temperature, MyIcons.palette],
          onToggle: (index) {
            setState(() {
              colorMode.colorMode = index;
              updateForegroundColor();
            });
          },
        ),
      ),
    ]);
  }

  Widget getGroup(Widget title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: <Widget>[title, content]),
    );
  }

  Widget getLightsListView() {
    RefreshController _refreshController =
        RefreshController(initialRefresh: false);
    return SmartRefresher(
        controller: _refreshController,
        child: ListView(shrinkWrap: false, children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getGroup(
                    getColorGroupTitle(colorMode),
                    getGroupContent([
                      [getTempCard(), getBrightnessCard()],
                      [getRGBCard(), getSpotifyCard()]
                    ])),
                getGroup(
                    getLightsTitle(),
                    getGroupContent([
                      [
                        getLampCard(lightRepo.repo[0]),
                        getLampCard(lightRepo.repo[1])
                      ],
                      [
                        getLampCard(lightRepo.repo[2]),
                        getLampCard(lightRepo.repo[3]),
                        getLampCard(lightRepo.repo[4])
                      ]
                    ])),
              ])
        ]),
        onRefresh: () async {
          updateLightsTab();
          if (mounted) setState(() {});
          _refreshController.refreshCompleted();
        });
  }

  Color getLightIconColor(Light light, {bool secondLight: false}) {
    LightData data = secondLight ? light.data.secondLight : light.data;
    if (data.powerMode) {
      return data.colorMode
          ? Color.fromRGBO(data.red, data.green, data.blue, 1.0)
          : kelvinToColor(data.ct.toDouble());
    }
    return Colors.white54;
  }

  Widget getDevicesListView() {
    RefreshController _refreshController =
        RefreshController(initialRefresh: false);
    return SmartRefresher(
        controller: _refreshController,
        child: ListView(shrinkWrap: false, children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getGroup(
                    getDeviceTitle(tv),
                    getGroupContent([
                      [getTVAppsCard()]
                    ])),
                getGroup(
                    getDeviceTitle(amp),
                    getGroupContent([
                      [getDenonInputsCard()],
                      [getVolumeCard()]
                    ])),
              ])
        ]),
        onRefresh: () async {
          updateDevicesTab();
          if (mounted) setState(() {});
          _refreshController.refreshCompleted();
        });
  }

  ListView getScenesListView() {
    return ListView(shrinkWrap: false, children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        getGroupContent([
          [
            _buildCard(),
            _buildCard(),
            _buildCard(),
          ],
          [
            _buildCard(),
            _buildCard(),
            _buildCard(),
          ],
          [
            _buildCard(),
            _buildCard(),
            _buildCard(),
          ],
        ])
      ])
    ]);
  }

  updateLightsTab() {
    lightRepo.updateLightData().then((result) {
      setState(() {
        lightRepo = result;
      });
    });
  }

  updateDevicesTab() {
    tv.update().then((result) {
      setState(() {
        tv = result;
      });
    });
    amp.update().then((result) {
      setState(() {
        amp = result;
      });
    });
  }

  updateAll() {
    updateLightsTab();
    updateDevicesTab();
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
        resumeCallBack: () async => setState(() {
              updateAll();
            })));
    lightRepo.addLight(Light("desk", "Desk", MyIcons.desk_lamp, null));
    lightRepo.addLight(Light("table", "Table", MyIcons.down, MyIcons.up));
    lightRepo.addLight(Light("couch", "Couch", MyIcons.floor_lamp, null));
    lightRepo.addLight(Light("kitchen", "Kitchen", MyIcons.strip_led, null));
    lightRepo.addLight(Light("bed", "Bed", MyIcons.bed_lamp, null));
    updateAll();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          sliderTheme: SliderTheme.of(context).copyWith(
            //slider modifications
            thumbColor: Colors.white,
            inactiveTrackColor: Color(0xFF8D8E98),
            activeTrackColor: Colors.white,
            trackHeight: 6,
            overlayColor: Colors.transparent,
          ),
          fontFamily: "raleway"),
      home: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: SafeArea(
              child: TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(MyIcons.star),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("SCENES"),
                        )
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.lightbulb_outline),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("LIGHTS"),
                        )
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.devices_other),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("DEVICES"),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              getScenesListView(),
              getLightsListView(),
              getDevicesListView(),
            ],
          ),
        ),
      ),
    );
  }
}

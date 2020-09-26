import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homeassistant/common.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'common.dart';

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
  Light deskLight = Light(0, "Desk", MyIcons.desk_lamp, 0);
  Light table1Light = Light(1, "Table 1", MyIcons.up, 0);
  Light table2Light = Light(2, "Table 2", MyIcons.down, 0);
  Light couchLight = Light(3, "Couch", MyIcons.floor_lamp, 0);
  Light kitchenLight = Light(4, "Kitchen", MyIcons.strip_led, 0);
  Light bedLight = Light(5, "Bed", MyIcons.bed_lamp, 0);

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

  Widget getLightSwitch(Light light) {
//    return ToggleSwitch(
//        initialLabelIndex: light.power,
//        labels: ['', ''],
//        activeBgColors: [Colors.white54, Theme.of(context).accentColor],
//        inactiveBgColor: Colors.white12,
//        minWidth: 20.0,
//        minHeight: 20.0,
//        onToggle: (index) {
//          setState(() {
//            light.power = index;
//          });
//        });
    return IconButton(
      icon: Icon(MyIcons.lightbulb_on),
      onPressed: () {},
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
                child: Icon(MyIcons.fire, color: kelvinToColor(1700),),
              ),
              Text("${temp.round()} K"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(MyIcons.sunny, color: kelvinToColor(6500),),
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
                child: Icon(Icons.volume_down),
              ),
              FlatButton(
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
                child: Icon(MyIcons.tv),
              )),
              Flexible(
                  child: FlatButton(
                child: Icon(MyIcons.desktop),
              )),
              Flexible(
                  child: FlatButton(
                child: Icon(MyIcons.laptop),
              )),
            ],
          )
        ],
      ),
    );
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
                child: Icon(MyIcons.youtube),
              )),
              Flexible(
                  child: FlatButton(
                child: Icon(MyIcons.spotify),
              )),
              Flexible(
                  child: FlatButton(
                child: Icon(MyIcons.netflix),
              )),
              Flexible(
                  child: FlatButton(
                child: Icon(MyIcons.hbo_go),
              )),
              Flexible(
                  child: FlatButton(
                child: Icon(MyIcons.twitch),
              )),
            ],
          )
        ],
      ),
    );
  }

  Card getLampCard(Light light, {Light secondLight}) {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(light.icon),
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
          ),
          if (secondLight != null)
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Icon(secondLight.icon),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(secondLight.name,
                                    style: TextStyle(fontSize: 25)),
                              ),
                            ],
                          ))),
                ),
                getLightSwitch(secondLight)
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

  Row getGroupTitle(String groupName) {
    return Row(children: <Widget>[
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(groupName, style: TextStyle(fontSize: 40)),
      )),
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ToggleSwitch(
          initialLabelIndex: 0,
          labels: ['OFF', 'ON'],
          activeBgColors: [Colors.white54, Colors.white],
          inactiveBgColor: Colors.white10,
          inactiveFgColor: Colors.white30,
          minWidth: 50.0,
          onToggle: (index) {},
        ),
      ),
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

  ListView getLightsListView() {
    return ListView(shrinkWrap: false, children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        getGroup(
            getColorGroupTitle(colorMode),
            getGroupContent([
              [getTempCard(), getBrightnessCard()],
              [getRGBCard(), getSpotifyCard()]
            ])),
        getGroup(
            getGroupTitle("Lights"),
            getGroupContent([
              [
                getLampCard(deskLight),
                getLampCard(table1Light, secondLight: table2Light)
              ],
              [
                getLampCard(couchLight),
                getLampCard(kitchenLight),
                getLampCard(bedLight)
              ]
            ])),
      ])
    ]);
  }

  ListView getDevicesListView() {
    return ListView(shrinkWrap: false, children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        getGroup(
            getGroupTitle("TV"),
            getGroupContent([
              [getTVAppsCard()]
            ])),
        getGroup(
            getGroupTitle("Denon"),
            getGroupContent([
              [getDenonInputsCard()],
              [getVolumeCard()]
            ])),
      ])
    ]);
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

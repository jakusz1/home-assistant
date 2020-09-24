import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homeassistant/common.dart';
import 'package:toggle_switch/toggle_switch.dart';

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
  ColorSliderData red = ColorSliderData(MyIcons.r, 255.0);
  ColorSliderData green = ColorSliderData(MyIcons.g, 255.0);
  ColorSliderData blue = ColorSliderData(MyIcons.b, 255.0);
  ColorModeData colorMode = ColorModeData(1);

  Card getTempCard() {
    return Card(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Slider(
                      onChanged: colorMode.colorMode == 0 ? (double value) {
                        setState(() {
                          temp = value;
                        });
                      } : null,
                      value: temp,
                      min: 1700,
                      divisions: (65 - 17),
                      max: 6500))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(MyIcons.fire),
              ),
              Text("${temp.round()} K"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(MyIcons.sunny),
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
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(sliderData.icon),
        ),
        Expanded(
            child: Slider(
                onChanged: colorMode.colorMode == 1 ? (double newValue) {
                  setState(() {
                    sliderData.value = newValue;
                  });
                } : null,
                value: sliderData.value,

                min: 0,
                max: 255))
      ],
    );
  }

  Card getRGBCard() {
    return Card(
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

  Card getLampCard(String name, int lampId, IconData icon,
      {bool doubleLamp: false}) {
    return Card(
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
                            Icon(icon, color: Colors.black),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(name,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .headline5),
                            ),
                          ],
                        ))),
              ),
              Switch(
                value: false,
                onChanged: (bool value) {},
              )
            ],
          ),
          if (doubleLamp)
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Icon(MyIcons.down, color: Colors.black),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text("Table 2",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headline5),
                              ),
                            ],
                          ))),
                ),
                Switch(
                  value: false,
                  onChanged: (bool value) {},
                )
              ],
            )
        ],
      ),
    );
  }

  Card _buildCard() {
    return Card(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text("Card"),
              )],
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
            child: Text(groupName, style: Theme
                .of(context)
                .textTheme
                .headline3),
          )),
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ToggleSwitch(
          initialLabelIndex: 0,
          labels: ['OFF', 'ON'],
          activeBgColors: [Colors.black45, Theme.of(context).accentColor],
          inactiveBgColor: Colors.black12,
          minWidth: 50.0,
          onToggle: (index) {
          },
        ),
      ),
    ]);
  }

  Row getColorGroupTitle(ColorModeData colorMode) {
    return Row(children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "Pick",
                style: Theme
                    .of(context)
                    .textTheme
                    .headline3),
          )),
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ToggleSwitch(
          initialLabelIndex: colorMode.colorMode,
          labels: ['', ''],
          inactiveBgColor: Colors.black12,
          minWidth: 50.0,
          icons: [MyIcons.temperature, MyIcons.palette],
          onToggle: (index) {
            setState(() {
              colorMode.colorMode = index;
            });
          },
        ),
      ),
    ]);
  }

  Column getGroup(Widget title, Widget content) {
    return Column(children: <Widget>[title, content]);
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
                getLampCard("Desk", 0, MyIcons.desk_lamp),
                getLampCard("Table 1", 1, MyIcons.up, doubleLamp: true)
              ],
              [
                getLampCard("Couch", 2, MyIcons.floor_lamp),
                getLampCard("Kitchen", 3, MyIcons.strip_led),
                getLampCard("Bed", 4, MyIcons.bed_lamp)
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
      home: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
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
            title: Text('Home'),
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

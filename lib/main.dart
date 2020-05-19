import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:light/light.dart';
import 'dart:async';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:convert';
import 'package:json_table/json_table.dart';
import 'package:sensor_light/utils/json.dart';
import 'package:sensor_light/utils/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            title: '',
            theme: notifier.darkTheme ? dark : light,
            home: HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Light _light;

  String _luxString = 'unknown';
  StreamSubscription _subscription;

  //json for table data
  final String jsonSample =
      '[{"site":"room","level":"150", "site":"doctors office","level":"300"}, {"site":"software developer job","level":"300"},'
      '{"site":"teachers room","level":"450"},{"site":"sewing machine work","level":"2000"}]';
  bool toggle = true;

  void onData(int luxValue) async {
    print("lux value: $luxValue");
    setState(() {
      _luxString = "$luxValue";
    });
  }

  void stopListening(){
    _subscription.cancel();
  }

  void startListening(){
    _light = new Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatFormState();
  }

  Future<void> initPlatFormState() async {
    startListening();
  }

  @override
  Widget build(BuildContext context) {

    double nivel = double.tryParse('$_luxString') ?? 0.0;
    var json = jsonDecode(jsonSample);

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter + Sensor Light'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Consumer<ThemeNotifier>(
              builder: (context, notifier, child) => SwitchListTile(
                title: Text("Dark Mode"),
                onChanged: (val) {
                  notifier.toogleTheme();
                },
                value: notifier.darkTheme,
              ),
            ),

            const SizedBox(height: 10.0,),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.only(right: 100.0),
                        child: Icon(
                          FontAwesomeIcons.lightbulb,
                          size: 45.0,
                          color: Colors.green[500],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: new CircularPercentIndicator(
                      radius: 240.0,
                      lineWidth: 25.0,
                      percent: (nivel <= 999) ? nivel / 1000 : 0.0,
                      center: Container(
                        margin: EdgeInsets.only(top: 40.0),
                        padding: EdgeInsets.only(top: 10.0),
                        child: new Text(
                          "$_luxString\n",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
                        ),
                      ),
                      footer: new Text(
                        "Niveles de lúmenes por M²(LUX)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Colors.green,
                  ),
                  ),
                ],
              ),
            ),

            Divider(),
            //json datatable
            Container(
              child: Padding(padding: EdgeInsets.all(5.0),
              child: Container(
                margin: EdgeInsets.only(left: 50.0),
                padding: EdgeInsets.all(16.0),
                child: toggle ? Column(
                  children: <Widget>[
                    JsonTable(
                      json,
                      showColumnToggle: true,
                      tableHeaderBuilder: (String header){
                        return Container(
                         padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                         decoration: BoxDecoration(border: Border.all(width: 0.5),
                         color: Colors.blue[300]),
                         child: Text(header,
                         textAlign: TextAlign.center,
                         style: Theme.of(context).textTheme.display1.copyWith(fontWeight: FontWeight.w700,
                         fontSize: 14.0, color: Colors.black87),
                        ),
                        );
                      },
                      tableCellBuilder: (value){
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                              color: Colors.grey.withOpacity(0.5)
                            ),
                          ),
                          child: Text(value, textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.display1.copyWith(
                         fontSize: 14.0),
                         ),
                        );                   
                      },
                      allowRowHighlight: true,
                      rowHighlightColor: Colors.yellow[500].withOpacity(0.7),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 60.0),
                      child: Text("Youtube CodigoAlpha Flutter", style: TextStyle(color: Colors.blueAccent, fontSize:  12.0),),
                    )
                  ],
                ) : Center( child: Text(getPrettyJSONString(jsonSample)),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

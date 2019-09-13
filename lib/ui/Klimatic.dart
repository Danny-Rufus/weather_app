import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String _cityEntered;
  Future _gotoSecondScreen(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute<Map>(builder: (BuildContext context) {
      return EnterCity();
    }));

    if(  results.containsKey('enter') ){
      _cityEntered = results['enter'];
    }else if(results['enter'] == false){
      setState(() {
        Text("enter a city");
      });
    }


  }

  void showWeather() async {
    Map data = await getWeather(util.apiId, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Klimatic"),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _gotoSecondScreen(context);
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              "images/umbrella.png",
              width: 490.0,
              fit: BoxFit.fitWidth,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 0.0),
            child: Text(
              "${_cityEntered == null? util.defaultCity: _cityEntered}",
              style: CityStyle(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset("images/light_rain.png"),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30.0, 300.0, 80.0, 0.0),
            alignment: Alignment.center,
            child: updateTemprature(_cityEntered),
          )
        ],
      ),
    );
  }

  Future<Map> getWeather(String apiId, String cityName) async {
    String apiUrl =
        "http://api.openweathermap.org/data/2.5/weather?q=$cityName,in&APPID=${util.apiId}&units=metric";

    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateTemprature(String city) {
    return FutureBuilder(
      future: getWeather(util.apiId, city == null ? util.defaultCity : _cityEntered),
      builder: (BuildContext context, AsyncSnapshot<Map> snapShot) {
        if (snapShot.hasData) {
          Map weatherContent = snapShot.data;
          return Container(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    "${weatherContent['main']['temp'].toString()} °C",
                    style: temperatureStyle(),
                  ),
                  subtitle: Text(
                    weatherContent['weather'][0]['description'],
                    style: CityStyle(), overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class EnterCity extends StatelessWidget {
  var _cityFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change City'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Stack(
        children: <Widget>[
          Image.asset(
            "images/white_snow.png",
            width: 490.0,
            fit: BoxFit.fill,
          ),
          ListView(
            children: <Widget>[
              ListTile(
                  title: TextField(
                decoration: InputDecoration(hintText: 'Enter City'),
                controller: _cityFieldController,
                keyboardType: TextInputType.text,
              )),
              ListTile(
                title: FlatButton(
                    color: Colors.greenAccent,
                    onPressed: (){ Navigator.pop(context,{
                      'enter': _cityFieldController.text.isNotEmpty
                    });},
                    child: Text(
                      "Get Weather",
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}

TextStyle CityStyle() {
  return TextStyle(
      color: Colors.white, fontSize: 20.0, fontStyle: FontStyle.italic);
}

TextStyle temperatureStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 40.0,
  );
}

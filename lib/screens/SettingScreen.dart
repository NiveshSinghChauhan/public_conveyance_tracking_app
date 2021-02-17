import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  TextEditingController _emergencyController = TextEditingController();
  bool _valid=true;
  String mobileNumber;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: FutureBuilder<SharedPreferences>(
          future: prefs,
          builder: (BuildContext context, preference) {
            if (preference.connectionState == ConnectionState.done) {
              mobileNumber = preference.data.getString("emergency") != null
                  ? preference.data.getString("emergency")
                  : "Not Set Yet." ;

              return SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Text("Current Emergency Number"),
                      SizedBox(
                        height: 40,
                      ),
                      Text(mobileNumber),
                      SizedBox(
                        height: 40,
                      ),
                      TextField(
                        maxLength: 10,
                        controller: _emergencyController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Emergency Call Number',
                          hintText: 'Type here',
                          errorText:  _valid ?null:'Please enter Mobile Number',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(
                            Icons.call,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),

                      RaisedButton(
                        child: Text("Set"),
                        textColor: Colors.white,
                        color: Colors.blue,
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        onPressed: (){
                          if(_emergencyController.text.isNotEmpty && RegExp(r'(^(?:[+0]9)?[0-9]{10}$)').hasMatch(_emergencyController.text)){

                            preference.data.setString("emergency", _emergencyController.text);

                            setState(() {
                              mobileNumber = _emergencyController.text;
                              _valid = true;
                            });


                          }else{
                            setState(() {
                              _valid = false;
                            });
                          }
                        },
                      ),

                      SizedBox(
                        height: 40,
                      ),

                      RaisedButton(
                        child: Text("Remove"),
                        textColor: Colors.white,
                        color: Colors.blue,
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        onPressed: (){


                            preference.data.remove("emergency");

                            setState(() {
                              mobileNumber = "Not Set Yet.";

                            });

                        },
                      )

                    ],
                  ),
                ),
              );
            }

            if (preference.hasError) {
              return Center(
                child: Text(
                  "Something went wrong",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

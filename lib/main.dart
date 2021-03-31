import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starflut/starflut.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  StarObjectClass python;
  String FrameTag;
  StarObjectClass numpy;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    StarCoreFactory starcore = await Starflut.getFactory(); //starflut object
    FrameTag = Starflut.newLocalFrame(); //starflut frame id

    StarServiceClass Service =
        await starcore.initSimple("test", "123", 0, 0, []); //starflut service
    StarSrvGroupClass SrvGroup =
        await Service["_ServiceGroup"]; //starflut group

    String assetsPath = await Starflut.getAssetsPath();
    print("assetsPath = $assetsPath");

    print("begin init Raw)");
    bool rr1 = await SrvGroup.initRaw("python39", Service); //import python
    print("initRaw = $rr1");

    python = await Service.importRawContext(
        FrameTag, "python", "", false, ""); //initialize python

    // python.lock();//don't understand

    await SrvGroup.doFile(
        "python",
        assetsPath +
            "/flutter_assets/starfiles/" +
            "testcallback.py"); //add python script

    await Starflut.copyFileFromAssets(
        "text.txt", "flutter_assets/starfiles", "flutter_assets/starfiles");

    //setup print in python script//
    StarObjectClass CallBackObj = await Service.newObject(FrameTag, []);
    await python.setValue("CallBackObj", CallBackObj);
    await CallBackObj.regScriptProcP("PrintHello",
        (StarObjectClass cleObject, String FrameTag, List paras) async {
      print("$paras");
    });

    python.call("import", ["os"]);

    //import numpy
    python.call("import", ["sys"]);
    StarObjectClass pythonSys = await python.getValue("sys");
    print("python sys : $pythonSys");
    StarObjectClass pythonPath = await pythonSys.getValue("path");
    print("pyhonPath : $pythonPath");
    pythonPath.call(
        "insert", [0, assetsPath + "/flutter_assets/starfiles/numpy.zip"]);
    python.call("import", ["numpy"]);
    numpy=await python.getValue("numpy");
    print("numpy : $numpy");
    print("finish init"); //print the end
  }

  Future<void> runNumpy() async {
    var rrr2 = await python
        .call("nump", []); //call the founction tt in the python file
    print("return from python $rrr2"); //print the return of the fonction tt
  }

  Future<void> runFile() async {
    var rrr =
        await python.call("tt", []); //call the founction tt in the python file
    print("return from python $rrr"); //print the return of the fonction tt
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  child: Text("runFile"),
                  onPressed: () {
                    runFile();
                  },
                ),
                MaterialButton(
                  child: Text("runNumpy"),
                  onPressed: () {
                    runNumpy();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

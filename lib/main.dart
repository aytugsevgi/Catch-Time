import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:catch_time/custom_clip.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: MyGenerateRoute.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyGenerateRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var args = settings.arguments;
    var name = settings.name;

    switch (name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
    }
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }
  
   AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  playLocal() async {
    int result = await audioPlayer.play('./assets/buttonClick.mp3', isLocal: true);
  }

  int level = 1;
  bool isGameScreen = false;  
  int totalCount = 5;
  int successCount = 0;
  int failCount = 0;
  bool isWin = false;
  bool isLose = false;
  bool isStart = false;
  int _time = 0;
  int randomIntIndex = 0;
  int deviation = 5;
  bool onButtonDown = false;
  List<int> randomInt;
  Timer _timer;
  List<Widget> prevList;
  List<Widget> currentList;
  void startTimer() {
    Duration dur = Duration(milliseconds: (500 * (1 / level)).floor());

    _timer = new Timer.periodic(
      dur,
      (Timer timer) => setState(
        () {
          if (_time < 300 || isStart == true) {
            _time++;
          }
        },
      ),
    );
  }

  String textGame() {
    if (isStart) {
      return "$_time";
    } else if (isLose) {
      return "AGAIN";
    } else if (isWin) {
      return "Level Up";
    } else {
      return "START";
    }
  }

  List<int> randomIntFunc() {
    randomInt = [];
    var rng = new Random();
    int prevInt = 0;
    int currentInt;
    for (int i = 0; i < totalCount; i++) {
      currentInt = rng.nextInt(10) + prevInt + level * 5;
      randomInt.add(currentInt);
      prevInt = currentInt;
    }
    return randomInt;
  }

  List<Widget> pushColor(List<Widget> list, Color color) {
    list.add(
      Padding(
        padding: const EdgeInsets.all(2),
        child: ClayContainer(
          width: 36,
          height: 36,
          parentColor: Color(0xFFF2F2F2),
          spread: 0,
          surfaceColor: color,
          borderRadius: 18,
          curveType: CurveType.concave,
        ),
      ),
    );
    return list;
  }

  void controlInt() {
    if ((randomInt[randomIntIndex] - _time).abs() <= 5) {
      successCount++;
      if (totalCount - 1 > randomIntIndex) {
        randomIntIndex++;
      }
    } else {
      failCount++;
    }
    if (successCount == totalCount) {
      setState(() {
        isWin = true;
        isStart = false;
        level++;
      });
    }
  }

  List<Widget> iconlar() {
    currentList = [];
    if (successCount > totalCount) {
      setState(() {
        successCount--;
      });
    }

    if (!isLose) {
      for (int j = 0; j < successCount; j++) {
        currentList = pushColor(currentList, Color(0xFFff7ade));
      }
      for (int j = 0; j < failCount; j++) {
        currentList = pushColor(currentList, Color(0xFF8c0069));
      }

      for (int i = 0; i < totalCount - (successCount + failCount); i++) {
        currentList = pushColor(currentList, Color(0xFFffdee9));
      }
      prevList = currentList;
    }

    if (failCount > 0) {
      setState(() {
        isLose = true;
        isStart = false;
      });
    }
    if (isLose || isWin) {
      return prevList;
    } else {
      return currentList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DEVICE_SIZE = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: DEVICE_SIZE.height * 0.3,
              width: DEVICE_SIZE.width,
              color: Color(0xFFF2F2F2),
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClayText(
                    "LEVEL $level",
                    textColor: Colors.white,
                    parentColor: Color(0xFFffc7da),
                    size: 40,
                    spread: 5,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  ClayContainer(
                      width: DEVICE_SIZE.width * 0.95,
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: iconlar(),
                      )),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  height: DEVICE_SIZE.height * 0.25,
                  alignment: Alignment.topCenter,
                  child: ClayText(
                    isStart ? "${randomInt[randomIntIndex]}" : " ",
                    size: 40,
                    textColor: Color(0xFFfc51a1),
                    parentColor: Color(0xFFfc51a1),
                    spread: 15,
                  ),
                ),
                AnimatedContainer(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        DEVICE_SIZE.height * 0.2,
                      ),
                    ),
                    boxShadow: onButtonDown
                        ? [
                            BoxShadow(
                              color: Color(0xFFffc7fc),
                              blurRadius: 40,
                              spreadRadius: 30,
                            ),
                          ]
                        : [],
                  ),
                  duration: Duration(milliseconds: 100),
                  width: DEVICE_SIZE.height * 0.4,
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTapCancel: () {
                      setState(() {
                        onButtonDown = false;
                      });
                    },
                    onTapDown: (TapDownDetails) {
                      setState(() {
                        onButtonDown = true;
                      });
                    },
                    onTapUp: (TapUpDetails) {
                      setState(() {
                        onButtonDown = false;
                      });
                      SystemSound.play(SystemSoundType.click);
                      
                      //playLocal();
                      //audioPlayer.resume(); 
                    },
                    onTap: () {
                      if (!isLose) {
                        if (isWin) {
                          randomIntFunc();
                          setState(() {
                            isWin = false;
                            _time = 0;
                            successCount = 0;
                            failCount = 0;
                            randomIntIndex = 0;
                            randomInt = [];
                            _timer = null;
                          });
                        } else {
                          if (isStart) {
                            print(_time);

                            //fail mi succes mi
                            controlInt();
                          } else {
                            randomIntFunc();
                            startTimer();
                            setState(() {
                              isStart = true;
                            });
                          }
                        }
                      } else {
                        setState(() {
                          isLose = false;
                          isStart = true;
                          isWin = false;
                          _time = 0;
                          successCount = 0;
                          failCount = 0;
                          randomIntIndex = 0;
                          randomInt = [];
                          randomIntFunc();
                          _timer = null;
                        });
                      }
                    },
                    child: ClayContainer(
                      width: DEVICE_SIZE.height * 0.4,
                      height: DEVICE_SIZE.height * 0.4,
                      parentColor: Color(0xFFFFFFFF),
                      spread: 20,
                      surfaceColor: Color(0xFFF2F2F2),
                      borderRadius: DEVICE_SIZE.height * 0.2,
                      curveType: CurveType.convex,
                      child: Padding(
                        padding: EdgeInsets.all(DEVICE_SIZE.width * 0.06),
                        child: ClayContainer(
                          width: DEVICE_SIZE.height * 0.4,
                          height: DEVICE_SIZE.height * 0.4,
                          parentColor: Color(0xFFF2F2F2),
                          spread: 5,
                          surfaceColor: Color(0xFFF2F2F2),
                          borderRadius: DEVICE_SIZE.height * 0.2,
                          curveType: CurveType.concave,
                          child: Padding(
                            padding: EdgeInsets.all(DEVICE_SIZE.width * 0.06),
                            child: ClayContainer(
                              width: DEVICE_SIZE.height * 0.4,
                              height: DEVICE_SIZE.height * 0.4,
                              parentColor: Color(0xFFF2F2F2),
                              spread: 5,
                              surfaceColor: Color(0xFFF2F2F2),
                              borderRadius: DEVICE_SIZE.height * 0.2,
                              curveType: CurveType.convex,
                              child: Center(
                                child: ClayText(
                                  textGame(),
                                  size: 40,
                                  textColor: Color(0xFFfc51a1),
                                  parentColor: Color(0xFFfc51a1),
                                  spread: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        AnimatedPositioned(
          top: isLose ? DEVICE_SIZE.height * 0.4 : -300,
          left:  DEVICE_SIZE.width * 0.2 ,

          curve: Curves.bounceOut,
          child: isLose
              ? ClayText(
                  '   GAME OVER',
                  size: 40,
                  textColor: Color(0xFFFFFFFF),
                  spread: 2,
                  parentColor: Color(0xFF8c0069),
                )
              : ClayText(
                  '         DO IT',
                  size: 40,
                  textColor: Color(0xFFFFFFFF),
                  spread: 2,
                  parentColor: Color(0xFF8c0069),
                ),
          duration: Duration(seconds: 2),
        ),
        AnimatedPositioned(
          top: isGameScreen ? DEVICE_SIZE.height : 0,
          left: 0,
          duration: Duration(seconds: 2),
          curve: Curves.bounceOut,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInSine,
            width: DEVICE_SIZE.width,
            height: DEVICE_SIZE.height,
            color: isGameScreen
                ? Color.fromARGB(0, 255, 255, 255)
                : Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        AnimatedPositioned(
          top: isGameScreen ? -DEVICE_SIZE.height : 0,
          left: 0,
          duration: Duration(seconds: 2),
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              width: DEVICE_SIZE.width,
              height: DEVICE_SIZE.height * 0.5,
              color: Color(0xFFffc7da),
              alignment: Alignment.center,
              child: ClayText("CATCH TIME",
                  textColor: Colors.white,
                  parentColor: Colors.purple,
                  spread: 20,
                  size: 40),
            ),
          ),
        ),
        AnimatedPositioned(
          top: isGameScreen
              ? -DEVICE_SIZE.height * 0.4
              : DEVICE_SIZE.height * 0.35,
          right: DEVICE_SIZE.width * 0.1 + 50,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isGameScreen = true;
                print(isGameScreen);
              });
            },
            child: ClayContainer(
                height: DEVICE_SIZE.width * 0.4,
                width: DEVICE_SIZE.width * 0.4,
                parentColor: Colors.white,
                surfaceColor: Colors.white,
                spread: 5,
                borderRadius: DEVICE_SIZE.width * 0.2,
                curveType: CurveType.concave,
                child: Center(
                    child: ClayText(
                  "LET'S GO",
                  size: 24,
                  textColor: Colors.white,
                  parentColor: Color(0xFFffc7da),
                ))),
          ),
          duration: Duration(seconds: 3),
          curve: Curves.fastLinearToSlowEaseIn,
        ),
      ]),
    );
  }
}

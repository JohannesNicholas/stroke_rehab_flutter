import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:stroke_rehab/record.dart';
import 'package:stroke_rehab/record_page.dart';
import 'package:stroke_rehab/strings.dart';

class NormalGame extends StatefulWidget {
  const NormalGame({Key? key}) : super(key: key);

  @override
  State<NormalGame> createState() => appear();
}

class appear extends State<NormalGame> {
  List<NormalGameButtonData> buttons = [];

  Random random = Random();
  final db = FirebaseFirestore.instance;
  var numberOfButtons = 5;
  var numberOfRounds = 5;
  var randomOrder = true;
  var highlightNextButton = true;
  var buttonSize = 4;
  var freePlay = false;
  String documentID = "";
  late Record recordData;
  var nextNumber = 1;
  var round = 1;
  var timeLimit = 0;
  var time = 1;
  Timer? timer;
  String scoreText = "5/5";
  Future? startFuture;

  @override
  Widget build(BuildContext context) {
    //if start of game,
    if (buttons.isEmpty) {
      startFuture = startOfGame();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.normalGameTitle),
      ),
      body: FutureBuilder(
          future: startFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("loading settings"),
                  CircularProgressIndicator()
                ],
              );
            }
            return Column(
              children: [
                (timeLimit != 0)
                    ? Stack(
                        children: [
                          LinearProgressIndicator(
                            value:
                                (1 - (time.toDouble() / timeLimit.toDouble())),
                            minHeight: 15,
                          ),
                          Center(
                            child: Text(
                              "$time",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      )
                    : const SizedBox.shrink(),
                Text(
                  "$round/$numberOfRounds",
                  style: const TextStyle(fontSize: 64),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children:
                          getOrderedListOfButtons().toList().map((button) {
                        return Column(
                          children: [
                            Spacer(flex: button.posY),
                            Row(
                              children: [
                                Spacer(flex: button.posX),
                                Container(
                                  height: buttonSize.toDouble(),
                                  width: buttonSize.toDouble(),
                                  child: FittedBox(
                                    child: FloatingActionButton(
                                      heroTag: "${button.number}_button",
                                      child: Text(
                                        button.number.toString(),
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                      onPressed: (() {
                                        buttonPressed(button.number);
                                      }),
                                      backgroundColor:
                                          button.number == nextNumber
                                              ? Colors.orange
                                              : Colors.orange[300],
                                    ),
                                  ),
                                ),
                                Spacer(flex: 100 - button.posX)
                              ],
                            ),
                            Spacer(flex: 100 - button.posY)
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }

  //puts the highlighted button at the bottom of the stack, as to appear
  //at the top of the view, without anything else overlapping.
  List<NormalGameButtonData> getOrderedListOfButtons() {
    var newButtons = buttons.toList();
    newButtons.sort((a, b) {
      if (a.number == nextNumber) {
        return 1;
      }
      if (b.number == nextNumber) {
        return -1;
      }
      return 0;
    });

    return newButtons;
  }

  //called at the start of a game
  Future<bool?> startOfGame() async {
    await loadSettings();

    documentID =
        DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19);

    resetButtons();

    if (timeLimit != 0) {
      time = timeLimit;
      timer = Timer.periodic(Duration(seconds: 1), (t) {
        setState(() {
          time--;
          if (time < 0) {
            endOfGame(timeout: true);
          }
        });
      });
    }

    recordData = Record(
        title: Strings.normalGameTitle,
        messages: [],
        reps: (!freePlay) ? numberOfRounds : null,
        buttonsOrNotches: numberOfButtons,
        start: Timestamp.now(),
        goals: !freePlay);

    return true;
  }

  //loads the settings from firestore database
  Future<void> loadSettings() async {
    final settingsSnapshot =
        await db.collection("settings").doc("settings").get();
    final settingsMap = settingsSnapshot.data();

    numberOfRounds =
        int.tryParse(settingsMap?[Strings.normalRepsSettingsKey]) ?? 0;
    timeLimit = int.tryParse(settingsMap?[Strings.normalTimeSettingsKey]) ?? 0;
    numberOfButtons =
        int.tryParse(settingsMap?[Strings.normalNumButtonsSettingsKey]) ?? 3;
    randomOrder = settingsMap?[Strings.normalRandomSettingsKey] != false;
    highlightNextButton =
        settingsMap?[Strings.normalRandomSettingsKey] != false;
    buttonSize = {
          'S': 50,
          'M': 70,
          'L': 100,
          'XL': 200
        }[settingsMap?[Strings.normalSizeSettingsKey] ?? 'M'] ??
        70;
  }

  //when a stroke rehab button is pressed
  void buttonPressed(int button) {
    record("$button Pressed", button == nextNumber);
    if (button == nextNumber) {
      if (button == numberOfButtons) {
        newRound();
      } else {
        nextNumber += 1;
      }
    }

    setState(() {});
  }

  void endOfGame({bool timeout = false}) {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecordPage(record: recordData)));
  }

  //when the last button in a round is pressed, this resets the board.
  void newRound() {
    if (round >= numberOfRounds) {
      endOfGame();
    }

    resetButtons();
    round++;
  }

  //moves and resets all the buttons.
  void resetButtons() {
    buttons = [];
    for (var i = 0; i < numberOfButtons; i++) {
      buttons.add(NormalGameButtonData(
          1 + random.nextInt(98), 1 + random.nextInt(98), i + 1));
    }
    nextNumber = 1;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void record(String message, bool? correctPress) {
    recordData.messages?.add(RecordMessage(
        datetime: Timestamp.now(),
        message: message,
        correctPress: correctPress,
        rep: round));

    db.collection("Records").doc(documentID).set(recordData.toFirestore());

    //TODO: decrement total correct presses counter on history page.
    //increment the total correct presses counter
    if (correctPress == true) {
      db.collection("totals").doc("totals").get().then((snapshot) {
        final totalButtonPresses =
            snapshot.data()?["correctButtonPresses"] as int?;

        if (totalButtonPresses != null) {
          db
              .collection("totals")
              .doc("totals")
              .update({"correctButtonPresses": (totalButtonPresses + 1)});
        }
      });
    }
  }
}

class NormalGameButtonData {
  int posX = 0;
  int posY = 0;
  int number = 1;

  NormalGameButtonData(this.posX, this.posY, this.number);
}

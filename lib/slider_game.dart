import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:stroke_rehab/record.dart';
import 'package:stroke_rehab/record_page.dart';
import 'package:stroke_rehab/strings.dart';

typedef void IntCallback();

class SliderGame extends StatefulWidget {
  final IntCallback onGameDone;
  final bool freePlay;
  const SliderGame({
    Key? key,
    required this.onGameDone,
    required this.freePlay,
  }) : super(key: key);

  @override
  State<SliderGame> createState() => appear();
}

class appear extends State<SliderGame> {
  List<NormalGameButtonData> buttons = [];

  Random random = Random();
  final db = FirebaseFirestore.instance;
  var numberOfButtons = 5;
  var numberOfRounds = 5;
  var randomOrder = true;
  var highlightNextButton = true;
  var buttonSize = 4;
  var freePlay = false;
  late Record recordData;
  var nextNumber = 1;
  var round = 1;
  var timeLimit = 0;
  var time = 1;
  Timer? timer;
  String scoreText = "5/5";
  Future? startFuture;

  int sliderValue = 1;

  @override
  Widget build(BuildContext context) {
    //if start of game,
    if (buttons.isEmpty) {
      startFuture = startOfGame();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.sliderGameTitle),
      ),
      body: FutureBuilder(
          future: startFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("loading settings"),
                    CircularProgressIndicator()
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                children: [
                  (timeLimit != 0)
                      ? Stack(
                          children: [
                            LinearProgressIndicator(
                              value: (1 -
                                  (time.toDouble() / timeLimit.toDouble())),
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
                    "$round/${numberOfRounds == 0 || freePlay ? '∞' : numberOfRounds}",
                    style: const TextStyle(fontSize: 64),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: Stack(children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: LinearProgressIndicator(
                                value: 2.0 / 5,
                                minHeight: 30,
                                color: Colors.orange[300],
                              ),
                            ),
                          ),
                          Center(
                            child: Slider(
                              onChanged: (newValue) {
                                setState(() {
                                  sliderValue = newValue.toInt();
                                });
                              },
                              min: 0,
                              max: 5,
                              divisions: 5,
                              value: sliderValue.toDouble(),
                            ),
                          )
                        ]),
                      ),
                    ),
                  )
                ],
              ),
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
      title: Strings.sliderGameTitle,
      messages: [],
      reps: (!freePlay) ? numberOfRounds : null,
      buttonsOrNotches: numberOfButtons,
      start: Timestamp.now(),
      goals: !freePlay,
      id: DateTime.now()
          .toIso8601String()
          .replaceAll('T', ' ')
          .substring(0, 19),
    );

    return true;
  }

  //loads the settings from firestore database
  Future<void> loadSettings() async {
    freePlay = widget.freePlay;

    final settingsSnapshot =
        await db.collection("settings").doc("settings").get();
    final settingsMap = settingsSnapshot.data();

    numberOfRounds =
        int.tryParse(settingsMap?[Strings.normalRepsSettingsKey]) ?? 0;
    timeLimit = int.tryParse(settingsMap?[Strings.normalTimeSettingsKey]) ?? 0;
    if (freePlay) {
      timeLimit = 0;
    }
    numberOfButtons =
        int.tryParse(settingsMap?[Strings.normalNumButtonsSettingsKey]) ?? 3;
    randomOrder = settingsMap?[Strings.normalRandomSettingsKey] != false;
    highlightNextButton =
        settingsMap?[Strings.normalHighlightNextSettingsKey] != false;
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
    final message = !timeout ? "🏆 COMPLETE! 🏆" : "⏱️ TIME OUT! ⏱️";

    record(message, null);

    widget.onGameDone();
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecordPage(record: recordData)));
  }

  //when the last button in a round is pressed, this resets the board.
  void newRound() {
    if (round >= numberOfRounds && numberOfRounds != 0 && !freePlay) {
      endOfGame();
    } else {
      record("Round $round", null);
    }

    resetButtons();
    round++;
  }

  //moves and resets all the buttons.
  void resetButtons() {
    buttons = [];
    for (var i = 0; i < numberOfButtons; i++) {
      buttons.add(NormalGameButtonData(
          1 + (randomOrder ? random.nextInt(98) : i * 19),
          1 + (randomOrder ? random.nextInt(98) : i * 19),
          i + 1));
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

    db.collection("Records").doc(recordData.id).set(recordData.toFirestore());

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

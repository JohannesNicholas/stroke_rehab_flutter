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
  Random random = Random();
  final db = FirebaseFirestore.instance;
  var numberOfNotches = 5;
  var numberOfRounds = 5;
  var randomOrder = true;
  var freePlay = false;
  Record? recordData;
  var nextNotch = 1;
  var round = 0;
  var timeLimit = 0;
  var time = 1;
  Timer? timer;
  String scoreText = "5/5";
  Future? startFuture;

  int sliderValue = 1;

  @override
  Widget build(BuildContext context) {
    //if start of game,
    if (recordData == null) {
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
                                value: nextNotch.toDouble() /
                                    (numberOfNotches + 1),
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
                              onChangeEnd: (newValue) {
                                sliderChanged(newValue.toInt());
                              },
                              min: 0,
                              max: numberOfNotches + 1,
                              divisions: numberOfNotches + 1,
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

  //called at the start of a game
  Future<bool?> startOfGame() async {
    await loadSettings();

    if (timeLimit != 0) {
      time = timeLimit;
      timer = Timer.periodic(Duration(seconds: 1), (t) {
        setState(() {
          time--;
          if (time <= 0) {
            endOfGame(timeout: true);
          }
        });
      });
    }

    recordData = Record(
      title: Strings.sliderGameTitle,
      messages: [],
      reps: (!freePlay) ? numberOfRounds : null,
      buttonsOrNotches: numberOfNotches,
      start: Timestamp.now(),
      goals: !freePlay,
      id: DateTime.now()
          .toIso8601String()
          .replaceAll('T', ' ')
          .substring(0, 19),
    );

    newRound();

    return true;
  }

  //loads the settings from firestore database
  Future<void> loadSettings() async {
    freePlay = widget.freePlay;

    final settingsSnapshot =
        await db.collection("settings").doc("settings").get();
    final settingsMap = settingsSnapshot.data();

    numberOfRounds =
        int.tryParse(settingsMap?[Strings.sliderRepsSettingsKey]) ?? 0;
    timeLimit = int.tryParse(settingsMap?[Strings.sliderTimeSettingsKey]) ?? 0;
    if (freePlay) {
      timeLimit = 0;
    }
    numberOfNotches =
        int.tryParse(settingsMap?[Strings.sliderNotchesSettingsKey]) ?? 3;
    randomOrder = settingsMap?[Strings.sliderRandomSettingsKey] != false;
  }

  //when a stroke rehab button is pressed
  void sliderChanged(int notch) {
    //TODO change this
    record("$notch Pressed", notch == nextNotch);
    if (notch == nextNotch) {
      newRound();
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
            builder: (context) => RecordPage(record: recordData!)));
  }

  //when the last button in a round is pressed, this resets the board.
  void newRound() {
    if (round >= numberOfRounds && numberOfRounds != 0 && !freePlay) {
      endOfGame();
    } else {
      record("Round $round", null);
    }

    sliderValue = 0;
    nextNotch = numberOfNotches;

    if (randomOrder) {
      sliderValue = random.nextInt(2) * (numberOfNotches + 1);
      nextNotch = 1 + random.nextInt(numberOfNotches);
    }

    round++;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void record(String message, bool? correctPress) {
    recordData?.messages?.add(RecordMessage(
        datetime: Timestamp.now(),
        message: message,
        correctPress: correctPress,
        rep: round));

    db.collection("Records").doc(recordData?.id).set(recordData!.toFirestore());

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

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:stroke_rehab/record.dart';
import 'package:stroke_rehab/strings.dart';

class NormalGame extends StatefulWidget {
  const NormalGame({Key? key}) : super(key: key);

  @override
  State<NormalGame> createState() => appear();
}

class appear extends State<NormalGame> {
  List<NormalGameButtonData> buttons = [];

  Random random = Random();

  var numberOfButtons = 5;
  var numberOfRounds = 5;
  var randomOrder = true;
  var highlightNextButton = true;
  var buttonSize = 4;
  var freePlay = false;
  String documentID = "";
  late Record recordData;
  var nextNumber = 1;
  var round = 0;
  var timeLimit = 0;
  Timer? timer;
  String scoreText = "5/5";

  @override
  Widget build(BuildContext context) {
    //if start of game,
    if (buttons.isEmpty) {
      resetButtons();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.normalGameTitle),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              LinearProgressIndicator(
                value: 0.5,
                minHeight: 15,
              ),
              Center(
                child: Text(
                  "25",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
          Text(
            "3/5",
            style: TextStyle(fontSize: 64),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: getOrderedListOfButtons().toList().map((button) {
                  return Column(
                    children: [
                      Spacer(flex: button.posY),
                      Row(
                        children: [
                          Spacer(flex: button.posX),
                          FloatingActionButton(
                            child: Text(
                              button.number.toString(),
                              style: TextStyle(fontSize: 30),
                            ),
                            onPressed: (() {
                              buttonPressed(button.number);
                            }),
                            backgroundColor: button.number == nextNumber
                                ? Colors.orange
                                : Colors.orange[300],
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
      ),
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

  void buttonPressed(int button) {
    print("Button $button pressed");
    buttons[button - 1].highlighted = false;
    buttons[button].highlighted = true;
    nextNumber += 1;
    setState(() {});
  }

  void resetButtons() {
    buttons = [];
    for (var i = 0; i < numberOfButtons; i++) {
      buttons.add(NormalGameButtonData(
          1 + random.nextInt(98), 1 + random.nextInt(98), i + 1, false));
    }
    nextNumber = 1;
  }
}

class NormalGameButtonData {
  int posX = 0;
  int posY = 0;
  int number = 1;
  bool highlighted = false;

  NormalGameButtonData(this.posX, this.posY, this.number, this.highlighted);
}

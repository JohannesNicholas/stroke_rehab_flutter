import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:stroke_rehab/record.dart';
import 'package:stroke_rehab/strings.dart';

class NormalGame extends StatefulWidget {
  const NormalGame({Key? key}) : super(key: key);

  @override
  State<NormalGame> createState() => _NormalGameState();
}

class _NormalGameState extends State<NormalGame> {
  List<NormalGameButtonData> buttons = [];

  var numberOfButtons = 5;
  var numberOfRounds = 5;
  var randomOrder = true;
  var highlightNextButton = true;
  var buttonSize = 1;
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
    resetButtons();

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
                children: buttons.map((button) {
                  return Positioned(
                      top: button.posY,
                      left: button.posX,
                      height: buttonSize * 40,
                      width: buttonSize * 40,
                      child: FloatingActionButton(
                        child: Text(
                          button.number.toString(),
                          style: TextStyle(fontSize: 30),
                        ),
                        onPressed: (() {}),
                        backgroundColor: button.highlighted
                            ? Colors.orange
                            : Colors.orange[300],
                      ));
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  void resetButtons() {
    buttons = [];
    for (var i = 0; i < numberOfButtons; i++) {
      buttons.add(NormalGameButtonData(
          i.toDouble() * 30, i.toDouble() * 30, i + 1, false));
    }
  }
}

class NormalGameButtonData {
  double posX = 0;
  double posY = 0;
  int number = 1;
  bool highlighted = false;

  NormalGameButtonData(this.posX, this.posY, this.number, this.highlighted);
}

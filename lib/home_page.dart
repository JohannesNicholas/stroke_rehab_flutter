import 'package:flutter/material.dart';
import 'package:stroke_rehab/slider_game.dart';
import 'package:stroke_rehab/strings.dart';

import 'normal_game.dart';

typedef void IntCallback();

class HomePage extends StatelessWidget {
  final IntCallback onGameDone;
  const HomePage({
    Key? key,
    required this.onGameDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Card(
                    child: Column(
                      children: [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('🏆 Exercise with Goals 🏆'),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: ((() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NormalGame(
                                              onGameDone: onGameDone,
                                              freePlay: false,
                                            )));
                              })),
                              child: const Text(
                                Strings.normalGameTitle,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: ((() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SliderGame(
                                              onGameDone: onGameDone,
                                              freePlay: false,
                                            )));
                              })),
                              child: const Text(
                                Strings.sliderGameTitle,
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.orange[300] ?? Colors.orange),
                              ),
                            ),
                          ),
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Card(
                    child: Column(
                      children: [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('∞ Free-play ∞'),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: ((() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NormalGame(
                                              onGameDone: onGameDone,
                                              freePlay: true,
                                            )));
                              })),
                              child: const Text(
                                Strings.normalGameTitle,
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.orange[300] ?? Colors.orange),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: ((() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SliderGame(
                                              onGameDone: onGameDone,
                                              freePlay: true,
                                            )));
                              })),
                              child: const Text(
                                Strings.sliderGameTitle,
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.orange[300] ?? Colors.orange),
                              ),
                            ),
                          ),
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                    ),
                  ),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          const Center(
            child: Text(
              "By Johannes Nicholas",
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    ));
  }
}

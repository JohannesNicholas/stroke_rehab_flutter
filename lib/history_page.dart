import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stroke_rehab/strings.dart';
import 'record_page.dart';
import 'firebase_options.dart';
import 'record.dart';
import 'package:share_plus/share_plus.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var db = FirebaseFirestore.instance;

  Iterable<QueryDocumentSnapshot<Object?>> recordDocuments = [];
  Map<String, bool> chipValues = {};
  @override
  Widget build(BuildContext context) {
    final docRef = db.collection("totals");
    var cloudTotals = docRef.snapshots();

    Query<Map<String, dynamic>> query = db.collection("Records");

    final freePlay = chipValues[Strings.freePlayShort] ?? false;
    final goals = chipValues[Strings.goalsShort] ?? false;
    final slider = chipValues[Strings.sliderGameTitle] ?? false;
    final normal = chipValues[Strings.normalGameTitle] ?? false;

    //filter results
    if (freePlay && !goals) {
      query = query.where("goals", isEqualTo: false);
    }
    if (goals && !freePlay) {
      query = query.where("goals", isEqualTo: true);
    }
    if (slider && !normal) {
      query = query.where("title", isEqualTo: Strings.sliderGameTitle);
    }
    if (normal && !slider) {
      query = query.where("title", isEqualTo: Strings.normalGameTitle);
    }

    final recordsStream = query
        .withConverter(
            fromFirestore: Record.fromFirestore,
            toFirestore: (Record record, _) => record.toFirestore())
        .snapshots();

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: StreamBuilder<QuerySnapshot>(
                stream: cloudTotals,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }
                  var totalsDoc =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  var total = totalsDoc[Strings.correctButtonPressesKey] as int;
                  return Text(total.toString() + " correct presses in total");
                },
              )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                onOffChip(Strings.normalGameTitle),
                onOffChip(Strings.sliderGameTitle),
                onOffChip(Strings.freePlayShort),
                onOffChip(Strings.goalsShort),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: recordsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }

                recordDocuments = snapshot.data!.docs.reversed;

                return Expanded(
                  child: ListView(
                    children: recordDocuments
                        .map((DocumentSnapshot document) {
                          final record = document.data() as Record;
                          final start = record.start?.toDate() ?? DateTime(0);
                          final months = [
                            "Jan",
                            "Feb",
                            "Mar",
                            "Apr",
                            "May",
                            "Jun",
                            "Jul",
                            "Aug",
                            "Sep",
                            "Aug",
                            "Sep",
                            "Oct",
                            "Nov",
                            "Dec",
                          ];
                          final hourString = start.hour > 12
                              ? (start.hour - 12).toString() + 'PM'
                              : start.hour.toString() + "AM";
                          return Stack(
                            children: [
                              Hero(
                                tag: "record_image_${record.id}",
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 72,
                                  child: (record.imagePath ?? "") != ""
                                      ? Image.file(
                                          File(
                                            record.imagePath ?? "",
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.normal)),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RecordPage(record: record)));
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 0, 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Hero(
                                          tag: "record_title_${record.id}",
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: Text(
                                              record.title ?? "Untitled",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadows: <Shadow>[
                                                  Shadow(
                                                    offset: Offset(1, 1),
                                                    blurRadius: 5,
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Hero(
                                        tag: "record_time_${record.id}",
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Text(
                                            start.day.toString() +
                                                " " +
                                                months[start.month - 1] +
                                                " " +
                                                hourString,
                                            style: const TextStyle(
                                                color: Colors.orange,
                                                backgroundColor: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              record.reps
                                                      .toString()
                                                      .replaceAll("null", "∞") +
                                                  " x " +
                                                  record.buttonsOrNotches
                                                      .toString()
                                                      .replaceAll("null", "?"),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                shadows: <Shadow>[
                                                  Shadow(
                                                    offset: Offset(1, 1),
                                                    blurRadius: 5,
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.orange,
                                              size: 32,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                ),
                              ),
                            ],
                          );
                        })
                        .toList()
                        .cast(),
                  ),
                );
              },
            )
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.small(
                    heroTag: "camera_button",
                    onPressed: () {},
                    child: const Icon(Icons.camera),
                    backgroundColor: Colors.orange,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.small(
                    heroTag: "delete_button",
                    onPressed: () {},
                    child: const Icon(Icons.delete_forever),
                    backgroundColor: Colors.orange,
                  ),
                ),
                FloatingActionButton(
                  heroTag: "share_button",
                  onPressed: () {
                    var csv =
                        "title, start, end, repetition count, presses count\n";

                    for (var it in recordDocuments) {
                      final record = it.data() as Record;
                      final title = record.title ?? "Untitled";
                      final start = it.id;
                      final end = ((record.messages?.isNotEmpty ?? false)
                              ? (record.messages?.last.datetime?.toDate() ??
                                  DateTime(0))
                              : 0)
                          .toString();
                      final repC = (record.messages?.isNotEmpty ?? false)
                          ? ((record.messages?.last.rep ?? 1) - 1).toString()
                          : "?";
                      var pressC = 0;

                      record.messages?.forEach((message) {
                        if (message.correctPress != null) {
                          pressC += 1;
                        }
                      });

                      csv += "$title, $start, $end, $repC, $pressC\n";
                    }
                    Share.share(csv);
                  },
                  child: const Icon(Icons.share),
                  backgroundColor: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ChoiceChip onOffChip(String title) {
    return ChoiceChip(
      selectedColor: Colors.orange,
      label: Text(title),
      selected: chipValues[title] ?? false,
      onSelected: (bool selected) {
        setState(() {
          chipValues[title] = selected;
        });
      },
    );
  }
}

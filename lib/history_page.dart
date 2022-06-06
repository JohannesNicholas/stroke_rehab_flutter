import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stroke_rehab/strings.dart';
import 'firebase_options.dart';
import 'record.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var db = FirebaseFirestore.instance;

  final Stream<QuerySnapshot> recordsStream = FirebaseFirestore.instance
      .collection('Records')
      .withConverter(
          fromFirestore: Record.fromFirestore,
          toFirestore: (Record record, _) => record.toFirestore())
      .snapshots();

  Map<String, bool> chipValues = {};
  @override
  Widget build(BuildContext context) {
    final docRef = db.collection("totals");
    var cloudTotals = docRef.snapshots();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: StreamBuilder<QuerySnapshot>(
            stream: cloudTotals,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            return Expanded(
              child: ListView(
                children: snapshot.data!.docs.reversed
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
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                        child: Row(
                          children: [
                            Text(
                              record.title ?? "Untitled",
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              start.day.toString() +
                                  " " +
                                  months[start.month - 1] +
                                  " " +
                                  hourString,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Row(
                              children: const [
                                Text(
                                  "x/x",
                                  style: TextStyle(fontSize: 18),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.orange,
                                  size: 32,
                                ),
                              ],
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                      );
                    })
                    .toList()
                    .cast(),
              ),
            );
          },
        )
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

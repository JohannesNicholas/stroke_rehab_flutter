import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stroke_rehab/strings.dart';
import 'firebase_options.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var db = FirebaseFirestore.instance;

  final Stream<QuerySnapshot> recordsStream =
      FirebaseFirestore.instance.collection('Records').snapshots();

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
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['title'].toString()),
                        subtitle: Text(data['reps'].toString()),
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

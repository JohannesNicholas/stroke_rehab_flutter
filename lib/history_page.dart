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
  var value = false;
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
          children: [
            Chip(label: Text(Strings.normalGameTitle)),
            OnOffChip(),
          ],
        )
      ],
    );
  }
}

class OnOffChip extends StatefulWidget {
  const OnOffChip({
    Key? key,
  }) : super(key: key);

  @override
  State<OnOffChip> createState() => _OnOffChipState();
}

class _OnOffChipState extends State<OnOffChip> {
  var value = false;
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selectedColor: Colors.orange,
      label: Text('test'),
      selected: value,
      onSelected: (bool selected) {
        setState(() {
          value = selected;
          print(value);
        });
      },
    );
  }
}

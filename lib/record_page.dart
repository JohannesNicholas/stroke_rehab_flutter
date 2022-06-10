import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stroke_rehab/record.dart';
import 'package:image_picker/image_picker.dart';

class RecordPage extends StatelessWidget {
  final Record record;
  const RecordPage({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDate = record.start?.toDate() ?? DateTime(0);

    var correctPresses = 0;
    record.messages?.forEach((message) {
      if (message.correctPress == true) {
        correctPresses += 1;
      }
    });

    final repetitions = (record.messages?.last.rep ?? 1) - 1;
    final totalTime = (record.messages?.last.datetime
                ?.toDate()
                .difference(startDate)
                .inMilliseconds ??
            0) /
        1000.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: "record_title_${record.id}",
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  record.title ?? "Untitled",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Hero(
              tag: "record_time_${record.id}",
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  startDate.toString().substring(0, 19),
                  style: TextStyle(fontSize: 15),
                ),
              ),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
      body: Stack(
        children: [
          Image.file(File(record.imagePath ?? "")),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                    child:
                        Text("$repetitions repetitions in $totalTime seconds")),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Center(child: Text("$correctPresses correct presses")),
              ),
              Expanded(
                child: ListView(
                  children: record.messages!.map((RecordMessage message) {
                    final time = message.datetime?.toDate() ?? DateTime(0);
                    final timeDiff =
                        time.difference(startDate).inMilliseconds / 1000.0;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              message.message ?? "?",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Text(
                            "+ " + timeDiff.toStringAsFixed(1) + " s",
                            style: const TextStyle(
                                color: Colors.orange,
                                backgroundColor: Colors.black),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  (message.correctPress == null)
                                      ? ""
                                      : message.correctPress!
                                          ? "✅"
                                          : "❌",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.small(
              heroTag: "camera_button",
              onPressed: () async {
                final image =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                record.imagePath = image?.path;

                FirebaseFirestore.instance
                    .collection("Records")
                    .doc(record.id)
                    .set(record.toFirestore());
                Navigator.pop(context);
              },
              child: const Icon(Icons.camera),
              backgroundColor: Colors.orange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.small(
              heroTag: "delete_button",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext alertContext) => AlertDialog(
                    title: const Text('Delete Record Forever?'),
                    content: const Text(
                        'Permanently delete this recorded exercise?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(alertContext, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("Records")
                              .doc(record.id)
                              .delete()
                              .then((doc) {
                            Navigator.pop(alertContext, 'OK');
                            Navigator.pop(context);
                          });
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.delete_forever),
              backgroundColor: Colors.orange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: "share_button",
              onPressed: () {
                var csv = "message, date and time, correct press\n";
                record.messages?.forEach((m) {
                  final message = m.message;
                  final timestamp = m.datetime?.toDate().toString();
                  final correctButton = m.correctPress.toString();
                  csv += "$message, $timestamp, $correctButton\n";
                });
                Share.share(csv);
              },
              child: const Icon(Icons.share),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
      ),
    );
  }
}

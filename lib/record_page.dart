import 'package:flutter/material.dart';
import 'package:stroke_rehab/record.dart';

class RecordPage extends StatelessWidget {
  final Record record;
  const RecordPage({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDate = record.start?.toDate() ?? DateTime(0);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(record.title ?? "Untitled"),
            Text(
              startDate.toString().substring(0, 19),
              style: TextStyle(fontSize: 15),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(child: Text("x repetitions in x.xxx seconds")),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(child: Text("x correct presses")),
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
      floatingActionButton: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.small(
              onPressed: () {
                //TODO
              },
              child: const Icon(Icons.camera),
              backgroundColor: Colors.orange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.small(
              onPressed: () {
                //TODO
              },
              child: const Icon(Icons.delete_forever),
              backgroundColor: Colors.orange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                //TODO
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

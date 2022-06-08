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
    return Scaffold(
      appBar: AppBar(
        title: Text(record.title ?? "Untitled"),
      ),
      body: Center(child: Text("Records page")),
    );
  }
}

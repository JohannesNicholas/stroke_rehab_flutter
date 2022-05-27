// ignore: file_names
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
          child: ListView(
        children: [
          SettingsSection("Personal Details"),
          SettingsSection("Normal"),
          SettingsSection("Slider"),
        ],
      )),
    );
  }

  Padding SettingsSection(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title),
    );
  }
}

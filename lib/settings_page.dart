// ignore: file_names
import 'package:flutter/material.dart';
import 'package:stroke_rehab/strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        settingsSection("🙋 Personal Details"),
        settingsOption("Name", TextField()),
        settingsSection(Strings.normalGameTitle),
        settingsOption(
            "Name",
            Switch(
                value: false,
                onChanged: (bool state) {
                  print(state);
                })),
        settingsSection(Strings.sliderGameTitle),
      ],
    );
  }

  Padding settingsSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 8),
      child: Text(title),
    );
  }

  Padding settingsOption(String title, Widget input) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 8, 32, 8),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(child: Text(title)),
            Expanded(
              child: input,
            ),
          ]),
    );
  }
}

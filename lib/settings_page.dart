// ignore: file_names
import 'package:flutter/material.dart';
import 'package:stroke_rehab/strings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var switchState = false;

  var settings = {
    Strings.nameSettingsKey: "Nick O'Teen",
    Strings.normalRepsSettingsKey: "5",
    Strings.normalTimeSettingsKey: "No limit",
    Strings.normalNumButtonsSettingsKey: "3",
    Strings.normalRandomSettingsKey: true,
    Strings.normalHighlightNextSettingsKey: true,
    Strings.normalSizeSettingsKey: "M",
    Strings.sliderRepsSettingsKey: "5",
    Strings.sliderTimeSettingsKey: "No limit",
    Strings.sliderRandomSettingsKey: true,
    Strings.sliderNotchesSettingsKey: "4",
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        settingsSection("🙋 Personal Details"),
        settingsOption("Name", TextField()),
        settingsSection(Strings.normalGameTitle),
        settingsOption(
          "Number of Reps (Goal)",
          dropDown(["No goal", "3", "5", "20"], Strings.normalRepsSettingsKey),
        ),
        settingsOption(
          "Time limit",
          dropDown(
              ["No limit", "10", "30", "60"], Strings.normalTimeSettingsKey),
        ),
        settingsOption(
          "Number of buttons",
          dropDown(["2", "3", "4", "5"], Strings.normalNumButtonsSettingsKey),
        ),
        settingsOption(
          "Random Order",
          switchSetting(Strings.normalRandomSettingsKey),
        ),
        settingsOption(
          "Highlight next button",
          switchSetting(Strings.normalHighlightNextSettingsKey),
        ),
        settingsOption(
          "Button size",
          dropDown(["S", "M", "L", "XL"], Strings.normalSizeSettingsKey),
        ),
        settingsSection(Strings.sliderGameTitle),
        settingsOption(
          "Number of Reps (Goal)",
          dropDown(["No goal", "3", "5", "20"], Strings.sliderRepsSettingsKey),
        ),
        settingsOption(
          "Time limit:",
          dropDown(
              ["No limit", "10", "30", "60"], Strings.sliderTimeSettingsKey),
        ),
        settingsOption(
          "Random Order",
          switchSetting(Strings.sliderRandomSettingsKey),
        ),
        settingsOption(
          "Number of notches",
          dropDown(["2", "3", "4", "5"], Strings.sliderNotchesSettingsKey),
        ),
      ],
    );
  }

  Widget dropDown(List<String> options, String key) {
    return DropdownButton<String>(
        // Callback that sets the selected popup menu item.
        value: settings[key] as String,
        isExpanded: true,
        onChanged: (value) => setState(() {
              settings[key] = value ?? "5";
            }),
        items: options
            .map((String item) => DropdownMenuItem<String>(
                child: Center(child: Text(item)), value: item))
            .toList());
  }

  Widget switchSetting(String key) {
    return Switch(
      value: settings[key] as bool,
      onChanged: (bool state) {
        setState(() {
          settings[key] = state;
        });
      },
      activeColor: Colors.orange,
    );
  }

  Padding settingsSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      ),
    );
  }

  Padding settingsOption(String title, Widget input) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 8, 32, 8),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            Expanded(
              child: input,
            ),
          ]),
    );
  }
}

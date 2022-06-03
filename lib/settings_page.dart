// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
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
  var db = FirebaseFirestore.instance;

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
    final docRef = db.collection("settings").doc("settings");
    var cloudSettings = docRef.get();

    return FutureBuilder(
      future: cloudSettings,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          final doc = snapshot.data as DocumentSnapshot;
          final data = doc.data() as Map<String, dynamic>;
          settings.forEach((key, value) {
            settings[key] = data[key] ?? settings[key];
          });

          return ListView(
            children: [
              settingsSection("🙋 Personal Details"),
              settingsOption(
                  "Name",
                  TextFormField(
                    initialValue: settings[Strings.nameSettingsKey] as String,
                    onFieldSubmitted: (text) {
                      settings[Strings.nameSettingsKey] = text;
                      save();
                    },
                  )),
              settingsSection(Strings.normalGameTitle),
              settingsOption(
                "Number of Reps (Goal)",
                dropDown(["No goal", "3", "5", "10", "20"],
                    Strings.normalRepsSettingsKey),
              ),
              settingsOption(
                "Time limit",
                dropDown(["No limit", "10", "30", "60"],
                    Strings.normalTimeSettingsKey),
              ),
              settingsOption(
                "Number of buttons",
                dropDown(
                    ["2", "3", "4", "5"], Strings.normalNumButtonsSettingsKey),
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
                dropDown(["No goal", "3", "5", "10", "20"],
                    Strings.sliderRepsSettingsKey),
              ),
              settingsOption(
                "Time limit:",
                dropDown(["No limit", "10", "30", "60"],
                    Strings.sliderTimeSettingsKey),
              ),
              settingsOption(
                "Random Order",
                switchSetting(Strings.sliderRandomSettingsKey),
              ),
              settingsOption(
                "Number of notches",
                dropDown(
                    ["2", "3", "4", "5"], Strings.sliderNotchesSettingsKey),
              ),
            ],
          );
        }
      },
    );

    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        settings.forEach((key, value) {
          settings[key] = data[key] ?? settings[key];
        });
        print(settings);
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  Widget dropDown(List<String> options, String key) {
    return DropdownButton<String>(
        // Callback that sets the selected popup menu item.
        value: settings[key] as String,
        isExpanded: true,
        onChanged: (value) => setState(() {
              settings[key] = value ?? "5";
              save();
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
        save();
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

//saves settings to the database
  void save() {
    db
        .collection("settings")
        .doc("settings")
        .set(settings)
        .onError((e, _) => print("Error writing document: $e"));
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

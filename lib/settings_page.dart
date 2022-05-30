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

enum Menu { itemOne, itemTwo, itemThree, itemFour }

class _SettingsPageState extends State<SettingsPage> {
  var switchState = false;
  int _selectedMenu = 5;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        settingsSection("🙋 Personal Details"),
        settingsOption("Name", TextField()),
        settingsSection(Strings.normalGameTitle),
        settingsOption(
            "Number of Reps (Goal)",
            PopupMenuButton<int>(
                // Callback that sets the selected popup menu item.
                onSelected: (int item) {
                  setState(() {
                    _selectedMenu = item;
                  });
                },
                icon: Text(_selectedMenu.toString()),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text('Item 1'),
                      ),
                      const PopupMenuItem<int>(
                        value: 2,
                        child: Text('Item 3'),
                      ),
                      const PopupMenuItem<int>(
                        value: 4,
                        child: Text('Item 4'),
                      ),
                    ])),
        settingsOption(
            "Random Order",
            Switch(
                value: switchState,
                onChanged: (bool state) {
                  setState(() {
                    switchState = state;
                  });
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

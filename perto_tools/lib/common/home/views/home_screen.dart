import 'package:flutter/material.dart';
import 'package:perto_tools/modules/printer_commands/views/printer_commands_screen.dart';
import '../../../modules/chart_data/views/chart_data_view.dart';
import '../../../modules/key_derivation/views/key_derivation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, WidgetBuilder> buttonToScreenMap = {
    'Key Derivation': (context) => const KeyDerivationScreen(),
    'Antiskimming': (context) => SuChartApp(),
    'Cash Recycler': (context) => const HomeScreen(),
    'Thermal Printer': (context) => const CommandScreen(),
    'Sensor Board': (context) => const HomeScreen(),
  };

  List<List<String>> _splitButtonsIntoGroups(
      List<String> buttons, int groupSize) {
    List<List<String>> groups = [];
    for (int i = 0; i < buttons.length; i += groupSize) {
      groups.add(buttons.sublist(
          i, i + groupSize > buttons.length ? buttons.length : i + groupSize));
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    List<String> buttonLabels = buttonToScreenMap.keys.toList();
    List<List<String>> buttonGroups = _splitButtonsIntoGroups(buttonLabels, 5);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var buttonGroup in buttonGroups)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: buttonGroup.map((buttonLabel) {
                      return ElevatedButton(
                        onPressed: buttonLabel == 'Cash Recycler' || buttonLabel == 'Sensor Board' 
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: buttonToScreenMap[buttonLabel]!,
                                  ),
                                );
                              },
                        child: Text(buttonLabel),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

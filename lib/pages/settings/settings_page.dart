import 'package:flutter/material.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/constants/styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _HomePageState();
}

class _HomePageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Styles.backgroundColor,
          title: const Text(AppConstants.appTitle),
        ),
        body: const Center(
          child: Text('Settings'),
        ));
  }
}

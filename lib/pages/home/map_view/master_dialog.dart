import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/widgets/buttons.dart';

import '../../../services/api_services/auth_service.dart';
import '../../../widgets/animated_text_field.dart';

void showMasterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          FlutterI18n.translate(context, 'map_view.master_dialog.title'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Button(
              labelText: FlutterI18n.translate(
                  context, 'map_view.master_dialog.create'),
              onPressed: () {
                Navigator.pushNamed(context, '/create-master');
              },
              active: true,
              icon: Icons.add,
              size: Size.medium,
            ),
            Button(
              labelText: FlutterI18n.translate(
                  context, 'map_view.master_dialog.login'),
              onPressed: () {
                Navigator.pop(context);
                showLoginDialog(context);
              },
              active: false,
              icon: Icons.login,
              size: Size.medium,
            ),
          ],
        ),
      );
    },
  );
}

void showLoginDialog(BuildContext context) {
  final TextEditingController phoneController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          FlutterI18n.translate(context, 'map_view.master_dialog.input_phone'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedTextField(
              keyboardType: TextInputType.phone,
              controller: phoneController,
              labelText: FlutterI18n.translate(
                  context, 'map_view.master_dialog.input_phone'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(FlutterI18n.translate(context, 'common.cancel')),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(FlutterI18n.translate(context, 'common.submit')),
            onPressed: () async {
              await AuthService().sendSms(phoneController.text);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

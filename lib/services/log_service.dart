// ignore_for_file: unused_local_variable

import 'package:flutter_udid/flutter_udid.dart';
import 'package:loggme/loggme.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../global_val.dart';

class LogService {
  static Future<void> log(String message,
      {String codeLanguage = 'dart', String type = 'error'}) async {
    String udid2 = await FlutterUdid.udid;
    Logger.sendOnTelegram(telegramChannelsSenders);
    String? email = await authService.getEmail();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionP = packageInfo.version;

    final maxMessageLength = 800;
    List<String> messageParts = [];

    for (int i = 0; i < message.length; i += maxMessageLength) {
      final endIndex = (i + maxMessageLength < message.length)
          ? i + maxMessageLength
          : message.length;
      messageParts.add(message.substring(i, endIndex));
    }

    for (var part in messageParts) {
      final telegramMessage = TelegramLoggMessage()
        ..addBoldText('Email: $email\n')
        ..addBoldText('Udid: $udid2\n')
        ..addBoldText('Version: $versionP\n')
        ..addCodeText('$part\n');

      /// Send on multiple channels (telegram, slack, and custom)
      final logger = Logger(
          slackChannelsSenders: null,
          telegramChannelsSenders: telegramChannelsSenders);

      final responses = await logger.logs(telegramLoggMessage: telegramMessage);
    }
  }
}

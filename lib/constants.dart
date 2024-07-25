import 'package:flutter/material.dart';

class Constants {
  final primaryColor = const Color(0xffcc7d64);
}

enum PROCESS_TYPE {
  UNKNOWN,
  BACKGROUND,
  PAGE,
}

class Command {
  static String stopCommand() => '<S>|';
  static String ringCommand(String value) => '<R>$value|';
  static String changePinCommand(String value) => '<C>$value|';
  static String addContactsCommand(String value) => '<T>$value|';
}

String getFormatedDate() {
  DateTime dateTime = DateTime.now();

  return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
}

String formatDateTime(dateTime) {
  if (dateTime is DateTime) {
    return "${dateTime.day < 10 ? '0' : ''}${dateTime.day}-${dateTime.month < 10 ? '0' : ''}${dateTime.month}-${dateTime.year}";
  }
  try {
    DateTime date = DateTime.parse(dateTime);
    return "${date.day < 10 ? '0' : ''}${date.day}-${date.month < 10 ? '0' : ''}${date.month}-${date.year}";
  } catch (e) {
    return '';
  }
}

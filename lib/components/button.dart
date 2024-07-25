import 'package:flutter/material.dart';

Widget button(String buttonName, Function action) {
  return ElevatedButton(
      onPressed: () {
        action();
      },
      child: Text(buttonName));
}

void nextScreen(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return page;
      },
    ),
  );
}

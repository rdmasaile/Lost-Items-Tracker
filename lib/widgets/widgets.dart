import 'package:flutter/material.dart';
import 'package:projectfbs/main.dart';
import 'package:projectfbs/pages/settings_page.dart';

var inputDecoration = InputDecoration(
  fillColor: Colors.white,
  labelStyle: const TextStyle(color: Color.fromARGB(255, 163, 160, 160)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
  border: OutlineInputBorder(
    borderSide: const BorderSide(width: 5),
    borderRadius: BorderRadius.circular(60),
  ),
  focusColor: Colors.black,
  prefixIconColor: Colors.grey,
  prefixStyle: const TextStyle(
    color: Colors.grey,
  ),
);
Widget button(String buttonName, Function action) {
  return ElevatedButton(
      onPressed: () {
        action();
      },
      child: Text(buttonName));
}

Widget h(String heading, {double size = 18}) {
  return Text(
    heading,
    style: TextStyle(fontSize: size),
  );
}

Widget iconButton(IconData icon, Function action) {
  return IconButton(
    onPressed: () {
      action();
    },
    icon: Icon(icon),
  );
}

Widget columnSpace({double height = 10}) {
  return SizedBox(height: height);
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

void popContext(BuildContext context) {
  Navigator.of(context).pop();
}

void nextScreenReplace(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) {
        return page;
      },
    ),
  );
}

void showSnackBar(BuildContext context, String message,
    {color, Duration duration = const Duration(seconds: 5)}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: duration,
  ));
}

Widget nothing(String message) {
  return SingleChildScrollView(
      child: Container(
    height: 150,
    decoration: const BoxDecoration(
      color: Color.fromARGB(213, 1, 5, 17),
      borderRadius: BorderRadius.all(
        Radius.circular(15),
      ),
    ),
    child: Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ),
  ));
}

Future<void> showDialogueBox(
    BuildContext context, String message, List<Widget> actions,
    {icon, barrierDismissible = true}) async {
  dynamic icons = icon;
  if (icon is String) {
    switch (icon) {
      case "error":
        icons = const Icon(
          Icons.cancel,
          size: 30,
          color: Color.fromARGB(255, 245, 42, 52),
        );
        break;
      case "success":
        icons = const Icon(
          Icons.task_alt_rounded,
          size: 30,
          color: Color.fromARGB(255, 12, 243, 127),
        );
        break;
    }
  }
  if (icons != null) {
    showDialog<Widget>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          icon: icons,
          alignment: Alignment.center,
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: actions,
        );
      },
    );
  } else {
    showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: actions,
        );
      },
    );
  }
}

// AlertDialog showAlertDialog(
//     {required String message, Widget? icon, List? actions}) {
//   return AlertDialog(
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(
//         Radius.circular(15),
//       ),
//     ),
//     icon: icon,
//     alignment: Alignment.center,
//     content: Text(
//       message,
//       textAlign: TextAlign.center,
//     ),
//     actions: actions,
//   );
// }

class GlobalValues {
  static HomeState homePage = HomeState();
  static MyHomePageState home = MyHomePageState();
  static MyAppState myApp = MyAppState();
  ThemeData theme = darkTheme;
  GlobalValues._();
  static final GlobalValues _instance = GlobalValues._();
  static final GlobalValues instance = _instance;
  void setHomePage(page) {
    homePage = page;
  }

  void setMyApp(app) {
    myApp = app;
  }

  void setHome(home1) {
    home = home1;
  }

  void setTheme(THEME themeColor) {
    if (themeColor == THEME.dark) {
      theme = darkTheme;
    } else if (themeColor == THEME.light) {
      theme = lightTheme;
    }
    myApp.update();
  }

  void setCurrentPage(page) {
    home.setCurrentPage(page);
  }
}

final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.grey,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color.fromARGB(255, 44, 43, 43),
);

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.grey,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
);

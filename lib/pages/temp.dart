import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Log in to ")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Log in",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: inputDecoration.copyWith(
                    labelText: "Username",
                    hintText: "example",
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xffee7b64),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: inputDecoration.copyWith(
                    labelText: "Password",
                    hintText: "",
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xffee7b64),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Log in",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//  DropdownMenu(menuStyle: MenuStyle(),
            //     onSelected: ((value) {
            //       print(value);
            //     }),
            //     dropdownMenuEntries: a
            //         .map((e) => DropdownMenuEntry(value: e, label: e))
            //         .toList(),),
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homestay_raya_application/ServerConfig.dart';
import 'package:ndialog/ndialog.dart';

class Registrationscreen extends StatefulWidget {
  const Registrationscreen({super.key});

  @override
  State<Registrationscreen> createState() => _RegistrationscreenState();
}

class _RegistrationscreenState extends State<Registrationscreen> {
  @override
  void initState() {
    super.initState();
    loadEula();
  }

  bool _isChecked = false;
  bool _passwordVisible = true;
  String eula = "", passwordInfo = "";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _pass2EditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Registration Form")),
        body: Center(
            child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: _nameEditingController,
                    keyboardType: TextInputType.text,
                    validator: (val) => val!.isEmpty || (val.length < 3)
                        ? "name must be longer than 3"
                        : null,
                    decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(),
                        icon: Icon(Icons.person),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0),
                        )),
                  ),
                  const Padding(padding: EdgeInsets.all(4)),
                  TextFormField(
                    controller: _emailEditingController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        val!.isEmpty || !val.contains("@") || !val.contains(".")
                            ? "enter a valid email"
                            : null,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(),
                        icon: Icon(Icons.email),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0),
                        )),
                  ),
                  const Padding(padding: EdgeInsets.all(4)),
                  TextFormField(
                    controller: _phoneEditingController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(),
                        icon: Icon(Icons.phone_android),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0),
                        )),
                  ),
                  const Padding(padding: EdgeInsets.all(4)),
                  GestureDetector(
                      onTap: showPasswordInfo,
                      child: const Icon(Icons.announcement_rounded)),
                  TextFormField(
                    controller: _passEditingController,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (val) => validatePassword(val.toString()),
                    obscureText: _passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(),
                      icon: const Icon(Icons.password),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(4)),
                  TextFormField(
                      controller: _pass2EditingController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Re-enter Password',
                        labelStyle: const TextStyle(),
                        icon: const Icon(Icons.password),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      )),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Checkbox(
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          }),
                      Flexible(
                          child: GestureDetector(
                        onTap: showEula,
                        child: const Text(
                          'Agree with terms',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        minWidth: 115,
                        height: 50,
                        elevation: 10,
                        onPressed: _registerAccount,
                        color: Theme.of(context).colorScheme.primary,
                        child: const Text(
                          'Register',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ]),
              ),
            ),
          ),
        )));
  }

  String? validatePassword(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{10,}$';
    RegExp regex = RegExp(pattern);
    if (value.isEmpty) {
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(value)) {
        return 'Enter valid password';
      } else {
        return null;
      }
    }
  }

  void _registerAccount() {
    String _name = _nameEditingController.text;
    String _email = _emailEditingController.text;
    String _phone = _phoneEditingController.text;
    String _password = _passEditingController.text;
    String _password2 = _pass2EditingController.text;

    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the registration form first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (!_isChecked) {
      Fluttertoast.showToast(
          msg: "Please Accept terms",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (_password != _password2) {
      Fluttertoast.showToast(
          msg: "Please check your password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    //if everything good, proceed
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Register new Account",
            style: TextStyle(),
          ),
          content: const Text(
            "Are you sure?",
            style: TextStyle(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                _registerUser(_name, _email, _phone, _password);
              },
            ),
            TextButton(
              child: const Text(
                "No",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  loadEula() async {
    WidgetsFlutterBinding.ensureInitialized();
    eula = await rootBundle.loadString('assets/eula/eula.txt');
  }

  showEula() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "EULA",
            style: TextStyle(),
          ),
          content: SizedBox(
            height: 300,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: RichText(
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                        text: eula),
                  )),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Close",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // either retake value from text editing controller or pass the value.
  void _registerUser(String name, String email, String phone, String password) {
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Registration in progress.."),
        title: const Text("Registering account..."));
    progressDialog.show();
    http.post(Uri.parse("${ServerConfig.SERVER}/php/register_user.php"), body: {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "register": "register"
    }).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        Fluttertoast.showToast(
          msg: "Success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
        progressDialog.dismiss();
        return;
      } else {
        Fluttertoast.showToast(
          msg:
              "Fail", // juz throw success or fail for security purposes, unless it is nessesary to provide information.
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
        progressDialog.dismiss();
        return;
      }
    });
  }

  void showPasswordInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Password Info",
            style: TextStyle(),
          ),
          content: SizedBox(
            height: 100,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: RichText(
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    // ignore: prefer_const_constructors
                    text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                        text:
                            "Your password should be:\n- At least one capital Letter (A-Z)\n- At least one small letter (a-z)\n- At least one number (0-9)\n- At least 10 minimum numbers of character"),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Close",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}

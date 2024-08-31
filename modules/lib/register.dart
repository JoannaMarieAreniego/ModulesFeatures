import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modules/login.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool showPassword = true;

  void togglePassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  InputDecoration _setTextDecoration(String text) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      labelText: text,
      suffixIcon: (text == 'Password' || text == 'Confirm Password')
          ? IconButton(
              onPressed: togglePassword,
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
              ),
            )
          : null,
    );
  }

  void _register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Are you sure?',
      confirmBtnText: 'YES',
      cancelBtnText: 'No',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        _registerUser();
      },
    );
  }

  void _registerUser() async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Loading',
        text: 'Registering your account',
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      String userId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': email.text,
      });
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on FirebaseAuthException catch (ex) {
      Navigator.of(context).pop();
      String errorTitle = '';
      String errorText = '';
      if (ex.code == 'weak-password') {
        errorText = 'Please enter a password with more than 6 characters';
        errorTitle = 'Weak Password';
      } else if (ex.code == 'email-already-in-use') {
        errorText = 'Email is already registered';
        errorTitle = 'Please enter a new email';
      }
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: errorTitle,
        text: errorText,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register User'),
        centerTitle: true,
        backgroundColor: Colors.yellow.shade300,
      ),
      body: Stack(
        children: [
          // Container(
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('assets/images/home_back.jpg'),
          //       opacity: 0.8,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          Container(
            height: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'To register, please enter your email and password',
                      style: TextStyle(fontSize: 19),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: _setTextDecoration('Email Address'),
                      controller: email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required. Please enter your email address';
                        }
                        if (!EmailValidator.validate(value)) {
                          return 'Invalid email';
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      obscureText: showPassword,
                      decoration: _setTextDecoration('Password'),
                      controller: password,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required. Please enter your password';
                        }
                        if (value.length <= 5) {
                          return 'Please enter at least 6 characters';
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      obscureText: showPassword,
                      decoration: _setTextDecoration('Confirm Password'),
                      controller: confirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required. Please confirm your password';
                        }
                        if (value != password.text) {
                          return 'Passwords do not match';
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _register,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Row(
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text('Login'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

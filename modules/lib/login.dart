import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:modules/Modules/moduleHome.dart';
import 'package:modules/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailCon = TextEditingController();
  var passCon = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool hidePass = true;

  void togglePassword() {
    setState(() {
      hidePass = !hidePass;
    });
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Processing...');
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailCon.text, password: passCon.text)
          .then((userCredential) async {
        EasyLoading.dismiss();
        String userId = userCredential.user!.uid;
        final document = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (_) => const ModuleHomeScreen(),
            ),
          );
        }
      }).catchError((error) {
        EasyLoading.showError('Incorrect Username and/or Password');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(5),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(30),
                  const Text(
                    'Enter your email and passsword to login',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(30),
                  TextFormField(
                    controller: emailCon,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required.';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Invalid Email';
                      }
                      return null;
                    },
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: passCon,
                    obscureText: hidePass,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: togglePassword,
                        icon: Icon(
                            hidePass ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required.';
                      }
                      return null;
                    },
                  ),
                  const Gap(12),
                  ElevatedButton(
                    onPressed: login,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    children: [
                      const Text('Dont have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Register'),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

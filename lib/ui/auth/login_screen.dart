import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:posterapp/services/firebase_auth_services.dart';
import 'package:posterapp/ui/admin_screens/home_screen.dart';
import 'package:posterapp/ui/user_screen/user_home_screen.dart';
import 'package:posterapp/ui/widgets/authentication_buttons.dart';
import 'package:posterapp/ui/widgets/textfield.dart';
import 'package:posterapp/utils/utils.dart';

import 'signup_screen.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login_Screen> {
  bool _showProgress = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Login function
  void login(String role) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showProgress = true;
      });

      try {
        User? user = await _authService.signInWithEmailAndPassword(
          usernameController.text.trim(),
          passwordController.text.trim(),
        );

        if (user != null) {
          String userRole = await _authService.getUserRole(user.uid);
          if (userRole == "User") {
            Utils.toastMesage("Sign In as ${user.email}");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const UserDashBoard()),
            );
          } else {
            Utils.toastMesage("Sign In as ${user.email}");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } catch (error) {
        Utils.toastMesage(error.toString());
      } finally {
        setState(() {
          _showProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SingleChildScrollView(
        child: Container(
          height: 800,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  alignment: Alignment.topCenter,
                  margin: const EdgeInsets.all(20),
                  child: Center(
                    child: Image.asset(
                      "assets/Images/welcomeimage.png",
                      height: 200,
                      width: 150,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "Login Your Account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Username Text Field
                buildTextField(
                  controller: usernameController,
                  hintText: "Enter Email",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email cannot be empty";
                    }
                    if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                buildTextField(
                  controller: passwordController,
                  hintText: "Enter Password",
                  obscureText: _isObscure,
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password cannot be empty";
                    }
                    if (value.length < 6) {
                      return "Please enter a valid password with min. 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                authButtons(
                  text: "Login In as User",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      login("User");
                    }
                  },
                  showProgress: _showProgress,
                  color: const Color.fromARGB(255, 113, 158, 231),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 30),
                authButtons(
                  text: "Login In as Admin",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      login("Admin");
                    }
                  },
                  showProgress: _showProgress,
                  color: Colors.white,
                  textColor: const Color.fromARGB(255, 113, 158, 231),
                  borderColor: const Color.fromARGB(255, 113, 158, 231),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have an account? ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 113, 158, 231),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

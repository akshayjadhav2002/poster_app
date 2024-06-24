import 'dart:math';
import "package:posterapp/providers/auth_provider.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:posterapp/ui/widgets/authentication_buttons.dart';
import 'package:posterapp/ui/widgets/textfield.dart';
import 'package:provider/provider.dart';
import 'signup_screen.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login_Screen> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
   final _formKey = GlobalKey<FormState>();

  // Login function


  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<AuthenticationProvider>(context);
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
                  obscureText: false,
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
                Consumer(
                  builder:(context, value, child) {
                   return buildTextField(
                    controller: passwordController,
                    hintText: "Enter Password",
                    obscureText: provider.isObscure,
                    suffixIcon: IconButton(
                      icon: Icon(provider.isObscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        provider.toggleObscure();
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
                  );
                  }
                ),
                const SizedBox(height: 30),
                authButtons(
                  text: "Login In as User",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      provider.login("User",usernameController,passwordController,context);
                    }
                  },
                  showProgress: provider.loadingUserSignin,
                  color: const Color.fromARGB(255, 113, 158, 231),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 30),
                authButtons(
                  text: "Login In as Admin",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      provider.login("Admin",usernameController,passwordController,context);
                    }
                  },
                  showProgress: provider.loadingAdminSignin,
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
                        Navigator.pushReplacement(
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

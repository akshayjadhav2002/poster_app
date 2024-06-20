import 'dart:io';
import 'package:flutter/material.dart';
import 'package:posterapp/services/firebase_auth_services.dart';
import 'package:posterapp/ui/auth/login_screen.dart';
import 'package:posterapp/ui/widgets/authentication_buttons.dart';
import 'package:posterapp/ui/widgets/textfield.dart';
import 'package:posterapp/utils/utils.dart';
import '../../services/firestore_services.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _showProgress = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  var role = 'User';

  void signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showProgress = true;
      });
      try {
        final user = await _authService.createUserWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        if (user != null) {
          await _firestoreService.postDetailsToFirestore(
            uid: user.uid,
            email: emailController.text.trim(),
            role: role,
            name: nameController.text.trim(),
          );
        }
        setState(() {
          _showProgress = false;
        });
        Utils.toastMesage("Successfully Signed Up!");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login_Screen()),
        );
      } catch (error) {
        Utils.toastMesage(error.toString());
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Container(
                  alignment: Alignment.topCenter,
                  margin: const EdgeInsets.all(20),
                  child: Center(
                    child: Image.asset(
                      "assets/Images/signup.png",
                      height: 150,
                      width: 200,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "Create Your Account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField(
                  controller: nameController,
                  hintText: "Name",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter a valid name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                buildTextField(
                  controller: emailController,
                  hintText: "Email",
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
                  hintText: "Password",
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
                const SizedBox(height: 20),
                buildTextField(
                  controller: confirmPassController,
                  hintText: "Confirm Password",
                  obscureText: _isObscure2,
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure2 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure2 = !_isObscure2;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                authButtons(
                  text: "Sign Up as User",
                  showProgress: _showProgress,
                  onTap: () {
                    setState(() {
                      role = "User";
                    });
                    signup();
                  },
                  color: const Color.fromARGB(255, 113, 158, 231),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 20),
                authButtons(
                  text: "Sign Up as Admin",
                  showProgress: _showProgress,
                  onTap: () {
                    setState(() {
                      role = "Admin";
                    });
                    signup();
                  },
                  color: Colors.white,
                  textColor: const Color.fromARGB(255, 113, 158, 231),
                  borderColor: const Color.fromARGB(255, 113, 158, 231),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Login_Screen()),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 113, 158, 231),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

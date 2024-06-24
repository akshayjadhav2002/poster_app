import 'dart:io';
import 'package:flutter/material.dart';
import 'package:posterapp/providers/auth_provider.dart';
import 'package:posterapp/services/firebase_auth_services.dart';
import 'package:posterapp/ui/auth/login_screen.dart';
import 'package:posterapp/ui/widgets/authentication_buttons.dart';
import 'package:posterapp/ui/widgets/textfield.dart';
import 'package:posterapp/utils/utils.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // bool _isObscure = true;
  // bool _isObscure2 = true;
  File? file;



  @override
  Widget build(BuildContext context) {

    AuthenticationProvider provider = Provider.of<AuthenticationProvider>(context);
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
                  obscureText: false,
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
                buildTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: provider.isObscureSignUppassword,
                  suffixIcon: IconButton(
                    icon: Icon(provider.isObscureSignUppassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      provider.toggleObsecureOfsignupPassword();
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
                  obscureText: provider.isObscureSignupConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon( provider.isObscureSignupConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      provider.toggleObsecureOfConfirmsignupPassword();
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
                  showProgress: provider.loadingProgressSignupUser,
                  onTap: () {
                    provider.loadingProgressSignupUserButton(true);
                    provider.signup(emailController, passwordController, nameController, "User", context);
                  },
                  color: const Color.fromARGB(255, 113, 158, 231),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 20),
                authButtons(
                  text: "Sign Up as Admin",
                  showProgress: provider.loadingProgressSignupAdmin,
                  onTap: () {
                    provider.loadingProgressignupAdminButton(true);
                    provider.signup(emailController, passwordController, nameController, "Admin", context);
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

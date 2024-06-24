
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:posterapp/services/firebase_auth_services.dart';
import 'package:posterapp/services/firestore_services.dart';
import 'package:posterapp/ui/admin_screens/home_screen.dart';
import 'package:posterapp/ui/auth/login_screen.dart';
import 'package:posterapp/ui/user_screen/user_home_screen.dart';
import 'package:posterapp/utils/utils.dart';

class AuthenticationProvider with ChangeNotifier {
   final FirebaseAuthService _authService = FirebaseAuthService();
   final FirestoreService _firestoreService = FirestoreService();
    bool _isObscure = false;
    bool _loadingUserSignin = false;
    bool _loadingAdminSignin = false;
    bool _loadingProgressSignupUser = false;
    bool _loadingProgressSignupAdmin = false;
    bool _obscurepassword = false;
    bool _obscureConfirmPassword = false;

    //getters for login
    bool get isObscure =>_isObscure;
    bool get loadingUserSignin =>_loadingUserSignin;
    bool get loadingAdminSignin =>_loadingAdminSignin;

    //getter for signup
    bool get isObscureSignUppassword => _obscurepassword;
    bool get isObscureSignupConfirmPassword => _obscureConfirmPassword;
    bool get loadingProgressSignupUser =>_loadingProgressSignupUser;
    bool get loadingProgressSignupAdmin =>_loadingProgressSignupAdmin;

    /// toogle obsecure for login
    void toggleObscure(){
      _isObscure = !_isObscure;
      notifyListeners();
    } 
    /// toggle function for the signup obscures
    void toggleObsecureOfsignupPassword(){
        _obscurepassword = !_obscurepassword;
        notifyListeners();
    }
    void toggleObsecureOfConfirmsignupPassword(){
        _obscureConfirmPassword = !_obscureConfirmPassword;
        notifyListeners();
    }
    void loadingProgressSignupUserButton(bool value){
      _loadingProgressSignupUser = value;
      notifyListeners();
    }
    void loadingProgressignupAdminButton(bool value){
      _loadingProgressSignupUser = value;
      notifyListeners();
    }
   
    ///loading for login
    void loadinguser(bool value){
      _loadingUserSignin = value;
      notifyListeners();
    }
    void loadingAdmin(bool value){
      _loadingAdminSignin =value;
      notifyListeners(); 
    }

    //login function
    Future<void> login(String role,TextEditingController usernameController,TextEditingController passwordController, BuildContext context,) async {
      try {
        User? user = await _authService.signInWithEmailAndPassword(usernameController.text.trim(),passwordController.text.trim());
        if (user != null) {
          String userRole = await _authService.getUserRole(user.uid);
          if (userRole == "User") {
             loadinguser(true);
             loadingAdmin(false);
            Utils.toastMesage("Sign In as ${user.email}");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const UserDashBoard()),
            );
          } else {
            loadinguser(false);
            Utils.toastMesage("Sign In as ${user.email}");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      }
      catch (error) {
        Utils.toastMesage("Fialed to Sign In${error.toString()}");
        log("${error.toString()}");
        loadinguser(false);
        loadingAdmin(false);
      }
    }

    //Sign up function
    Future<void> signup( TextEditingController emailController, TextEditingController passwordController,TextEditingController nameController,String role,BuildContext context) async {
      if(role=="User"){
        loadingProgressSignupUserButton(true);
      }
      else{
        loadingProgressignupAdminButton(true);
      }

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
         loadingProgressSignupUserButton(false);
         loadingProgressignupAdminButton(false);
        Utils.toastMesage("Successfully Signed Up!");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login_Screen()),
        );
      } catch (error) {
        Utils.toastMesage(error.toString());
        loadingProgressSignupUserButton(false);
        loadingProgressignupAdminButton(false);
      }
  }
  
  
}


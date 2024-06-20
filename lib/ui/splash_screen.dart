import 'package:flutter/material.dart';
import 'package:posterapp/services/splash_services.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  SplashServices splashScreen = SplashServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    splashScreen.isLogin(context);
  }
  @override
  Widget build(BuildContext context) {
    
    return  Scaffold(

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(20),
                
                child: Center(
                  child: Image.asset(
                    "assets/Images/welcomeimage.png",
                    height: 350,
                    width: 200,
                  ),
                ),
              ),
         const Text('Poster App' , 
          style: TextStyle(
            shadows: [
              BoxShadow( 
                color: Color.fromARGB(255, 59, 116, 216),
                spreadRadius:90,
                blurRadius: 30,
                
              )
            ],
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 4, 96, 255)
            ),),
        ],
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";


class Utils{

 static void toastMesage(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 57, 160, 230),
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}
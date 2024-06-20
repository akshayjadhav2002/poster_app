import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posterapp/services/firebase_auth_services.dart';
import 'package:posterapp/services/firestore_services.dart';
import 'package:posterapp/ui/auth/login_screen.dart';
import 'package:share_plus/share_plus.dart';

import 'package:posterapp/utils/utils.dart';

class UserDashBoard extends StatefulWidget {
  const UserDashBoard({super.key});

  @override
  State<UserDashBoard> createState() => _UserDashBoardState();
}

class _UserDashBoardState extends State<UserDashBoard> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _shareImage(String imageUrl, String title, String description) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        'Check out this image: $title\n\n$description\n\n$imageUrl',
        subject: 'Check out this image',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      Utils.toastMesage('Error sharing image: $e');
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 244, 250),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.only(left: 20, bottom: 10),
                    child: Text("Welcome Back 👋",
                      style: GoogleFonts.quicksand(
                        color: const Color.fromARGB(255, 113, 158, 231),
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      )),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(left: 20, bottom: 20),
                    child: Text("Akshay 😊",
                      style: GoogleFonts.quicksand(
                        color: const Color.fromARGB(255, 27, 108, 190),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      )),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () {
                    _authService.signOut().then((value) {
                      Utils.toastMesage("Successfully Signed out");
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return const Login_Screen();
                        },
                      ));
                    }).onError((error, stackTrace) {
                      Utils.toastMesage(error.toString());
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, left: 10),
                    child: const Icon(Icons.logout,
                      color: Color.fromARGB(255, 113, 158, 231),
                      size: 35,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20)
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                stream: _firestoreService.getPostersStream(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }

                  final posters = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 300,
                    ),
                    itemCount: posters.length,
                    itemBuilder: (context, index) {
                      final poster = posters[index];
                      final imageUrl = poster['image'];
                      final title = poster['title'];
                      final description = poster['description'];

                      return Card(
                        color: const Color.fromARGB(255, 113, 158, 231),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 70,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          //download 
                                            // downloadImage(imageUrl);
                                        },
                                        icon: const Icon(Icons.download, color: Colors.white),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Add share functionality here
                                          _shareImage(imageUrl, title, description);
                                        },
                                        icon: const Icon(Icons.share, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              child: Text(
                                "Title: $title",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              child: Text(
                                "Description: $description",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

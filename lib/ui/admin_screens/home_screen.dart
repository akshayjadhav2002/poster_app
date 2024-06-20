import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posterapp/ui/auth/login_screen.dart';
import 'package:posterapp/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance.collection('Posters').snapshots();

  bool loading = false ;
  File? _image ;
  final picker = ImagePicker();


  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance ;
  DatabaseReference databaseRef= FirebaseDatabase.instance.ref('Posters') ;


  Future getImageGallery()async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery , imageQuality: 80);
    setState(() {
      if(pickedFile != null){
        _image = File(pickedFile.path);
      }else {
        print('no image picked');
      }
    });
  }

  Future<void> addPosterDetailsToFirestore(
    File image, String title, String description) async {
    // Upload image to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}');
    await storageRef.putFile(image);
    final imageUrl = await storageRef.getDownloadURL();

    // Add data to Firestore
    final User? user = auth.currentUser;
    final CollectionReference postersRef =
        FirebaseFirestore.instance.collection('Posters');
    await postersRef.add({
      'title': title,
      'description': description,
      'image': imageUrl,
      'userId': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePoster(String docId, String imageUrl) async {
    await FirebaseFirestore.instance.collection('Posters').doc(docId).delete();
    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();
  }

  Future<void> editPosterDetailsInFirestore(
    String docId, File? image, String title, String description, String imageUrl) async {
    String newImageUrl = imageUrl;

    if (image != null) {
      // Upload new image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}');
      await storageRef.putFile(image);
      newImageUrl = await storageRef.getDownloadURL();

      // Delete old image
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
    }

    // Update data in Firestore
    await FirebaseFirestore.instance.collection('Posters').doc(docId).update({
      'title': title,
      'description': description,
      'image': newImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void showEditDeleteDialog(BuildContext context, String docId, String title, String description, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 166, 205, 219),
        title: const Text('Edit or Delete Poster....?',
          style: TextStyle( 
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 15,
                fontWeight: FontWeight.bold
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showEditPosterBottomSheet(context, docId, title, description, imageUrl);
            },
            child: Container(
              height: 25,
              width: 60,
              decoration:  BoxDecoration( 
                color:const Color.fromARGB(255, 255, 251, 251),
                borderRadius: BorderRadius.circular(10),
                border: Border.all( 
                  color: const Color.fromARGB(255, 0, 0, 0),
                )
              ),
              child: const Center(
                child:  Text(
                  'Edit',
                  style: TextStyle( 
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  ),
                  ),
              ),
            ),
          ),
         const SizedBox(
            width: 40,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deletePoster(docId, imageUrl);
            },
            child: Container(
              height: 25,
              width: 60,
              decoration:  BoxDecoration( 
                color: const Color.fromARGB(255, 255, 254, 254),
                borderRadius: BorderRadius.circular(10),
                border: Border.all( 
                  color: const Color.fromARGB(255, 255, 17, 0),
                )
              ),
              child: const Center(
                child: Text('Delete',
                style: TextStyle( 
                  color: Color.fromARGB(255, 255, 0, 0),
                  fontWeight: FontWeight.w800,
                ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showEditPosterBottomSheet(BuildContext context, String docId, String title, String description, String imageUrl) {
    final TextEditingController titleController = TextEditingController(text: title);
    final TextEditingController descriptionController = TextEditingController(text: description);

    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Picker Button
              GestureDetector(
                onTap: () async {
                  getImageGallery();
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: const Color.fromRGBO(140, 128, 128, 0.2)),
                  child:  Center(
                    child: (_image != null) ?  Image.file(height: 80,width:80,_image!.absolute):const Icon(
                      Icons.image_outlined,
                      color: Color.fromARGB(255, 78, 134, 225),
                      size: 40,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              const Text(
                "Image",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Row(
                children: [
                  Text(
                    "Title",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                    hintText: "Title",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 113, 158, 231),
                            width: 2))),
              ),
              const SizedBox(
                height: 20,
              ),
              const Row(
                children: [
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                    hintText: "Description",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 113, 158, 231),
                            width: 2))),
              ),
              const SizedBox(
                height: 30,
              ),
              // Add button
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    // Edit data in Firestore
                    editPosterDetailsInFirestore(
                        docId,
                        _image,
                        titleController.text.toString(),
                        descriptionController.text.toString(),
                        imageUrl);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 78, 134, 225),
                    fixedSize: const Size(150, 50)),
                child: const Text(
                  "Update",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 78, 134, 225),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, bottom: 10),
                  child: Text("Welcome Back 👋",
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      )),
                ),

                /*
              * Lougout user button 
              */
                IconButton(
                  onPressed: () {
                    auth.signOut().then((value) {
                      Utils.toastMesage("Successfully Signout");
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return const Login_Screen();
                        },
                      ));
                    }).onError((error, stackTrace) {
                      Utils.toastMesage(error.toString());
                    });
                  },
                  icon: const Icon(
                    Icons.logout_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                  tooltip: "LogOut",
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: Text("Akshay 😊",
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  )),
            ),

            /// Main Body
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(217, 217, 217, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Text("POSTERS",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: StreamBuilder(
                              stream: fireStore,
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData && !snapshot.hasError) {
                                  final docs = snapshot.data!.docs;
                                  List<Map<String, dynamic>> items =
                                      docs.map((doc) {
                                    return {
                                      "key": doc.id,
                                      "title": doc["title"],
                                      "description": doc["description"],
                                      "image": doc["image"]
                                    };
                                  }).toList();

                                  return DataTable(
                                    columns:const [
                                      DataColumn(label: Text('Sr. No')),
                                      DataColumn(label: Text('Title')),
                                      DataColumn(label: Text('Description')),
                                      DataColumn(label: Text('Image')),
                                    ],
                                    rows: List<DataRow>.generate(
                                      items.length,
                                      (index) => DataRow(
                                        onLongPress: () {
                                          showEditDeleteDialog(
                                            context,
                                            items[index]["key"],
                                            items[index]["title"],
                                            items[index]["description"],
                                            items[index]["image"]
                                          );
                                        },
                                        cells: [
                                          DataCell(
                                              Text((index + 1).toString())),
                                          DataCell(Text(items[index]['title'])),
                                          DataCell(Text(
                                              items[index]['description'])),
                                          DataCell(Image.network(
                                              items[index]['image'],
                                              width: 50,
                                              height: 50)),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                return const Center(
                                      child: CircularProgressIndicator(
                                        color: Color.fromARGB(255, 136, 169, 222),
                                      ));
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addPosterBottomSheet(context);
        },
        backgroundColor: const Color.fromARGB(255, 113, 158, 231),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

//Bottom sheet 
addPosterBottomSheet(BuildContext context) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  

  showModalBottomSheet(
    isScrollControlled: true,
    isDismissible: true,
    context: context,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
            top: 20,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Image Picker Button
            GestureDetector(
              onTap: () async {
                getImageGallery();
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color.fromRGBO(140, 128, 128, 0.2)),
                child:  Center(
                  child: (_image != null) ?  Image.file(height: 80,width:80,_image!.absolute):const Icon(
                    Icons.image_outlined,
                    color: Color.fromARGB(255, 78, 134, 225),
                    size: 40,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),
            const Text(
              "Image",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                Text(
                  "Title",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                  hintText: "Title",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9)),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 113, 158, 231),
                          width: 2))),
            ),
            const SizedBox(
              height: 20,
            ),
            const Row(
              children: [
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                  hintText: "Description",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9)),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 113, 158, 231),
                          width: 2))),
            ),
            const SizedBox(
              height: 30,
            ),
            //Add button
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    _image != null) {
                  // Add data to Firestore
                  addPosterDetailsToFirestore(
                      _image!,
                      titleController.text.toString(),
                      descriptionController.text.toString());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 78, 134, 225),
                  fixedSize: const Size(150, 50)),
              child: const Text(
                "Add",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(255, 255, 255, 1)),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      );
    },
  );
}

}

import 'dart:io';

import 'package:chat_app_final/screens/home/main_user_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class EditProfileScreen extends StatefulWidget {
  String username;
  String imageURL;
  String bio;
  EditProfileScreen({required this.username, required this.bio, required this.imageURL});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? imageFile;
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool signingUserIn = false;
  Future<void> pickImage() async {
    //bool check = await _permission.isGranted;
    print("HELLO");
    // print(check.toString() + " Hello");
    var pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;
    setState(() {
      print(pickedImage.path);
      imageFile = File(pickedImage.path);
    });
  }

  Future<void> uploadImage() async {
    final destination = FirebaseAuth.instance.currentUser!.email! + "userImage";
    var ref = FirebaseStorage.instance.ref(destination);
    try{
      await ref.putFile(imageFile!);
      print("YES1");
      String imageURL = await FirebaseStorage.instance.ref(FirebaseAuth.instance.currentUser!.email! + "userImage").getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).update({"imageURL":imageURL});
      return null;
    }
    on Firebase catch (error){
      return null;
    }
  }

  Image bgImage() {
    if(imageFile==null){
      return Image.network(widget.imageURL);
    }
    return Image.file(imageFile!);
  }

  Widget screenToShowOnImageUpload(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text("Uploading Your Image..."),
        ],
      ),);
  }
  @override
  Widget build(BuildContext context) {
    usernameController.text = widget.username;
    bioController.text = widget.bio;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          body: signingUserIn==true ? screenToShowOnImageUpload() : Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth,
                ),
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: Container(
                    height: screenWidth * 0.16,
                    width: screenWidth * 0.16,
                    child: GestureDetector(
                      onTap: (){
                        pickImage();
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: screenWidth*0.08,
                            backgroundImage: bgImage().image,
                          ),
                          Positioned(
                            bottom: 5,

                            right: 5,
                            child: Container(
                              height: screenWidth*0.05,
                              width: screenWidth*0.05,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(screenWidth*0.025),
                                  border: Border.all(color: Colors.black,width: 1)
                              ),
                              child: Icon(Icons.edit,size: screenWidth*0.04,),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * 0.8,
                  padding: EdgeInsets.only(bottom: screenHeight*0.04),
                  margin: EdgeInsets.only(top: screenHeight*0.03),
                  child: TextFormField(
                    controller: usernameController,
                    maxLength: 15,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    ),
                    validator: (value){
                      if(value==null || value==""){
                        return "Username cannot be empty !";
                      }
                    },
                  ),
                ),
                Container(
                  width: screenWidth * 0.8,
                  padding: EdgeInsets.only(bottom: screenHeight*0.04),
                  child: TextFormField(
                    controller: bioController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: "Your Bio",
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    ),
                    validator: (value){
                      if(value==null || value==""){
                        return "Bio cannot be empty !";
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final isValidate = formKey.currentState!.validate();
                    if(isValidate==false) return;
                    List<String> possibleSearchPrefixes = [];
                    String toAdd = "";
                    for(int i=0;i<usernameController.text.length;i++){
                      toAdd = toAdd + usernameController.text[i].toLowerCase();
                      possibleSearchPrefixes.add(toAdd);
                    }
                    if(imageFile==null){
                      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email).update({"username" : usernameController.text,"bio" : bioController.text,"imageURL" : widget.imageURL,"possibleSearch" : possibleSearchPrefixes});
                    }
                    else{
                      setState(() {
                        signingUserIn=true;
                      });
                      await uploadImage();
                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).update({"username":usernameController.text,"possibleSearch" : possibleSearchPrefixes,"bio" : bioController.text});
                      // FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email).set("photoURL":)
                    }
                    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).get();
                    QuerySnapshot friendsQuery = await FirebaseFirestore.instance.collection('users').doc(userSnapshot.get("email")).collection("personal chats").get();
                    print("HELLO WORLD HERE");
                    print(friendsQuery.docs.length);
                    friendsQuery.docs.forEach((element) async {
                      print("");
                      print(element.id);
                      print("");
                      await FirebaseFirestore.instance.collection('users').doc(element.id).collection("personal chats").doc(userSnapshot.get("email")).update({"imageURL" : userSnapshot.get("imageURL"),"username" : userSnapshot.get("username")});
                    });
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainUserScreen()));
                  },
                  child: Text('Save'),),
              ],
            ),
          )),
    );
  }
}

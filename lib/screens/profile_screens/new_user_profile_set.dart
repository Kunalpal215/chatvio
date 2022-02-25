import 'package:chat_app_final/screens/home/main_user_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SetUsernameAndImage extends StatefulWidget {
  const SetUsernameAndImage({Key? key}) : super(key: key);

  @override
  _SetUsernameAndImageState createState() => _SetUsernameAndImageState();
}

class _SetUsernameAndImageState extends State<SetUsernameAndImage> {
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
      return Image.asset('assets/default.jpg');
    }
    return Image.file(imageFile!);
  }
  
  Widget screenToShowOnImageUpload(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: CircularProgressIndicator(),
        ),
        Text("Saving your profile ...",style: TextStyle(fontFamily: "SFpro",fontSize: 25),),
      ],
    ),);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
          body: signingUserIn==true ? screenToShowOnImageUpload() : Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight*0.11),
              child: Image.asset("assets/app_logo.png",width: screenWidth*0.7,),
            ),
            SizedBox(
              width: screenWidth,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight*0.04),
              child: GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: Container(
                  height: screenWidth * 0.25,
                  width: screenWidth * 0.25,
                  child: GestureDetector(
                    onTap: (){
                      pickImage();
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: screenWidth*0.18,
                            backgroundImage: bgImage().image,
                        ),
                        Positioned(
                          bottom: screenWidth*0.019,
                          right: screenWidth*0.019,
                          child: Container(
                            height: screenWidth*0.07,
                            width: screenWidth*0.07,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(screenWidth*0.035),
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
            ),
            Container(
              width: screenWidth * 0.8,
              padding: EdgeInsets.only(bottom: screenHeight*0.04),
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
            GestureDetector(
              onTap: () async {
                final isValidate = formKey.currentState!.validate();
                if(isValidate==false) return;
                List<String> possibleSearchPrefixes = [];
                String toAdd = "";
                for(int i=0;i<usernameController.text.length;i++){
                  toAdd = toAdd + usernameController.text[i].toLowerCase();
                  possibleSearchPrefixes.add(toAdd);
                }
                if(imageFile==null){
                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email).update({"username" : usernameController.text,"bio" : bioController.text,"imageURL" : "https://firebasestorage.googleapis.com/v0/b/chat-app-flutter-7212d.appspot.com/o/default.jpg?alt=media&token=9288eb05-4051-4374-8e9b-3b83836cd543","possibleSearch" : possibleSearchPrefixes});
                }
                else{
                  setState(() {
                    signingUserIn=true;
                  });
                  await uploadImage();
                  await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).update({"username":usernameController.text,"possibleSearch" : possibleSearchPrefixes,"bio" : bioController.text});
                  // FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email).set("photoURL":)
                }
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainUserScreen()));
              },
              child: Container(
                width: screenWidth*0.6,
                height: screenWidth*0.13,
                decoration: BoxDecoration(
                  color: Color(0xff3E7FE0),
                  borderRadius: BorderRadius.circular(screenWidth*0.065),
                ),
                alignment: Alignment.center,
                child: Text("Save my profile",style: TextStyle(
                  fontFamily: "SFpro",
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth*0.05,
                  color: Colors.white,
                ),),
              ),
            )
          ],
        ),
      )),
    );
  }
}

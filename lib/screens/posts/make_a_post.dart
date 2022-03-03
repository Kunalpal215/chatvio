import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
class PostMakerScreen extends StatefulWidget {
  const PostMakerScreen({Key? key}) : super(key: key);

  @override
  _PostMakerScreenState createState() => _PostMakerScreenState();
}

class _PostMakerScreenState extends State<PostMakerScreen> {
  File? imageFile;
  final formKey = GlobalKey<FormState>();
  final TextEditingController postDescpController = TextEditingController();
  bool uploadingPost = false;
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

  Future<String> uploadImage() async {
    final destination = FirebaseAuth.instance.currentUser!.email! + "/" + Uuid().v4();
    var ref = FirebaseStorage.instance.ref(destination);
    try{
      await ref.putFile(imageFile!);
      print("YES1");
      String imageURL = await FirebaseStorage.instance.ref(destination).getDownloadURL();
      print(imageURL);
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).update({"imageURL":imageURL});
      return imageURL;
    }
    on Firebase catch (error){
      return "upload failed !";
    }
  }

  Widget screenToShowOnMakingPost(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text("Uploading your post..."),
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
        appBar: AppBar(
          title: Text("Make a Post :)"),
        ),
          body: uploadingPost==true ? screenToShowOnMakingPost() : Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth,
                  height: screenHeight*0.07,
                ),
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: Container(
                    height: screenWidth * 0.9,
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: GestureDetector(
                      onTap: (){
                        pickImage();
                      },
                      child: imageFile==null ? Container(
                        child: Center(child: Text("Click to pick an image"),),
                      ) : Image.file(imageFile!,fit: BoxFit.cover,),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * 0.8,
                  padding: EdgeInsets.only(bottom: screenHeight*0.04),
                  margin: EdgeInsets.only(top: screenHeight*0.03),
                  child: TextFormField(
                    controller: postDescpController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: "Post Description",
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    ),
                    validator: (value){
                      if(value==null || value==""){
                        return "Description cannot be empty !";
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final isValidate = formKey.currentState!.validate();
                    if(isValidate==false) return;
                    String imageURL;
                    if(imageFile==null){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pick an image to make post")));
                      return;
                    }
                    else{
                      setState(() {
                        uploadingPost=true;
                      });
                      imageURL = await uploadImage();
                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).collection('posts').add({"timestamp":DateTime.now().microsecondsSinceEpoch,"imageURL":imageURL,"postDescp":postDescpController.text});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your post got uploaded")));
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Upload Post'),),
              ],
            ),
          ),
      ),
    );
  }
}

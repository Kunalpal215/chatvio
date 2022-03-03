import 'package:chat_app_final/auth/google_auth.dart';
import 'package:chat_app_final/screens/profile_screens/edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_app_final/screens/posts/make_a_post.dart';
import 'dart:math';

import '../welcome_screen.dart';
class ProfileScreen extends StatefulWidget {
  String username;
  String email;
  String bio;
  String imageURL;
  ProfileScreen({required this.username, required this.email,required this.imageURL,required this.bio});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Widget PostShowMaker(QueryDocumentSnapshot snapshot, var screenWidth){
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(snapshot.get("imageURL"),width: screenWidth*0.9,height: screenWidth*0.9,fit: BoxFit.cover,),
          Padding(
            padding: EdgeInsets.only(top: 8,left: 4,right: 4,bottom: 8),
            child: Text(snapshot.get("postDescp"),
              style: TextStyle(
                fontFamily: "SFpro",
                fontSize: screenWidth*0.04,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Profile"),
      ),
      body: ListView(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth,
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.1,),
            child: Center(
              child: CircleAvatar(
                radius: screenWidth*0.14,
                backgroundImage: NetworkImage(widget.imageURL)
              )
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.03),
            child: Center(
              child: Text(widget.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: screenWidth*0.08,
                  fontFamily: 'SFpro',
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.01,left: screenWidth*0.1,right: screenWidth*0.1),
            child: Center(
              child: Text(widget.bio,
                style: TextStyle(
                    fontSize: screenWidth*0.04,
                    fontFamily: 'SFpro',
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight*0.02),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfileScreen(username: widget.username, bio: widget.bio, imageURL: widget.imageURL)));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth*0.04,vertical: screenHeight*0.01),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(screenWidth*0.02)
                    ),
                    child: Text("Edit my profile",style: TextStyle(color: Colors.white,fontFamily: "SFpro",fontSize: screenWidth*0.04),),
                  ),
                ),
              ),
              SizedBox(width: 50,),
              Padding(
                padding: EdgeInsets.only(top: screenHeight*0.02),
                child: GestureDetector(
                  onTap: () async {
                    GoogleAuthClass().logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth*0.04,vertical: screenHeight*0.01),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(screenWidth*0.02)
                    ),
                    child: Text("Logout",style: TextStyle(color: Colors.white,fontFamily: "SFpro",fontSize: screenWidth*0.04),),
                  ),
                ),
              ),
            ],
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).collection('posts').snapshots(),
            builder: (context,AsyncSnapshot snapshot){
              if(!snapshot.hasData){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              List<Widget> toShow = [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10,top: 20),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text("Posts",style: TextStyle(fontFamily: "SFpro",fontSize: screenWidth*0.07,fontWeight: FontWeight.w700),),
                      )
                    )
                  ],
                )
              ];
              snapshot.data.docs.forEach((element) => {
                toShow.add(PostShowMaker(element, screenWidth)),
              });
              return Column(
                children: toShow,
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostMakerScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

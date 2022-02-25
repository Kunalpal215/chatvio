import 'package:chat_app_final/auth/google_auth.dart';
import 'package:chat_app_final/screens/profile_screens/edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Profile"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth,
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.1),
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.imageURL,),
              radius: screenWidth*0.14,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.03),
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
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.01,left: screenWidth*0.1,right: screenWidth*0.1),
            child: Text(widget.bio,
              style: TextStyle(
                  fontSize: screenWidth*0.04,
                  fontFamily: 'SFpro',
                  fontWeight: FontWeight.w500
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
        ],
      ),
    );
  }
}

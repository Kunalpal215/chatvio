import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class SuggestionProfileScreen extends StatefulWidget {
  String username;
  String imageURL;
  String email;
  String bio;
  String relation;
  SuggestionProfileScreen({required this.username,required this.imageURL,required this.email,required this.bio, required this.relation});
  @override
  _SuggestionProfileScreenState createState() => _SuggestionProfileScreenState();
}

class _SuggestionProfileScreenState extends State<SuggestionProfileScreen> {
  Widget onNotAFriend(var screenWidth, var screenHeight){
    return GestureDetector(
      onTap: () async {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).get();
        await FirebaseFirestore.instance.collection('users').doc(widget.email).collection("friend requests").doc(userSnapshot.id).set({
          "imageURL" : userSnapshot.get("imageURL"),
          "username" : userSnapshot.get("username"),
          "email" : userSnapshot.get("email"),
          "bio" : userSnapshot.get("bio"),
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth*0.04,vertical: screenHeight*0.01),
        margin: EdgeInsets.only(top: screenHeight*0.03),
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(screenWidth*0.02)
        ),
        child: Text("Send friend request",style: TextStyle(color: Colors.white,fontFamily: "SFpro",fontSize: screenWidth*0.04),),
      ),
    );
  }

  Widget otherCase(String message,var screenWidth, var screenHeight){
    return Container(
      margin: EdgeInsets.only(top: screenHeight*0.03),
      child: Text(message,style: TextStyle(fontFamily: "SFpro",fontSize: screenWidth*0.04),),
    );
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Searched person"),
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
            widget.relation == "not a friend" ? onNotAFriend(screenWidth,screenHeight) : otherCase(widget.relation,screenWidth,screenHeight),
          ],
      ),
    );
  }
}

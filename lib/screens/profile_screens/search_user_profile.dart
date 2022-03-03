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
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth*0.04,vertical: screenHeight*0.01),
          margin: EdgeInsets.only(top: screenHeight*0.03),
          decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(screenWidth*0.02)
          ),
          child: Text("Send friend request",style: TextStyle(color: Colors.white,fontFamily: "SFpro",fontSize: screenWidth*0.04),),
        ),
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
            // Padding(
            //   padding: EdgeInsets.only(top: screenHeight*0.1),
            //   child: CircleAvatar(
            //     backgroundImage: NetworkImage(widget.imageURL,),
            //     radius: screenWidth*0.14,
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.only(top: screenHeight*0.03),
            //   child: Text(widget.username,
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //     style: TextStyle(
            //         fontSize: screenWidth*0.08,
            //         fontFamily: 'SFpro',
            //         fontWeight: FontWeight.w500
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.only(top: screenHeight*0.01,left: screenWidth*0.1,right: screenWidth*0.1),
            //   child: Text(widget.bio,
            //     style: TextStyle(
            //         fontSize: screenWidth*0.04,
            //         fontFamily: 'SFpro',
            //         fontWeight: FontWeight.w500
            //     ),
            //   ),
            // ),
            widget.relation == "not a friend" ? onNotAFriend(screenWidth,screenHeight) : otherCase(widget.relation,screenWidth,screenHeight),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(widget.email).collection('posts').snapshots(),
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
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
class RequestUserProfile extends StatefulWidget {
  String username;
  String imageURL;
  String email;
  String bio;
  RequestUserProfile({required this.username,required this.imageURL,required this.email,required this.bio});
  @override
  _RequestUserProfileState createState() => _RequestUserProfileState();
}

class _RequestUserProfileState extends State<RequestUserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.username),
          Image.network(widget.imageURL,width: 100, height: 100,),
          Text(widget.bio),
          ElevatedButton(onPressed: () async {
            String newChatDocId = Uuid().v4();
            FirebaseFirestore.instance.collection('chats').doc(newChatDocId).collection("random").doc().set({"Made on" : DateTime.now().day.toString() + "/" + DateTime.now().month.toString() + "/" + DateTime.now().year.toString()});
            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).get();
            await FirebaseFirestore.instance.collection('users').doc(userSnapshot.get("email")).collection('personal chats').doc(widget.email).set({"chatDocId" : newChatDocId,"imageURL" : widget.imageURL,"username" : widget.username, "timestamp" : 0, "lastMessage" : "","email" : widget.email});
            await FirebaseFirestore.instance.collection('users').doc(widget.email).collection('personal chats').doc(userSnapshot.get("email")).set({"chatDocId" : newChatDocId,"imageURL" : userSnapshot.get("imageURL"),"username" : userSnapshot.get("username"),"timestamp" : 0, "lastMessage" : "","email" : userSnapshot.id});
            await FirebaseFirestore.instance.collection('users').doc(userSnapshot.get("email")).collection('friend requests').doc(widget.email).delete();
            Navigator.pop(context);
          },
            child: Text("Accept Friend Request"),),
        ],
      ),
    );
  }
}

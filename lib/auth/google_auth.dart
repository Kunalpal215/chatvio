import 'package:chat_app_final/screens/home/main_user_screen.dart';
import 'package:chat_app_final/screens/profile_screens/new_user_profile_set.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class GoogleAuthClass{
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email','https://www.googleapis.com/auth/contacts.readonly']);
  Future<void> signInWithGoogle(BuildContext context) async{
    try{
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if(googleSignInAccount!=null){
        GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        AuthCredential _authCredential = GoogleAuthProvider.credential(idToken: googleSignInAuthentication.idToken,accessToken: googleSignInAuthentication.accessToken);
        try{
          UserCredential _userCredential = await _auth.signInWithCredential(_authCredential);
          print("SIGNED IN");
          User _user = _userCredential.user!;
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(_user.email!).get();
          if(!userSnapshot.exists){
            FirebaseFirestore.instance.collection('users').doc(_user.email).set({"email" : _user.email,"imageURL": _user.photoURL,"possibleSearch" : [],"bio" : ""});
          }
          userSnapshot = await FirebaseFirestore.instance.collection('users').doc(_user.email!).get();
          if(_userCredential!=null && userSnapshot.get("imageURL")==_user.photoURL){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetUsernameAndImage()));
          }
          else{
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainUserScreen()));
          }
        }
        on FirebaseException catch (error){
          print(error.message);
        }
      }
    }
    catch (error){
      print(error);
    }
  }
  Future<void> logout() async{
    googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
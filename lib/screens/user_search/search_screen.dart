import 'dart:async';

import 'package:chat_app_final/screens/profile_screens/search_user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  StreamController searchController = StreamController();
  TextEditingController formController = TextEditingController();

  Future<String> checkIfFriend(String email) async {
    print(email);
    String res = "not a friend";
    //DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).get();
    if(email == FirebaseAuth.instance.currentUser!.email!){
      res = "This is you";
    }
    if(res == "not a friend"){
      QuerySnapshot chatsSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).collection("personal chats").get();
      chatsSnapshot.docs.forEach((element) {
        if(element.id==email){
          res = "already a friend";
        }
      });
    }
    return res;
  }

  Future<bool> checkIfRequestSent(String email) async {
    bool res = false;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').doc(email).collection("friend requests").get();
    querySnapshot.docs.forEach((element) {
      if(element.id==FirebaseAuth.instance.currentUser!.email){
        res=true;
      }
    });
    return res;
  }
  
  Widget searchedUserSuggestionTile (String username, String imageURL,String email, String bio,var screenWidth, var screenHeight){
    bool clickable = false;
    String relation = "";
    return GestureDetector(
      onTap: (){
        if(clickable==false) return;
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SuggestionProfileScreen(username: username,imageURL: imageURL,email: email,bio: bio,relation: relation,)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(left: 15,top: 8,bottom: 8,right: screenWidth*0.05),
              child: CircleAvatar(
                backgroundImage: NetworkImage(imageURL),
                radius: screenWidth*0.06,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth*0.83 - 41,
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 5,right: 6,),
                  child: Text(username,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: screenWidth*0.045,fontWeight: FontWeight.w800,fontFamily: "SFpro"),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('users').doc(email).collection("friend requests").snapshots(),
                  builder: (context, AsyncSnapshot asyncSnapshot){
                    return FutureBuilder(
                      future: checkIfFriend(email),
                      builder: (context,snapshot){
                        if(snapshot.hasData){
                          if(snapshot.data == "not a friend"){
                            return FutureBuilder(
                              future: checkIfRequestSent(email),
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  clickable=true;
                                  if(snapshot.data==true){
                                    relation = "A friend request already sent";
                                    return Text("A friend request already sent");
                                  }
                                  relation = "not a friend";
                                  return Container(
                                    padding: EdgeInsets.only(right: 6),
                                    height: screenHeight*0.03,
                                    width: screenWidth*0.4,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(screenHeight*0.02)
                                    ),
                                    child: Text("Send friend request",
                                      style: TextStyle(fontSize: screenWidth*0.034,fontWeight: FontWeight.w500,fontFamily: "SFpro",color: Colors.white),
                                    ),
                                  );
                                }
                                return Container();
                              },
                            );
                          }
                          else if(snapshot.data == "This is you"){
                            clickable=true;
                            relation = "This is you";
                            return Text("this is you");
                          }
                          else{
                            clickable=true;
                            relation = "Already your friend";
                            return Text("Already your friend");
                          }
                        }
                        return Container();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight*0.07),
        child: AppBar(
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          backgroundColor: Colors.white,
          title: Container(
            height: screenHeight*0.08,
            alignment: Alignment.center,
            child: Container(
              height: screenHeight*0.06,
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenHeight*0.03),
                border: Border.all(color: Colors.black,width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8,right: 8),
                    child: Icon(Icons.search,color: Colors.black,size: screenWidth*0.065),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: formController,
                      onChanged: (value) async {
                        if(value == null || value==""){
                          searchController.sink.add("NO SUCH USER!");
                          return;
                        }
                        await FirebaseFirestore.instance.collection("users").where("possibleSearch", arrayContains: value.toLowerCase()).get().then((value){
                          searchController.sink.add(value);
                        });
                      },
                      style: TextStyle(
                        fontSize: screenWidth*0.043,
                        fontFamily: "SFpro",
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search a user",
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: (){
                        searchController.sink.add("NO SUCH USER!");
                        formController.text="";
                      },
                      child: Icon(Icons.cancel,color: Colors.black,size: screenWidth*0.065,),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: searchController.stream,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.hasData){
            List<Widget> toShow = [];
            if(snapshot.data!="NO SUCH USER!"){
              snapshot.data.docs.forEach((element) => {
                print(element.get("imageURL")),
                toShow.add(searchedUserSuggestionTile(element.get("username"), element.get("imageURL"), element.get("email"), element.get("bio"),screenWidth,screenHeight)),
              });
            }
            return ListView(
              children: toShow
            );
          }
          return Container();
        },
      )
    );
  }
}

import 'dart:async';

import 'package:chat_app_final/auth/google_auth.dart';
import 'package:chat_app_final/screens/friend_screens/personal_chat_screen.dart';
import 'package:chat_app_final/screens/posts/make_a_post.dart';
import 'package:chat_app_final/screens/profile_screens/friend_profile_screen.dart';
import 'package:chat_app_final/screens/profile_screens/profile_screen.dart';
import 'package:chat_app_final/screens/profile_screens/request_user_file.dart';
import 'package:chat_app_final/screens/user_search/search_screen.dart';
import 'package:chat_app_final/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MainUserScreen extends StatefulWidget{
  @override
  _MainUserScreenState createState() => _MainUserScreenState();
}

class _MainUserScreenState extends State<MainUserScreen>{

  String? imageURL;
  DocumentSnapshot? userSnapshot;
  bool userLoaded = false;
  StreamController userImageController = StreamController();
  StreamController chatsController = StreamController();

  Widget PostShowMaker(QueryDocumentSnapshot snapshot, String username ,var screenWidth){
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
          Center(child: Image.network(snapshot.get("imageURL"),width: screenWidth*0.9,height: screenWidth*0.9,fit: BoxFit.cover,)),
          Padding(
            padding: EdgeInsets.only(top: 8,left: 4,right: 4,),
            child: Text(username,
              style: TextStyle(
                  fontFamily: "SFpro",
                  fontSize: screenWidth*0.043,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 1,left: 4,right: 4,bottom: 8),
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
  
  Future<void> getImageURL() async {
    String toInsert = await FirebaseStorage.instance
        .ref(FirebaseAuth.instance.currentUser!.email! + "userImage")
        .getDownloadURL();
    userImageController.sink.add(toInsert);
  }

  Future<void> getUserSnapshot() async {
    userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email!)
        .get();
    userLoaded = true;
  }

  @override
  void initState() {
    super.initState();
    getImageURL();
    getUserSnapshot();
  }

  Widget requestUserTile(
      String username, String imageURL, String email, String bio, var screenWidth, var screenHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RequestUserProfile(
                  username: username,
                  imageURL: imageURL,
                  email: email,
                  bio: bio,
                )));
      },
      child: Container(
        color: Colors.yellow,
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
              children: [
                SizedBox(
                  width: screenWidth*0.83 - 21,
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 5,right: 6,top: 6),
                  child: Text(username,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: screenWidth*0.04,fontWeight: FontWeight.w800,fontFamily: "SFpro"),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    String newChatDocId = Uuid().v4();
                    FirebaseFirestore.instance.collection('chats').doc(newChatDocId).collection("random").doc().set({"Made on" : DateTime.now().day.toString() + "/" + DateTime.now().month.toString() + "/" + DateTime.now().year.toString()});
                    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).get();
                    await FirebaseFirestore.instance.collection('users').doc(userSnapshot.get("email")).collection('personal chats').doc(email).set({"chatDocId" : newChatDocId,"imageURL" : imageURL,"username" : username, "timestamp" : 0, "lastMessage" : "","email" : email});
                    await FirebaseFirestore.instance.collection('users').doc(email).collection('personal chats').doc(userSnapshot.get("email")).set({"chatDocId" : newChatDocId,"imageURL" : userSnapshot.get("imageURL"),"username" : userSnapshot.get("username"),"timestamp" : 0, "lastMessage" : "","email" : userSnapshot.id});
                    await FirebaseFirestore.instance.collection('users').doc(userSnapshot.get("email")).collection('friend requests').doc(email).delete();
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.only(right: 6),
                    margin: EdgeInsets.only(bottom: 6),
                    height: screenHeight*0.04,
                    width: screenWidth*0.3,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(screenHeight*0.02)
                    ),
                    child: Text("Accept request",
                      style: TextStyle(fontSize: screenWidth*0.034,fontWeight: FontWeight.w500,fontFamily: "SFpro",color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget friendChatUserTile(
      String username, String imageURL, String chatDocId,String email,String timestamp ,String lastMessage,var screenWidth, var screenHeight){
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(
                      chatDocId: chatDocId,
                      email: email,
                    )));
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8,horizontal: 4),
            height: screenWidth*0.16,
            decoration: BoxDecoration(
              //color: Colors.yellow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black,width: 0.5),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: screenWidth*0.17+15,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 7,right: 6),
                      child: Text(username,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: screenWidth*0.04,fontWeight: FontWeight.w800,fontFamily: "SFpro"),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 6),
                      width: (screenWidth*0.83)-29,
                      child: Text(timestamp == "0" ? "Start chatting with your new friend :)" : lastMessage,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: screenWidth*0.034,fontWeight: FontWeight.w400,fontFamily: "SFpro"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () async {
              print("YES PRESSED");
              DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance.collection('users').doc(email).get();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => FriendProfileScreen(username: username, imageURL: imageURL, email: email, bio: friendSnapshot.get("bio"))));
            },
            child: Container(
              padding: EdgeInsets.only(left: 15,top: 8,bottom: 8,right: screenWidth*0.05),
              child: CircleAvatar(
                backgroundImage: NetworkImage(imageURL),
                radius: screenWidth*0.06,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<Widget> getPosts(AsyncSnapshot snapshot,var screenWidth) async {
    print("YAHA PAHUCHA HAI");
    List<Widget> postsList = [];
    for(var i = 0;i<snapshot.data.docs.length ; i++){
      print("2 Yaha pahuc");
      print((snapshot.data.docs[i]).get("email"));
      QuerySnapshot friendPostSnapshot = await FirebaseFirestore.instance.collection('users').doc((snapshot.data.docs[i]).get("email")).collection('posts').orderBy("timestamp").limit(3).get();
      print("Passed from here");
      friendPostSnapshot.docs.forEach((postElement) {
        print("YES");
        postsList.add(PostShowMaker(postElement,(snapshot.data.docs[i]).get("username"),screenWidth));
        print("YES2");
      });
    }
    if (postsList.length == 0) {
      print("HELLO HERE");
      return Center(
        child: Text("No recent Posts"),
      );
    }
    return ListView(
      children: postsList,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 10,
            leadingWidth: 0,
            title:  Image.asset("assets/app_logo.png",width: screenWidth*0.4,),
            actions: [
              StreamBuilder(
                  stream: userImageController.stream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          onTap: () {
                            if (userLoaded == false) return;
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(
                                      username: userSnapshot!.get("username"),
                                      email: userSnapshot!.get("email"),
                                      bio: userSnapshot!.get("bio"),
                                      imageURL: userSnapshot!.get("imageURL"),
                                    )));
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              snapshot.data,
                            ),
                            radius: screenWidth * 0.06,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () {
                          if (userLoaded == false) return;
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(
                                    username: userSnapshot!.get("username"),
                                    email: userSnapshot!.get("email"),
                                    bio: userSnapshot!.get("bio"),
                                    imageURL: userSnapshot!.get("imageURL"),
                                  )));
                        },
                        child: CircleAvatar(
                          backgroundImage: AssetImage("assets/default.jpg"),
                          radius: screenWidth * 0.06,
                        ),
                      ),
                    );
                  }
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserSearchScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Icon(
                    Icons.search,
                    color: Colors.black,
                    size: screenWidth*0.07,
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              labelColor: Colors.black,
              labelStyle: TextStyle(
                  fontSize: screenWidth*0.045,
                  fontFamily: "SFpro",
                  fontWeight: FontWeight.w500
              ),
              tabs: [
                Tab(
                  text: "Chats",
                ),
                Tab(
                  text: "Requests",
                ),
                Tab(
                  text: "Posts",
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.email!)
                    .collection('personal chats')
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> toShow = [];
                    print("HELLO 1");
                    print(snapshot.data.docs.toString());
                    print("HELLO 2");
                    List<Widget> friendsList = [];
                    snapshot.data.docs.forEach((element) => {
                      friendsList.add(friendChatUserTile(
                          element.get("username"),
                          element.get("imageURL"),
                          element.get("chatDocId"),
                          element.get("email"),
                          element.get("timestamp").toString(),
                          element.get("lastMessage"),
                          screenWidth,
                          screenHeight
                      ))
                    });
                    if (friendsList.length == 0) {
                      return Center(
                        child: Text("Make some friends :)"),
                      );
                    }
                    return ListView(
                      children: friendsList,
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("An error occured :("),
                    );
                  }
                  return Center(
                    child: Text("Loading..."),
                  );
                },
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.email!)
                    .collection("friend requests")
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> toShow = [];
                    print("HELLO 1");
                    print(snapshot.data.docs.toString());
                    print("HELLO 2");
                    List<Widget> requestsList = [];
                    snapshot.data.docs.forEach((element) => {
                      requestsList.add(requestUserTile(
                          element.get("username"),
                          element.get("imageURL"),
                          element.get("email"),
                          element.get("bio"),
                          screenWidth,
                          screenHeight
                      ),
                      ),
                    });
                    if (requestsList.length == 0) {
                      return Center(
                        child: Text("No friend requests"),
                      );
                    }
                    return ListView(
                      children: requestsList,
                    );
                  }
                  return Center(
                    child: Text("Loading..."),
                  );
                },
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).collection('personal chats').snapshots(),
                builder: (context,AsyncSnapshot snapshot){
                  if (snapshot.hasData) {
                    print(snapshot.data.docs.toString());
                    print("HELLO 2");
                    return FutureBuilder(
                      future: getPosts(snapshot, screenWidth),
                      builder: (context, AsyncSnapshot postsSnapshot){
                        if(postsSnapshot.hasData){
                          return postsSnapshot.data;
                        }
                        return Container();
                      },
                    );
                  }
                  return Center(
                    child: Text("Loading..."),
                  );
                },
              ),
            ],
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostMakerScreen()));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}


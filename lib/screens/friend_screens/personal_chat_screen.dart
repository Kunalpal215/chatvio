import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class ChatScreen extends StatefulWidget {
  String chatDocId;
  String email;
  ChatScreen({required this.chatDocId,required this.email});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  var userSnapshot;
  var friendSnapshot;
  bool isLoading = true;
  Future<void> getUserSnapshot() async {
    userSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).get();
    friendSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.email).get();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserSnapshot();
  }

  Widget messageTileMaker(String message,String senderEmail,var screenWidth){
    return Row(
      mainAxisAlignment: senderEmail==userSnapshot.get("email") ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.symmetric(vertical: 3,horizontal: 10),
          constraints: BoxConstraints(minWidth: 20,maxWidth: screenWidth*0.5),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: senderEmail==userSnapshot.get("email") ? false : true,
                child: Container(
                  margin: EdgeInsets.only(bottom: 3),
                  child: Text(senderEmail==userSnapshot.get("email") ? userSnapshot.get("username") : friendSnapshot.get("username"), maxLines: 1, overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blue,fontSize: screenWidth*0.04,fontWeight: FontWeight.w900,fontFamily: "SFpro"),),
                ),
              ),
              Text(message,style: TextStyle(fontFamily: "SFpro",fontWeight: FontWeight.w500,fontSize: screenWidth*0.037),),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffECE5DD),
        body: isLoading == true ? Center(child: CircularProgressIndicator(),) : Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Color(0xff075E54),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 18,top: 4,bottom: 4,right: 15),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(friendSnapshot.get("imageURL")),
                      radius: screenWidth*0.06,
                    ),
                  ),
                  Text(friendSnapshot.get("username"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth*0.05
                  ),),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatDocId).collection('messages').orderBy("timestamp",descending: false).snapshots(),
                builder: (context, AsyncSnapshot snapshot){
                  if(snapshot.hasData){
                    List<Widget> allMessages = [
                      Container(width: screenWidth,height: 3,),
                    ];
                    snapshot.data.docs.forEach((element) => {
                      allMessages.add(messageTileMaker(element.get("message"), element.get("email"), screenWidth)),
                    });
                    return ListView(
                      scrollDirection: Axis.vertical,
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      children: allMessages,
                    );
                  }
                  return Container();
                },
              ),
            ),
            Container(
              width: screenWidth,
              margin: EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(right: 6),
                      padding: EdgeInsets.only(left: 8),
                      child: TextFormField(
                        controller: messageController,
                        style: TextStyle(
                          fontSize: screenWidth*0.043,
                          fontFamily: "SFpro",
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if(messageController.text==null || messageController.text==""){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Empty message can't be sent"),duration: Duration(seconds: 2),));
                        return;
                      }
                      String toStore = messageController.text;
                      messageController.text = "";
                      var timestamp = DateTime.now().microsecondsSinceEpoch;
                      await FirebaseFirestore.instance.collection('chats').doc(widget.chatDocId).collection('messages').add({"timestamp" : timestamp,"message":toStore,"email" : userSnapshot.get("email"),});
                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email!).collection("personal chats").doc(widget.email).update({"timestamp" : timestamp,"lastMessage" : toStore});
                      await FirebaseFirestore.instance.collection('users').doc(widget.email).collection("personal chats").doc(FirebaseAuth.instance.currentUser!.email!).update({"timestamp" : timestamp,"lastMessage" : toStore});
                    },
                    child: Container(
                      width: screenWidth*0.14,
                      height: screenWidth*0.14,
                      margin: EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: Color(0xff128C7E),
                        borderRadius: BorderRadius.circular(screenWidth*0.07),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.send_rounded,color: Colors.white,size: screenWidth*0.07,),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

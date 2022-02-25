import 'package:chat_app_final/auth/google_auth.dart';
import 'package:flutter/material.dart';
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/welcome_screen_bg.png"),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight*0.08),
              child: Image.asset("assets/app_logo.png",width: screenWidth*0.7,),
            ),
            InkWell(
              onTap: (){
                GoogleAuthClass().signInWithGoogle(context);
              },
              child: Container(
                width: screenWidth*0.8,
                height: screenWidth*0.13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth*0.065),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 2,
                        spreadRadius: 2,
                        offset: Offset(
                            2,6
                        )
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10,top: 10,bottom: 10,left: 15),
                      child: Image.asset('assets/google.png',height: screenWidth*0.07,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10,right: 15),
                      child: Text("Continue with Google ",style: TextStyle(
                        fontFamily: "SFpro",
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth*0.055,
                      ),),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}

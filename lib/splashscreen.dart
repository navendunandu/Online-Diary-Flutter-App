import 'package:flutter/material.dart';
import 'package:online_dairy/login.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<splashscreen> {
  @override
  void initState(){
    super.initState();
    gotoLogin();
  }
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child:Text('DAIRY TOUCH',style:TextStyle(fontSize:40,fontStyle:FontStyle.normal,color:Color.fromARGB(255, 1, 11, 12),fontWeight: FontWeight.w900),)) ,
        ),
      );
  }
void gotoLogin(){
      Future.delayed(const Duration(seconds: 3), (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Login(),));
      });
  }
}


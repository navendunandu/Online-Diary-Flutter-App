import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_dairy/dashboard.dart';
import 'package:online_dairy/forgotpassword.dart';
import 'package:online_dairy/registration.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState()=>_Login();
}
class _Login extends State<Login>{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
   

   Future<void> login() async {
     try {
        final FirebaseAuth auth = FirebaseAuth.instance;

        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Dashboard()));
      } catch (e) {
        // Handle login failure and show an error toast.
        String errorMessage = 'Login failed';

        if (e is FirebaseAuthException) {
          errorMessage = e.code;
        }

        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }

   }
   @override
   Widget build(BuildContext context){
    return Scaffold( 
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: EdgeInsets.all(30.0),
          height: 1000,
          width: 1000,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 151, 151, 146),
            borderRadius: BorderRadius.circular(20.0)
          ),
          child: Column(
            children: [
              Text('Login'),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter Email'
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText:true,
                decoration: InputDecoration(
                  hintText: 'Enter Password'
                ),
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: (){
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPassword(title: 'Forget Password',),)); 
                },
                child: const Text('Forgot Password?')),
              ElevatedButton(onPressed: (){
                login();
              }, child:Text('Login')
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: (){
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const Registration(),)); 
                },
                child: Text("Create an account")),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
    ),
    );
  }
void gotodashboard(){
      Future.delayed(const Duration(seconds: 3), (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Dashboard(),));
      });
  }
}


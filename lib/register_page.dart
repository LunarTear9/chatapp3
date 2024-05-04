import 'package:flutter/material.dart';
import 'package:messaging/components/colors.dart';
import 'package:messaging/components/my_button.dart';
import 'package:messaging/components/my_text_field.dart';
import 'package:messaging/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key,required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}



class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  void signUp () async {
if (passwordController.text != confirmpasswordController.text){

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords dont match")));

  return;
}


final authService = Provider.of<AuthService>(context,listen: false);

try {

  await authService.signUpWithEmailandPassword(emailController.text, passwordController.text);
} catch (e) {

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
}
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(child: Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:8.0),
        child: Column(mainAxisAlignment:MainAxisAlignment.center,children: [SizedBox(height:4),Icon(Icons.message_outlined,size: 120,color: colorOne),SizedBox(height:20),Text("Welcome Back",style: TextStyle(fontSize: 40,color: Colors.black),),SizedBox(height:20),MyTextField(controller: emailController, hintText: 'Email', obscureText: false),SizedBox(height:20),TextField(controller: passwordController, obscureText: true,decoration: InputDecoration(hintText:'Password',enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colorOne),),focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorOne)),fillColor: Colors.grey[200],filled:true,hintStyle: TextStyle(color: Colors.black))),SizedBox(height:5),TextField(controller: confirmpasswordController, obscureText: true,decoration: InputDecoration(hintText:'Confirm Password',enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colorOne),),focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorOne)),fillColor: Colors.grey[200],filled:true,hintStyle: TextStyle(color: Colors.black))),SizedBox(height:25),Button(onTap: signUp, text: 'Register'),SizedBox(height:30),Row(mainAxisAlignment: MainAxisAlignment.center,children:[Text('Already a member?'),SizedBox(width: 5,),GestureDetector(onTap: widget.onTap,child: Text('Login Now',style: TextStyle(fontWeight: FontWeight.bold,color: colorOne),)),])],),
      )))
    );
  }
}
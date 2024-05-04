import 'package:flutter/material.dart';
import 'package:messaging/components/colors.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  const MyTextField({super.key,required this.controller,required this.hintText,required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: null,
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colorOne),),focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),fillColor: Colors.grey[200],filled:true,hintText: hintText,hintStyle: TextStyle(color: Colors.black)),
    );
  }
}


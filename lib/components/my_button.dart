import 'package:flutter/material.dart';
import 'package:messaging/components/colors.dart';

class Button extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const Button({super.key,required this.onTap,required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,child: Container(padding:EdgeInsets.all(25),decoration: BoxDecoration(color: colorOne,borderRadius: BorderRadius.circular(25)),child: Center(child: Text(text,style: TextStyle(color: Colors.black,fontSize: 22),),)),);
  }
}
import 'package:flutter/material.dart';
import 'package:messaging/components/colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  const ChatBubble({super.key,required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(constraints:BoxConstraints(maxWidth: 250),padding: EdgeInsets.all(12),decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: colorOne),child: Text(message,style: TextStyle(fontSize: 16),),);
  }
}
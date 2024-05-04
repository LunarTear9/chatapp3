import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging/model/message.dart';

class ChatService extends ChangeNotifier{


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message)  async {

    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timeStamp = Timestamp.now();

Message newMessage = Message(senderId: currentUserId, receiverId: receiverId, senderEmail: currentUserEmail, message: message, timestamp: timeStamp);
List<String> ids = [currentUserId, receiverId];
ids.sort();

String chatRoomId = ids.join("_");

await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otheruserId) {

    List<String> ids = [userId, otheruserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }
}
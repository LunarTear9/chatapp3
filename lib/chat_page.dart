import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messaging/chat_bubble.dart';
import 'package:messaging/components/colors.dart';
import 'package:messaging/components/my_text_field.dart';
import 'package:messaging/services/chat/chat_service.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  final String receiveuserEmail;
  final String receiveUserID;
  final Widget alias;
  const ChatPage({super.key,required this.receiveUserID,required this.receiveuserEmail,required this.alias});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  Color _backgroundColor = Colors.grey[100]!;
  String? _backgroundImagePath;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isButtonDisabled = false;

  void sendMessage(BuildContext context) async {
    if (!_isButtonDisabled && _messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiveUserID, _messageController.text);
      _messageController.clear();

      // Delay for 1-2 seconds
      await Future.delayed(Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: colorOne, title: AbsorbPointer(child: widget.alias, absorbing: true)),
      body: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          image: _backgroundImagePath != null
              ? DecorationImage(
                  image: FileImage(File(_backgroundImagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiveUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error" + snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        // Extract messages from the snapshot
        List<DocumentSnapshot> messages = snapshot.data!.docs;

        // Limit the maximum number of messages displayed
        if (messages.length > 20) {
          messages = messages.sublist(messages.length - 20);
        }

        // Scroll to the bottom of the list when it first loads
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });

        return ListView.builder(
          reverse: false, // Start from bottom
          controller: _scrollController, // Assign the scroll controller
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messages[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid) ? Alignment.bottomRight : Alignment.bottomLeft;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            ChatBubble(message: data['message']),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'Send a message',
              obscureText: false,
            ),
          ),
         // GestureDetector(
          //  onTap: _pickImage,
         //   child: Padding(
          //    padding: EdgeInsets.only(left: 5),
          //    child: Icon(Icons.image, size: 40),
          //  ),
       //   ),
          Builder(
            builder: (context) => SendButton(
              onPressed: () => sendMessage(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _backgroundImagePath = pickedFile.path; // Set the selected image path
        _backgroundColor = Colors.transparent; // Set background color to transparent
      });
    }
  }
}

class SendButton extends StatefulWidget {
  final Function onPressed;

  const SendButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  _SendButtonState createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
  bool _isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isButtonDisabled ? null : () {
        setState(() {
          _isButtonDisabled = true;
        });
        widget.onPressed();
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            _isButtonDisabled = false;
          });
        });
      },
      icon: Icon(Icons.arrow_upward, size: 40),
    );
  }
}

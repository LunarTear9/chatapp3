import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging/chat_page.dart';
import 'package:messaging/components/colors.dart';
import 'package:messaging/components/my_text_field.dart';
import 'package:provider/provider.dart';

import 'services/auth/auth_service.dart';

dynamic feedbackController = TextEditingController();
String text = '';
dynamic placeHolderString = '';

dynamic friendsController = TextEditingController();


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
   late String _userAlias = _auth.currentUser!.email!; // Initialize user's alias variable

  @override
  void initState() {
    super.initState();
    // Fetch user's alias when the widget initializes
    _fetchUserAlias();
  }

 void _fetchUserAlias() async {
  if (_auth.currentUser != null) {
    // Fetch user's data from Firestore
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();

    // Update the user's alias variable
    setState(() {
      if (snapshot['alias'] != ''){
      _userAlias = snapshot['alias'] ?? _auth.currentUser!.email ?? '';} // Use email if alias is not available
    });
  }
}


void signOut() {

  final authService = Provider.of<AuthService>(context,listen:false);

  authService.signOut();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(floatingActionButton: FloatingActionButton(onPressed: (){_showOptionsModal(context);},backgroundColor: colorOne,child: Icon(Icons.person_add,color: Colors.black,),),appBar:AppBar(centerTitle:true,backgroundColor:colorOne,title: Text('Signed In as ${_userAlias}',),actions: [IconButton(onPressed: (){_showDialog3(context);}, icon: Icon(Icons.settings ))]),body: Container(decoration: BoxDecoration(color: Colors.grey[200]),child: Row(children: [ Container(decoration:BoxDecoration(color: Color.fromARGB(255, 255, 200, 152)),child:SizedBox(width:160,child:_buildUsersList())),Column(children: [Text('-FIXED BUGS\n  ',style: TextStyle(color: colorOne,fontWeight: FontWeight.bold,fontSize: 38),),Text('-ADDED MULTILINE\n        SUPPORT\n ',style: TextStyle(color: colorOne,fontWeight: FontWeight.bold,fontSize: 26),),Text('-UI REDESIGN\n',style: TextStyle(color: colorOne,fontWeight: FontWeight.bold,fontSize: 36),),Text('-PERFORMANCE\n  UPDATES  ',style: TextStyle(color: colorOne,fontWeight: FontWeight.bold,fontSize: 30),),])])));
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>( stream: FirebaseFirestore.instance.collection('users').snapshots(),builder: (context, snapshot) {
      if (snapshot.hasError) {

        return Text('Error');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {

        return Text('Loading');
      }

      return ListView(children: snapshot.data!.docs.map<Widget>((doc) => _buildUsersListItem(doc)).toList(),);
    },);
  }

 Widget _buildUsersListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    bool isFriend = _auth.currentUser != null &&
        _auth.currentUser!.email != null &&
        data.containsKey('friends') &&
        (data['friends'] as List).contains(_auth.currentUser!.email);

    if (isFriend) {
      return Padding(
        padding: const EdgeInsets.all(14.0),
        child: ElevatedButton(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(data['uid'])
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error');
              }

              if (snapshot.hasData) {
                Map<String, dynamic> userData =
                    snapshot.data!.data()! as Map<String, dynamic>;
                 String alias = userData['alias'] ?? data['email'];

                return Text(
                  alias,
                  style: TextStyle(color: Colors.black),
                );
              }

              return Text('No Data');
            },
          ),
          onPressed: () {
            FirebaseFirestore.instance
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .set({
              'friends': FieldValue.arrayUnion([data['email']]),
            }, SetOptions(merge: true));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  alias: _buildUsersListItem(document),// cant pass var
                  receiveuserEmail: data['email'],
                  receiveUserID: data['uid'],
                ),
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(colorOne),
          ),
        ),
      );
    } else {
      return Container();
    }
  }





  
  void _showOptionsModal(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: colorOne,
    context: context,
    builder: (BuildContext context) {
      return Container(
        // Customize your pop-up window here
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Send Feedback'),
              onTap: () {
                // Handle option 1
                Navigator.pop(context);
                showDialogue(context, '(Any feedback will be checked within 2 days of delivery)');
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add a friend'),
              onTap: () {
                // Handle option 2
                
                Navigator.pop(context);
                _showDialog2(context);
              },
            ),
            // Add more options as needed
          ],
        ),
      );
    },
  );
}

void _showDialog2(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.only(bottom:100,left: 30,right: 30,top: 19),
        backgroundColor: colorOne,
        title: Text("Add a friend"),
        content: MyTextField(controller: friendsController, hintText: 'Email', obscureText: false),
        actions: <Widget>[
          TextButton(onPressed: (){


           FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).set({
              'friends': FieldValue.arrayUnion([friendsController.text]), // Use FieldValue.arrayUnion to add an item to an array
            }, SetOptions(merge: true));

            // Clear the text field after adding the friend
            friendsController.clear();




          }, child: Text('Add Friend',style: TextStyle(color: Colors.black),)),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Close",style: TextStyle(color: Colors.black),),
          ),
        ],
      );
    },
  );
  
}
void _showDialog3(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Column(children: [AlertDialog(
        contentPadding: EdgeInsets.only(bottom:100,left: 30,right: 30,top: 19),
        backgroundColor: colorOne,
        title: Text("Options"),
        content: MyTextField(controller: friendsController, hintText: 'Alias', obscureText: false),
        actions: <Widget>[IconButton(onPressed: (){signOut();
      Navigator.of(context).pop();}, icon: Icon(Icons.logout)),
          TextButton(onPressed: (){
            if (friendsController.text.trim().isNotEmpty)
setState(() {
  _userAlias = friendsController.text;
});

           FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).set({
              'alias': friendsController.text, // Use FieldValue.arrayUnion to add an item to an array
            }, SetOptions(merge: true));

            // Clear the text field after adding the friend
            friendsController.clear();




          }, child: Text('Change Alias',style: TextStyle(color: Colors.black),)),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Close",style: TextStyle(color: Colors.black),),
          ),
        ],
      ),]);
    },
  );
  
}

}


 void showDialogue(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(backgroundColor: colorOne,
          title: Text("Send Feedback"),
          content: Text(message),
          actions: <Widget>[TextField(
            decoration: InputDecoration(enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colorOne),),focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),fillColor: Colors.grey[200],filled:true,hintText: 'Feedback',hintStyle: TextStyle(color: Colors.black)),
                  controller: feedbackController,
          ),TextButton(onPressed: () {submitFeed(feedbackController.text);}, child: Text('Submit',style: TextStyle(color: Colors.black))) ,
            TextButton(child: Text("Close",style: TextStyle(color: Colors.black),),
              onPressed: () {

                
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

   
  }
 void submitFeed(text) async {
  
  
  // Handle response here, e.g., print response.body, response.statusCode
  
  // Optionally, you can also add code to handle navigation or UI updates here
}
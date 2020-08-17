import 'package:FlutterChatApp/helper/authenticate.dart';
import 'package:FlutterChatApp/helper/constants.dart';
import 'package:FlutterChatApp/helper/helper_function.dart';
import 'package:FlutterChatApp/services/auth.dart';
import 'package:FlutterChatApp/services/database.dart';
import 'package:FlutterChatApp/views/conversation.dart';
import 'package:FlutterChatApp/views/search.dart';
import 'package:FlutterChatApp/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthService authService = new AuthService();
  DatabaseService databaseService = new DatabaseService();

  Stream chatRoomsStream;

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myUsername = await HelperFunctions.getUserNameSharedPreference();
    databaseService.getChatRooms(Constants.myUsername).then((chatRooms) {
      setState(() {
        chatRoomsStream = chatRooms;
      });
    });
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          print(snapshot.data);
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return ChatRoomsTile(
                        snapshot.data.documents[index].data["chatroomId"]
                            .toString()
                            .replaceAll("_", "")
                            .replaceAll(Constants.myUsername, ""),
                        snapshot.data.documents[index].data["chatroomId"]);
                  },
                )
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/images/logo.png",
          height: 50,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              authService.signOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Authenticate(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.exit_to_app),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(),
            ),
          );
        },
        child: Icon(
          Icons.search,
        ),
      ),
      body: Container(
        child: chatRoomList(),
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoom;

  ChatRoomsTile(this.userName, this.chatRoom);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Conversation(chatRoom),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(40)),
              child: Text(
                this.userName.substring(0, 1).toUpperCase(),
                style: mediumTextStyle(),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              this.userName,
              style: mediumTextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:FlutterChatApp/helper/constants.dart';
import 'package:FlutterChatApp/services/database.dart';
import 'package:FlutterChatApp/views/conversation.dart';
import 'package:FlutterChatApp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchEditingController = new TextEditingController();

  DatabaseService databaseService = new DatabaseService();

  QuerySnapshot searchSnapshot;

  initiateSearch() {
    databaseService
        .getUserByUsername(searchEditingController.text)
        .then((results) {
      setState(() {
        searchSnapshot = results;
      });
      print(results);
    });
  }

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchItemTile(
                  username: searchSnapshot.documents[index].data["name"],
                  email: searchSnapshot.documents[index].data["email"]);
            })
        : Container();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: searchEditingController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search username ...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0x36FFFFFF),
                            const Color(0x0FFFFFFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Image.asset("assets/images/search_white.png"),
                    ),
                  ),
                ],
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}

class SearchItemTile extends StatelessWidget {
  final String username;
  final String email;

  SearchItemTile({this.username, this.email});

  createChatroomAndStartConversation({BuildContext context, String username}) {
    if (this.username != Constants.myUsername) {
      String chatRoomId = getChatRoomId(username, Constants.myUsername);
      List<String> users = [username, Constants.myUsername];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomId": chatRoomId,
      };
      DatabaseService().createChatRoom(chatRoomId, chatRoomMap);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Conversation(chatRoomId),
        ),
      );
    } else {
      print("Cannot send message to yourself");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                this.username,
                style: mediumTextStyle(),
              ),
              Text(
                this.email,
                style: simpleTextStyle(),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatroomAndStartConversation(
                  context: context, username: this.username);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text("Message", style: mediumTextStyle()),
            ),
          )
        ],
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}

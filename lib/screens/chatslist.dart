import 'dart:typed_data';

import 'package:chat_hub/chatpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final auth = FirebaseAuth.instance;
  User? user;

  // void chatscreen(BuildContext context) {
  //   Navigator.pushNamed(context, "chatpage");
  // }

  void checkCurrentUser() {
    user = auth.currentUser;
    if (user != null) {
      print('Current User: ${user!.email}');
      // Perform actions with the current user
    } else {
      print('No user is currently logged in');
      // Handle the case when no user is logged in
    }
  }

  @override
  void initState() {
    checkCurrentUser();
    getsenderinfo();
    // TODO: implement initState
    super.initState();
  }

  String? url;
  Future<Uint8List> fetchAvatar() async {
    http.Response response = await http.get(Uri.parse(url!));
    return response.bodyBytes;
  }

  void getsenderinfo() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: user!.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        var documentData = docSnapshot.data() as Map<String, dynamic>;
        // documentId = docSnapshot.id;
        ChatScreen.uniquename = documentData["uniquename"];
      }
    }
  }

  Widget loadingWidget() {
    return FutureBuilder<Uint8List>(
      future: fetchAvatar(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print(snapshot.data);
          return SizedBox(height: 10, child: Image.memory(snapshot.data!));
        } else if (snapshot.hasError) {
          print('${snapshot.error}');
          return const Center(
              child: Text('❌', style: TextStyle(fontSize: 72.0)));
        } else {
          return Container(
            height: 12,
            padding: const EdgeInsets.all((150 - 50.0) / 2.0),
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.sort,
                color: Colors.green,
              ));
        }),
        actions: [
          IconButton(
              onPressed: () {
                String time24 = "2023-06-08T14:01:28.138367+05:30";
                int hours =
                    int.parse(time24.split("T")[1].split(".")[0].split(":")[0]);
                var AmOrPm = hours >= 12 ? 'pm' : 'am';
                hours = (hours % 12);
                var minutes =
                    int.parse(time24.split("T")[1].split(".")[0].split(":")[1]);
                print(minutes);
                var finalTime = "Time   $hours:$minutes $AmOrPm";
                // final time Time - 22:10
                print(finalTime + time24);
              },
              icon: const Icon(
                Icons.search,
                color: Colors.green,
              ))
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("Users").snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final userSnapshot = snapshot.data?.docs;
            if (userSnapshot!.isEmpty) {
              return const Text("no data");
            } else {
              // print(userSnapshot[0]["email"]);
            }
            // return Center(child: Text(userSnapshot[0]["email"].toString()));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Chats",
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: userSnapshot.length,
                        itemBuilder: (context, index) {
                          if (userSnapshot[index]["email"] != user!.email) {
                            url =
                                "https://robohash.org/${userSnapshot[index]["uniquename"]}";
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              child: GestureDetector(
                                onTap: () async {
                                  QuerySnapshot querySnapshot =
                                      await FirebaseFirestore.instance
                                          .collection("Users")
                                          .where("email",
                                              isEqualTo: userSnapshot[index]
                                                  ["email"])
                                          .get();
                                  if (querySnapshot.docs.isNotEmpty) {
                                    for (QueryDocumentSnapshot documentSnapshot
                                        in querySnapshot.docs) {
                                      var data = documentSnapshot.data()
                                          as Map<String, dynamic>;
                                      ChatScreen.chatdocid =
                                          documentSnapshot.id;
                                      ChatScreen.uniquename =
                                          data["uniquename"];
                                      print(data["uniquename"]);
                                    }
                                  }

                                  await Navigator.pushNamed(
                                      context, "chatpage");
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.2),
                                            offset: const Offset(4, 2),
                                            blurRadius: 5,
                                            blurStyle: BlurStyle.solid),
                                      ],
                                      // border:
                                      borderRadius: BorderRadius.circular(5)),
                                  // color: Colors.red,

                                  // title: userSnapshot[index]["name"],
                                  height: 77,
                                  width: 50,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Container(
                                          width: 55,
                                          height: 55,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.green,
                                                width: 2.0,
                                              ),
                                              gradient: const LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black12,
                                                  ])),
                                          child: ClipOval(
                                            child: loadingWidget(),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        child: Column(
                                          children: [
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  userSnapshot[index]
                                                      ["uniquename"],
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      color:
                                                          Colors.grey.shade700),
                                                )),
                                            // Align(
                                            //     alignment: Alignment.centerLeft,
                                            //     child: Text(
                                            //       userSnapshot[index]["name"],
                                            //       style: GoogleFonts.poppins(
                                            //           fontWeight:
                                            //               FontWeight.w500,
                                            //           fontSize: 10,
                                            //           color:
                                            //               Colors.grey.shade700),
                                            //     )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }

                          // return null;
                        }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

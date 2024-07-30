import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:path/path.dart' as Path;

class ChatScreen extends StatefulWidget {
  static String uniquename = "";
  static String chatdocid = "";
  // static String currentdocid = "";
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final auth = FirebaseAuth.instance;
  User? user;
  var oppuid;
  var oppname;
  var currentuid;
  var message;
  var timestamp;
  var timestampseconds;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _emojieditingcontroller = TextEditingController();
  String? url;
  Future<Uint8List> fetchAvatar() async {
    url = "https://robohash.org/$oppname";

    http.Response response = await http.get(Uri.parse(url!));
    return response.bodyBytes;
  }

  Widget loadingWidget() {
    return FutureBuilder<Uint8List>(
      future: fetchAvatar(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print(snapshot.data);
          return SizedBox(
              height: 150, width: 40, child: Image.memory(snapshot.data!));
        } else if (snapshot.hasError) {
          print('${snapshot.error}');
          return const Center(
              child: Text('❌', style: TextStyle(fontSize: 72.0)));
        } else {
          return Container(
            height: 4,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
                child: const Center(child: CircularProgressIndicator())),
          );
        }
      },
    );
  }

  Timer? _timer;

  @override
  void initState() {
    _startTimer();
    getuserinfo();
    currentuserinfo();
    super.initState();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    // Start a timer that runs every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Call a function to refresh the page or perform any other action
      _refreshPage();
    });
  }

  void _stopTimer() {
    // Cancel the timer if it is running
    _timer?.cancel();
  }

  void _refreshPage() {
    // Implement your logic to refresh the page here
    setState(() {
      // Call setState to rebuild the UI if needed
    });
    _stopTimer();
  }

  void getuserinfo() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await firestore.collection("Users").doc(ChatScreen.chatdocid).get();
    oppuid = documentSnapshot["uid"];
    oppname = documentSnapshot["uniquename"];
    // print(documentSnapshot["uid"]);
  }

  void currentuserinfo() async {
    user = auth.currentUser;
    QuerySnapshot querySnapshot = await firestore
        .collection("Users")
        .where("email", isEqualTo: user?.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot docsnap in querySnapshot.docs) {
        var data = docsnap.data() as Map<String, dynamic>;
        currentuid = data["uid"];
      }
    }
  }

  void sendmessage() async {
    var url = "http://worldtimeapi.org/api/timezone/Asia/Kolkata";
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      var responsedata = jsonDecode(res.body);
      timestamp = responsedata["datetime"];
      timestampseconds = responsedata["unixtime"];
      // print(timestamp.split("T"));
      print(responsedata);
    } else {
      print("error in time");
    }
    await firestore.collection("messages").doc().set({
      "uid": currentuid,
      "sender": oppuid,
      "text": message,
      "timestamp": timestamp,
      "timesecond": timestampseconds
    });
  }

  void getdata() async {
    QuerySnapshot querySnapshot = await firestore
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot docsnapshot in querySnapshot.docs) {
        var data = docsnapshot.data() as Map<String, dynamic>;
        print(data["text"]);
      }
    }
  }

  String convertTo12HourFormat(String? time24) {
    if (time24 == null) {
      return ''; // or handle the null case as desired
    }
    int hours = int.parse(time24.split("T")[1].split(".")[0].split(":")[0]);
    var AmOrPm = hours >= 12 ? 'pm' : 'am';
    hours = (hours % 12);
    var minutes = int.parse(time24.split("T")[1].split(".")[0].split(":")[1]);
    print(minutes);
    var finalTime = "$hours:$minutes $AmOrPm";
    // final time Time - 22:10
    return finalTime;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDataStream() {
    return FirebaseFirestore.instance
        .collection("messages")
        // .where("uid", isEqualTo: oppuid)
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  final picker = ImagePicker();
  bool isurl = false;
  File? _imageFile;
  String? downloadUrl;
  Future uploadImageToFirebase() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        print("image selected");
      } else {
        print(' image  not selected');
      }
    });
    if (_imageFile == null) {
      print('No image selected');
      return "firebase problem";
    }

    String fileName = Path.basename(_imageFile!.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    downloadUrl = await taskSnapshot.ref.getDownloadURL();
    print("Done: $downloadUrl");
    if (downloadUrl != null) {
      message = downloadUrl;
      sendmessage();
    }
    print(isurl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(25)),
            side: BorderSide(color: Colors.green.withOpacity(0.6))),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        // automaticallyImplyLeading: false,
        title: Text(
          ChatScreen.uniquename,
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.call,
                color: Colors.green,
              )),
          IconButton(
              onPressed: () async {
                await auth.signOut();
                Navigator.pop(context, "chatlist");
                Navigator.pushReplacementNamed(context, "signin");
                print("signing out");
              },
              icon: const Icon(
                Icons.more_vert,
                color: Colors.green,
              ))
        ],
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.green,
              ),
              onPressed: () {
                Navigator.pop(context);
                // print(sender_uniquename);
                // Handle menu button press here
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green,
                      width: 3.0,
                    ),
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                        ])),
                child: ClipOval(
                  child: loadingWidget(),
                ),
              ),
            ),
          ],
        ),
        leadingWidth: 100,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          color: Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: getDataStream(),
                    // initialData: null,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      var usersnapshot = snapshot.data;

                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return const CircularProgressIndicator();
                      if (!snapshot.hasData) {
                        return const Text("no data");
                      }

                      return ListView.builder(
                        itemCount: usersnapshot.size,
                        itemBuilder: (BuildContext context, int index) {
                          var data = usersnapshot.docs[index].data();
                          if (data["uid"] == currentuid &&
                              data["sender"] == oppuid) {
                            isurl =
                                Uri.tryParse(data["text"])?.hasAbsolutePath ??
                                    false;

                            print(isurl);
                            return SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 120, top: 8, right: 15),
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        child: IntrinsicWidth(
                                          // stepWidth: 100,
                                          child: GestureDetector(
                                            onTap: () => print("image tapped"),
                                            child: Container(
                                                // width: 600,
                                                // width: data["text"]
                                                //     .toString()
                                                //     .length
                                                //     .toDouble(),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.green.shade400,
                                                ),
                                                child: isurl
                                                    ? Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 10,
                                                                    left: 10,
                                                                    right: 10,
                                                                    bottom: 4),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child:
                                                                  Image.network(
                                                                data["text"],
                                                              ),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      // top: 5,
                                                                      bottom: 5,
                                                                      left: 5,
                                                                      right:
                                                                          10),
                                                              child: Text(
                                                                convertTo12HourFormat(
                                                                    data[
                                                                        "timestamp"]),
                                                                style: GoogleFonts.sansita(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade800),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Row(
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        8),
                                                                child: Text(
                                                                  data["text"]
                                                                      .toString(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),

                                                                  // maxLines: 1,
                                                                )),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical:
                                                                        5),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          5),
                                                              child: Text(
                                                                convertTo12HourFormat(
                                                                    data[
                                                                        "timestamp"]),
                                                                style: GoogleFonts.sansita(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade800),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )),
                                          ),
                                        ),
                                      ))),
                            );
                          } else if (data["uid"] == oppuid &&
                              data["sender"] == currentuid) {
                            isurl =
                                Uri.tryParse(data["text"])?.hasAbsolutePath ??
                                    false;
                            return Padding(
                                padding: const EdgeInsets.only(
                                    top: 8, right: 120, left: 10),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      child: IntrinsicWidth(
                                        // stepWidth: 100,
                                        child: Container(
                                          // width: 600,
                                          // width: data["text"]
                                          //     .toString()
                                          //     .length
                                          //     .toDouble(),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey.shade700,
                                          ),
                                          child: isurl
                                              ? Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              left: 10,
                                                              right: 10,
                                                              bottom: 4),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          data["text"],
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                // top: 5,
                                                                bottom: 5,
                                                                left: 5,
                                                                right: 10),
                                                        child: Text(
                                                          convertTo12HourFormat(
                                                              data[
                                                                  "timestamp"]),
                                                          style: GoogleFonts
                                                              .sansita(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 8.0,
                                                                vertical: 8),
                                                        child: Text(
                                                          data["text"]
                                                              .toString(),
                                                          overflow:
                                                              TextOverflow.fade,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),

                                                          // maxLines: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 5),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 5),
                                                        child: Text(
                                                          convertTo12HourFormat(
                                                              data[
                                                                  "timestamp"]),
                                                          style: GoogleFonts
                                                              .sansita(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                        ),
                                      ),
                                    )));
                          }
                          return Container();
                          // return null;
                        },
                      );

                      // return const Center();
                    }),
              ),
              Stack(
                children: [
                  Container(
                    color: Colors.white,
                    height: 75,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        // color: Colors.white,
                        padding: const EdgeInsets.only(
                            bottom: 20, top: 10, left: 16, right: 16),
                        child: Row(
                          children: [
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width,
                                  maxWidth: MediaQuery.of(context).size.width,
                                  minHeight: 30.0,
                                  maxHeight: 250.0,
                                ),
                                child: Scrollbar(
                                  child: TextField(
                                    cursorColor: Colors.green,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    controller: _textEditingController,
                                    // _handleSubmitted: null,
                                    decoration: InputDecoration(
                                      prefixIcon: IconButton(
                                          onPressed: () async {
                                            uploadImageToFirebase();
                                          },
                                          icon: const Icon(
                                            Icons.image,
                                            color: Colors.green,
                                          )),
                                      suffixIcon: Container(
                                        height: 14,
                                        width: 10,
                                        // color: Colors.green,
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                topRight: Radius.circular(5),
                                                bottomLeft: Radius.circular(5),
                                                bottomRight:
                                                    Radius.circular(25)),
                                            color: Colors.green),
                                        child: IconButton(
                                          onPressed: () async {
                                            setState(() {});
                                            getuserinfo();
                                            message =
                                                _textEditingController.text;
                                            sendmessage();
                                            _textEditingController.clear();
                                          },
                                          iconSize: 18,
                                          icon: const Icon(Icons.send),
                                          color: Colors.white,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft: Radius.circular(25)),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade100)),
                                      focusColor: Colors.green,
                                      fillColor: Colors.grey.shade100,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade100,
                                              width: 1.0),
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft: Radius.circular(25))),
                                      contentPadding: const EdgeInsets.only(
                                          top: 5.0,
                                          left: 15.0,
                                          right: 15.0,
                                          bottom: 5.0),
                                      hintText: "Type your message",
                                      hintStyle: const TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class AvatarPage extends StatefulWidget {
  // static String uid = "";
  String uid;
  AvatarPage({super.key, required this.uid});

  @override
  State<StatefulWidget> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  var url;
  var docid;

  Future<Uint8List> fetchAvatar() async {
    http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Widget loadingWidget() {
    return FutureBuilder<Uint8List>(
      future: fetchAvatar(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data);
          return Image.memory(snapshot.data!);
        } else if (snapshot.hasError) {
          print('${snapshot.error}');
          return const Center(
              child: Text('❌', style: TextStyle(fontSize: 72.0)));
        } else {
          return Container(
            padding: const EdgeInsets.all((150 - 50.0) / 2.0),
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }

  TextEditingController uniquename = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Your Avatar",
                      style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 25),
                  child: Container(
                    width: 150,
                    height: 150,
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
                              Colors.transparent,
                              Colors.black12,
                            ])),
                    child: ClipOval(
                      child: loadingWidget(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter Your Unique name",
                      style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextField(
                    autocorrect: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.green, width: 1.5)),
                      hintText: "Enter Your unique name",
                      labelText: "Name",
                      suffixIcon: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.green,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.check),
                          color: Colors.white,
                          onPressed: () async {
                            var name = uniquename.text;

                            setState(() {});
                            url = 'https://robohash.org/$name';
                            fetchAvatar();
                          },
                        ),
                      ),
                      suffixIconColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.focused)
                              ? Colors.green
                              : Colors.grey),
                      // suffixStyle: ,
                      labelStyle: GoogleFonts.poppins(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                      hoverColor: Colors.green,
                      focusColor: Colors.green,
                    ),
                    controller: uniquename,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: () async {
                        print(widget.uid);
                        QuerySnapshot queSnapshot = await FirebaseFirestore
                            .instance
                            .collection("Users")
                            .where("uniquename", isEqualTo: uniquename.text)
                            .get();
                        if (queSnapshot.docs.isEmpty) {
                          final QuerySnapshot querySnapshot =
                              await FirebaseFirestore.instance
                                  .collection("Users")
                                  .where("uid", isEqualTo: widget.uid)
                                  .get();

                          final List<QueryDocumentSnapshot> documents =
                              querySnapshot.docs;
                          for (var doc in documents) {
                            // Access the document data

                            docid = doc.id;
                            print(docid);
                          }
                          FirebaseFirestore.instance
                              .collection("Users")
                              .doc(docid)
                              .update({"uniquename": uniquename.text});
                          Navigator.pushReplacementNamed(context, "chatlist");
                          print("No same name");
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                            content: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.red),
                              child: const Text(
                                  "This unique name is already registered"),
                            ),
                          ));
                        }
                      },
                      child: SizedBox(
                          // color: Colors.red,
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: 16,
                          child: Center(
                              child: Text(
                            "OK",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          )))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

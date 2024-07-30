// String? uniquename;
// void getrecieverinfo() async {
//   DocumentSnapshot documentSnapshot =
//       await firestore.collection("Users").doc(ChatScreen.chatdocid).get();
//   if (documentSnapshot.exists) {
//     var val = documentSnapshot.data() as Map<String, dynamic>;

//     uniquename = val["uniquename"];
//     print(uniquename);
//   }
// }

// var sender_uniquename;
// void getsenderinfo() async {
//   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//       .collection('Users')
//       .where('email', isEqualTo: user!.email)
//       .get();

//   if (querySnapshot.docs.isNotEmpty) {
//     for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
//       var documentData = docSnapshot.data() as Map<String, dynamic>;
//       documentId = docSnapshot.id;
//       sender_uniquename = documentData["uniquename"];
//     }
//   }
//   // print(sender_uniquename);
// }

// late int recieveddocsize;
// void updaterecieverchats() async {
//   DateTime now = DateTime.now();
//   String formatter = DateFormat('yMd').format(now); // 28/03/2020
//   String formattedTime = DateFormat('HH:mm:ss').format(now);
//   print(formattedTime);
//   await firestore
//       .collection("Users")
//       .doc(ChatScreen.chatdocid)
//       .collection("Chats")
//       .get()
//       .then((jdncj) => {
//             recieveddocsize = jdncj.size,
//             // print(docsize)
//             // console.log('Total documents: ', totalDocuments);
//           });
//   await FirebaseFirestore.instance
//       .collection("Users")
//       .doc(ChatScreen.chatdocid)
//       .collection("Chats")
//       .doc(now.toString())
//       .set({
//     "recieved": message,
//     "uniquename": sender_uniquename,
//     "date": formatter,
//     "time": formattedTime,
//     "sentcheck": false,
//     "timestamp": now
//   });
// }

// var documentId;
// late int docsize;
// void updatechats() async {
//   DateTime now = DateTime.now();
//   String formatter = DateFormat('yMd').format(now); // 28/03/2020
//   String formattedTime = DateFormat('HH:mm:ss').format(now);
//   print(formattedTime);

//   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//       .collection('Users')
//       .where('email', isEqualTo: user!.email)
//       .get();

//   if (querySnapshot.docs.isNotEmpty) {
//     for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
//       var documentData = docSnapshot.data() as Map<String, dynamic>;
//       // print(size);
//       documentId = docSnapshot.id;
//       print(documentId);
//       await firestore
//           .collection("Users")
//           .doc(documentId)
//           .collection("Chats")
//           .get()
//           .then((jdncj) => {
//                 docsize = jdncj.size,

//                 print(docsize)
//                 // console.log('Total documents: ', totalDocuments);
//               });
//       await firestore
//           .collection("Users")
//           .doc(documentId)
//           .collection("Chats")
//           .doc(now.toString())
//           .set({
//         "uniquename": uniquename,
//         "sent": message,
//         "date": formatter,
//         "time": formattedTime,
//         "sentcheck": true,
//         "timestamp": now
//       });
//       // Process the document data and ID
//     }
//   } else {
//     // No documents found that match the query
//   }
// }

// void checkdata() async {
//   // Access the "Chats" collection within each user document
//   QuerySnapshot querySnapshot = await firestore
//       .collection("Users")
//       .doc("yH1oVyBMJipXnPJDyN6m")
//       .collection("Chats")
//       .orderBy("time")
//       .get();

//   if (querySnapshot.docs.isNotEmpty) {
//     for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
//       Map<String, dynamic>? chatData =
//           documentSnapshot.data() as Map<String, dynamic>?;
//       // Process the chat data as required

//       print(documentSnapshot.id);
//     }
//   } else {
//     // No chat documents found
//     print('No chat documents found');
//   }
// }

// void checkCurrentUser() {
//   user = auth.currentUser;
//   if (user != null) {
//     print('Current User: ${user!.email}');
//     // Perform actions with the current user
//   } else {
//     print('No user is currently logged in');
//     // Handle the case when no user is logged in
//   }
// }

// void getrecievedchats() async {
//   await firestore
//       .collection("Users")
//       .doc(ChatScreen.chatdocid)
//       .collection("Chats")
//       .where("uniquename", isEqualTo: sender_uniquename)
//       .where("sentcheck", isEqualTo: true)
//       .get()
//       .then((value) => value.docs.forEach((element) {
//             var val = element.data();
//             print(val["sent"]);
//           }));
//   // if (querySnapshot.docs.isEmpty) {
//   //   print(sender_uniquename);
//   // } else {
//   //   for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
//   //     var data = documentSnapshot.data() as Map<String, dynamic>;
//   //     print("object");
//   //     print(data["sent"]);

//   //     return data["sent"];
//   //   }
//   // }
// }

// String? url;
// Future<Uint8List> fetchAvatar() async {
//   url = "https://robohash.org/$uniquename";

//   http.Response response = await http.get(Uri.parse(url!));
//   return response.bodyBytes;
// }

// Widget loadingWidget() {
//   return FutureBuilder<Uint8List>(
//     future: fetchAvatar(),
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         // print(snapshot.data);
//         return SizedBox(
//             height: 150, width: 40, child: Image.memory(snapshot.data!));
//       } else if (snapshot.hasError) {
//         print('${snapshot.error}');
//         return const Center(child: Text('❌', style: TextStyle(fontSize: 72.0)));
//       } else {
//         return Container(
//           height: 4,
//           padding: const EdgeInsets.all((150 - 50.0) / 2.0),
//           child: const CircularProgressIndicator(),
//         );
//       }
//     },
//   );
// }

// Timer? _timer;

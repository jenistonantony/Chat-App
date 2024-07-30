import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final auth = FirebaseAuth.instance;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool access = false;
  void getdata(String name, String pass) async {
    firestore
        .collection('Users') // Replace with your collection name
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          // Access the document data
          // print(doc.get("chats"));
          Map<String, dynamic>? docData = doc.data() as Map<String, dynamic>?;
          // Process the data as required
          if (docData!["name"] == name && docData["password"] == pass) {
            access = true;
          }
          print([docData["name"]]);
        }
      } else {
        // No documents found
        print('No documents found');
      }
    }).catchError((error) {
      // Error retrieving data
      print('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "CHAT-HUB",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.green,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 25),
                    child: Image.asset(
                      "assets/mobile.png",
                      height: 150,
                      width: 150,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "LOGIN NOW",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),

                  // ElevatedButton(
                  //     onPressed: () {
                  //       Navigator.pushReplacementNamed(context, "/signup");
                  //     },
                  //     child: const Text("sign up")),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: SizedBox(
                      width: 320,
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter your Email",
                          // focusColor: Colors.red,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.5),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.green, width: 1.5)),
                          labelText: "Email",
                          suffixIcon: const Icon(Icons.person),
                          suffixIconColor: MaterialStateColor.resolveWith(
                              (states) => states.contains(MaterialState.focused)
                                  ? Colors.green
                                  : Colors.grey),
                          labelStyle: GoogleFonts.poppins(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                        controller: email,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: SizedBox(
                      width: 320,
                      child: TextField(
                        autocorrect: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.5),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.green, width: 1.5)),
                          hintText: "Enter Your Password",
                          labelText: "Password",
                          suffixIcon: const Icon(Icons.password),
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
                        controller: password,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                        ),
                        onPressed: () async {
                          try {
                            final user = await auth.signInWithEmailAndPassword(
                                email: email.text, password: password.text);
                            Navigator.pushReplacementNamed(context, "chatlist");
                            print(user.user!.uid.toString());
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                              content: Container(
                                decoration:
                                    const BoxDecoration(color: Colors.red),
                                child: Text(e.toString()),
                              ),
                            ));

                            print(e);
                          }
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => const HomeScreen()));
                        },

                        //  ElevatedButton(
                        //         onPressed: () async {
                        //           try {
                        //             final user = await _auth.signInWithEmailAndPassword(
                        //                 email: email, password: password);
                        //             Navigator.pushReplacementNamed(
                        //                 context, 'home_screen');
                        //           } catch (e) {
                        //             var error = e.toString().split(']');
                        //             ScaffoldMessenger.of(context).showSnackBar(
                        //               SnackBar(
                        //                 behavior: SnackBarBehavior.floating,
                        //                 backgroundColor: Colors.red,
                        //                 content: Container(
                        //                   decoration: const BoxDecoration(
                        //                     color: Colors.red,
                        //                   ),
                        //                   child: Text(error[1]),
                        //                 ),
                        //               ),
                        //             );
                        //             print(error[1]);
                        //           }
                        //         },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          child: SizedBox(
                              // color: Colors.red,
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 16,
                              child: Center(
                                  child: Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ))),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Dont have an account ?",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              // color: Colors.green,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, "signup");
                                // Navigator.pop(context);
                              },
                              child: Text("Sign Up",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.green)))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // child: ,
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final TextEditingController email = TextEditingController();
    final TextEditingController password = TextEditingController();
    final TextEditingController name = TextEditingController();
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100, bottom: 20),
                  child: Text(
                    "Chat-hub".toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.green,
                    ),
                  ),
                ),
                Image.asset(
                  "assets/mobile-phone.png",
                  height: 200,
                  width: 250,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hello, Welcome !",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "SIGN UP",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: SizedBox(
                    width: 320,
                    child: TextField(
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: "Enter your Name",
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
                        labelText: "Name",
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
                      controller: name,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                        suffixIcon: const Icon(Icons.email),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: SizedBox(
                    width: 320,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter your Password",
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
                        labelText: "Password",
                        suffixIcon: const Icon(Icons.password_rounded),
                        suffixIconColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.focused)
                                ? Colors.green
                                : Colors.grey),
                        labelStyle: GoogleFonts.poppins(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      controller: password,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: () async {
                        try {
                          final user =
                              await auth.createUserWithEmailAndPassword(
                                  email: email.text, password: password.text);
                          // AvatarPage.uid = user.user!.uid;
                          Navigator.pushReplacementNamed(
                            context,
                            "avatarpage",
                            arguments: {
                              "uid": user.user!.uid,
                            },
                          );
                          FirebaseFirestore.instance
                              .collection("Users")
                              .doc()
                              .set({
                            "uid": user.user!.uid,
                            "name": name.text,
                            "email": email.text,
                            "password": password.text
                          });

                          // print(user.u)
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
                      },
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account ?",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            // color: Colors.green,
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, "signin");
                              // Navigator.pop(context);
                            },
                            child: Text("Sign In",
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
            // child: ,
          ),
        ),
      ),
    );
  }
}

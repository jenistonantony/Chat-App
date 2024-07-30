import 'package:chat_hub/chatpage.dart';
import 'package:chat_hub/screens/chatslist.dart';
import 'package:chat_hub/screens/signinpage.dart';
import 'package:chat_hub/screens/signuppage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_hub/screens/avatarpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: const SignInScreen(),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? "signin" : "chatlist",
      // FirebaseAuth.instance.currentUser == null ? 'signin' : 'chatlist',
      onGenerateRoute: (settings) {
        Widget currentScreen;
        switch (settings.name) {
          case 'signup':
            currentScreen = const SignUpScreen();
            break;
          case 'signin':
            currentScreen = const SignInScreen();
            break;

          case 'chatlist':
            currentScreen = const ChatList();
            break;
          case 'chatpage':
            currentScreen = const ChatScreen();
            break;

          case 'avatarpage':
            final args = settings.arguments as Map<String, dynamic>;

            currentScreen = AvatarPage(
              uid: args["uid"].toString(),
            );
            break;

          default:
            currentScreen = const SignInScreen();
            break;
        }
        return MaterialPageRoute(builder: (context) => currentScreen);
      },
    );
  }
}

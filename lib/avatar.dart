import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Avatar extends StatefulWidget {
  const Avatar({super.key, required this.url, required this.size});
  final String url;
  final double size;
  @override
  State<StatefulWidget> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  Future<Uint8List> fetchAvatar() async {
    http.Response response = await http.get(Uri.parse(widget.url));
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
            padding: EdgeInsets.all((widget.size - 50.0) / 2.0),
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue,
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
    );
  }
}

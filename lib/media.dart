import 'package:flutter/material.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Media Page"),
      ),
      body: const Center(
        child: Text("This is Media Page"),
      ),
    );
  }
}
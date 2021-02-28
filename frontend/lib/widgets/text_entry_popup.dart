import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextEntryPopUp extends StatelessWidget {
  final Function function;
  final TextEditingController controller;
  final String title;

  const TextEntryPopUp({Key key, this.function, this.controller, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: controller,
        onEditingComplete: function,
        autofocus: true,
      ),
      actions: [
        CupertinoButton(child: Text("Submit"), onPressed: function),
        CupertinoButton(
            child: Text("Cancel"),
            onPressed: () {
              print(controller.text);
              Navigator.of(context).pop();
            })
      ],
      title: Text(title),
    );
  }
}

import 'package:flutter/material.dart';

class AlertDialogWidget extends StatelessWidget {
  final String? contentText;
  final Function? confirmFunction;
  final Function? declineFunction;

  AlertDialogWidget({
    this.contentText,
    this.confirmFunction,
    this.declineFunction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        contentText!,
      ),
      actions: [
        TextButton(
          onPressed: declineFunction as void Function()?,
          child: Text("No"),
        ),
        TextButton(
          onPressed: confirmFunction as void Function()?,
          child: Text("Yes"),
        ),
      ],
    );
  }
}


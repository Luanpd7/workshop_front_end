import 'package:flutter/material.dart';

class AlertDialogUtil extends StatelessWidget {
  const AlertDialogUtil(
      {super.key, required this.title, required this.content, this.labelButtonPrimary, this.onPressedPrimary});

  final String title;
  final String content;
  final String? labelButtonPrimary;
  final void Function()? onPressedPrimary;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: Navigator.of(context).pop,
              child: Text('Voltar'),
            ),
            if(labelButtonPrimary != null)
            ElevatedButton(
              onPressed: onPressedPrimary,
              child: Text(labelButtonPrimary!),
            ),
          ],
        ),
      ],
    );
  }
}

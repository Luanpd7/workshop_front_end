import 'package:flutter/material.dart';

class AlertDialogUtil extends StatelessWidget {
  const AlertDialogUtil({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [ElevatedButton(onPressed: Navigator.of(context).pop, child: Text('Voltar'),),],
    );
  }
}

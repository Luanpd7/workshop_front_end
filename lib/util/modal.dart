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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(title),
      content: Text(content),
      actions: [
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ButtonStyle(backgroundColor:  WidgetStatePropertyAll( Colors.lightBlue.shade900,),),
              onPressed: Navigator.of(context).pop,
              child: Text('Voltar'),
            ),
            if(labelButtonPrimary != null)
            ElevatedButton(
              style: ButtonStyle(backgroundColor:  WidgetStatePropertyAll( Colors.lightBlue.shade900,),),
              onPressed: onPressedPrimary,
              child: Text(labelButtonPrimary!),
            ),
          ],
        ),
      ],
    );
  }
}

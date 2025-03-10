import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TarefaFabiano extends StatelessWidget {
  const TarefaFabiano({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(child: Expanded(child: ContainerStyle())),
    );
  }
}

class ContainerStyle extends StatelessWidget {
  const ContainerStyle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_outlined,
          size: 80,
          color: Colors.green,
        ),
        Text(
          'Chatt',
          style: TextStyle(
              color: Colors.green, fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          'Simle mobile chat and notes',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  width: 100,
                  color: Colors.blueAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign in with',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Icon(
                        Icons.facebook,
                        size: 20,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Container(
                  height: 60,
                  width: 100,
                  color: Colors.lightBlueAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign in with',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Icon(
                        Icons.tablet_android_rounded,
                        size: 20,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'or',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            height: 50,
            child: TextFormField(
              decoration: InputDecoration(
                hoverColor: Colors.grey,
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38, width: 2)),

                label: Row(
                  spacing: 2.0,
                  children: [Icon(Icons.people),
                Text('Email'),
                ],)
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            height: 70,
            child: TextFormField(
              decoration: InputDecoration(
                  hoverColor: Colors.grey,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38, width: 2)),
                  label: Row(
                    spacing: 2.0,
                    children:
                  [Icon(Icons.password_sharp),
                    Text('Password'),
                  ],)
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: 60,
            width: double.infinity,
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

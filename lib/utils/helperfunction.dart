

 import 'package:flutter/material.dart';

void showMsg(BuildContext context, String msg) =>
  ScaffoldMessenger.of(context)
  .showSnackBar(
    SnackBar(content: Text(msg),)
  );

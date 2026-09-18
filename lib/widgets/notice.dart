import 'package:flutter/material.dart';

void showNimzoNotice(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

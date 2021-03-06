import 'package:flutter/material.dart';

Widget get menuButton {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 5),
            Container(height: 3, width: 12, color: Colors.white),
          ],
        ),
        SizedBox(height: 7),
        Container(height: 3, width: 24, color: Colors.white),
        SizedBox(height: 7),
        Container(height: 3, width: 12, color: Colors.white),
      ],
    ),
  );
}

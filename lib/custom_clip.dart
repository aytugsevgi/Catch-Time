 

 import 'package:flutter/material.dart';

class CustomShapeClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    final Path path = new Path();
    path.lineTo(0, size.height);
    
    var firstControlPoint = Offset(size.width* 0.25, size.height-50);
    var firstEndPoint = Offset(size.width/2, size.height-35);
    
    var secondControlPoint = Offset(size.width*0.75, size.height-20);
    var secondEndPoint = Offset(size.width, size.height-70);
    
    path.quadraticBezierTo(firstControlPoint.dx,firstControlPoint.dy, firstEndPoint.dx,firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx,secondControlPoint.dy,secondEndPoint.dx,secondEndPoint.dy);
    
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
  

}
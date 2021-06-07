import 'package:flutter/material.dart';
import 'package:shouz/Pages/Actualite.dart';
import 'package:shouz/Pages/Setting.dart';

final routes = {
  '/home': (BuildContext context) => new Actualite(),
  '/setting': (BuildContext context) => new Setting(),
  '/': (BuildContext context) => new Actualite(),
};

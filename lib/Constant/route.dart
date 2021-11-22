import 'package:flutter/material.dart';
import 'package:shouz/Pages/Actualite.dart';
import 'package:shouz/Pages/Checkout.dart';
import 'package:shouz/Pages/ChoiceHobie.dart';
import 'package:shouz/Pages/CreateProfil.dart';
import 'package:shouz/Pages/Login.dart';
import 'package:shouz/Pages/Opt.dart';
import 'package:shouz/Pages/ResultSubscribeForfait.dart';
import 'package:shouz/Pages/Setting.dart';

import '../MenuDrawler.dart';

final routes = {
  Login.rootName: (context) => Login(),
  Otp.rootName: (context) => Otp(),
  CreateProfil.rootName: (context) => CreateProfil(),
  MenuDrawler.rootName: (context) => MenuDrawler(),
  ChoiceHobie.rootName: (context) => ChoiceHobie(),
  Checkout.rootName: (context) => Checkout(),
  Setting.rootName: (context) => Setting(),
  ResultSubscribeForfait.rootName: (context) => ResultSubscribeForfait(),
};

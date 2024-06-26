import 'package:flutter/material.dart';
import 'package:shouz/Pages/Checkout.dart';
import 'package:shouz/Pages/ChoiceHobie.dart';
import 'package:shouz/Pages/CreateDeals.dart';
import 'package:shouz/Pages/CreateEvent.dart';
import 'package:shouz/Pages/CreateProfil.dart';
import 'package:shouz/Pages/ExplainEvent.dart';
import 'package:shouz/Pages/Login.dart';
import 'package:shouz/Pages/Notifications.dart';
import 'package:shouz/Pages/Opt.dart';
import 'package:shouz/Pages/Profil.dart';
import 'package:shouz/Pages/ResultSubscribeForfait.dart';
import 'package:shouz/Pages/Setting.dart';
import 'package:shouz/Pages/checkout_recharge_mobile_money.dart';
import 'package:shouz/Pages/checkout_retrait.dart';
import 'package:shouz/Pages/checkout_retrait_mobile_money.dart';
import 'package:shouz/Pages/create_travel.dart';
import 'package:shouz/Pages/create_vote.dart';
import 'package:shouz/Pages/demande_conducteur.dart';
import 'package:shouz/Pages/event_decode.dart';
import 'package:shouz/Pages/result_buy_covoiturage.dart';
import 'package:shouz/Pages/result_buy_event.dart';
import 'package:shouz/Pages/travel_decode.dart';
import 'package:shouz/Pages/update_info_basic.dart';

import '../MenuDrawler.dart';
import '../Pages/wallet_page.dart';

final routes = {
  Login.rootName: (context) => Login(),
  CreateProfil.rootName: (context) => CreateProfil(),
  MenuDrawler.rootName: (context) => MenuDrawler(),
  ChoiceHobie.rootName: (context) => ChoiceHobie(),
  Checkout.rootName: (context) => Checkout(),
  Setting.rootName: (context) => Setting(),
  ResultSubscribeForfait.rootName: (context) => ResultSubscribeForfait(),
  ExplainEvent.rootName: (context) => ExplainEvent(),
  CreateEvent.rootName: (context) => CreateEvent(),
  CreateDeals.rootName: (context) => CreateDeals(),
  ResultBuyEvent.rootName: (context) => ResultBuyEvent(),
  ResultBuyCovoiturage.rootName: (context) => ResultBuyCovoiturage(),
  DemandeConducteur.rootName: (context) => DemandeConducteur(),
  CreateTravel.rootName: (context) => CreateTravel(key: UniqueKey()),
  Profil.rootName: (context) => Profil(),
  Notifications.rootName: (context) => Notifications(),
  CheckoutRechargeMobileMoney.rootName: (context) => CheckoutRechargeMobileMoney(key: UniqueKey(),),
  CheckoutRetraitMobileMoney.rootName: (context) => CheckoutRetraitMobileMoney(key: UniqueKey()),
  WalletPage.rootName: (context) => WalletPage(key: UniqueKey()),
  UpdateInfoBasic.rootName: (context) => UpdateInfoBasic(key: UniqueKey(),),
  CheckoutRetrait.rootName: (context) => CheckoutRetrait(),
  EventDecode.rootName: (context) => EventDecode(),
  TravelDecode.rootName: (context) => TravelDecode(),
  CreateVote.rootName: (context) => CreateVote(),
};

import 'dart:convert';

import 'package:ff_alarm_monitor/server/monitor.dart';
import 'package:ff_alarm_monitor/utils/prefs.dart';
import 'package:flutter/cupertino.dart';

abstract class Globals {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext get context => navigatorKey.currentState!.context;

  static final Prefs prefs = Prefs(identifier: 'main');
  static final ValueNotifier<bool> loggedIn = ValueNotifier<bool>(false);
  static Monitor? monitor;

  static String get server => prefs.getString('server_domain')!;

  static void logout() {
    prefs.remove('monitor_id');
    prefs.remove('server_domain');
    prefs.remove('monitor_token');
    prefs.remove('monitor');
    monitor = null;
    loggedIn.value = false;
  }

  static void init() {
    try {
      int? id = prefs.getInt('monitor_id');
      String? server = prefs.getString('server_domain');
      String? token = prefs.getString('monitor_token');
      String? monitorJson = prefs.getString('monitor');

      if (id != null && server != null && token != null && monitorJson != null) {
        try {
          monitor = Monitor.fromJson(jsonDecode(monitorJson));
          loggedIn.value = true;
        } catch (e) {
          logout();
        }
      }
    } catch (e) {
      logout();
      prefs.clear();
    }
  }
}

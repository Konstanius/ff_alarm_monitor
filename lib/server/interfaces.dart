import 'dart:convert';

import 'package:ff_alarm_monitor/server/request.dart';

import '../utils/globals.dart';
import 'monitor.dart';

abstract class Interfaces {
  static Future<Monitor> register({required String server, required String token}) async {
    Map<String, dynamic> data = {'token': token};

    Request response = await Request('register', data, server).emit(true, guest: true);

    Monitor monitor = Monitor.fromJson(response.ackData!);

    Globals.monitor = monitor;
    Globals.prefs.setInt('monitor_id', monitor.id);
    Globals.prefs.setString('server_domain', server);
    Globals.prefs.setString('monitor_token', token);
    Globals.prefs.setString('monitor', jsonEncode(monitor.toJson()));
    Globals.loggedIn.value = true;

    return monitor;
  }
}

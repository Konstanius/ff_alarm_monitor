import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ff_alarm_monitor/link/link_session.dart';
import 'package:ff_alarm_monitor/server/interfaces.dart';
import 'package:ff_alarm_monitor/utils/dialogs.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Timer? timer;
  LinkSession? session;
  Map<String, dynamic>? fetchedData;

  Future<void> generateSession() async {
    while (true) {
      try {
        Random random = Random();
        String content = "";
        for (int i = 0; i < 100; i++) {
          content += random.nextInt(256).toString();
        }
        session = await LinkSession.generateSession(content: content);
        if (mounted) setState(() {});
        break;
      } catch (e, s) {
        print(e);
        print(s);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    generateSession();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (session == null) return;
      if (fetchedData != null) return;

      try {
        String data = await session!.fetchContent();
        dynamic result = jsonDecode(data);
        if (result is Map<String, dynamic>) {
          fetchedData = result;

          String token = fetchedData!['token']!;
          String server = fetchedData!['server']!;

          try {
            await Interfaces.register(server: server, token: token);
          } catch (_) {
            fetchedData = null;
            session = null;
            generateSession();
            Dialogs.error(message: 'Fehler bei der Registrierung. Bitte versuchen Sie es erneut.');
            return;
          }
          timer.cancel();
        }
      } catch (e, s) {
        print(e);
        print(s);
        fetchedData = null;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('FF Alarm - Monitor Registrierung')),
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (session == null)
              const Column(
                children: [
                  ProgressRing(),
                  SizedBox(height: 8),
                  Text('Zugangscode wird erstellt...'),
                ],
              )
            else
              () {
                String display = "${session!.identifier}\n${session!.session}\n${session!.authentication}";
                return QrImageView(data: display, size: MediaQuery.of(context).size.height / 2);
              }(),
          ],
        ),
      ),
    );
  }
}

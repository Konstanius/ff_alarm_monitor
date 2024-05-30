import 'package:ff_alarm_monitor/pages/monitor_screen.dart';
import 'package:ff_alarm_monitor/pages/register_screen.dart';
import 'package:ff_alarm_monitor/utils/globals.dart';
import 'package:fluent_ui/fluent_ui.dart';

void main() {
  Globals.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      navigatorKey: Globals.navigatorKey,
      themeMode: ThemeMode.light,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Globals.loggedIn,
      builder: (context, value, child) {
        if (!value) {
          return const RegisterPage();
        } else {
          return const MonitorPage();
        }
      },
    );
  }
}

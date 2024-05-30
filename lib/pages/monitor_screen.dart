import 'package:ff_alarm_monitor/server/interfaces.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../utils/globals.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  @override
  void initState() {
    super.initState();

    Interfaces.ping().catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text('Monitor: ${Globals.monitor!.name}'),
      ),
    );
  }
}

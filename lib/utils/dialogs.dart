import 'package:quickalert/quickalert.dart';

import 'globals.dart';

abstract class Dialogs {
  static Future<void> error({
    required String message,
    Duration autoCloseDuration = const Duration(seconds: 10),
  }) =>
      QuickAlert.show(
        context: Globals.context,
        type: QuickAlertType.error,
        text: message,
        title: 'Fehler',
        barrierDismissible: true,
        width: 400,
        autoCloseDuration: autoCloseDuration,
      );

  static void loading({
    required String title,
    required String message,
  }) {
    QuickAlert.show(
      context: Globals.context,
      type: QuickAlertType.loading,
      text: message,
      title: title,
      barrierDismissible: false,
      width: 400,
      disableBackBtn: true,
      showConfirmBtn: false,
      showCancelBtn: false,
    );
  }
}

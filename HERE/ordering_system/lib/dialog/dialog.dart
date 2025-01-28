import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WaitingDialog extends StatelessWidget {
  static Future<T?> show<T>(BuildContext context,
      {required Future<T> future, String? prompt, Color? color}) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dCon) {
            return WaitingDialog(prompt: prompt, color: color);
          });
      T result = await future;
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      return result;
    } catch (e, st) {
      print(e);
      print(st);
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Info.showSnackbarMessage(context, actionLabel: "Copy",
            onCloseTapped: () {
          Clipboard.setData(ClipboardData(text: e.toString()));
          Info.showSnackbarMessage(context, message: "Copied to clipboard");
        }, message: e.toString(), duration: const Duration(seconds: 10));
      }
      return null;
    }
  }

  final String? prompt;
  final Color? color;

  const WaitingDialog({super.key, this.prompt, this.color});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitChasingDots(
              color: color ?? Colors.white,
              size: 32,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              prompt ?? "Please wait . . .",
              style: TextStyle(color: color ?? Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

class Info {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackbarMessage(BuildContext context,
          {required String message,
          String? label,
          String actionLabel = "Close",
          void Function()? onCloseTapped,
          Duration duration = const Duration(seconds: 3)}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 2,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(
                      label,
                    ),
                  Text(
                    message,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: () {
                if (onCloseTapped != null) {
                  onCloseTapped();
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                }
              },
              child: Text(
                actionLabel,
              ),
            )
          ],
        ),
        duration: duration,
      ),
    );
  }
}

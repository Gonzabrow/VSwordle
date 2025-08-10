import 'package:flutter/material.dart';
import 'color.dart';

class OverlayToast {
  static void show(
    BuildContext context, {
    required String message,
    Duration displayDuration = const Duration(seconds: 1),
    Duration fadeInDuration = const Duration(milliseconds: 10),
    Duration fadeOutDuration = const Duration(milliseconds: 400),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return _ToastWidget(
        message: message,
        fadeInDuration: fadeInDuration,
        fadeOutDuration: fadeOutDuration,
        displayDuration: displayDuration,
        onFinish: () => overlayEntry.remove(),
      );
    });

    overlay.insert(overlayEntry);

  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Duration displayDuration;
  final VoidCallback onFinish;

  const _ToastWidget({
    required this.message,
    required this.fadeInDuration,
    required this.fadeOutDuration,
    required this.displayDuration,
    required this.onFinish,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
      reverseDuration: widget.fadeOutDuration,
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut, reverseCurve: Curves.easeIn);

    _controller.forward();

    // 表示後にゆっくり消す
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onFinish();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fade,
        child: Material(
          color: Colors.transparent, // これなんなん
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: appColors.field.TextPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.message,
                style: TextStyle(
                  color: appColors.field.Background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
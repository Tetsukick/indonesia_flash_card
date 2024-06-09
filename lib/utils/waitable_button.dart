import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WaitableElevatedButton extends StatefulWidget {

  WaitableElevatedButton({
    required this.onPressed,
    required this.child,
    this.style,
    super.key,
  });
  @override
  createState() => _WaitableElevatedButtonState();

  final AsyncCallback? onPressed;
  final ButtonStyle? style;
  final Widget child;
}

class _WaitableElevatedButtonState extends State<WaitableElevatedButton> {
  bool _waiting = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: widget.style,
      onPressed: widget.onPressed == null || _waiting
          ? null
          : () async {
        setState(() => _waiting = true);
        await widget.onPressed!();
        setState(() => _waiting = false);
      },
      child: widget.child,
    );
  }
}

class WaitableOutlinedButton extends StatefulWidget {

  WaitableOutlinedButton({
    required this.onPressed,
    required this.child,
    this.style,
    super.key,
  });
  @override
  createState() => _WaitableOutlinedButtonState();

  final AsyncCallback? onPressed;
  final ButtonStyle? style;
  final Widget child;
}

class _WaitableOutlinedButtonState extends State<WaitableOutlinedButton> {
  bool _waiting = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: widget.style,
      onPressed: widget.onPressed == null || _waiting
          ? null
          : () async {
        setState(() => _waiting = true);
        await widget.onPressed!();
        setState(() => _waiting = false);
      },
      child: widget.child,
    );
  }
}
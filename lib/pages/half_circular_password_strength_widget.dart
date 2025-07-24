import 'dart:math' as math;
import 'package:flutter/material.dart';

class HalfCircularPasswordStrengthWidget extends StatelessWidget {
  final String? password;
  final double? strengthValue;
  final double size;

  const HalfCircularPasswordStrengthWidget({
    super.key,
    this.password,
    this.strengthValue,
    this.size = 150,
  }) : assert(password != null || strengthValue != null);

  double get _strength {
    if (strengthValue != null) return strengthValue!;
    return _calculatePasswordStrength(password!);
  }

  static double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    double strength = 0;
    if (password.length >= 8) strength += 0.15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;

    return strength.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    Color strengthColor = _getStrengthColor(_strength);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size / 2,
          child: CustomPaint(
            painter: _HalfCircularStrengthPainter(
              strength: _strength,
              color: strengthColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${(_strength * 100).toInt()}%",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: strengthColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _status(_strength),
          style: TextStyle(
            fontSize: 18,
            color: strengthColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.2) return Colors.red;
    if (strength <= 0.3) return Colors.deepOrange;
    if (strength <= 0.4) return Colors.orange;
    if (strength <= 0.5) return Colors.yellow;
    if (strength <= 0.6) return Colors.lightGreen;
    if (strength <= 0.75) return Colors.green;
    if (strength <= 0.9) return Colors.blue;
    return Colors.purple;
  }

  String _status(double strength) {
    if (strength <= 0.2) return 'Very Weak';
    if (strength <= 0.3) return 'Weak';
    if (strength <= 0.4) return 'Fair';
    if (strength <= 0.5) return 'Good';
    if (strength <= 0.6) return 'Very Good';
    if (strength <= 0.75) return 'Strong';
    if (strength <= 0.9) return 'Very Strong';
    return 'Excellent';
  }
}

class _HalfCircularStrengthPainter extends CustomPainter {
  final double strength;
  final Color color;

  const _HalfCircularStrengthPainter({
    required this.strength,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0;

    double radius = size.width / 2;
    double centerX = size.width / 2;
    double centerY = size.height;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );

    // Progress arc
    paint.color = color;
    double progressAngle = strength * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      math.pi,
      progressAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_HalfCircularStrengthPainter oldDelegate) {
    return oldDelegate.strength != strength || oldDelegate.color != color;
  }
}

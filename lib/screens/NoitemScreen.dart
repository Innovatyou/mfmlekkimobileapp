import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:lottie/lottie.dart';

class NoitemScreen extends StatelessWidget {
  final String title;
  final String message;
  final Function onClick;

  const NoitemScreen({
    Key? key,
    required this.title,
    required this.message,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/network.json',
              width: 220,
              height: 220,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MyColors.textSecondary,
                fontSize: 14,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 44,
              child: ElevatedButton(
                onPressed: () => onClick(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  t.retry,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

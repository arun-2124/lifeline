import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final String? message;

  const CustomLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CentralBackButton extends StatelessWidget {
  const CentralBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (Navigator.of(context).canPop()){
          Navigator.of(context).pop();
        } else {
        // fallback to dasboard
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      },
    );
  }
}

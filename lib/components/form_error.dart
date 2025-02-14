import 'package:flutter/material.dart';

class FormError extends StatelessWidget {
  const FormError({
    super.key,
    required this.errors,
  });

  final List<String?> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          errors.length, (index) => formErrorText(error: errors[index]!)),
    );
  }

  Row formErrorText({required String error}) {
    return Row(
      children: [
        const Icon(
          Icons.error, 
          color: Colors.red, 
          size: 16, 
        ),
        const SizedBox(
          width: 10,
        ),
        Text(error),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:liana_plant/constants/styles.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isPasswordField;
  final int maxLines;

  const AnimatedTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPasswordField = false,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  AnimatedTextFieldState createState() => AnimatedTextFieldState();
}

class AnimatedTextFieldState extends State<AnimatedTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: _isFocused ? Styles.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                maxLines: widget.maxLines,
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.isPasswordField,
                cursorColor: Colors.blueAccent,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  labelStyle: const TextStyle(
                    color: Styles.primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w300,
                  ),
                  border: InputBorder.none,
                ),
                validator: widget.validator,
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey.shade700),
                onPressed: () {
                  widget.controller.clear();
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }
}

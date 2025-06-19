import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final Icon fieldIcon;
  final String hintText;
  final TextEditingController? controller; // Agregar el controlador como parámetro opcional

  const InputField(this.fieldIcon, this.hintText, {this.controller, super.key});

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Material(
        elevation: 5.0,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        color: Colors.indigo,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.fieldIcon,
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              width: 200,
              height: 60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: widget.controller, // Usar el controlador proporcionado
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
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

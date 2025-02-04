import 'package:flutter/material.dart';

class ItemButton extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemButton({
    super.key,
    required this.item,
  });

  @override
  ItemButtonState createState() => ItemButtonState();
}

class ItemButtonState extends State<ItemButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          // Smth
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shadowColor: Colors.grey.withValues(alpha: 0.5),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding trong button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.black, // Màu của border
              width: 1, // Độ dày của border
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Điều chỉnh kích thước theo nội dung
          children: [
            Icon(
              widget.item['icon'],
              color: Colors.blue,
              size: 20, // Kích thước biểu tượng nhỏ hơn
            ),
            const SizedBox(width: 4), // Khoảng cách giữa icon và text
            Text(
              widget.item['label'],
              style: const TextStyle(
                fontSize: 18, // Kích thước chữ nhỏ hơn
              ),
            ),
          ],
        )
    );
  }
}
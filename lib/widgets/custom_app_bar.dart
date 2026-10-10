import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,

      // 🔙 Leading (Back Button)
      leading:
          showBack
              ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF525151),
                ),
                onPressed: () => Navigator.pop(context),
              )
              : null,

      // 🏷 Title
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),

      // ⚙️ Actions (optional)
      actions: actions,
    );
  }
}

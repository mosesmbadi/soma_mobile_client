import 'package:flutter/material.dart';

class AddStoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AddStoryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Add New Story'),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pushNamed(context, '/home'),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

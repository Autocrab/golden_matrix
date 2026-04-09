import 'package:flutter/material.dart';

class SampleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const SampleCard({super.key, required this.title, this.subtitle, this.icon = Icons.info_outline});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/gunpla.dart';

class GunplaCard extends StatelessWidget {
  const GunplaCard({super.key, required this.item, required this.onTap});
  final Gunpla item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12), onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const CircleAvatar(radius: 25, child: Icon(Icons.smart_toy_outlined)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: Theme.of(context).textTheme.titleMedium),
            Text('${item.modelCode} • ${item.grade}'),
            const SizedBox(height: 8),
            Text('${item.status}  |  ${money(item.priceSatang)} บาท',
              style: Theme.of(context).textTheme.bodySmall),
          ])),
          const Icon(Icons.chevron_right),
        ]),
      ),
    ),
  );
}

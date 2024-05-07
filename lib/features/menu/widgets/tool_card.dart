import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';

class ToolCard extends ConsumerWidget {
  final String name;
  final List<Widget> list;

  const ToolCard({super.key, required this.name, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontSize: 18,
                    ),
              ),
              Divider(
                height: 20,
                thickness: 1,
                color: AppPalette.greyColor.withOpacity(0.5),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return list[index];
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExtensionItem extends ConsumerWidget {
  final String name;

  const ExtensionItem({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: Row(
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: 16,
                  ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

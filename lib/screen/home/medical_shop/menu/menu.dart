import 'package:flutter/material.dart';

import '../../../../common/color_extension.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),

          leading: Image.asset("assets/image/icons8-user-100.png", width: 80, height: 80, fit: BoxFit.cover),
          title: Text('Shanzida', style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColor.primaryTextW)),

    );
  }
}

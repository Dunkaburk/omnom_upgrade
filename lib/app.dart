import 'package:flutter/material.dart';

import 'features/shell/app_shell.dart';
import 'theme/theme.dart';

class OmnomApp extends StatelessWidget {
  const OmnomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omnom',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}

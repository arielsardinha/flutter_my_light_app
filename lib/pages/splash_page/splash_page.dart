import 'package:flutter/material.dart';

import 'package:my_light_app/infra/storage/storage.dart';

class SplashPage extends StatefulWidget {
  final Storage storage;
  const SplashPage({super.key, required this.storage});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    widget.storage
        .get<Map<String, dynamic>>(StorageEnum.proprietario)
        .then((value) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (value != null) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          return;
        }
        Navigator.pushNamedAndRemoveUntil(
            context, '/login_page', (route) => false);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_editor/main/bloc/main_bloc.dart';

import 'main/view/main_page.dart';

class PhotoEditorApp extends StatelessWidget {
  // const PhotoEditorApp({Key? key})
  //     : super(key: key, home: BlocProvider(create: (context) => MainBloc()));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo editor app',
      home: BlocProvider(
        create: (context) => MainBloc(),
        child: const MainPage(),
      ),
    );
  }
}

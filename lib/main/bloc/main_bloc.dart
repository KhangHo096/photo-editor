// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {

  final ImagePicker _picker = ImagePicker();

  MainBloc() : super(const MainInitial()) {
    on<MainEvent>((event, emit) {
      if (event is GetImageSuccess) {
        emit(MainImageLoaded(event.imagePath));
      } else if (event is GetImageFailed) {
        emit(const MainImageNotLoaded());
      }
    });
  }

  void getImage() async {
    ///Use image_picker to load image
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      add(GetImageFailed());
    } else {
      add(GetImageSuccess(file.path));
    }
  }

  void getCameraImage() async {
    ///Use image_picker to capture image from camera
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) {
      add(GetImageFailed());
    } else {
      add(GetImageSuccess(file.path));
    }
  }

  Future<void> saveImage(GlobalKey globalKey, BuildContext context) async {
    ///Delay 200ms for UI to render
    await Future.delayed(const Duration(milliseconds: 200));
    ///Converting widget to byte data then to image bytes (Uint8List)
    RenderRepaintBoundary? boundary =
    globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    ///
    if (pngBytes != null) {
      ///Save image on cache
      final dir = await getExternalStorageDirectory();
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      final myImagePath = dir!.path + '/my-img-$timeStamp.png';
      File imageFile = File(myImagePath);
      if (!await imageFile.exists()) {
        imageFile.create(recursive: true);
      }
      imageFile.writeAsBytes(pngBytes.toList());
      ///
      // print('Created file successfully!');
      // print('File path: ${imageFile.path}');
      ///Delay 200ms for UI to render
      await Future.delayed(const Duration(milliseconds: 200));
      ///Show saved image
      showDialog(
          context: context,
          builder: (context) {
            return Image.file(imageFile);
          },
          barrierDismissible: true);
    } else {
      print('Failed to create file: pngBytes is null!');
    }
  }
}

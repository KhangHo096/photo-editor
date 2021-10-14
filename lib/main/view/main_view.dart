// ignore_for_file: avoid_print

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:photo_editor/main/bloc/main_bloc.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  ///List stickers' paths and matrix for stickers' coordinates on the painter
  final List<String> _listStickerPaths = [];
  final List<Matrix4> listMatrix = [];

  ///
  ///Loaded image path
  String imagePath = '';

  ///
  /// Global key for getting RepaintBoundary's image byte data
  final GlobalKey _globalKey = GlobalKey();

  ///

  ///Check processing image to save cache
  bool isSaving = false;
  ///

  ///Color filter
  final _filters = [
    Colors.white,
    ...List.generate(
      Colors.primaries.length,
      (index) => Colors.primaries[(index * 4) % Colors.primaries.length],
    )
  ];
  Color? _currentFilterColor;
  ///

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo editor')),
      body: Center(
        child: BlocConsumer<MainBloc, MainState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is MainInitial) {
              return _buildInitial('Image not chosen!');
            } else if (state is MainImageNotLoaded) {
              return _buildInitial('Please choose or take an image!');
            } else if (state is MainImageLoaded) {
              if (state.imagePath.isNotEmpty) {
                imagePath = state.imagePath;
                return _buildImageLoaded();
              }
              return _buildInitial('Image not chosen!');
            }
            return _buildInitial('Image not chosen!');
          },
        ),
      ),
    );
  }

  Widget _buildInitial(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(message),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGalleryButton(),
            const SizedBox(
              width: 20,
            ),
            _buildCameraButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImageLoaded() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: RepaintBoundary(
          key: _globalKey,
          child: Stack(
            children: [_buildImageLayout(), _buildStickerStack()],
          ),
        )),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGalleryButton(),
            const SizedBox(
              width: 20,
            ),
            _buildCameraButton(),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAddStickerButton(context),
            const SizedBox(
              width: 20,
            ),
            _buildAddFilterButton(context),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        _buildSaveImageButton(),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildImageLayout() {
    return Positioned.fill(
        child: Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      color: _currentFilterColor?.withOpacity(0.5),
      colorBlendMode: BlendMode.color,
    ));
  }

  Widget _buildStickerStack() {
    return Stack(
      children: _listStickerPaths.isNotEmpty
          ? _listStickerPaths.mapIndexed((index, path) {
              return Positioned.fill(
                child: MatrixGestureDetector(
                  onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
                    setState(() {
                      listMatrix[index] = m;
                    });
                  },
                  child: Transform(
                    transform: listMatrix[index],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        isSaving
                            ? const SizedBox()
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    _listStickerPaths.removeAt(index);
                                    listMatrix.removeAt(index);
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.white, borderRadius: BorderRadius.circular(25)),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 50,
                                  ),
                                )),
                        Image.asset(path),
                      ],
                    ),
                  ),
                ),
              );
            }).toList()
          : [],
    );
  }

  Widget _buildSaveImageButton() {
    return SimpleButton(
      text: 'Save image',
      iconData: Icons.save_alt,
      onTap: saveImage,
    );
  }

  Widget _buildAddStickerButton(BuildContext context) {
    return SimpleButton(
      text: 'Add sticker',
      iconData: Icons.sticky_note_2,
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return SizedBox(
                height: 150,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStickerItem(context, 'assets/images/sticker_1.png'),
                      _buildStickerItem(context, 'assets/images/sticker_2.png'),
                      _buildStickerItem(context, 'assets/images/sticker_3.png'),
                      _buildStickerItem(context, 'assets/images/sticker_4.png'),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  Widget _buildAddFilterButton(BuildContext context) {
    return SimpleButton(
      text: 'Apply filter',
      iconData: Icons.format_paint,
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return SizedBox(
                height: 150,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.mapIndexed((index, element) {
                      return _buildFilterItem(context, element);
                    }).toList(),
                  ),
                ),
              );
            });
      },
    );
  }

  Widget _buildFilterItem(BuildContext context, Color color) {
    return InkWell(
      child: Image.file(
        File(imagePath),
        width: 125,
        height: 125,
        color: color.withOpacity(0.5),
        colorBlendMode: BlendMode.color,
      ),
      onTap: () {
        setState(() {
          _currentFilterColor = color;
          Navigator.pop(context);
        });
      },
    );
  }

  Widget _buildStickerItem(BuildContext context, String path) {
    return InkWell(
      child: Image.asset(
        path,
        width: 125,
        height: 125,
      ),
      onTap: () {
        setState(() {
          _listStickerPaths.add(path);
          listMatrix.add(Matrix4.identity());
          Navigator.pop(context);
        });
      },
    );
  }

  Widget _buildGalleryButton() {
    return SimpleButton(
      text: 'Gallery',
      iconData: Icons.style,
      onTap: getImage,
    );
  }

  Widget _buildCameraButton() {
    return SimpleButton(
      text: 'Camera',
      iconData: Icons.camera_alt_rounded,
      onTap: getCameraImage,
    );
  }

  void getImage() async {
    final mainBloc = BlocProvider.of<MainBloc>(context);
    mainBloc.getImage();
  }

  void getCameraImage() async {
    final mainBloc = BlocProvider.of<MainBloc>(context);
    mainBloc.getCameraImage();
  }

  void saveImage() async {
    setState(() {
      isSaving = true;
    });
    final mainBloc = BlocProvider.of<MainBloc>(context);
    await mainBloc.saveImage(_globalKey, context);
    setState(() {
      isSaving = false;
    });
  }
}

class SimpleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData iconData;
  final String text;

  const SimpleButton({
    required this.onTap,
    required this.iconData,
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: 28,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

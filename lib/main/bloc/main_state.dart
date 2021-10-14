part of 'main_bloc.dart';

@immutable
abstract class MainState {
  const MainState();
}

class MainInitial extends MainState {
  const MainInitial();
}

class MainImageNotLoaded extends MainState {
  const MainImageNotLoaded();
}

class MainImageLoaded extends MainState {
  final String imagePath;
  const MainImageLoaded(this.imagePath);
}
part of 'main_bloc.dart';

@immutable
abstract class MainEvent {

}

class GetImageSuccess extends MainEvent {
  final String imagePath;

  GetImageSuccess(this.imagePath);
}

class GetImageFailed extends MainEvent {
  GetImageFailed();
}
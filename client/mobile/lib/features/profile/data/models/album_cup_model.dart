import 'dart:ui';
import 'single_photo_item.dart';

class AlbumCupModel {
  static const int maxPhotos = 6;
  final String id;
  String name;
  Offset position;
  final List<SinglePhotoItem> photos;
  double floatPhase;

  bool get isFull => photos.length >= maxPhotos;

  AlbumCupModel({
    required this.id,
    required this.name,
    required this.position,
    List<SinglePhotoItem>? photos,
    this.floatPhase = 0.0,
  }) : photos = photos ?? [];

  int get count => photos.length;

  AlbumCupModel copyWith({
    String? id,
    String? name,
    Offset? position,
    List<SinglePhotoItem>? photos,
    double? floatPhase,
  }) {
    return AlbumCupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      photos: photos ?? List.from(this.photos),
      floatPhase: floatPhase ?? this.floatPhase,
    );
  }
}

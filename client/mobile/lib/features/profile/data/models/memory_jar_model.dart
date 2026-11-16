import '../../../feed/data/models/post_item_model.dart';

class MemoryJarModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<PostItemModel> photos;

  MemoryJarModel({
    required this.id,
    required this.title,
    this.description = '',
    this.emoji = '🏺',
    List<PostItemModel>? photos,
  }) : photos = photos ?? [];

  int get count => photos.length;

  MemoryJarModel copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    List<PostItemModel>? photos,
  }) {
    return MemoryJarModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      photos: photos ?? List.from(this.photos),
    );
  }
}

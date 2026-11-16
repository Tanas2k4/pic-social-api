import '../../../feed/data/models/post_item_model.dart';

class SinglePhotoItem {
  final String id;
  final String photoUrl;
  final int photoIndex;
  final PostItemModel parentPost;

  const SinglePhotoItem({
    required this.id,
    required this.photoUrl,
    required this.photoIndex,
    required this.parentPost,
  });
}

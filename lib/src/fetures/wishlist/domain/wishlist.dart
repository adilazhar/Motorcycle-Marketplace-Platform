import 'package:equatable/equatable.dart';

class Wishlist extends Equatable {
  final List<String> listingIds;
  const Wishlist({
    required this.listingIds,
  });

  factory Wishlist.empty() {
    return Wishlist(listingIds: []);
  }

  Wishlist copyWith({
    List<String>? listingIds,
  }) {
    return Wishlist(
      listingIds: listingIds ?? this.listingIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listingIds': listingIds,
    };
  }

  factory Wishlist.fromMap(Map<String, dynamic> map) {
    return Wishlist(
      listingIds:
          map['listingIds'] != null ? List<String>.from(map['listingIds']) : [],
    );
  }

  @override
  String toString() => 'WishList(listingIds: $listingIds)';

  @override
  List<Object> get props => [listingIds];
}

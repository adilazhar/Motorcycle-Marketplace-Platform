import 'dart:io';

import 'package:bike_listing/src/fetures/listing/application/listing_service.dart';
import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:bike_listing/src/routing/app_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_listing_screen_controller.g.dart';

@riverpod
class AddListingScreenController extends _$AddListingScreenController {
  @override
  FutureOr<void> build() {}

  void createListing(Listing listing, List<File> images) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(listingServiceProvider).createListing(listing, images),
    );

    if (!state.hasError) {
      final goRouter = ref.read(appRouterProvider);
      goRouter.pop();
    }
  }

  Future<void> updateListing(
    Listing listing, {
    List<File>? newImages,
    List<String>? deletedImageUrls,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(listingServiceProvider).updateListing(
            listing,
            newImages: newImages,
            deletedImageUrls: deletedImageUrls,
          );
    });
    if (!state.hasError) {
      final goRouter = ref.read(appRouterProvider);
      goRouter.pop();
    }
  }
}

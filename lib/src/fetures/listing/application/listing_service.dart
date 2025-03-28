import 'package:bike_listing/src/fetures/authentication/data/auth_user_repository.dart';
import 'package:bike_listing/src/fetures/listing/data/firebase_storage_image_repository.dart';
import 'package:bike_listing/src/fetures/listing/data/firestore_listing_repository.dart';
import 'package:bike_listing/src/fetures/listing/data/image_repository.dart';
import 'package:bike_listing/src/fetures/listing/data/listing_repository.dart';
import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'listing_service.g.dart';

class ListingService {
  final Ref _ref;
  ListingService(this._ref);

  ListingRepository get _listingRepository =>
      _ref.read(listingRepositoryProvider);
  ImageRepository get _imageRepository => _ref.read(imageRepositoryProvider);
  AuthUserRepository get _authRepository =>
      _ref.read(authUserRepositoryProvider);

  /// Creates a new listing with images
  Future<void> createListing(Listing listing, List<File> images) async {
    try {
      // First upload images to get URLs
      final imageUrls = await _imageRepository.uploadImages(images);

      // TODO: Iterate through image urls and replace the ip with 127.0.0.1 in each of their address in Dev Mode

      // Create new listing with the image URLs
      final listingWithImages = listing.copyWith(
        imageUrls: imageUrls,
        userId: _authRepository.currentUser?.uid ?? '',
      );

      await _listingRepository.createListing(listingWithImages);
    } catch (e) {
      // If any error occurs after uploading images, clean them up
      if (listing.imageUrls.isNotEmpty) {
        await _imageRepository.deleteImages(listing.imageUrls);
      }
      rethrow;
    }
  }

  /// Deletes a listing and its associated images
  Future<void> deleteListing(Listing listing) async {
    try {
      // Delete the listing
      await _listingRepository.deleteListing(listing.id);

      // Delete associated images after listing is deleted
      if (listing.imageUrls.isNotEmpty) {
        await _imageRepository.deleteImages(listing.imageUrls);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing listing
  Future<void> updateListing(
    Listing listing, {
    List<File>? newImages,
    List<String>? deletedImageUrls,
  }) async {
    try {
      // Start with current image URLs
      List<String> finalImageUrls = [...listing.imageUrls];

      // Remove deleted images from the list if any
      if (deletedImageUrls != null && deletedImageUrls.isNotEmpty) {
        finalImageUrls.removeWhere((url) => deletedImageUrls.contains(url));

        // Delete the images from storage
        await _imageRepository.deleteImages(deletedImageUrls);
      }

      // Upload and add new images if provided
      if (newImages != null && newImages.isNotEmpty) {
        final newImageUrls = await _imageRepository.uploadImages(newImages);
        finalImageUrls.addAll(newImageUrls);
      }

      // Update listing with final image URLs
      final updatedListing = listing.copyWith(
        imageUrls: finalImageUrls,
      );

      // Update the listing in Firestore
      await _listingRepository.updateListing(updatedListing);
    } catch (e) {
      // If error occurs after uploading new images but before updating listing,
      // we should clean up any newly uploaded images
      if (newImages != null && newImages.isNotEmpty) {
        // We can't know exactly which images were newly uploaded at this point,
        // so we'll have to compare with the original listing
        final newlyUploadedUrls = listing.imageUrls
            .where((url) => !listing.imageUrls.contains(url))
            .toList();
        if (newlyUploadedUrls.isNotEmpty) {
          await _imageRepository.deleteImages(newlyUploadedUrls);
        }
      }
      rethrow;
    }
  }

  /// Removes specific images from a listing
  Future<void> removeImagesFromListing(
      String listingId, List<String> imageUrlsToRemove) async {
    try {
      final listing = await _listingRepository.getListingById(listingId);
      final remainingUrls = listing.imageUrls
          .where((url) => !imageUrlsToRemove.contains(url))
          .toList();

      // Update listing with remaining URLs
      final updatedListing = listing.copyWith(imageUrls: remainingUrls);
      await _listingRepository.updateListing(updatedListing);

      // Delete the removed images
      await _imageRepository.deleteImages(imageUrlsToRemove);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches all listings for the current user
  Future<List<Listing>> fetchListingsForCurrentUser() async {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }
    return _listingRepository.fetchListingsByUserId(userId);
  }

  /// Watches (streams) all listings for the current user
  Stream<List<Listing>> watchListingsForCurrentUser() {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }
    return _listingRepository.watchListingsByUserId(userId);
  }

  /// Fetches a single listing by ID
  Future<Listing> getListingById(String id) async {
    return _listingRepository.getListingById(id);
  }

  /// Watches (streams) a single listing by ID
  Stream<Listing> watchListingById(String id) {
    return _listingRepository.watchListingById(id);
  }

  /// Checks if the current user owns a listing
  bool isListingOwner(Listing listing) {
    final userId = _authRepository.currentUser?.uid;
    return userId != null && listing.userId == userId;
  }
}

@Riverpod(keepAlive: true)
ListingService listingService(Ref ref) {
  return ListingService(ref);
}

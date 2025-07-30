/* eslint-disable linebreak-style */
import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import * as functions from "firebase-functions/v1";
import { logger } from "firebase-functions";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { UserRecord } from "firebase-admin/auth";

// Initialize Firebase Admin SDK
initializeApp();
const db = getFirestore();
const storage = getStorage();

// Define an interface for our Listing data structure for type safety
interface Listing {
  userId: string;
  imageUrls: string[];
  // Add other listing properties if needed for logic
}

function getFilePathFromUrl(url: string): string | null {
  try {
    const decodedUrl = decodeURIComponent(url);
    // Extracts the path between '/o/' and '?'
    const pathRegex = /\/o\/(.*?)\?/;
    const matches = decodedUrl.match(pathRegex);
    if (matches && matches.length > 1) {
      return matches[1];
    }
    return null;
  } catch (error) {
    logger.warn("Could not parse URL:", url, error);
    return null;
  }
}

// ------------------------------------------------------------------
// ---- Function 1: Handle Deletion of a Single Listing          ----
// ------------------------------------------------------------------

export const onListingDeleted = onDocumentDeleted("listings/{listingId}", async (event) => {
  const snapshot = event.data;
  const { listingId } = event.params;

  if (!snapshot) {
    logger.log(`No data for deleted listing: ${listingId}. Skipping.`);
    return;
  }

  const listingData = snapshot.data() as Listing;
  logger.log(`Starting cleanup for deleted listing: ${listingId}`);

  // 1. Delete associated images from Firebase Storage
  const { imageUrls } = listingData;
  if (imageUrls && imageUrls.length > 0) {
    const deletionPromises = imageUrls.map((url) => {
      const filePath = getFilePathFromUrl(url);
      if (filePath) {
        logger.log(`Deleting image from Storage: ${filePath}`);
        return storage.bucket().file(filePath).delete().catch((err) => {
          logger.error(`Failed to delete image ${filePath}:`, err);
        });
      }
      return Promise.resolve();
    });
    await Promise.all(deletionPromises);
  }

  // 2. Remove listing from all users' wishlists
  const wishlistQuery = db.collection("wishlist").where("listingIds", "array-contains", listingId);
  const wishlistDocs = await wishlistQuery.get();

  if (wishlistDocs.empty) {
    logger.log(`Listing ${listingId} was not in any wishlists.`);
    logger.log(`Cleanup complete for listing ${listingId}.`);
    return;
  }

  const batch = db.batch();
  wishlistDocs.forEach((doc) => {
    logger.log(`Removing listing ${listingId} from wishlist of user ${doc.id}`);
    batch.update(doc.ref, { listingIds: FieldValue.arrayRemove(listingId) });
  });

  await batch.commit();
  logger.log(`Cleanup complete for listing ${listingId}.`);
});


// ------------------------------------------------------------------
// ---- Function 2: Handle Deletion of a User Account            ----
// ------------------------------------------------------------------
export const handleUserDeletion = functions.auth.user().onDelete(async (user: UserRecord) => {
  // In v1, the 'user' object is directly passed as the first argument, not within 'event.data'.
  // We've already destructured it for you in the parameter.
  const { uid } = user;

  logger.log(`Starting cleanup process for deleted user: ${uid}`);
  const batch = db.batch();

  // 1. & 2. Delete user doc and wishlist doc
  batch.delete(db.collection("users").doc(uid));
  batch.delete(db.collection("wishlist").doc(uid));

  // 3. Find and delete all listings by the user
  const listingsQuery = db.collection("listings").where("userId", "==", uid);
  const listingsSnapshot = await listingsQuery.get();

  const listingIdsToDelete: string[] = [];
  const imageDeletionPromises: Promise<any>[] = [];

  if (!listingsSnapshot.empty) {
    listingsSnapshot.forEach((doc) => {
      logger.log(`Scheduling deletion of listing: listings/${doc.id}`);
      batch.delete(doc.ref); // Add listing deletion to batch

      const listingData = doc.data() as Listing;
      listingIdsToDelete.push(doc.id);

      // Collect image URLs for deletion
      if (listingData.imageUrls?.length > 0) {
        listingData.imageUrls.forEach((url) => {
          const filePath = getFilePathFromUrl(url);
          if (filePath) {
            imageDeletionPromises.push(
              storage.bucket().file(filePath).delete().catch((err) => {
                logger.error(`Failed to delete image ${filePath}:`, err);
              })
            );
          }
        });
      }
    });
  }

  // 4. Remove deleted listings from other users' wishlists
  if (listingIdsToDelete.length > 0) {
    const wishlistQuery = db.collection("wishlist").where("listingIds", "array-contains-any", listingIdsToDelete);
    const wishlistsToClean = await wishlistQuery.get();

    wishlistsToClean.forEach((doc) => {
      // No need to clean the deleted user's own wishlist
      if (doc.id !== uid) {
        logger.log(`Cleaning listings from wishlist of user ${doc.id}`);
        batch.update(doc.ref, {
          listingIds: FieldValue.arrayRemove(...listingIdsToDelete),
        });
      }
    });
  }

  // 5. Commit all batched Firestore writes and wait for image deletions
  await Promise.all([batch.commit(), ...imageDeletionPromises]);

  logger.log(`Cleanup complete for user ${uid}.`);
  return null; // Important: Always return null for 1st gen background functions to indicate success
});

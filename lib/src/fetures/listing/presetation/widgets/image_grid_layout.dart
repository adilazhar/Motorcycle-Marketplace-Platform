import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageGridLayout extends StatelessWidget {
  final List<String> images;
  final String title;
  final double spacing;
  final Function(int) onImageTap;

  const ImageGridLayout({
    super.key,
    required this.images,
    required this.title,
    required this.onImageTap,
    this.spacing = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon((Icons.arrow_back_ios_new))),
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final tileHeight = (width * 9) / 16; // 16:9 aspect ratio

            return Column(
              children: _buildImageTiles(width, tileHeight),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildImageTiles(double width, double tileHeight) {
    List<Widget> tiles = [];
    int remainingImages = images.length;
    int currentIndex = 0;

    while (remainingImages > 0) {
      if (remainingImages == 1) {
        // Single image remaining
        tiles.add(_buildSingleImageTile(currentIndex, width, tileHeight));
        break;
      } else if (remainingImages == 2) {
        // Two images remaining
        tiles.add(_buildSingleImageTile(currentIndex, width, tileHeight));
        tiles.add(SizedBox(height: spacing));
        tiles.add(_buildSingleImageTile(currentIndex + 1, width, tileHeight));
        break;
      } else if (remainingImages == 3) {
        // Three images remaining
        tiles.add(_buildSingleImageTile(currentIndex, width, tileHeight));
        tiles.add(SizedBox(height: spacing));
        tiles.add(_buildDoubleImageTile(currentIndex + 1, width, tileHeight));
        break;
      } else if (remainingImages >= 4) {
        // Start of a new cycle (1+2+1+3 pattern)
        // First tile (single image)
        tiles.add(_buildSingleImageTile(currentIndex, width, tileHeight));
        tiles.add(SizedBox(height: spacing));

        // Second tile (double image)
        if (remainingImages >= 3) {
          tiles.add(_buildDoubleImageTile(currentIndex + 1, width, tileHeight));
          tiles.add(SizedBox(height: spacing));
        }

        // Third tile (single image)
        if (remainingImages >= 4) {
          tiles.add(_buildSingleImageTile(currentIndex + 3, width, tileHeight));
          tiles.add(SizedBox(height: spacing));
        }

        // Fourth tile (triple image)
        if (remainingImages >= 7) {
          tiles.add(_buildTripleImageTile(currentIndex + 4, width, tileHeight));
          tiles.add(SizedBox(height: spacing));
        } else if (remainingImages >= 6) {
          tiles.add(_buildDoubleImageTile(currentIndex + 4, width, tileHeight));
          break;
        } else if (remainingImages >= 5) {
          tiles.add(_buildSingleImageTile(currentIndex + 4, width, tileHeight));
          break;
        }

        currentIndex += 7;
        remainingImages -= 7;
        continue;
      }
      break;
    }
    return tiles;
  }

  Widget _buildSingleImageTile(int index, double width, double height) {
    return GestureDetector(
      onTap: () => onImageTap(index),
      child: CachedNetworkImage(
        imageUrl: '${images[index]}.png',
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildDoubleImageTile(int startIndex, double width, double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onImageTap(startIndex),
              child: CachedNetworkImage(
                imageUrl: '${images[startIndex]}.png',
                height: height,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error),
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: GestureDetector(
              onTap: () => onImageTap(startIndex + 1),
              child: CachedNetworkImage(
                imageUrl: '${images[startIndex + 1]}.png',
                height: height,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripleImageTile(int startIndex, double width, double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onImageTap(startIndex),
              child: CachedNetworkImage(
                imageUrl: '${images[startIndex]}.png',
                height: height,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error),
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onImageTap(startIndex + 1),
                    child: CachedNetworkImage(
                      imageUrl: '${images[startIndex + 1]}.png',
                      height: height,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onImageTap(startIndex + 2),
                    child: CachedNetworkImage(
                      imageUrl: '${images[startIndex + 2]}.png',
                      height: height,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

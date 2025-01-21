import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late int currentIndex;
  late PageController pageController;
  bool isZoomed = false;
  PhotoViewScaleStateController scaleStateController =
      PhotoViewScaleStateController();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: currentIndex);
    scaleStateController.addIgnorableListener(_handleScaleState);
  }

  @override
  void dispose() {
    pageController.dispose();
    scaleStateController.dispose();
    super.dispose();
  }

  void _handleScaleState() {
    setState(() {
      isZoomed = scaleStateController.scaleState != PhotoViewScaleState.initial;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${currentIndex + 1}/${widget.imageUrls.length}'),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: isZoomed
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage("${widget.imageUrls[index]}.png"),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            scaleStateController: scaleStateController,
            heroAttributes: PhotoViewHeroAttributes(tag: "image_$index"),
          );
        },
        itemCount: widget.imageUrls.length,
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        pageController: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

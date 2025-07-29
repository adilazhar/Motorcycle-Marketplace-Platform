import 'package:bike_listing/src/fetures/listing/presetation/widgets/feature_card.dart';
import 'package:bike_listing/src/fetures/listing/presetation/widgets/image_grid_layout.dart';
import 'package:bike_listing/src/fetures/listing/presetation/widgets/image_viewer_screen.dart';
import 'package:bike_listing/src/fetures/listing/presetation/widgets/owner_card.dart';
import 'package:bike_listing/src/fetures/wishlist/presentation/widgets/wishlist_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:latlong2/latlong.dart';

class BikeDetailScreen extends StatefulWidget {
  final Listing listing;
  const BikeDetailScreen(this.listing, {super.key});

  @override
  State<BikeDetailScreen> createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends State<BikeDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0);
  int _currentIndex = 0;
  final _controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scrollOffsetNotifier.value = _scrollController.offset;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<double>(
          valueListenable: _scrollOffsetNotifier,
          builder: (context, offset, child) {
            double opacity = (offset / (screenHeight / 3.5)).clamp(0, 1);
            return AppBar(
              elevation: opacity * 4,
              shadowColor: Colors.black.withOpacity(opacity * .7),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: Color.lerp(Colors.white, Colors.black, opacity)),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                WishlistButton(listingId: widget.listing.id),
              ],
              title: Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.listing.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      widget.listing.formattedPrice,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              backgroundColor:
                  Color.lerp(Colors.transparent, Colors.white, opacity),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ImageGridLayout(
                  images: widget.listing.imageUrls,
                  title: widget.listing.title,
                  onImageTap: (index) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewerScreen(
                          imageUrls: widget.listing.imageUrls,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                ),
              )),
              child: Stack(
                children: [
                  CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: widget.listing.imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return CachedNetworkImage(
                            width: double.infinity,
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.error),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Colors.black),
                          SizedBox(width: 5),
                          Text(
                            '${_currentIndex + 1}/${widget.listing.imageUrls.length}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price And Title Info Section
                  Text(
                    widget.listing.formattedPrice,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.listing.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                widget.listing.location,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(widget.listing.formattedDate),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),

                  // Details Section
                  const Text('Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 16,
                    ),
                    children: [
                      FeatureCard(
                        icon: Icons.motorcycle,
                        name: 'Brand',
                        value: widget.listing.formattedBrand,
                      ),
                      FeatureCard(
                        icon: Icons.calendar_today,
                        name: 'Year',
                        value: widget.listing.formattedYear,
                      ),
                      FeatureCard(
                        icon: Icons.local_offer,
                        name: 'Model',
                        value: widget.listing.model,
                      ),
                      FeatureCard(
                        icon: Icons.speed,
                        name: 'Mileage',
                        value: widget.listing.formattedMileage,
                      ),
                      FeatureCard(
                        icon: Icons.bolt,
                        name: 'Engine Capacity',
                        value: widget.listing.formattedEngineCapacity,
                      ),
                      FeatureCard(
                        icon: Icons.power_settings_new,
                        name: 'Ignition Type',
                        value: widget.listing.ignitionType,
                      ),
                      FeatureCard(
                        icon: Icons.new_releases,
                        name: 'Condition',
                        value: widget.listing.condition,
                      ),
                      FeatureCard(
                        icon: Icons.location_city,
                        name: 'Registration City',
                        value: widget.listing.formattedRegistrationCity,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),

                  // Description Section
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(widget.listing.description),

                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),

                  // Location Section
                  const Text('Location',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.listing.location,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.listing.adID,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                            widget.listing.coordinates.latitude,
                            widget.listing.coordinates.longitude),
                        initialZoom: 11,
                        onTap: (tapPosition, point) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InteractiveMapScreen(
                                coordinates: widget.listing.coordinates),
                          ),
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.adistudio.bike_listing',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(widget.listing.coordinates.latitude,
                                  widget.listing.coordinates.longitude),
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Seller Information Section
                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),

                  OwnerCard(widget.listing.userId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InteractiveMapScreen extends StatelessWidget {
  final GeoPoint coordinates;

  const InteractiveMapScreen({super.key, required this.coordinates});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
            initialCenter: LatLng(coordinates.latitude, coordinates.longitude)),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(coordinates.latitude, coordinates.longitude),
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

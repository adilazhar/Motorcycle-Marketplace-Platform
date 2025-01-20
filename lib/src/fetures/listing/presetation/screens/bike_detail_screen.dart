import 'package:bike_listing/src/fetures/listing/presetation/widgets/feature_card.dart';
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
  // final listing = Listing(
  //   id: '1',
  //   imageUrls: [
  //     'https://placehold.co/600x400/png',
  //     'https://placehold.co/600x400/png',
  //     'https://placehold.co/600x400/png',
  //     'https://placehold.co/600x400/png'
  //   ],
  //   title: 'Sample Bike Title',
  //   description: 'Description',
  //   price: 150000,
  //   year: 2020,
  //   mileage: 5000,
  //   brand: BikeBrand.honda,
  //   model: 'CD 70',
  //   engineCapacity: EngineCapacity.cc70,
  //   registrationCity: RegistrationCity.karachi,
  //   isSelfStart: true,
  //   isNew: false,
  //   coordinates: const GeoPoint(29.8018018018018, 70.6393658318525),
  //   location: 'Karachi, Pakistan',
  //   createdAt: DateTime.now(),
  //   userId: '1',
  // );
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0);
  int _currentIndex = 0;
  final _controller = CarouselSliderController();
  final List<String> imageUrls = List.generate(
    3,
    (index) => 'https://placehold.co/600x400/png?text=Brand+Model+${index + 1}',
  );

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
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Color.lerp(Colors.white, Colors.black, opacity)),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.favorite_border,
                      color: Color.lerp(Colors.white, Colors.black, opacity)),
                  onPressed: () {},
                ),
              ],
              title: Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.listing.title,
                        style: const TextStyle(fontSize: 16)),
                    Text(
                      widget.listing.formattedPrice,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              backgroundColor:
                  Color.lerp(Colors.transparent, Colors.blue[600], opacity),
              elevation: 0,
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
            Stack(
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
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    );
                  }).toList(),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          '${_currentIndex + 1}/${widget.listing.imageUrls.length}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price And Title Info Section
                  Text(widget.listing.formattedPrice),
                  Text(widget.listing.title),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined),
                      SizedBox(width: 5),
                      Text(widget.listing.location),
                      Spacer(),
                      Text(widget.listing.formattedDate),
                    ],
                  ),
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
                  const SizedBox(height: 24),

                  // Description Section
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(widget.listing.description),
                  const SizedBox(height: 24),

                  // Location Section
                  const Text('Location',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.listing.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c'],
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
                  // const SizedBox(height: 24),
                  // _buildSellerSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

//   Widget _buildSellerSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Seller Information',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 16),
//         Stack(
//           children: [
//             Column(
//               children: List.generate(
//                 2,
//                 (index) => Padding(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 24,
//                         backgroundColor: Colors.blue[600],
//                         child: const Text('S',
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                       const SizedBox(width: 16),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Seller Name',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             Text('Member since Jan 2024',
//                                 style: TextStyle(color: Colors.grey)),
//                             Text('View Profile',
//                                 style: TextStyle(color: Colors.blue)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum BikeBrand {
  honda,
  yamaha,
  suzuki,
  united,
  roadPrince,
  unique,
}

enum EngineCapacity {
  below50cc,
  cc70,
  cc100_149,
  cc150_199,
  cc200_299,
  cc300_499,
  cc500_700,
  cc701_999,
  cc1000,
  above1000cc,
}

// Todo: Also Add Unregisterd Option
enum RegistrationCity {
  abbottabad,
  attock,
  badin,
  bagh,
  bahawalpur,
  bannu,
  battagram,
  bhimber,
  burewala,
  chakwal,
  chaman,
  charsadda,
  chiniot,
  chitral,
  deraIsmailKhan,
  deraGhaziKhan,
  faisalabad,
  gilgit,
  gujarKhan,
  gujranwala,
  gujrat,
  gwadar,
  haripur,
  hyderabad,
  islamabad,
  jacobabad,
  jhang,
  jhelum,
  karachi,
  kasur,
  khairpur,
  khanewal,
  kharian,
  khuzdar,
  kohat,
  kotli,
  kotri,
  lahore,
  larkana,
  mandiBahauddin,
  mansehra,
  mardan,
  mirpur,
  mirpurKhas,
  multan,
  muzaffarabad,
  murree,
  nawabshah,
  nowshera,
  okara,
  peshawar,
  quetta,
  rahimYarKhan,
  rawalakot,
  rawalpindi,
  sadiqabad,
  sahiwal,
  sargodha,
  sheikhupura,
  sialkot,
  skardu,
  sukkur,
  swabi,
  swat,
  talagang,
  tank,
  taxila,
  thatta,
  timergara,
  tobaTekSingh,
  ziarat,
}

class BikeModels {
  static final Map<BikeBrand, List<String>> availableModels = {
    BikeBrand.honda: [
      'CD 70',
      'CD 70 Dream',
      'Pridor',
      'CG 125',
      'CG 125S',
      'CG 125S Gold',
      'CB 125F',
      'CB 150F',
      'CB 250F',
      'CBR 150R',
      'CBR 500R',
      'CBR 600RR',
      'CBR 1000RR',
      'Gold Wing',
    ],
    BikeBrand.yamaha: [
      'YBR 125',
      'YBR 125G',
      'YB 125Z',
      'YB 125Z-DX',
      'FZ-16',
      'Yamaha R6',
      'Yamaha R1',
    ],
    BikeBrand.suzuki: [
      'GD 110S',
      'GS 150',
      'GS 150SE',
      'GR 150',
      'Gixxer 150',
      'Inazuma Aegis',
      'Hayabusa',
      'Intruder',
    ],
    BikeBrand.united: [
      'US 70',
      'US 100',
      'US 125',
      'US 150',
      'US Scooty 100',
    ],
    BikeBrand.roadPrince: [
      'RP 70',
      'RP 70 Passion Plus',
      'RP 110',
      'RP 110 Jack Pot',
      'RP 125',
      'Wego 150',
      'Robinson 150',
      'RX3',
      'Bella',
      'Zeus',
      'Zeus XR',
    ],
    BikeBrand.unique: [
      'UD 70',
      'UD 100',
      'UD 125',
      'Crazer 150',
      'UD 150',
    ],
  };

  // Get models for a specific brand
  static List<String> getModelsForBrand(BikeBrand brand) {
    return availableModels[brand] ?? [];
  }
}

// Storing the year as int .
// The User selects the Year Through DateTime Picker:
// DateTime currentDate = DateTime.now();
// Get the year as int 👇
// int year = currentDate.year;
// Converting back to a DateTime object (if needed) 👇
// DateTime dateTime = DateTime(year);

// for isSelfStart value we will show the two fields to select from With
// label
// Ignition Type :
// 1.Self Start
// 2.Kick Start

// for isNew value we will show the two fields to select from With label
// condition :
// 1.New
// 2.Used

class Listing extends Equatable {
  final String id;
  final List<String> imageUrls;
  final String title;
  final String description;
  final int price;
  final int year;
  final int mileage;
  final BikeBrand brand;
  final String model;
  final EngineCapacity engineCapacity;
  final RegistrationCity registrationCity;
  final bool isSelfStart;
  final bool isNew;
  final GeoPoint coordinates;
  final String location;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String userId;

  const Listing({
    required this.id,
    required this.imageUrls,
    required this.title,
    required this.description,
    required this.price,
    required this.year,
    required this.mileage,
    required this.brand,
    required this.model,
    required this.engineCapacity,
    required this.registrationCity,
    required this.isSelfStart,
    required this.isNew,
    required this.coordinates,
    required this.location,
    this.createdAt,
    this.updatedAt,
    required this.userId,
  });

  /// Converts the Listing object to a map for creating a new Firestore document.
  /// Maybe Pass the user id through params of the method toMapForCreation(String uid) if needed
  /// Usage Example:
  /// Creating a new listing
  /// final listingData = listing.toMapForCreate();
  /// final docRef = await FirebaseFirestore.instance.collection('listings').add(listingData);
  Map<String, dynamic> toMapForCreation() {
    return {
      'imageUrls': imageUrls,
      'title': title,
      'description': description,
      'price': price,
      'year': year,
      'mileage': mileage,
      'brand': brand.name,
      'model': model,
      'engineCapacity': engineCapacity.name,
      'registrationCity': registrationCity.name,
      'isSelfStart': isSelfStart,
      'isNew': isNew,
      'coordinates': coordinates,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
    };
  }

  /// Converts the Listing object to a map for updating an existing Firestore document.
  /// Updating an existing listing
  /// await FirebaseFirestore.instance.collection('listings').doc(listing.id).update(listing.toMapForUpdate());
  Map<String, dynamic> toMapForUpdate() {
    return {
      'imageUrls': imageUrls,
      'title': title,
      'description': description,
      'price': price,
      'year': year,
      'mileage': mileage,
      'brand': brand.name,
      'model': model,
      'engineCapacity': engineCapacity.name,
      'registrationCity': registrationCity.name,
      'isSelfStart': isSelfStart,
      'isNew': isNew,
      'coordinates': coordinates,
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a [Listing] instance from a map retrieved from Firestore.
  /// Usage Example:
  /// DocumentSnapshot doc = await FirebaseFirestore.instance.collection('listings').doc('documentId').get();
  /// Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
  /// Listing listing = Listing.fromMap(doc.id, map);
  factory Listing.fromMap(String id, Map<String, dynamic> map) {
    return Listing(
      id: id,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      year: map['year'] ?? 0,
      mileage: map['mileage'] ?? 0,
      brand:
          _getEnum<BikeBrand>(map['brand'], BikeBrand.values, BikeBrand.honda),
      model: map['model'] ?? '',
      engineCapacity: _getEnum<EngineCapacity>(map['engineCapacity'],
          EngineCapacity.values, EngineCapacity.below50cc),
      registrationCity: _getEnum<RegistrationCity>(map['registrationCity'],
          RegistrationCity.values, RegistrationCity.abbottabad),
      isSelfStart: map['isSelfStart'] ?? false,
      isNew: map['isNew'] ?? false,
      coordinates: map['coordinates'] ?? GeoPoint(0.0, 0.0),
      location: map['location'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      userId: map['userId'] ?? '',
    );
  }

  static T _getEnum<T extends Enum>(
      dynamic value, List<T> values, T defaultValue) {
    if (value == null) return defaultValue;
    final String stringValue = value.toString();
    return values.firstWhere((e) => e.name == stringValue,
        orElse: () => defaultValue);
  }

  @override
  String toString() {
    return 'Listing(id: $id, imageUrls: $imageUrls, title: $title, description: $description, price: $price, year: $year, mileage: $mileage, brand: $brand, model: $model, engineCapacity: $engineCapacity, registrationCity: $registrationCity, isSelfStart: $isSelfStart, isNew: $isNew, coordinates: lat(${coordinates.latitude})long(${coordinates.longitude}), location: $location, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId)';
  }

  @override
  List<Object?> get props {
    return [
      id,
      imageUrls,
      title,
      description,
      price,
      year,
      mileage,
      brand,
      model,
      engineCapacity,
      registrationCity,
      isSelfStart,
      isNew,
      coordinates,
      location,
      createdAt,
      updatedAt,
      userId,
    ];
  }

  Listing copyWith({
    String? id,
    List<String>? imageUrls,
    String? title,
    String? description,
    int? price,
    int? year,
    int? mileage,
    BikeBrand? brand,
    String? model,
    EngineCapacity? engineCapacity,
    RegistrationCity? registrationCity,
    bool? isSelfStart,
    bool? isNew,
    GeoPoint? coordinates,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Listing(
      id: id ?? this.id,
      imageUrls: imageUrls ?? this.imageUrls,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      year: year ?? this.year,
      mileage: mileage ?? this.mileage,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      engineCapacity: engineCapacity ?? this.engineCapacity,
      registrationCity: registrationCity ?? this.registrationCity,
      isSelfStart: isSelfStart ?? this.isSelfStart,
      isNew: isNew ?? this.isNew,
      coordinates: coordinates ?? this.coordinates,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}

String formatEnum(Enum enumValue) {
  final name = enumValue.name;
  // Split on capital letters but keep them
  final spaced = name
      .replaceAllMapped(RegExp('([A-Z])'), (match) => ' ${match.group(1)}')
      .trim();

  // Only capitalize first word, keep others as they are
  final words = spaced.split(' ');
  if (words.isEmpty) return '';

  words[0] = words[0].capitalize();
  return words.join(' ');
}

String formatEngineSize(Enum enumValue) {
  final name = enumValue.name;

  // Handle 'below' case
  if (name.startsWith('below')) {
    final number = RegExp(r'\d+').firstMatch(name)?.group(0) ?? '';
    return 'Below ${number}cc';
  }

  // Handle 'above' case
  if (name.startsWith('above')) {
    final number = RegExp(r'\d+').firstMatch(name)?.group(0) ?? '';
    return 'Above ${number}cc';
  }

  // Handle range case (e.g., cc100_149)
  if (name.contains('_')) {
    final numbers = name
        .replaceAll('cc', '')
        .split('_')
        .map((n) => n.replaceAll(RegExp(r'[^0-9]'), ''))
        .toList();
    return '${numbers[0]}cc-${numbers[1]}cc';
  }

  // Handle simple cc cases (e.g., cc70, cc1000)
  if (name.startsWith('cc')) {
    final number = name.replaceAll('cc', '');
    return '${number}cc';
  }

  return name;
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}

import 'dart:io';
import 'dart:ui';

import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:bike_listing/src/fetures/listing/presetation/controller/add_listing_screen_controller.dart';
import 'package:bike_listing/src/utils/async_value_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  final _formKey = GlobalKey<FormBuilderState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  BikeBrand? _selectedBrand;
  String _selectedModel = '';
  int currentYear = DateTime.now().year;
  EngineCapacity? _selectedEngineCapacity;
  RegistrationCity? _selectedRegistrationCity;
  GeoPoint? _coordinates;
  String _location = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController(text: 'Tap to Get Location');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveListing() {
    if (_formKey.currentState?.validate() ?? false) {
      // First check if images are selected
      if (selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one image')),
        );
        return;
      }

      // Get all form values
      _formKey.currentState?.save();
      final formData = _formKey.currentState?.value;

      if (formData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting form data')),
        );
        return;
      }

      // Validate location
      if (_coordinates == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select your location')),
        );
        return;
      }

      final Listing listing = Listing(
        id: '',
        imageUrls: [],
        brand: _selectedBrand!,
        model: _selectedModel,
        year: int.parse(formData['year']),
        engineCapacity: _selectedEngineCapacity!,
        mileage: int.parse(formData['mileage']),
        isSelfStart: formData['isSelfStart'],
        isNew: formData['condition'],
        registrationCity: _selectedRegistrationCity!,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _location,
        coordinates: GeoPoint(_coordinates!.latitude, _coordinates!.longitude),
        price: int.parse(formData['price']),
        userId: '',
      );

      ref
          .read(addListingScreenControllerProvider.notifier)
          .createListing(listing, selectedImages);
    } else {
      // Form validation failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields correctly')),
      );
    }
  }

  Future<void> _selectEnumValue<T extends Enum>({
    required String title,
    required List<T> options,
    required Function(T) onSelected,
    bool isEngineCapacity = false,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView.separated(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return ListTile(
                title: Text(isEngineCapacity
                    ? formatEngineCapacity(option)
                    : formatEnum(option)),
                onTap: () {
                  onSelected(option);
                  Navigator.pop(context);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
          ),
        );
      },
    );
  }

  Future<void> _selectModel({
    required List<String> models,
    required Function(String) onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Choose Model'),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView.separated(
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return ListTile(
                title: Text(model),
                onTap: () {
                  onSelected(model);
                  Navigator.pop(context);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
          ),
        );
      },
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFile = await _picker.pickMultiImage();
    final finalImages = pickedFile
        .map(
          (xFile) => File(xFile.path),
        )
        .toList();
    if (pickedFile.isNotEmpty) {
      setState(() {
        selectedImages.addAll(finalImages);
      });
    }
  }

  Future<void> _showEditOptions(int index) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove image'),
                onTap: () {
                  setState(() {
                    selectedImages.removeAt(index);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Show loading state
      _locationController.text = 'Getting location...';

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationController.text = 'Tap to Get Location';
          throw Exception('Location permission denied');
        }
      }

      // Get location with lower accuracy
      final position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(accuracy: LocationAccuracy.best),
      );

      _coordinates = GeoPoint(position.latitude, position.longitude);

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Build address components
        List<String> addressParts = [];

        if (place.subLocality?.isNotEmpty == true) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality?.isNotEmpty == true) {
          addressParts.add(place.locality!);
        }
        if (place.subAdministrativeArea?.isNotEmpty == true &&
            place.subAdministrativeArea != place.locality) {
          addressParts.add(place.subAdministrativeArea!);
        }
        if (place.administrativeArea?.isNotEmpty == true) {
          addressParts.add(place.administrativeArea!);
        }

        // Filter out any plus codes (they usually contain '+' character)
        addressParts =
            addressParts.where((part) => !part.contains('+')).toList();

        // Join with commas
        final address = addressParts.join(', ');

        setState(() {
          _location = address;
          _locationController.text = address;
        });
      }
    } catch (e) {
      _locationController.text = 'Tap to Get Location';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Widget proxyDecor(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double scale = lerpDouble(1, 1.02, animValue)!;
        return Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox(
              height: 60,
              width: 60,
              child: Image.file(
                selectedImages[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      addListingScreenControllerProvider,
      (_, state) {
        state.showAlertDialogOnError(context);
      },
    );

    final state = ref.watch(addListingScreenControllerProvider);

    return PopScope(
      canPop: !state.isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed:
                  state.isLoading ? null : () => Navigator.of(context).pop(),
              icon: Icon(CupertinoIcons.xmark)),
          title: Text('Ad Details'),
        ),
        body: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            enabled: !state.isLoading,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images Picker
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: selectedImages.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(Icons.photo_library, size: 48.0),
                                ElevatedButton(
                                  onPressed: _pickImages,
                                  child: Text('Add Images'),
                                ),
                                SizedBox(
                                  height: 8.0,
                                  width: double.infinity,
                                ),
                                Text('Select All the images of the bike'),
                              ],
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 1.0),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: _pickImages,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SizedBox(
                                        height: 60,
                                        child: ReorderableListView(
                                          scrollDirection: Axis.horizontal,
                                          proxyDecorator: proxyDecor,
                                          onReorder: (oldIndex, newIndex) {
                                            setState(() {
                                              if (oldIndex < newIndex) {
                                                newIndex -= 1;
                                              }
                                              final File item = selectedImages
                                                  .removeAt(oldIndex);
                                              selectedImages.insert(
                                                  newIndex, item);
                                            });
                                          },
                                          children: selectedImages
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            File image = entry.value;
                                            return Padding(
                                              key: ValueKey(image
                                                  .path), // Unique key for each item
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _showEditOptions(index),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: SizedBox(
                                                    height: 60,
                                                    width: 60,
                                                    child: Image.file(
                                                      image,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                    'Hold and drag images to reorder. Tap to edit.'),
                              ],
                            ),
                          ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  // Brand Field
                  Text('Brand *'),
                  FormBuilderField(
                    name: 'brand',
                    validator: FormBuilderValidators.required(
                        errorText: 'Please select a brand'),
                    builder: (field) {
                      return GestureDetector(
                        onTap: () {
                          _selectEnumValue(
                            title: 'Choose Brand',
                            options: BikeBrand.values,
                            onSelected: (BikeBrand brand) {
                              setState(() {
                                _selectedBrand = brand;
                                _selectedModel = '';
                              });
                              _formKey.currentState?.fields['brand']
                                  ?.didChange(brand.name);
                            },
                          );
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedBrand != null
                                  ? formatEnum(_selectedBrand!)
                                  : 'Choose'),
                              Icon(Icons.keyboard_arrow_right_rounded),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  // Model Field
                  Text('Model *'),
                  FormBuilderField(
                    name: 'model',
                    validator: FormBuilderValidators.required(
                        errorText: 'Please select a model'),
                    builder: (field) {
                      return GestureDetector(
                        onTap: () {
                          if (_selectedBrand == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Please select a brand first')),
                            );
                            return;
                          }
                          _selectModel(
                            models:
                                BikeModels.getModelsForBrand(_selectedBrand!),
                            onSelected: (String model) {
                              setState(() {
                                _selectedModel = model;
                              });
                              _formKey.currentState?.fields['model']
                                  ?.didChange(model);
                            },
                          );
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedModel.isNotEmpty
                                  ? _selectedModel
                                  : 'Choose Model'),
                              Icon(Icons.keyboard_arrow_right_rounded),
                            ],
                          ),
                        ),
                      );
                    },
                    enabled: _selectedBrand != null,
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  // Year Field
                  Text('Year *'),
                  FormBuilderTextField(
                    name: 'year',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Year is required'),
                      FormBuilderValidators.integer(
                          errorText: 'Please enter a valid year'),
                      FormBuilderValidators.min(1900,
                          errorText: 'Year must be 1900 or later'),
                      FormBuilderValidators.max(currentYear + 1,
                          errorText: 'Invalid future year'),
                      (value) {
                        if (value == null || value.isEmpty) return null;
                        if (value.length != 4) return 'Year must be 4 digits';
                        return null;
                      },
                    ]),
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  // Engine Capacity Field
                  Text('Engine Capacity *'),
                  FormBuilderField(
                    name: 'engineCapacity',
                    validator: FormBuilderValidators.required(
                        errorText: 'Please select engine capacity'),
                    builder: (field) {
                      return GestureDetector(
                        onTap: () {
                          _selectEnumValue(
                            title: 'Choose Engine Capacity',
                            options: EngineCapacity.values,
                            isEngineCapacity: true,
                            onSelected: (EngineCapacity capacity) {
                              setState(() {
                                _selectedEngineCapacity = capacity;
                              });
                              _formKey.currentState?.fields['engineCapacity']
                                  ?.didChange(capacity.name);
                            },
                          );
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedEngineCapacity != null
                                  ? formatEngineCapacity(
                                      _selectedEngineCapacity!)
                                  : 'Choose'),
                              Icon(Icons.keyboard_arrow_right_rounded),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  // Mileage
                  Text('KM\'s Driven &'),
                  FormBuilderTextField(
                    name: 'mileage',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Mileage is required'),
                      FormBuilderValidators.numeric(
                          errorText: 'Please enter a valid number'),
                      FormBuilderValidators.min(0,
                          errorText: 'Mileage cannot be negative'),
                      FormBuilderValidators.max(999999,
                          errorText: 'Mileage seems too high'),
                    ]),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  // Ignition Type Field
                  Text('Ignition Type *'),
                  FormBuilderChoiceChip(
                    name: 'isSelfStart',
                    showCheckmark: false,
                    spacing: 10,
                    validator: FormBuilderValidators.required(
                        errorText: 'Please select ignition type'),
                    decoration: InputDecoration.collapsed(
                      hintText: '',
                    ),
                    options: [
                      FormBuilderChipOption(
                        value: true,
                        child: Text('Self Start'),
                      ),
                      FormBuilderChipOption(
                        value: false,
                        child: Text('Kick Start'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  // Condition Field
                  Text('Condition *'),
                  FormBuilderChoiceChip(
                    name: 'condition',
                    showCheckmark: false,
                    spacing: 10,
                    decoration: InputDecoration.collapsed(hintText: ''),
                    options: [
                      FormBuilderChipOption(
                        value: true,
                        child: Text('New'),
                      ),
                      FormBuilderChipOption(
                        value: false,
                        child: Text('Used'),
                      ),
                    ],
                    validator: FormBuilderValidators.required(
                        errorText: 'Please select condition'),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  // Registration City Field
                  Text('Registration City'),
                  FormBuilderField(
                    name: 'registrationCity',
                    validator: FormBuilderValidators.required(
                        errorText: 'Please select registration city'),
                    builder: (field) {
                      return GestureDetector(
                        onTap: () {
                          _selectEnumValue(
                            title: 'Choose Registration City',
                            options: RegistrationCity.values,
                            onSelected: (RegistrationCity city) {
                              setState(() {
                                _selectedRegistrationCity = city;
                              });
                              _formKey.currentState?.fields['registrationCity']
                                  ?.didChange(city.name);
                            },
                          );
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedRegistrationCity != null
                                  ? formatEnum(_selectedRegistrationCity!)
                                  : 'Choose'),
                              Icon(Icons.keyboard_arrow_right_rounded),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Divider(),

                  SizedBox(
                    height: 20,
                  ),

                  // Title Field
                  Text('Ad Title *'),
                  FormBuilderTextField(
                    controller: _titleController,
                    name: 'title',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Title is required'),
                      FormBuilderValidators.minLength(10,
                          errorText: 'Title must be at least 10 characters'),
                      FormBuilderValidators.maxLength(100,
                          errorText: 'Title cannot exceed 100 characters'),
                    ]),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  // Description Field
                  Text('Description *'),
                  FormBuilderTextField(
                    controller: _descriptionController,
                    name: 'description',
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        hintText: 'Describe the item you are selling'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Description is required'),
                      FormBuilderValidators.minLength(30,
                          errorText:
                              'Description must be at least 30 characters'),
                      FormBuilderValidators.maxLength(1000,
                          errorText:
                              'Description cannot exceed 1000 characters'),
                    ]),
                    maxLines: 3,
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Text('Location *'),
                  FormBuilderTextField(
                    controller: _locationController,
                    name: 'location',

                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Location is required'),
                      (value) {
                        if (value == 'Tap to Get Location') {
                          return 'Please select your location';
                        }
                        return null;
                      },
                    ]),
                    readOnly: true,
                    maxLines: null, // Allows the field to expand
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: _locationController.text == 'Tap to Get Location'
                          ? Colors.grey
                          : Colors.black,
                    ),
                    onTap: _locationController.text == 'Tap to Get Location'
                        ? _getCurrentLocation
                        : null,
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Divider(),

                  SizedBox(
                    height: 20,
                  ),

                  // Price Field
                  Text('Price *'),
                  FormBuilderTextField(
                    name: 'price',
                    decoration: InputDecoration(
                      prefixText: 'Rs-',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Price is required'),
                      FormBuilderValidators.numeric(
                          errorText: 'Please enter a valid number'),
                      FormBuilderValidators.min(3000,
                          errorText: 'Price must be greater than 3000'),
                      FormBuilderValidators.max(1000000,
                          errorText: 'Price seems too high'),
                      (value) {
                        if (value != null && value.toString().contains('.')) {
                          return 'Please enter a whole number';
                        }
                        return null;
                      },
                    ]),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
        persistentFooterButtons: [
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: state.isLoading ? null : _saveListing,
                  child: Text('Submit')))
        ],
      ),
    );
  }
}

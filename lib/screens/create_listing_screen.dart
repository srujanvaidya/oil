import 'package:fasalmitra/services/listing_service.dart';
import 'package:flutter/material.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  static const String routeName = '/create-listing';

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedCategory;
  DateTime? _selectedDate;
  String? _certificatePath;
  String? _imagePath;
  String? _location;
  bool _isLoading = false;

  final List<String> _categories = [
    'Seeds',
    'Fertilizers',
    'Pesticides',
    'Machinery',
    'Vegetables',
    'Fruits',
    'Grains',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Future<void> _pickFile(bool isCertificate) async {
    // Mock file picking
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCertificate ? 'Pick Certificate' : 'Pick Product Image'),
        content: const Text('This is a mock file picker.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (isCertificate) {
                  _certificatePath = 'mock_certificate.pdf';
                } else {
                  _imagePath = 'mock_image.jpg';
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Select Mock File'),
          ),
        ],
      ),
    );
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
    });
    // Mock location fetching
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _location = '12.9716° N, 77.5946° E (Bangalore)';
      _isLoading = false;
    });
  }

  Future<void> _submitListing() async {
    if (_formKey.currentState!.validate()) {
      if (_certificatePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a certificate')),
        );
        return;
      }
      if (_imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a product image')),
        );
        return;
      }
      if (_location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please get your location')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await ListingService.instance.createListing(
          title: _nameController.text,
          category: _selectedCategory!,
          quantity: double.parse(_quantityController.text),
          price: double.parse(_priceController.text),
          processingDate: _selectedDate!,
          certificatePath: _certificatePath!,
          imagePath: _imagePath!,
          location: _location!,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List New Product')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Processing Date (mm/dd/yyyy)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price per kg (INR)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Certificate (PDF)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _pickFile(true),
                          child: const Text('Choose File'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _certificatePath ?? 'No file chosen',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Product Image',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _pickFile(false),
                          child: const Text('Choose File'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _imagePath ?? 'No file chosen',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Location',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _getLocation,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Get Location'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _location ?? 'Location not fetched',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitListing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Create Listing'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

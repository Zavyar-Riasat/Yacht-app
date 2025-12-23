import 'package:flutter/material.dart';
import '../models/yacht_model.dart';
import '../services/yacht_service.dart';

class EditYachtPage extends StatefulWidget {
  final Yacht yacht;
  const EditYachtPage({Key? key, required this.yacht}) : super(key: key);

  @override
  State<EditYachtPage> createState() => _EditYachtPageState();
}

class _EditYachtPageState extends State<EditYachtPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController priceController;
  late TextEditingController imageController;
  late TextEditingController descController;
  late TextEditingController capacityController;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.yacht.name);
    locationController =
        TextEditingController(text: widget.yacht.location);
    priceController =
        TextEditingController(text: widget.yacht.pricePerDay.toString());
    imageController =
        TextEditingController(text: widget.yacht.imageUrl);
    descController =
        TextEditingController(text: widget.yacht.description);
    capacityController =
        TextEditingController(text: widget.yacht.capacity.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    priceController.dispose();
    imageController.dispose();
    descController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Yacht"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter name" : null,
              ),

              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter location" : null,
              ),

              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price Per Day"),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter price" : null,
              ),

              TextFormField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: "Capacity"),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter capacity" : null,
              ),

              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "Image URL"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter image URL" : null,
              ),

              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter description" : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await YachtService.updateYacht(
                      Yacht(
                        id: widget.yacht.id,
                        name: nameController.text,
                        location: locationController.text,
                        pricePerDay:
                            double.tryParse(priceController.text) ?? 0.0,
                        capacity:
                            int.tryParse(capacityController.text) ??
                                widget.yacht.capacity,
                        imageUrl: imageController.text,
                        description: descController.text,
                        available: widget.yacht.available,
                      ),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text("Update Yacht"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

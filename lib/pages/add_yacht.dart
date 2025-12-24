import 'package:flutter/material.dart';
import '../models/yacht_model.dart';
import '../services/yacht_service.dart';

class AddYachtPage extends StatefulWidget {
  const AddYachtPage({super.key});

  @override
  State<AddYachtPage> createState() => _AddYachtPageState();
}

class _AddYachtPageState extends State<AddYachtPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final capacityController = TextEditingController();
  final imageController = TextEditingController();
  final descController = TextEditingController(); // added

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Yacht"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Type"),
                validator: (val) => val!.isEmpty ? "Enter type" : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (val) => val!.isEmpty ? "Enter location" : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Enter price" : null,
              ),
              TextFormField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: "Capacity"),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Enter capacity" : null,
              ),
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "Image URL"),
                validator: (val) => val!.isEmpty ? "Enter image URL" : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (val) => val!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await YachtService.addYacht(Yacht(
                      id: "yacht_${DateTime.now().millisecondsSinceEpoch}",
                      name: nameController.text,
                      location: locationController.text,
                      pricePerDay: double.tryParse(priceController.text) ?? 0.0,
                      capacity: int.tryParse(capacityController.text) ?? 0,
                      imageUrl: imageController.text,
                      description: descController.text,
                      available: true,
                    ));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text("Add Yacht"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

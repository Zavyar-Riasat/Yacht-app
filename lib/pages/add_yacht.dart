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
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 768;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Yacht"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 25 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isLargeScreen ? 700 : 500),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildTextField("Name", nameController),
                            const SizedBox(height: 15),
                            _buildTextField("Type", typeController),
                            const SizedBox(height: 15),
                            _buildTextField("Location", locationController),
                            const SizedBox(height: 15),
                            _buildTextField("Price", priceController,
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 15),
                            _buildTextField("Capacity", capacityController,
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 15),
                            _buildTextField("Image URL", imageController),
                            const SizedBox(height: 15),
                            _buildTextField("Description", descController,
                                maxLines: 3),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final navigator = Navigator.of(context);
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
                            if (!mounted) return;
                            navigator.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Add Yacht",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (val) => val!.isEmpty ? "Enter $label" : null,
    );
  }
}
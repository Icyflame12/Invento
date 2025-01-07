import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../model/dbfunctions.dart';
import '../../model/product_user_model.dart';

class UpdateProductScreen extends StatefulWidget {
  final Productmodel product;
  final VoidCallback onProductUpdated;
  final int productId;

  const UpdateProductScreen({
    super.key,
    required this.product,
    required this.onProductUpdated,
    required this.productId,
  });

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();

  String _selectedCategory = '';
  File? _image;

  final List<String> _categories = ['Nike', 'Adidas', 'Puma', 'Bata'];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _productNameController.text = widget.product.productName;
    _productQuantityController.text = widget.product.productQuantity.toString();
    _productPriceController.text = widget.product.productPrice.toString();
    _productDescriptionController.text = widget.product.description;
    _selectedCategory = widget.product.category;
    if (File(widget.product.imagePath).existsSync()) {
      _image = File(widget.product.imagePath);
    }
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No image selected.')));
    }
  }

  void _selectCategory() {
    final TextEditingController newCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select or Add Category'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ..._categories.map((category) {
                  return ListTile(
                    title: Text(category),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }),
                TextField(
                  controller: newCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'New Category',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newCategory = newCategoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  setState(() {
                    _categories.add(newCategory);
                    _selectedCategory = newCategory;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add Category'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProduct() async {
    if (_productNameController.text.isEmpty ||
        _productQuantityController.text.isEmpty ||
        _productPriceController.text.isEmpty ||
        _productDescriptionController.text.isEmpty ||
        _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }

    final int? quantity = int.tryParse(_productQuantityController.text);
    final double? price = double.tryParse(_productPriceController.text);

    if (quantity == null || price == null || quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid quantity or price.')));
      return;
    }

    final updatedProduct = Productmodel(
      id: widget.product.id,
      productName: _productNameController.text.trim(),
      productQuantity: quantity,
      productPrice: price,
      category: _selectedCategory,
      imagePath: _image?.path ?? widget.product.imagePath,
      description: _productDescriptionController.text.trim(),
    );

    try {
      await updateProduct(widget.product.id, updatedProduct);
      widget.onProductUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error updating product. Please try again.')));
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _getImage,
              child: Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.canvasColor, // Adapt to theme
                ),
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : const Icon(Icons.add_a_photo),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('Product Name', _productNameController),
            const SizedBox(height: 16),
            _buildTextField('Quantity', _productQuantityController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('Price', _productPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            _buildTextField('Description', _productDescriptionController),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Category'),
              subtitle: Text(_selectedCategory.isEmpty
                  ? 'Select Category'
                  : _selectedCategory),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _selectCategory,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _updateProduct,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondaryHeaderColor,
                textStyle: TextStyle(color: const Color.fromARGB(255, 7, 7, 7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart'; // ✅ CORREGIDO
import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../services/permission_handler.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final l10n = AppLocalizations.of(context)!; // ✅ AGREGADO

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.products), // ✅ TRADUCIDO
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: productProvider.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 80.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.noProducts, // ✅ TRADUCIDO
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return ProductCard(product: product);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add),
        label: Text(l10n.addProduct), // ✅ TRADUCIDO
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddProductDialog(),
    );
  }
}

class AddProductDialog extends StatefulWidget {
  final Product? product;

  const AddProductDialog({super.key, this.product});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockController;
  String _category = 'food'; // ✅ Usar claves en vez de texto
  String? _imagePath;

  final List<String> _categories = ['food', 'drinks', 'desserts', 'others']; // ✅ Claves

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _category = widget.product?.category ?? 'food';
    _imagePath = widget.product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectImage), // ✅ TRADUCIDO
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2196F3)),
              title: Text(l10n.gallery), // ✅ TRADUCIDO
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: Text(l10n.camera), // ✅ TRADUCIDO
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    bool hasPermission = false;

    if (source == ImageSource.gallery) {
      hasPermission = await AppPermissionHandler.requestGalleryPermission(context);
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ ${l10n.galleryPermissionNeeded}'), // ✅ TRADUCIDO
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    } else if (source == ImageSource.camera) {
      hasPermission = await AppPermissionHandler.requestCameraPermission(context);
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ ${l10n.cameraPermissionNeeded}'), // ✅ TRADUCIDO
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${l10n.imageSelected}'), // ✅ TRADUCIDO
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error al seleccionar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.errorSelectingImage}: $e'), // ✅ TRADUCIDO
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getCategoryTranslation(String categoryKey, AppLocalizations l10n) {
    switch (categoryKey) {
      case 'food':
        return l10n.food;
      case 'drinks':
        return l10n.drinks;
      case 'desserts':
        return l10n.desserts;
      case 'others':
        return l10n.others;
      default:
        return categoryKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(context)!; // ✅ AGREGADO
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        constraints: BoxConstraints(maxHeight: 600.h),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.product == null
                          ? l10n.newProduct // ✅ TRADUCIDO
                          : l10n.editProduct, // ✅ TRADUCIDO
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Image Picker
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _imagePath != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: _showImageSourceDialog,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 40.sp, color: Colors.grey),
                              SizedBox(height: 8.h),
                              Text(l10n.addImage, // ✅ TRADUCIDO
                                  style: TextStyle(color: Colors.grey[600])),
                              SizedBox(height: 4.h),
                              Text(l10n.tapToSelect, // ✅ TRADUCIDO
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12.sp,
                                  )),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.productName, // ✅ TRADUCIDO
                    hintText: l10n.productNameHint, // ✅ TRADUCIDO
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? l10n.requiredField : null, // ✅ TRADUCIDO
                ),
                SizedBox(height: 16.h),

                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: l10n.price, // ✅ TRADUCIDO
                    hintText: '0',
                    prefixText: '${settingsProvider.currencySymbol} ', // ✅ DINÁMICO
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? l10n.requiredField : null, // ✅ TRADUCIDO
                ),
                SizedBox(height: 16.h),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description, // ✅ TRADUCIDO
                    hintText: l10n.descriptionHint, // ✅ TRADUCIDO
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),

                // Category
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: l10n.category, // ✅ TRADUCIDO
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(_getCategoryTranslation(cat, l10n)), // ✅ TRADUCIDO
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
                SizedBox(height: 16.h),

                // Stock
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: l10n.stock, // ✅ TRADUCIDO (ahora dice "Cantidad")
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? l10n.requiredField : null, // ✅ TRADUCIDO
                ),
                SizedBox(height: 24.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(l10n.cancel), // ✅ TRADUCIDO
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(l10n.save), // ✅ TRADUCIDO
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        category: _category,
        stock: int.parse(_stockController.text),
        imagePath: _imagePath ?? '',
      );

      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      if (widget.product == null) {
        productProvider.addProduct(product);
      } else {
        productProvider.updateProduct(product);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productSavedSuccess)), // ✅ TRADUCIDO
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart'; // ✅ CORREGIDO
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/settings_provider.dart'; // ✅ AGREGADO
import '../models/order.dart';
import 'dart:io';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
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
    final l10n = AppLocalizations.of(context)!; // ✅ AGREGADO
    final settingsProvider = Provider.of<SettingsProvider>(context); // ✅ AGREGADO
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final filteredProducts = productProvider.products.where((product) {
      return _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createOrder, style: TextStyle(fontSize: 18.sp)), // ✅ TRADUCIDO
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          if (orderProvider.currentOrderItems.isNotEmpty) ...[
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.shopping_cart, size: 24.sp),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.h,
                      ),
                      child: Text(
                        '${orderProvider.currentOrderItems.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () => _showCurrentOrderSheet(context),
              tooltip: l10n.viewCart, // ✅ TRADUCIDO
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep, size: 24.sp),
              onPressed: () => _confirmClearOrder(context),
              tooltip: l10n.clearCart, // ✅ TRADUCIDO
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchProducts, // ✅ TRADUCIDO
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, size: 20.sp),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),

          // Product List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.shopping_cart_outlined,
                          size: 80.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _searchQuery.isNotEmpty
                              ? _getNoProductsFoundText(l10n) // ✅ TRADUCIDO
                              : l10n.noProducts, // ✅ TRADUCIDO
                          style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: Icon(Icons.clear, size: 18.sp),
                            label: Text(_getClearSearchText(l10n), // ✅ TRADUCIDO
                                style: TextStyle(fontSize: 14.sp)),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final inCart = orderProvider.currentOrderItems
                          .any((item) => item.productId == product.id);

                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        color: inCart ? Colors.blue[50] : Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12.w),
                          leading: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: product.imagePath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.file(
                                      File(product.imagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.broken_image,
                                            size: 30.sp, color: Colors.grey);
                                      },
                                    ),
                                  )
                                : Icon(Icons.inventory_2,
                                    size: 30.sp, color: Colors.grey),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (inCart)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    _getInCartText(l10n), // ✅ TRADUCIDO
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                settingsProvider.formatPrice(product.price), // ✅ MONEDA DINÁMICA
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _getCategoryTranslation(product.category, l10n), // ✅ TRADUCIDO
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '${l10n.stock}: ${product.stock}', // ✅ TRADUCIDO
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: product.stock <= 5
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontWeight: product.stock <= 5
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: product.stock > 0
                                ? () {
                                    final orderProvider = Provider.of<OrderProvider>(
                                        context,
                                        listen: false);
                                    
                                    final added = orderProvider.addItemToCurrentOrder(
                                      OrderItem(
                                        productId: product.id,
                                        productName: product.name,
                                        price: product.price,
                                        quantity: 1,
                                      ),
                                      product.stock,
                                    );

                                    if (added) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${product.name} ${_getAddedText(l10n)}',
                                              style: TextStyle(fontSize: 14.sp)),
                                          duration: const Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '❌ ${_getInsufficientStockText(l10n)} ${product.name}',
                                              style: TextStyle(fontSize: 14.sp)),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                            ),
                            child: Text(
                              product.stock > 0 ? '+ ${l10n.addProduct}' : _getNoStockText(l10n), // ✅ TRADUCIDO
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Current Order Summary
          if (orderProvider.currentOrderItems.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getItemsText(l10n)}: ${orderProvider.currentOrderItems.length}', // ✅ TRADUCIDO
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${l10n.total}: ${settingsProvider.formatPrice(orderProvider.currentOrderTotal)}', // ✅ MONEDA DINÁMICA
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showCurrentOrderSheet(context),
                            icon: Icon(Icons.visibility, size: 18.sp),
                            label: Text(_getViewText(l10n), style: TextStyle(fontSize: 13.sp)), // ✅ TRADUCIDO
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2196F3),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateInvoiceDialog(context),
                            icon: Icon(Icons.receipt_long, size: 18.sp),
                            label: Text(l10n.createInvoice, // ✅ TRADUCIDO
                                style: TextStyle(fontSize: 13.sp)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  // ✅ Funciones helper para traducciones
  String _getNoProductsFoundText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'No se encontraron productos';
      case 'en':
        return 'No products found';
      case 'pt':
        return 'Nenhum produto encontrado';
      case 'zh':
        return '未找到产品';
      default:
        return 'No products found';
    }
  }

  String _getClearSearchText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Limpiar búsqueda';
      case 'en':
        return 'Clear search';
      case 'pt':
        return 'Limpar pesquisa';
      case 'zh':
        return '清除搜索';
      default:
        return 'Clear search';
    }
  }

  String _getInCartText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'En carrito';
      case 'en':
        return 'In cart';
      case 'pt':
        return 'No carrinho';
      case 'zh':
        return '在购物车中';
      default:
        return 'In cart';
    }
  }

  String _getAddedText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'agregado';
      case 'en':
        return 'added';
      case 'pt':
        return 'adicionado';
      case 'zh':
        return '已添加';
      default:
        return 'added';
    }
  }

  String _getInsufficientStockText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Stock insuficiente para';
      case 'en':
        return 'Insufficient stock for';
      case 'pt':
        return 'Estoque insuficiente para';
      case 'zh':
        return '库存不足';
      default:
        return 'Insufficient stock for';
    }
  }

  String _getNoStockText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Sin stock';
      case 'en':
        return 'Out of stock';
      case 'pt':
        return 'Sem estoque';
      case 'zh':
        return '缺货';
      default:
        return 'Out of stock';
    }
  }

  String _getItemsText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Items';
      case 'en':
        return 'Items';
      case 'pt':
        return 'Itens';
      case 'zh':
        return '项目';
      default:
        return 'Items';
    }
  }

  String _getViewText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Ver';
      case 'en':
        return 'View';
      case 'pt':
        return 'Ver';
      case 'zh':
        return '查看';
      default:
        return 'View';
    }
  }

  void _showCurrentOrderSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getOrderCartText(l10n), // ✅ TRADUCIDO
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 24.sp),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: provider.currentOrderItems.isEmpty
                          ? Center(
                              child: Text(
                                _getEmptyCartText(l10n), // ✅ TRADUCIDO
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: provider.currentOrderItems.length,
                              itemBuilder: (context, index) {
                                final item = provider.currentOrderItems[index];
                                final product = productProvider.getProductById(item.productId);
                                final availableStock = product?.stock ?? 0;
                                
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.productName,
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${_getAvailableStockText(l10n)}: $availableStock', // ✅ TRADUCIDO
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, size: 20.sp),
                                              color: Colors.red,
                                              onPressed: () {
                                                provider.removeItemFromCurrentOrder(
                                                    item.productId);
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.remove, size: 18.sp),
                                                  onPressed: item.quantity > 1
                                                      ? () {
                                                          provider
                                                              .updateItemQuantity(
                                                            item.productId,
                                                            item.quantity - 1,
                                                            availableStock,
                                                          );
                                                        }
                                                      : null,
                                                  style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    foregroundColor: Colors.black,
                                                    padding: EdgeInsets.all(8.w),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Text(
                                                  '${item.quantity}',
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                IconButton(
                                                  icon: Icon(Icons.add, size: 18.sp),
                                                  onPressed: () {
                                                    final success = provider.updateItemQuantity(
                                                      item.productId,
                                                      item.quantity + 1,
                                                      availableStock,
                                                    );
                                                    
                                                    if (!success) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              '❌ ${_getInsufficientStockText(l10n)}. ${_getAvailableText(l10n)}: $availableStock',
                                                              style: TextStyle(
                                                                  fontSize: 14.sp)),
                                                          backgroundColor: Colors.red,
                                                          duration:
                                                              const Duration(seconds: 2),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF2196F3),
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.all(8.w),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${settingsProvider.formatPrice(item.price)} ${_getEachText(l10n)}', // ✅ MONEDA DINÁMICA
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Text(
                                                  settingsProvider.formatPrice(item.total), // ✅ MONEDA DINÁMICA
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF4CAF50),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.total}:',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            settingsProvider.formatPrice(provider.currentOrderTotal), // ✅ MONEDA DINÁMICA
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmClearOrder(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(_getEmptyText(l10n), style: TextStyle(fontSize: 15.sp)), // ✅ TRADUCIDO
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCreateInvoiceDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(l10n.createInvoice,
                                style: TextStyle(fontSize: 15.sp)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Más funciones helper para traducciones
  String _getOrderCartText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Carrito de Pedido';
      case 'en':
        return 'Order Cart';
      case 'pt':
        return 'Carrinho de Pedido';
      case 'zh':
        return '订单购物车';
      default:
        return 'Order Cart';
    }
  }

  String _getEmptyCartText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'El carrito está vacío';
      case 'en':
        return 'Cart is empty';
      case 'pt':
        return 'O carrinho está vazio';
      case 'zh':
        return '购物车是空的';
      default:
        return 'Cart is empty';
    }
  }

  String _getAvailableStockText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Stock disponible';
      case 'en':
        return 'Available stock';
      case 'pt':
        return 'Estoque disponível';
      case 'zh':
        return '可用库存';
      default:
        return 'Available stock';
    }
  }

  String _getAvailableText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Disponible';
      case 'en':
        return 'Available';
      case 'pt':
        return 'Disponível';
      case 'zh':
        return '可用';
      default:
        return 'Available';
    }
  }

  String _getEachText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'c/u';
      case 'en':
        return 'each';
      case 'pt':
        return 'cada';
      case 'zh':
        return '每个';
      default:
        return 'each';
    }
  }

  String _getEmptyText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Vaciar';
      case 'en':
        return 'Empty';
      case 'pt':
        return 'Esvaziar';
      case 'zh':
        return '清空';
      default:
        return 'Empty';
    }
  }

  void _confirmClearOrder(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.sp),
            SizedBox(width: 12.w),
            Text(_getEmptyCartTitleText(l10n), style: TextStyle(fontSize: 18.sp)),
          ],
        ),
        content: Text(
          _getEmptyCartConfirmText(l10n),
          style: TextStyle(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<OrderProvider>(context, listen: false).clearCurrentOrder();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_getCartClearedText(l10n),
                      style: TextStyle(fontSize: 14.sp)),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(_getEmptyText(l10n), style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  String _getEmptyCartTitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Vaciar carrito';
      case 'en':
        return 'Empty cart';
      case 'pt':
        return 'Esvaziar carrinho';
      case 'zh':
        return '清空购物车';
      default:
        return 'Empty cart';
    }
  }

  String _getEmptyCartConfirmText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return '¿Estás seguro de vaciar el carrito? Se perderán todos los items.';
      case 'en':
        return 'Are you sure you want to empty the cart? All items will be lost.';
      case 'pt':
        return 'Tem certeza de que deseja esvaziar o carrinho? Todos os itens serão perdidos.';
      case 'zh':
        return '您确定要清空购物车吗？所有项目将丢失。';
      default:
        return 'Are you sure you want to empty the cart? All items will be lost.';
    }
  }

  String _getCartClearedText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Carrito vaciado';
      case 'en':
        return 'Cart cleared';
      case 'pt':
        return 'Carrinho esvaziado';
      case 'zh':
        return '购物车已清空';
      default:
        return 'Cart cleared';
    }
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(l10n.createInvoice, style: TextStyle(fontSize: 18.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: _getCustomerNameRequiredText(l10n), // ✅ TRADUCIDO
                labelStyle: TextStyle(fontSize: 14.sp),
                hintText: _getCustomerNameHintText(l10n), // ✅ TRADUCIDO
                hintStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: Icon(Icons.person, size: 20.sp),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _customerPhoneController,
              decoration: InputDecoration(
                labelText: _getPhoneOptionalText(l10n), // ✅ TRADUCIDO
                labelStyle: TextStyle(fontSize: 14.sp),
                hintText: '123456789',
                hintStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: Icon(Icons.phone, size: 20.sp),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_customerNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '⚠️ ${_getPleaseEnterCustomerNameText(l10n)}',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final orderProvider =
                  Provider.of<OrderProvider>(context, listen: false);
              final productProvider =
                  Provider.of<ProductProvider>(context, listen: false);
              final invoiceProvider =
                  Provider.of<InvoiceProvider>(context, listen: false);

              // Validar stock
              final errorMessage = orderProvider.validateCurrentOrder(
                (productId) => productProvider.getProductById(productId)?.stock,
              );

              if (errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ $errorMessage',
                        style: TextStyle(fontSize: 14.sp)),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
                return;
              }

              // Reducir stock
              for (final item in orderProvider.currentOrderItems) {
                await productProvider.reduceStock(
                  item.productId,
                  item.quantity,
                );
              }

              // Crear boleta
              await invoiceProvider.createInvoice(
                customerName: _customerNameController.text.trim(),
                customerPhone: _customerPhoneController.text.trim(),
                items: orderProvider.getCurrentOrderItemsCopy(),
              );

              orderProvider.clearCurrentOrder();
              _customerNameController.clear();
              _customerPhoneController.clear();

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '✅ ${_getInvoiceCreatedText(l10n)}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            child: Text(_getCreateText(l10n), style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  String _getCustomerNameRequiredText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Nombre del Cliente *';
      case 'en':
        return 'Customer Name *';
      case 'pt':
        return 'Nome do Cliente *';
      case 'zh':
        return '客户姓名 *';
      default:
        return 'Customer Name *';
    }
  }

  String _getCustomerNameHintText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Ej: Juan Pérez';
      case 'en':
        return 'E.g: John Doe';
      case 'pt':
        return 'Ex: João Silva';
      case 'zh':
        return '例如：张三';
      default:
        return 'E.g: John Doe';
    }
  }

  String _getPhoneOptionalText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Teléfono (opcional)';
      case 'en':
        return 'Phone (optional)';
      case 'pt':
        return 'Telefone (opcional)';
      case 'zh':
        return '电话（可选）';
      default:
        return 'Phone (optional)';
    }
  }

  String _getPleaseEnterCustomerNameText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Por favor ingresa el nombre del cliente';
      case 'en':
        return 'Please enter customer name';
      case 'pt':
        return 'Por favor insira o nome do cliente';
      case 'zh':
        return '请输入客户姓名';
      default:
        return 'Please enter customer name';
    }
  }

  String _getInvoiceCreatedText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Boleta creada y stock actualizado';
      case 'en':
        return 'Invoice created and stock updated';
      case 'pt':
        return 'Nota fiscal criada e estoque atualizado';
      case 'zh':
        return '发票已创建，库存已更新';
      default:
        return 'Invoice created and stock updated';
    }
  }

  String _getCreateText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Crear';
      case 'en':
        return 'Create';
      case 'pt':
        return 'Criar';
      case 'zh':
        return '创建';
      default:
        return 'Create';
    }
  }
}

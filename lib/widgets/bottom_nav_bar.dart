import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart'; // ✅ CORREGIDO
import '../providers/invoice_provider.dart';
import '../providers/settings_provider.dart'; // ✅ AGREGADO
import '../models/invoice.dart';
import 'package:intl/intl.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ AGREGADO
    final settingsProvider = Provider.of<SettingsProvider>(context); // ✅ AGREGADO
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    final filteredInvoices = invoiceProvider.invoices.where((invoice) {
      return _searchQuery.isEmpty ||
          invoice.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          invoice.invoiceNumber.toString().contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoices, style: TextStyle(fontSize: 18.sp)), // ✅ TRADUCIDO
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, size: 24.sp),
            onPressed: () {
              // Implementar filtros si es necesario
            },
          ),
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
                hintText: _getSearchByCustomerText(l10n), // ✅ TRADUCIDO
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

          // Invoices List
          Expanded(
            child: filteredInvoices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.receipt_long_outlined,
                          size: 80.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _searchQuery.isNotEmpty
                              ? _getNoInvoicesFoundText(l10n) // ✅ TRADUCIDO
                              : l10n.noInvoices, // ✅ TRADUCIDO
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
                            label: Text(_getClearSearchText(l10n),
                                style: TextStyle(fontSize: 14.sp)),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = filteredInvoices[index];
                      return _buildInvoiceCard(context, invoice, l10n, settingsProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    Invoice invoice,
    AppLocalizations l10n,
    SettingsProvider settingsProvider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showInvoiceDetails(context, invoice, l10n, settingsProvider),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: const Color(0xFF2196F3),
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getInvoiceText(l10n)} #${invoice.invoiceNumber}', // ✅ TRADUCIDO
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2196F3),
                            ),
                          ),
                          Text(
                            dateFormat.format(invoice.createdAt),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    settingsProvider.formatPrice(invoice.total), // ✅ MONEDA DINÁMICA
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(height: 1, thickness: 1),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.person, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      invoice.customerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (invoice.customerPhone.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Text(
                      invoice.customerPhone,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    '${invoice.items.length} ${_getProductsText(l10n, invoice.items.length)}', // ✅ TRADUCIDO
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showInvoiceDetails(context, invoice, l10n, settingsProvider),
                    icon: Icon(Icons.visibility, size: 16.sp),
                    label: Text(_getViewText(l10n), style: TextStyle(fontSize: 13.sp)), // ✅ TRADUCIDO
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2196F3),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Implementar compartir/descargar boleta
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_getShareFunctionText(l10n)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(Icons.share, size: 16.sp),
                    label: Text(l10n.share, style: TextStyle(fontSize: 13.sp)), // ✅ TRADUCIDO
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvoiceDetails(
    BuildContext context,
    Invoice invoice,
    AppLocalizations l10n,
    SettingsProvider settingsProvider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
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
                
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getInvoiceText(l10n)} #${invoice.invoiceNumber}', // ✅ TRADUCIDO
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2196F3),
                          ),
                        ),
                        Text(
                          dateFormat.format(invoice.createdAt),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 24.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Customer Info
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCustomerInfoText(l10n), // ✅ TRADUCIDO
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.person, size: 18.sp, color: Colors.grey[700]),
                          SizedBox(width: 8.w),
                          Text(
                            invoice.customerName,
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ],
                      ),
                      if (invoice.customerPhone.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 18.sp, color: Colors.grey[700]),
                            SizedBox(width: 8.w),
                            Text(
                              invoice.customerPhone,
                              style: TextStyle(fontSize: 15.sp),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Items List
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: invoice.items.length,
                    itemBuilder: (context, index) {
                      final item = invoice.items[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            children: [
                              Container(
                                width: 50.w,
                                height: 50.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.quantity}x',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2196F3),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${settingsProvider.formatPrice(item.price)} ${_getEachText(l10n)}', // ✅ MONEDA DINÁMICA
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                settingsProvider.formatPrice(item.total), // ✅ MONEDA DINÁMICA
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),

                // Total
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.total}:', // ✅ TRADUCIDO
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        settingsProvider.formatPrice(invoice.total), // ✅ MONEDA DINÁMICA
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Implementar descarga de PDF
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_getDownloadFunctionText(l10n)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(Icons.download, size: 18.sp),
                        label: Text(l10n.download, style: TextStyle(fontSize: 14.sp)), // ✅ TRADUCIDO
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Implementar compartir
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_getShareFunctionText(l10n)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(Icons.share, size: 18.sp),
                        label: Text(l10n.share, style: TextStyle(fontSize: 14.sp)), // ✅ TRADUCIDO
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ Funciones helper para traducciones
  String _getSearchByCustomerText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Buscar por cliente o número...';
      case 'en':
        return 'Search by customer or number...';
      case 'pt':
        return 'Buscar por cliente ou número...';
      case 'zh':
        return '按客户或号码搜索...';
      default:
        return 'Search by customer or number...';
    }
  }

  String _getNoInvoicesFoundText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'No se encontraron boletas';
      case 'en':
        return 'No invoices found';
      case 'pt':
        return 'Nenhuma nota fiscal encontrada';
      case 'zh':
        return '未找到发票';
      default:
        return 'No invoices found';
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

  String _getInvoiceText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Boleta';
      case 'en':
        return 'Invoice';
      case 'pt':
        return 'Nota Fiscal';
      case 'zh':
        return '发票';
      default:
        return 'Invoice';
    }
  }

  String _getProductsText(AppLocalizations l10n, int count) {
    switch (l10n.localeName) {
      case 'es':
        return count == 1 ? 'producto' : 'productos';
      case 'en':
        return count == 1 ? 'product' : 'products';
      case 'pt':
        return count == 1 ? 'produto' : 'produtos';
      case 'zh':
        return '产品';
      default:
        return count == 1 ? 'product' : 'products';
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

  String _getShareFunctionText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Función de compartir próximamente';
      case 'en':
        return 'Share function coming soon';
      case 'pt':
        return 'Função de compartilhamento em breve';
      case 'zh':
        return '分享功能即将推出';
      default:
        return 'Share function coming soon';
    }
  }

  String _getDownloadFunctionText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Función de descarga próximamente';
      case 'en':
        return 'Download function coming soon';
      case 'pt':
        return 'Função de download em breve';
      case 'zh':
        return '下载功能即将推出';
      default:
        return 'Download function coming soon';
    }
  }

  String _getCustomerInfoText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Información del Cliente';
      case 'en':
        return 'Customer Information';
      case 'pt':
        return 'Informações do Cliente';
      case 'zh':
        return '客户信息';
      default:
        return 'Customer Information';
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
}

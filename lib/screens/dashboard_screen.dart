import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_typography.dart';
import '../core/utils/responsive_helper.dart';
import '../providers/business_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/settings_provider.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'invoices_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final businessProvider = context.watch<BusinessProvider>();
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final invoiceProvider = context.watch<InvoiceProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header con gradiente
              Container(
                width: double.infinity,
                padding: AppSpacing.paddingXL,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessProvider.profile.businessName.isEmpty
                          ? 'MiNegocio'
                          : businessProvider.profile.businessName,
                      style: AppTypography.h2.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.businessManagement,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textLight.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido principal
              Padding(
                padding: AppSpacing.paddingLG,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estadísticas en Grid (sin título "Panel de Control")
                    _buildStatsGrid(
                      context,
                      productProvider,
                      orderProvider,
                      invoiceProvider,
                      settingsProvider,
                      l10n,
                    ),

                    SizedBox(height: AppSpacing.xxl),

                    // Título "Opciones"
                    Text(
                      'Opciones',
                      style: AppTypography.h3,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    _buildQuickAccessGrid(context, l10n),

                    // Alerta de stock bajo
                    if (productProvider.lowStockProducts.isNotEmpty) ..[
                      SizedBox(height: AppSpacing.xxl),
                      _buildLowStockAlert(
                        context,
                        productProvider,
                        l10n,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    ProductProvider productProvider,
    OrderProvider orderProvider,
    InvoiceProvider invoiceProvider,
    SettingsProvider settingsProvider,
    AppLocalizations l10n,
  ) {
    final stats = [
      {
        'title': l10n.productsRegistered,
        'value': '${productProvider.totalProducts}',
        'icon': Icons.inventory_2,
        'color': AppColors.cardProductsColor,
      },
      {
        'title': l10n.ordersPlaced,
        'value': '${orderProvider.totalOrders}',
        'icon': Icons.shopping_cart,
        'color': AppColors.cardOrdersColor,
      },
      {
        'title': l10n.invoices,
        'value': '${invoiceProvider.totalInvoices}',
        'icon': Icons.receipt_long,
        'color': AppColors.cardInvoicesColor,
      },
      {
        'title': l10n.totalRevenue,
        'value': settingsProvider.formatPrice(invoiceProvider.totalRevenue),
        'icon': Icons.attach_money,
        'color': AppColors.cardRevenueColor,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar número de columnas según ancho - MÁS COMPACTO
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          childAspectRatio = 1.6; // Más alto para ser más compacto
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
          childAspectRatio = 1.4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.8;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 3.0; // Más horizontal en móvil
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              title: stat['title'] as String,
              value: stat['value'] as String,
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icono
          Container(
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.statLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  style: AppTypography.statNumber.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final quickActions = [
      {
        'icon': Icons.inventory_2,
        'label': l10n.products,
        'color': AppColors.cardProductsColor,
        'route': const ProductsScreen(),
      },
      {
        'icon': Icons.shopping_cart,
        'label': l10n.orders,
        'color': AppColors.cardOrdersColor,
        'route': const OrdersScreen(),
      },
      {
        'icon': Icons.receipt_long,
        'label': l10n.invoices,
        'color': AppColors.cardInvoicesColor,
        'route': const InvoicesScreen(),
      },
      {
        'icon': Icons.settings,
        'label': l10n.settings,
        'color': AppColors.info,
        'route': const SettingsScreen(),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          // Grid para tablets grandes
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 3.5,
            ),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return _buildQuickAccessButton(
                context: context,
                icon: action['icon'] as IconData,
                label: action['label'] as String,
                color: action['color'] as Color,
                route: action['route'] as Widget,
              );
            },
          );
        } else {
          // Lista vertical para móviles y tablets pequeñas
          return Column(
            children: quickActions.map((action) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildQuickAccessButton(
                  context: context,
                  icon: action['icon'] as IconData,
                  label: action['label'] as String,
                  color: action['color'] as Color,
                  route: action['route'] as Widget,
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildQuickAccessButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Widget route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => route),
        ),
        borderRadius: AppSpacing.borderRadiusMD,
        child: Container(
          padding: AppSpacing.paddingLG,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusMD,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.h5.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockAlert(
    BuildContext context,
    ProductProvider productProvider,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.errorWithOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: AppColors.errorWithOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 24.sp,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Productos con stock bajo',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.errorDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          ...productProvider.lowStockProducts.take(5).map((product) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: AppTypography.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Text(
                    '${l10n.stock}: ${product.stock}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

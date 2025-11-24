import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final VoidCallback? onTransfer;
  final bool showActions;

  const ProductCard({
    Key? key,
    required this.product,
    this.onEdit,
    this.onToggleActive,
    this.onTransfer,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderGrey,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final imageHeight = totalHeight * 0.45;
          final contentHeight = totalHeight * 0.55;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: _buildImage(),
                ),
              ),

              // Contenido
              SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      SizedBox(
                        height: 34,
                        child: Text(
                          product.nombre,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Precio y Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'S/ ${product.precio.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getStockColor(product.stock),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Stock: ${product.stock}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStockTextColor(product.stock),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      if (showActions) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionButton(
                              icon: Icons.edit_outlined,
                              color: Colors.grey[700]!,
                              onTap: onEdit,
                            ),
                            _ActionButton(
                              icon: product.activo
                                  ? Icons.toggle_on
                                  : Icons.toggle_off_outlined,
                              color: product.activo
                                  ? AppColors.activeGreen
                                  : Colors.grey[400]!,
                              onTap: onToggleActive,
                            ),
                            _ActionButton(
                              icon: Icons.swap_horiz,
                              color: AppColors.primary,
                              onTap: onTransfer,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage() {
    if (product.imagen == null || product.imagen!.isEmpty) {
      return Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 40,
          color: Colors.grey[400],
        ),
      );
    }

    // Si es URL de Cloudinary
    if (product.imagen!.startsWith('http')) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: CachedNetworkImage(
          imageUrl: product.imagen!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) => Center(
            child: Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
        ),
      );
    }

    // Si es path local (fallback)
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Image.file(
        File(product.imagen!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: _buildImageError,
      ),
    );
  }

  Widget _buildImageError(BuildContext context, Object error, StackTrace? stackTrace) {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock > 10) return AppColors.activeGreen.withOpacity(0.1);
    if (stock > 0) return Colors.orange.withOpacity(0.1);
    return AppColors.inactiveRed.withOpacity(0.1);
  }

  Color _getStockTextColor(int stock) {
    if (stock > 10) return AppColors.activeGreen;
    if (stock > 0) return Colors.orange[700]!;
    return AppColors.inactiveRed;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          icon,
          size: 25,
          color: color,
        ),
      ),
    );
  }
}
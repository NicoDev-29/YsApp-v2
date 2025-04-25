import 'package:flutter/material.dart';
import '/../themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import '/../models/models_exports.dart';
import 'package:collection/collection.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({Key? key}) : super(key: key);

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  String? _selectedSalon;
  String? _selectedType;
  String? _selectedItem;
  double _itemPrice = 0.0;

  List<SaleItem> _saleItems = [];

  final List<String> _salons = ['Salon 1', 'Salon 2', 'Salon 3'];
  final List<String> _types = ['Producto', 'Servicio'];
  final List<String> _productos = ['Shampoo', 'Acondicionador', 'Tinte'];
  final List<String> _servicios = ['Corte', 'Peinado', 'Manicure'];

  double get _total => _saleItems.map((item) => item.subtotal).sum;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = (screenWidth * 0.07).clamp(20.0, 40.0);
    final inputVerticalSpacing = screenHeight * 0.025;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
        title: const Text('Atrás'),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradient1,
              AppColors.gradient2,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomHeader(
                      title: 'AGREGAR VENTA',
                      imagePath: 'assets/item3.png',
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Selector Salón
                    CustomDropdownField<String>(
                      label: 'Salon',
                      value: _selectedSalon,
                      items: _salons
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSalon = value;
                        });
                      },
                    ),
                    SizedBox(height: inputVerticalSpacing),

                    // Selector Tipo (Producto/Servicio)
                    CustomDropdownField<String>(
                      label: 'Tipo',
                      value: _selectedType,
                      items: _types
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                          _selectedItem = null; // Reset item
                          _itemPrice = 0.0;
                        });
                      },
                    ),
                    SizedBox(height: inputVerticalSpacing),

                    // Selector Producto/Servicio (con búsqueda)
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        final items = _selectedType == 'Producto'
                            ? _productos
                            : _servicios;
                        if (textEditingValue.text == '') {
                          return items;
                        }
                        return items.where((item) => item
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String item) {
                        setState(() {
                          _selectedItem = item;
                          _itemPrice = 32.0; //Precio de prueba
                        });
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return CustomInputField(
                          label: _selectedType == null
                              ? 'Selecciona Tipo'
                              : _selectedType == 'Producto'
                                  ? 'Producto'
                                  : 'Servicio',
                          controller: textEditingController,
                        );
                      },
                    ),
                    SizedBox(height: inputVerticalSpacing),

                    // Precio (solo lectura)
                    CustomInputField(
                      label: 'Precio',
                      controller: TextEditingController(
                          text: 'S/. ${_itemPrice.toStringAsFixed(2)}'),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Botón "Agregar"
                    Center(
                      child: CustomButton(
                        label: 'AGREGAR',
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Lista de Items
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          // Encabezado
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Item',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Cantidad',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Subtotal',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey[400]),
                          // Items
                          Column(
                            children: _saleItems.map((item) {
                              return SaleItemRow(
                                item: item,
                                onQuantityChanged: (updatedItem) {
                                  setState(() {});
                                },
                                onRemove: () {
                                  setState(() {
                                    _saleItems.remove(item);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'S/. ${_total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Botón "Cerrar Venta"
                    Center(
                      child: CustomButton(
                        label: 'CERRAR VENTA',
                        onPressed: () {
                        },
                        backgroundColor: _saleItems.isEmpty
                            ? Colors.grey
                            : AppColors.tertiary,
                        foregroundColor: AppColors.secondary,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.13,
                          vertical: screenHeight * 0.018,
                        ),
                        borderRadius: 16,
                        elevation: 8,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

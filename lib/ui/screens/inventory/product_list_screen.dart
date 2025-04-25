import 'package:flutter/material.dart';
import '/../../themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import '/../models/models_exports.dart';
import '../screens_exports.dart';
import 'package:ysa_app/ui/widgets/filter_selector.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [
    Product(
      name: 'Shampoo Argán',
      imageUrl:
          'https://steamuserimages-a.akamaihd.net/ugc/2513644999170433438/1698ACC197CA3E8E997BD1FD50AEF7CD01CEADC9/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
      price: 25.00,
      stock: 10,
    ),
    Product(
      name: 'Acondicionador Coco',
      imageUrl:
          'https://steamuserimages-a.akamaihd.net/ugc/2513644999170433438/1698ACC197CA3E8E997BD1FD50AEF7CD01CEADC9/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
      price: 22.50,
      stock: 5,
    ),
    Product(
      name: 'Acondicionador Coco',
      imageUrl:
          'https://steamuserimages-a.akamaihd.net/ugc/2513644999170433438/1698ACC197CA3E8E997BD1FD50AEF7CD01CEADC9/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
      price: 22.50,
      stock: 5,
    ),
    Product(
      name: 'Acondicionador Coco',
      imageUrl:
          'https://steamuserimages-a.akamaihd.net/ugc/2513644999170433438/1698ACC197CA3E8E997BD1FD50AEF7CD01CEADC9/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
      price: 22.50,
      stock: 5,
    ),
    Product(
      name: 'Acondicionador Coco',
      imageUrl:
          'https://steamuserimages-a.akamaihd.net/ugc/2513644999170433438/1698ACC197CA3E8E997BD1FD50AEF7CD01CEADC9/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
      price: 22.50,
      stock: 5,
    ),
  ];

  String? _selectedSalon;
  String? _selectedCategoria;
  String? _selectedFilter;

  final List<String> _salones = ['Salon 1', 'Salon 2', 'Salon 3'];
  final List<String> _categorias = ['Categoria 1', 'Categoria 2', 'Categoria 3'];
  final List<String> _filters = ['Bajo Stock', 'Desactivados', 'Activos'];

  void toggleActive(int index) {
    setState(() {
      products[index].isActive = !products[index].isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final baseVerticalSpacing = screenHeight * 0.015;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
        title: const Text(
          'Atrás',
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const CustomHeader(
                  title: 'PRODUCTOS',
                  imagePath: 'assets/item4.png',
                ),
                SizedBox(height: baseVerticalSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar producto',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(    
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,  
                        ),
                        enabledBorder: OutlineInputBorder( 
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(  
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,              
                        fillColor: Colors.white,    
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: baseVerticalSpacing * 3),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilterSelector(
                          label: 'Seleccionar Salón',
                          options: _salones,
                          value: _selectedSalon,
                          onChanged: (value) {
                            setState(() {
                              _selectedSalon = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: FilterSelector(
                          label: 'Categorías',
                          options: _categorias,
                          value: _selectedCategoria,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoria = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: baseVerticalSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilterSelector(
                          label: 'Filtrar',
                          options: _filters,
                          value: _selectedFilter,
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      AddButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddProductScreen()),
                          );
                        },
                        label: 'Agregar',
                        icon: Icons.add, 
                      ),
                    ],
                  ),
                ),
                SizedBox(height: baseVerticalSpacing),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onToggleActive: () => toggleActive(index),
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProductScreen(product: product),
                          ),
                        );
                      },
                      deleteIcon: product.isActive ? Icons.block : Icons.check_circle,
                      deleteTooltip: product.isActive ? 'Desactivar' : 'Activar',
                    );
                  },
                ),
                SizedBox(height: baseVerticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '/../themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import '/../models/models_exports.dart';
import '../screens_exports.dart';

class SalesScreen extends StatelessWidget {
  SalesScreen({super.key});

  final List<Sale> sales = [
    Sale(
      total: 534.00,
      username: 'User1',
      dateTime: DateTime(2025, 4, 27, 14, 34),
    ),
    Sale(
      total: 120.50,
      username: 'User2',
      dateTime: DateTime(2025, 4, 26, 10, 15),
    ),
    Sale(
      total: 320.75,
      username: 'User3',
      dateTime: DateTime(2025, 4, 25, 9, 45),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = (screenWidth * 0.07).clamp(20.0, 40.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
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
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CustomHeader(
                        title: 'VENTAS',
                        imagePath: 'assets/item3.png',
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Center(
                        child: AddButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const AddSaleScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;

                                  final tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  final offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          label: 'Agregar',
                          icon: Icons.add,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sales.length,
                        itemBuilder: (context, index) {
                          final sale = sales[index];
                          return SaleCard(
                            index: index,
                            sale: sale,
                            onView: () {},
                            onEdit: () {},
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        onTap: (index) {},
      ),
    );
  }
}

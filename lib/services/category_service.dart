import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final CollectionReference _categoriesRef =
      FirebaseFirestore.instance.collection('categorias');

  Future<String?> addCategory(String nombre) async {
    try {
      final docRef = await _categoriesRef.add({
        'nombre': nombre,
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error agregando categoría: $e');
      return null;
    }
  }

  Stream<List<Category>> getCategories() {
    return _categoriesRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  Future<void> toggleCategoryStatus(String categoryId, bool currentStatus) async {
    await _categoriesRef.doc(categoryId).update({'activo': !currentStatus});
  }
}

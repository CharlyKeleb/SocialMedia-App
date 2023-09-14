import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePagination {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int itemsPerPage;

  FirestorePagination(this.itemsPerPage);

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchNextPage(
      DocumentSnapshot<Object?>? lastDocument) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('posts')
          .limit(itemsPerPage)
          .orderBy('timestamp', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await query.get();
      return querySnapshot.docs;
    } catch (e) {
      // Handle error
      print('Error fetching next page: $e');
      return [];
    }
  }
}

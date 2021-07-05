import 'dart:io';
import 'dart:convert';
import 'package:social_media_app/models/category.dart';
import 'package:social_media_app/services/services.dart';
import 'package:http/http.dart' as http;


class PostService extends Service {

 Future<Category> getCategories(Category categoryModel) async {
  final response = await http.post(
      Uri.parse('http://api.99huaren.local:3001/api/categories')
   // headers: <String, String>{
   //  'Content-Type': 'application/json; charset=UTF-8',
   // },
   // body: jsonEncode(categoryModel.toJson()),
  );
  if (response.statusCode == 200) {
   return Category.fromJson(jsonDecode(response.body));
  } else {
   throw Exception('Failed to load Categories.');
  }

 }
}

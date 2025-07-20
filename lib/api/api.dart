import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/news_model/news_model.dart';


const String apiKey = '1ff9a449dd954e97b7eec93a5807ff2f';

Future<NewsModel> getNews() async {
  final response = await http.get(
    Uri.parse('https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey'),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    final data = NewsModel.fromJson(result); 
    return data;
  } else {
    throw Exception('Failed to load news');
  }
}

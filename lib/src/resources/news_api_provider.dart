import 'package:http/http.dart' show Client;
import 'dart:convert';
import '../models/item_model.dart';
import 'repository.dart';

class NewsApiProvider implements Source {
  Client client = Client();
  final String baseUrl = 'https://hacker-news.firebaseio.com/v0';

  Future<List<int>> fetchTopIds() async {
    final response = await client.get('$baseUrl/topstories.json');
    final ids = json.decode(response.body);

    return ids.cast<int>();
  }
  
  Future<ItemModel> fetchItem(int itemId) async {
    final response = await client.get('$baseUrl/item/$itemId.json');
    final parsedItem = json.decode(response.body);
    //print('item after decoded $parsedItem');
    final item = ItemModel.fromJson(parsedItem);
    //print('item from api: ${item.id} - ${item.title}');
    return item;
  }
}
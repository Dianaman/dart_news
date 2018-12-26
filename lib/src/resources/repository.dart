import '../models/item_model.dart';
import 'dart:async';
import 'news_api_provider.dart';
import 'news_db_provider.dart';

class Repository {
  List<Source> sources = <Source>[
    newsDbProvider,
    NewsApiProvider()
  ];
  List<Cache> caches = <Cache>[
    newsDbProvider
  ];

  Future<ItemModel> fetchItem(int id) async {
    ItemModel item;
    Source source;

    for(Source source in sources) {
      item = await source.fetchItem(id);
      if(item != null) {
        break;
      }
    }

    for(Cache cache in caches) {
      if(cache != (source as Cache)) {
        cache.addItem(item);
      }
    }

    return item;
  }

  Future<List<int>> fetchTopIds() {
    return sources[1].fetchTopIds();
    /*List<int> ids;

    for(Source source in sources) {
      ids = await source.fetchTopIds();
      if(ids != null) {
        break;
      }
    }
    return ids;*/
  }

  /*NewsDbProvider dbProvider = NewsDbProvider();
  NewsApiProvider apiProvider = NewsApiProvider();

  Future<List<int>> fetchTopIds() {
    return apiProvider.fetchTopIds();
  }

  Future<ItemModel> fetchItem(int id) async {
    var item = await dbProvider.fetchItem(id);
    
    if(item == null) {
      item = await apiProvider.fetchItem(id);
      dbProvider.addItem(item); // async operation but not need to wait
    }

    return item;
  }*/

  Future<void> clearCaches() async {
    for(var cache in caches) {
      await cache.clear();
    }
  }
}

abstract class Source {
  Future<List<int>> fetchTopIds();
  Future<ItemModel> fetchItem(int id);
}

abstract class Cache {
  Future<int> addItem(ItemModel item);
  Future<int> clear();
}
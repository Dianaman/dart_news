import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';
import 'dart:async';

class StoriesBloc {
  final _repository = Repository();
  final _topIds = PublishSubject<List<int>>();
  final _itemsOutput = BehaviorSubject<Map<int, Future<ItemModel>>>();
  final _itemsFetcher = PublishSubject<int>();
  // final _items = BehaviourSubject<int>();
  
  // Observable<Map<int, Future<ItemModel>>> items;
  Observable<List<int>> get topIds => _topIds.stream;
  Observable<Map<int, Future<ItemModel>>> get items => _itemsOutput.stream;

  // no getters for public sink of topIds because is not a widget who manage data but the repository
  // get fetchItem => _items.sink.add;
  Function(int) get fetchItem => _itemsFetcher.sink.add;

  StoriesBloc() {
    // items = _items.stream.transform(_itemsTransformer());
    // this is invoked only once to prevent every StreamBuilder to have
    // an instance of the cache map. Cache map must have a single instance.

    _itemsFetcher.stream.transform(_itemsTransformer()).pipe(_itemsOutput);
  }

  Future<void> clearCaches() {
    return _repository.clearCaches();
  }

  Future<void> fetchTopIds() async {
    final ids = await _repository.fetchTopIds();
    _topIds.sink.add(ids);
  }

  _itemsTransformer() {
    return ScanStreamTransformer(
      (Map<int, Future<ItemModel>> cache, int id, index) { // we won't need the index --> times that ScanStreamTransformer has been invoked
        // print(index);
        cache[id] = _repository.fetchItem(id);
        return cache;
      },
      <int, Future<ItemModel>>{} //map initialization --> cache
    );
  }

  dispose() {
    _topIds.close();
    _itemsFetcher.close();
    _itemsOutput.close();
  }
}
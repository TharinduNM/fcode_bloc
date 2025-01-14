import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/bloc/default_stream_transformer.dart';
import 'package:fcode_bloc/db/db_model.dart';
import 'package:fcode_bloc/db/specification.dart';
import 'package:flutter/material.dart';

abstract class FirebaseRepository<T extends DBModel> {
  T fromSnapshot(DocumentSnapshot snapshot);

  Map<String, dynamic> toMap(T item);

  CollectionReference _merge(String type, DocumentReference parent) {
    return parent?.collection(type) ?? Firestore.instance.collection(type);
  }

  Future<void> add({@required T item, @required String type, DocumentReference parent}) async {
    final data = toMap(item);
    if (item.ref == null) {
      item.ref = _merge(type, parent).document();
    }
    item.ref.setData(data);
  }

  Future<void> addList({@required Iterable<T> items, @required String type, DocumentReference parent}) async {
    for (final item in items) {
      await add(item: item, type: type, parent: parent);
    }
  }

  Stream<List<T>> query({@required SpecificationI specification, @required String type, DocumentReference parent}) {
    final stream = specification.specify(_merge(type, parent));
    return stream
        .transform(DefaultStreamTransformer.transformer<List<DocumentSnapshot>, List<T>>(handleData: (data, sink) {
      final items = <T>[];
      for (final document in data) {
        final item = fromSnapshot(document);
        if (item != null) {
          items.add(item);
        }
      }
      sink.add(items);
    }));
  }

  Future<void> remove(T item) async {
    // TODO: implement remove
  }

  Future<void> removeList(SpecificationI specification) async {
    // TODO: implement removeList
  }

  Future<void> update({@required T item, @required String type, DocumentReference parent}) async {
    final data = toMap(item);
    if (item.ref == null) {
      return add(item: item, type: type, parent: parent);
    }
    return item.ref.updateData(data);
  }
}

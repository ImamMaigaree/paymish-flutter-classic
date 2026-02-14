import '../../../apis/dic_params.dart';

class ResCategoryList {
  List<CategoryListItem>? data;

  ResCategoryList({this.data});

  ResCategoryList.fromJson(Map<String, dynamic> json) {
    if (json[DicParams.data] != null) {
      data = <CategoryListItem>[];
      json[DicParams.data].forEach((v) {
        data?.add(CategoryListItem.fromJson(v));
      });
    }
  }
}

class CategoryListItem {
  int? id;
  String? name;

  CategoryListItem({this.id, this.name});

  CategoryListItem.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    name = json[DicParams.name];
  }
}

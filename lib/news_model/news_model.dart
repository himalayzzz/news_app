import 'package:json_annotation/json_annotation.dart';

import 'article.dart';

part 'news_model.g.dart';

@JsonSerializable()
class NewsModel {
  String? status;
  int? totalResults;
  List<Article>? articles;

  NewsModel({this.status, this.totalResults, this.articles});

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return _$NewsModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NewsModelToJson(this);
}

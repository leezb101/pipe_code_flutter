import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'list_item.g.dart';

@JsonSerializable()
class ListItem extends Equatable {
  const ListItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ListItem.fromJson(Map<String, dynamic> json) => _$ListItemFromJson(json);

  Map<String, dynamic> toJson() => _$ListItemToJson(this);

  ListItem copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, imageUrl, createdAt, updatedAt];
}
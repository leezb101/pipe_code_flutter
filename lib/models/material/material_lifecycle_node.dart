import 'package:equatable/equatable.dart';

class MaterialLifecycleNode extends Equatable {
  final String? businessName;
  final int? businessTime;
  final String? businessPeople;
  final String? businessAddress;

  const MaterialLifecycleNode({
    this.businessName,
    this.businessTime,
    this.businessPeople,
    this.businessAddress,
  });

  @override
  List<Object?> get props => [
    businessName,
    businessTime,
    businessPeople,
    businessAddress,
  ];

  Map<String, dynamic> toJson() => {
    'businessName': businessName,
    'businessTime': businessTime,
    'businessPeople': businessPeople,
    'businessAddress': businessAddress,
  };

  factory MaterialLifecycleNode.fromJson(Map<String, dynamic> json) {
    return MaterialLifecycleNode(
      businessName: json['businessName'] as String?,
      businessTime: json['businessTime'] as int?,
      businessPeople: json['businessPeople'] as String?,
      businessAddress: json['businessAddress'] as String?,
    );
  }
}

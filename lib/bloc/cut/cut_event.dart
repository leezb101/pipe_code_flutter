import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';

abstract class CutEvent extends Equatable {
  const CutEvent();

  @override
  List<Object?> get props => [];
}

class CutOriginalMaterialScanned extends CutEvent {
  final MaterialInfoForBusiness materialInfo;

  const CutOriginalMaterialScanned(this.materialInfo);

  @override
  List<Object?> get props => [materialInfo];
}

class CutOriginalPhotoUpdated extends CutEvent {
  final String photoPath;

  const CutOriginalPhotoUpdated(this.photoPath);

  @override
  List<Object?> get props => [photoPath];
}

class CutDescriptionUpdated extends CutEvent {
  final String description;

  const CutDescriptionUpdated(this.description);

  @override
  List<Object?> get props => [description];
}

class CutNewMaterialsScanned extends CutEvent {
  final List<String> qrCodes;

  const CutNewMaterialsScanned(this.qrCodes);

  @override
  List<Object?> get props => [qrCodes];
}

class CutNewItemLengthUpdated extends CutEvent {
  final int index;
  final double length;

  const CutNewItemLengthUpdated({required this.index, required this.length});

  @override
  List<Object?> get props => [index, length];
}

class CutNewItemPhotoUpdated extends CutEvent {
  final int index;
  final String photoPath;

  const CutNewItemPhotoUpdated({required this.index, required this.photoPath});

  @override
  List<Object?> get props => [index, photoPath];
}

class CutNewItemDeleted extends CutEvent {
  final int index;

  const CutNewItemDeleted(this.index);

  @override
  List<Object?> get props => [index];
}

class CutSubmitted extends CutEvent {}

class CutReset extends CutEvent {}

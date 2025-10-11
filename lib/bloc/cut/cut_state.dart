/*
 * @Author: LeeZB
 * @Date: 2025-07-31 10:18:14
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-31 10:26:48
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';

// Note: For a larger project, this custom exception should be in its own file.
/// Custom exception to handle server tips that are not critical errors.
class TipException implements Exception {
  final String message;
  TipException(this.message);

  @override
  String toString() => message;
}

enum CutStatus {
  initial,
  loading,
  success,
  failure,
  submitting,
  tip,
  confirmableTip,
}

class NewCutMaterialItem extends Equatable {
  final String qrCode;
  final String materialName;
  final double? length;
  final String? photoPath;

  const NewCutMaterialItem({
    required this.qrCode,
    required this.materialName,
    this.length,
    this.photoPath,
  });

  NewCutMaterialItem copyWith({double? length, String? photoPath}) {
    return NewCutMaterialItem(
      qrCode: qrCode,
      materialName: materialName,
      length: length ?? this.length,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  List<Object?> get props => [qrCode, materialName, length, photoPath];
}

class CutState extends Equatable {
  final CutStatus status;
  final MaterialInfoForBusiness? originalMaterialInfo;
  final String? originalMaterialPhotoPath;
  final String? cutDescription;
  final List<String>? cutDescriptionVoicePaths;
  final List<NewCutMaterialItem> newCutItems;
  final String? tipMessage;
  final String? errorMessage;

  const CutState({
    this.status = CutStatus.initial,
    this.originalMaterialInfo,
    this.originalMaterialPhotoPath,
    this.cutDescription,
    this.cutDescriptionVoicePaths,
    this.newCutItems = const [],
    this.tipMessage,
    this.errorMessage,
  });

  CutState copyWith({
    CutStatus? status,
    MaterialInfoForBusiness? originalMaterialInfo,
    String? originalMaterialPhotoPath,
    String? cutDescription,
    List<String>? cutDescriptionVoicePaths,
    List<NewCutMaterialItem>? newCutItems,
    String? tipMessage,
    String? errorMessage,
    // Helper to clear messages and specific fields
    bool clearMessages = false,
    bool clearOriginalMaterial = false,
  }) {
    return CutState(
      status: status ?? this.status,
      originalMaterialInfo: clearOriginalMaterial
          ? null
          : originalMaterialInfo ?? this.originalMaterialInfo,
      originalMaterialPhotoPath: clearOriginalMaterial
          ? null
          : originalMaterialPhotoPath ?? this.originalMaterialPhotoPath,
      cutDescription: clearOriginalMaterial
          ? null
          : cutDescription ?? this.cutDescription,
      cutDescriptionVoicePaths: clearOriginalMaterial
          ? null
          : cutDescriptionVoicePaths ?? this.cutDescriptionVoicePaths,
      newCutItems: newCutItems ?? this.newCutItems,
      tipMessage: clearMessages ? tipMessage : (tipMessage ?? this.tipMessage),
      errorMessage: clearMessages
          ? errorMessage
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    originalMaterialInfo,
    originalMaterialPhotoPath,
    cutDescription,
    cutDescriptionVoicePaths,
    newCutItems,
    tipMessage,
    errorMessage,
  ];
}

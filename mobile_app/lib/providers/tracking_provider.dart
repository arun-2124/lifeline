import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/delivery_log_model.dart';
import 'package:mobile_app/models/qr_code_model.dart';
import 'package:mobile_app/models/tracking_model.dart';
import 'package:mobile_app/repositories/tracking_repository.dart';

class TrackingState {
  final bool isLoading;
  final QrCodeModel? qrCode;
  final TrackingModel? liveTracking;
  final List<DeliveryLogModel> deliveryLogs;
  final String? errorMessage;
  final String? successMessage;

  const TrackingState({
    this.isLoading = false,
    this.qrCode,
    this.liveTracking,
    this.deliveryLogs = const [],
    this.errorMessage,
    this.successMessage,
  });

  TrackingState copyWith({
    bool? isLoading,
    QrCodeModel? qrCode,
    TrackingModel? liveTracking,
    List<DeliveryLogModel>? deliveryLogs,
    String? errorMessage,
    String? successMessage,
  }) {
    return TrackingState(
      isLoading: isLoading ?? this.isLoading,
      qrCode: qrCode ?? this.qrCode,
      liveTracking: liveTracking ?? this.liveTracking,
      deliveryLogs: deliveryLogs ?? this.deliveryLogs,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  final TrackingRepository _repository;

  TrackingNotifier({required TrackingRepository repository})
      : _repository = repository,
        super(const TrackingState());

  Future<void> loadQrCode(String donationId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getQrCode(donationId);

    if (result is ApiSuccess<QrCodeModel>) {
      state = state.copyWith(isLoading: false, qrCode: result.data);
    } else if (result is ApiFailure<QrCodeModel>) {
      state = state.copyWith(isLoading: false, errorMessage: result.failure.message);
    }
  }

  Future<bool> verifyQrCode({
    required String qrId,
    required String scannedBy,
    required String scannedByName,
    required String scannedRole,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.verifyQrCode(
      qrId: qrId,
      scannedBy: scannedBy,
      scannedByName: scannedByName,
      scannedRole: scannedRole,
    );

    if (result is ApiSuccess<QrCodeModel>) {
      state = state.copyWith(
        isLoading: false,
        qrCode: result.data,
        successMessage: 'QR Code verified successfully! Donation marked as Completed.',
      );
      return true;
    } else if (result is ApiFailure<QrCodeModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
    return false;
  }

  Future<void> loadDeliveryLogs(String donationId) async {
    final result = await _repository.getDeliveryLogs(donationId);
    if (result is ApiSuccess<List<DeliveryLogModel>>) {
      state = state.copyWith(deliveryLogs: result.data);
    }
  }

  Future<void> updateVolunteerLocation({
    required String donationId,
    required String deliveryId,
    required String volunteerId,
    required String volunteerName,
    required double lat,
    required double lng,
  }) async {
    final result = await _repository.updateLiveLocation(
      donationId: donationId,
      deliveryId: deliveryId,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
      lat: lat,
      lng: lng,
    );

    if (result is ApiSuccess<TrackingModel>) {
      state = state.copyWith(liveTracking: result.data);
    }
  }
}

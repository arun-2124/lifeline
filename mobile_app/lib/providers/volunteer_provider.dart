import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/delivery_request_model.dart';
import 'package:mobile_app/repositories/volunteer_repository.dart';

class VolunteerState {
  final bool isLoading;
  final List<DeliveryRequestModel> availableDeliveries;
  final List<DeliveryRequestModel> assignedDeliveries;
  final List<DeliveryRequestModel> deliveryHistory;
  final DeliveryRequestModel? selectedDelivery;
  final String? errorMessage;
  final String? infoMessage;

  const VolunteerState({
    this.isLoading = false,
    this.availableDeliveries = const [],
    this.assignedDeliveries = const [],
    this.deliveryHistory = const [],
    this.selectedDelivery,
    this.errorMessage,
    this.infoMessage,
  });

  VolunteerState copyWith({
    bool? isLoading,
    List<DeliveryRequestModel>? availableDeliveries,
    List<DeliveryRequestModel>? assignedDeliveries,
    List<DeliveryRequestModel>? deliveryHistory,
    DeliveryRequestModel? selectedDelivery,
    String? errorMessage,
    String? infoMessage,
  }) {
    return VolunteerState(
      isLoading: isLoading ?? this.isLoading,
      availableDeliveries: availableDeliveries ?? this.availableDeliveries,
      assignedDeliveries: assignedDeliveries ?? this.assignedDeliveries,
      deliveryHistory: deliveryHistory ?? this.deliveryHistory,
      selectedDelivery: selectedDelivery ?? this.selectedDelivery,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }
}

class VolunteerNotifier extends StateNotifier<VolunteerState> {
  final VolunteerRepository _repository;

  VolunteerNotifier({required VolunteerRepository repository})
      : _repository = repository,
        super(const VolunteerState());

  Future<void> loadAvailableDeliveries() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getAvailableDeliveries();

    if (result is ApiSuccess<List<DeliveryRequestModel>>) {
      state = state.copyWith(
        isLoading: false,
        availableDeliveries: result.data,
      );
    } else if (result is ApiFailure<List<DeliveryRequestModel>>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
    }
  }

  Future<bool> acceptDeliveryTask({
    required String deliveryId,
    required String volunteerId,
    required String volunteerName,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.acceptDeliveryTask(
      deliveryId: deliveryId,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
    );

    if (result is ApiSuccess<DeliveryRequestModel>) {
      final updatedAvailable = state.availableDeliveries
          .where((d) => d.deliveryId != deliveryId)
          .toList();
      final updatedAssigned = [result.data, ...state.assignedDeliveries];

      state = state.copyWith(
        isLoading: false,
        availableDeliveries: updatedAvailable,
        assignedDeliveries: updatedAssigned,
        selectedDelivery: result.data,
        infoMessage: 'Delivery task accepted successfully!',
      );
      return true;
    } else if (result is ApiFailure<DeliveryRequestModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
    return false;
  }

  Future<bool> updateDeliveryStatus({
    required String deliveryId,
    required String status,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.updateDeliveryStatus(
      deliveryId: deliveryId,
      status: status,
    );

    if (result is ApiSuccess<DeliveryRequestModel>) {
      final updatedAssigned = state.assignedDeliveries.map((d) {
        return d.deliveryId == deliveryId ? result.data : d;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        assignedDeliveries: updatedAssigned,
        selectedDelivery: result.data,
        infoMessage: 'Status updated to $status.',
      );
      return true;
    } else if (result is ApiFailure<DeliveryRequestModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
    return false;
  }

  Future<void> loadVolunteerDeliveries(String volunteerId) async {
    final result = await _repository.getVolunteerDeliveries(volunteerId);
    if (result is ApiSuccess<List<DeliveryRequestModel>>) {
      state = state.copyWith(assignedDeliveries: result.data);
    }
  }

  Future<void> loadVolunteerHistory(String volunteerId) async {
    final result = await _repository.getVolunteerHistory(volunteerId);
    if (result is ApiSuccess<List<DeliveryRequestModel>>) {
      state = state.copyWith(deliveryHistory: result.data);
    }
  }

  void selectDelivery(DeliveryRequestModel delivery) {
    state = state.copyWith(selectedDelivery: delivery);
  }
}

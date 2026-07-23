import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/models/ngo_request_model.dart';
import 'package:mobile_app/models/notification_model.dart';
import 'package:mobile_app/repositories/ngo_repository.dart';

class NgoState {
  final bool isLoading;
  final List<DonationModel> availableDonations;
  final List<NgoRequestModel> acceptedRequests;
  final List<NotificationModel> notifications;
  final DonationModel? selectedDonation;
  final String searchQuery;
  final String categoryFilter;
  final String foodTypeFilter;
  final String? errorMessage;
  final String? infoMessage;

  const NgoState({
    this.isLoading = false,
    this.availableDonations = const [],
    this.acceptedRequests = const [],
    this.notifications = const [],
    this.selectedDonation,
    this.searchQuery = '',
    this.categoryFilter = 'All',
    this.foodTypeFilter = 'All',
    this.errorMessage,
    this.infoMessage,
  });

  List<DonationModel> get filteredDonations {
    return availableDonations.where((donation) {
      final matchesSearch = searchQuery.isEmpty ||
          donation.foodName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          donation.pickupAddress.toLowerCase().contains(searchQuery.toLowerCase()) ||
          donation.foodCategory.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCategory = categoryFilter == 'All' ||
          donation.foodCategory.toLowerCase() == categoryFilter.toLowerCase();

      final matchesFoodType = foodTypeFilter == 'All' ||
          donation.foodType.toLowerCase() == foodTypeFilter.toLowerCase();

      return matchesSearch && matchesCategory && matchesFoodType;
    }).toList();
  }

  NgoState copyWith({
    bool? isLoading,
    List<DonationModel>? availableDonations,
    List<NgoRequestModel>? acceptedRequests,
    List<NotificationModel>? notifications,
    DonationModel? selectedDonation,
    String? searchQuery,
    String? categoryFilter,
    String? foodTypeFilter,
    String? errorMessage,
    String? infoMessage,
  }) {
    return NgoState(
      isLoading: isLoading ?? this.isLoading,
      availableDonations: availableDonations ?? this.availableDonations,
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      notifications: notifications ?? this.notifications,
      selectedDonation: selectedDonation ?? this.selectedDonation,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      foodTypeFilter: foodTypeFilter ?? this.foodTypeFilter,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }
}

class NgoNotifier extends StateNotifier<NgoState> {
  final NgoRepository _repository;

  NgoNotifier({required NgoRepository repository})
      : _repository = repository,
        super(const NgoState());

  Future<void> loadAvailableDonations() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getAvailableDonations();

    if (result is ApiSuccess<List<DonationModel>>) {
      state = state.copyWith(
        isLoading: false,
        availableDonations: result.data,
      );
    } else if (result is ApiFailure<List<DonationModel>>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
    }
  }

  Future<bool> acceptDonation({
    required DonationModel donation,
    required String ngoId,
    required String ngoName,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.acceptDonation(
      donation: donation,
      ngoId: ngoId,
      ngoName: ngoName,
      notes: notes,
    );

    if (result is ApiSuccess<NgoRequestModel>) {
      final updatedAvailable = state.availableDonations
          .where((d) => d.donationId != donation.donationId)
          .toList();
      final updatedAccepted = [result.data, ...state.acceptedRequests];

      state = state.copyWith(
        isLoading: false,
        availableDonations: updatedAvailable,
        acceptedRequests: updatedAccepted,
        infoMessage: 'Donation accepted! Pickup request created.',
      );
      return true;
    } else if (result is ApiFailure<NgoRequestModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
    return false;
  }

  Future<void> loadAcceptedRequests(String ngoId) async {
    final result = await _repository.getAcceptedRequests(ngoId);
    if (result is ApiSuccess<List<NgoRequestModel>>) {
      state = state.copyWith(acceptedRequests: result.data);
    }
  }

  Future<void> loadNotifications(String userId) async {
    final result = await _repository.getNgoNotifications(userId);
    if (result is ApiSuccess<List<NotificationModel>>) {
      state = state.copyWith(notifications: result.data);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(categoryFilter: category);
  }

  void setFoodTypeFilter(String foodType) {
    state = state.copyWith(foodTypeFilter: foodType);
  }

  void selectDonation(DonationModel donation) {
    state = state.copyWith(selectedDonation: donation);
  }
}

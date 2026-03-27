import 'package:flutter/material.dart';
import '../models/vendor_service_model.dart';
import '../models/service_model.dart';
import '../services/vendor_service_api_client.dart';

class VendorServicesProvider extends ChangeNotifier {
  // Vendor's own services
  List<VendorService> _vendorServices = [];
  bool _isLoadingVendorServices = false;
  String? _vendorServicesError;

  // Available services for selection
  List<Service> _availableServices = [];
  bool _isLoadingAvailableServices = false;
  String? _availableServicesError;

  // Vendors for a specific service (user browsing)
  List<dynamic> _vendorsForService = [];
  bool _isLoadingVendorsForService = false;
  String? _vendorsForServiceError;

  // Getters
  List<VendorService> get vendorServices => _vendorServices;
  bool get isLoadingVendorServices => _isLoadingVendorServices;
  String? get vendorServicesError => _vendorServicesError;

  List<Service> get availableServices => _availableServices;
  bool get isLoadingAvailableServices => _isLoadingAvailableServices;
  String? get availableServicesError => _availableServicesError;

  List<dynamic> get vendorsForService => _vendorsForService;
  bool get isLoadingVendorsForService => _isLoadingVendorsForService;
  String? get vendorsForServiceError => _vendorsForServiceError;

  // ===================================================
  // VENDOR METHODS - Manage own services
  // ===================================================

  /// Load all services added by a vendor
  Future<void> loadVendorServices(String vendorId) async {
    _isLoadingVendorServices = true;
    _vendorServicesError = null;
    notifyListeners();

    final services = await VendorServiceApiClient.getVendorServices(vendorId);
    _vendorServices = services;
    _isLoadingVendorServices = false;
    notifyListeners();
  }

  /// Add a new service to vendor's listings
  Future<bool> addService({
    required String vendorId,
    required String serviceId,
    required double pricing,
    required String pricingUnit,
    required String location,
    required String availability,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final service = await VendorServiceApiClient.addVendorService(
        vendorId: vendorId,
        serviceId: serviceId,
        pricing: pricing,
        pricingUnit: pricingUnit,
        location: location,
        availability: availability,
        startTime: startTime,
        endTime: endTime,
      );

      if (service != null) {
        _vendorServices.add(service);
        _vendorServicesError = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _vendorServicesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update a vendor's service
  Future<bool> updateService({
    required String vendorServiceId,
    double? pricing,
    String? location,
    String? availability,
    String? startTime,
    String? endTime,
    bool? isOnline,
  }) async {
    try {
      final updated = await VendorServiceApiClient.updateVendorService(
        vendorServiceId: vendorServiceId,
        pricing: pricing,
        location: location,
        availability: availability,
        startTime: startTime,
        endTime: endTime,
        isOnline: isOnline,
      );

      if (updated != null) {
        final index = _vendorServices.indexWhere((s) => s.id == vendorServiceId);
        if (index != -1) {
          _vendorServices[index] = updated;
          _vendorServicesError = null;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _vendorServicesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove a service from vendor's listings
  Future<bool> deleteService(String vendorServiceId) async {
    try {
      final success =
          await VendorServiceApiClient.deleteVendorService(vendorServiceId);
      if (success) {
        _vendorServices.removeWhere((s) => s.id == vendorServiceId);
        _vendorServicesError = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _vendorServicesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===================================================
  // USER METHODS - Browse available services and vendors
  // ===================================================

  /// Load all available services with vendor counts
  Future<void> loadAvailableServices() async {
    _isLoadingAvailableServices = true;
    _availableServicesError = null;
    notifyListeners();

    final services = await VendorServiceApiClient.getAllServices();
    _availableServices = services;
    _isLoadingAvailableServices = false;
    notifyListeners();
  }

  /// Get vendors offering a specific service
  Future<void> loadVendorsForService(
    String serviceId, {
    String? location,
    bool? onlineOnly,
  }) async {
    _isLoadingVendorsForService = true;
    _vendorsForServiceError = null;
    notifyListeners();

    final vendors = await VendorServiceApiClient.getVendorsForService(
      serviceId,
      location: location,
      onlineOnly: onlineOnly,
    );
    _vendorsForService = vendors;
    _isLoadingVendorsForService = false;
    notifyListeners();
  }

  /// Search vendors by service name
  Future<void> searchVendorsByServiceName(
    String serviceName, {
    String? location,
  }) async {
    _isLoadingVendorsForService = true;
    _vendorsForServiceError = null;
    notifyListeners();

    final vendors = await VendorServiceApiClient.getVendorsByServiceName(
      serviceName,
      location: location,
    );
    _vendorsForService = vendors;
    _isLoadingVendorsForService = false;
    notifyListeners();
  }

  // ===================================================
  // HELPER METHODS
  // ===================================================

  /// Get available locations
  List<String> getAvailableLocations() {
    return VendorServiceApiClient.getKarnatakaCities();
  }

  /// Clear all errors
  void clearErrors() {
    _vendorServicesError = null;
    _availableServicesError = null;
    _vendorsForServiceError = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _vendorServices = [];
    _isLoadingVendorServices = false;
    _vendorServicesError = null;
    _availableServices = [];
    _isLoadingAvailableServices = false;
    _availableServicesError = null;
    _vendorsForService = [];
    _isLoadingVendorsForService = false;
    _vendorsForServiceError = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_api_client.dart';

class ServiceProvider extends ChangeNotifier {
  List<Service> _allServices = [];
  List<Service> _filteredServices = [];
  
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  
  String _selectedDistrict = 'All Districts';
  String _searchQuery = '';

  // Getters
  List<Service> get allServices => _allServices;
  List<Service> get filteredServices => _filteredServices;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String get selectedDistrict => _selectedDistrict;
  String get searchQuery => _searchQuery;

  ServiceProvider() {
    _loadServices();
  }

  // Load all services from API
  Future<void> _loadServices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allServices = await ServiceApiClient.getServices();
      _applyFilters();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load services: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh services in background
  Future<void> refreshServices() async {
    try {
      _isRefreshing = true;
      notifyListeners();

      _allServices = await ServiceApiClient.getServices();
      _applyFilters();
      
      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh services: $e';
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // Set selected district and apply filters
  void setDistrict(String district) {
    _selectedDistrict = district;
    _applyFilters();
    notifyListeners();
  }

  // Set search query and apply filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters (location + search)
  void _applyFilters() {
    _filteredServices = _allServices.where((service) {
      // Filter by district
      bool districtMatch = _selectedDistrict == 'All Districts' ||
          service.location.toLowerCase() == _selectedDistrict.toLowerCase();

      // Filter by search query
      bool searchMatch = _searchQuery.isEmpty ||
          service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.vendorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return districtMatch && searchMatch;
    }).toList();

    // Sort by online status first, then by rating
    _filteredServices.sort((a, b) {
      if (a.isOnline != b.isOnline) {
        return a.isOnline ? -1 : 1;
      }
      return b.rating.compareTo(a.rating);
    });
  }

  // Get a single service by ID
  Future<Service?> getServiceById(String id) async {
    try {
      return await ServiceApiClient.getService(id);
    } catch (e) {
      _error = 'Failed to load service details: $e';
      notifyListeners();
      return null;
    }
  }
}

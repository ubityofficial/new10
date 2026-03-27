class Locations {
  // Karnataka Districts
  static const List<String> karnatakaDistricts = [
    'All Districts',
    'Bangalore Urban',
    'Bangalore Rural',
    'Belagavi',
    'Ballari',
    'Belgaum',
    'Bidar',
    'Bijapurnagar',
    'Chamarajanagar',
    'Chikballapur',
    'Chikmagalur',
    'Chitradurga',
    'Dakshina Kannada',
    'Davanagere',
    'Dharwad',
    'Gadag',
    'Gulbarga',
    'Hassan',
    'Haveri',
    'Kalaburagi',
    'Kodagu',
    'Kolar',
    'Koppal',
    'Mandya',
    'Mangalore',
    'Mysore',
    'Mysuru',
    'Raichur',
    'Shivamogga',
    'Tumkur',
    'Udupi',
    'Uttara Kannada',
    'Varanasi',
    'Vikarabad',
    'Vikarabad',
    'Yadgir',
  ];

  // Friendly names for districts (in case of changes)
  static Map<String, String> districtFriendlyNames = {
    'Bangalore Urban': 'Bengaluru Urban',
    'Bangalore Rural': 'Bengaluru Rural',
    'Belagavi': 'Belagavi (Belgaum)',
    'Ballari': 'Ballari (Bellary)',
    'Belgaum': 'Belgaum (Belagavi)',
    'Kalaburagi': 'Kalaburagi (Gulbarga)',
    'Gulbarga': 'Gulbarga (Kalaburagi)',
    'Mysore': 'Mysuru (Mysore)',
    'Mangalore': 'Mangaluru',
    'Shivamogga': 'Shimoga',
    'Uttara Kannada': 'Uttara Kannada (North Canara)',
  };

  // Get friendly name or original
  static String getFriendlyName(String district) {
    return districtFriendlyNames[district] ?? district;
  }

  // Get list of districts
  static List<String> getDistricts() => karnatakaDistricts;
}

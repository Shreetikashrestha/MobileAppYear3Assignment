class ApiConfig {
  // API Base URL Configuration
  // Change this based on your environment:
  // - iOS Simulator: http://127.0.0.1:5050 or http://localhost:5050
  // - Android Emulator: http://10.0.2.2:5050
  // - Real Device: http://YOUR_COMPUTER_IP:5050 (e.g., http://192.168.1.100:5050)
  
  static const String baseUrl = 'http://127.0.0.1:5050';
  
  // Alternative URLs (uncomment the one you need)
  // static const String baseUrl = 'http://localhost:5050'; // iOS Simulator alternative
  // static const String baseUrl = 'http://10.0.2.2:5050'; // Android Emulator
  // static const String baseUrl = 'http://192.168.1.100:5050'; // Real Device (replace with your IP)
  
  // API Endpoints
  static const String authEndpoint = '/api/auth';
  static const String usersEndpoint = '/api/users';
  static const String campaignsEndpoint = '/api/campaigns';
  static const String applicationsEndpoint = '/api/applications';
  static const String messagesEndpoint = '/api/messages';
  static const String notificationsEndpoint = '/api/notifications';
  static const String analyticsEndpoint = '/api/analytics';
  static const String profilesEndpoint = '/api/profiles';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

class ApiConfig {
  static const String baseUrl = 'https://waka-islx.onrender.com/api/wakafit';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers 
  static Map<String, String> getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
    }; 
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}
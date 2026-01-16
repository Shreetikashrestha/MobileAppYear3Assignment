class ApiEndpoints {
  static const String baseUrl = 'http://your-api-base-url.com/api';

  // Auth endpoints
  static const String studentLogin = '$baseUrl/auth/login';
  static const String students = '$baseUrl/students';
  static const String studentRegister = '$baseUrl/auth/register';
  static const String studentLogout = '$baseUrl/auth/logout';
  static const String studentProfile = '$baseUrl/students/profile';

  // Batch endpoints
  static const String batches = '$baseUrl/batches';
  static const String batchById = '$baseUrl/batches/:id';
  static const String batchByName = '$baseUrl/batches/name/:name';

  // Category endpoints
  static const String categories = '$baseUrl/categories';
  static const String categoryById = '$baseUrl/categories/:id';

  // Item endpoints
  static const String items = '$baseUrl/items';
  static const String itemById = '$baseUrl/items/:id';
  static const String itemsByUser = '$baseUrl/items/user/:userId';
  static const String lostItems = '$baseUrl/items/lost';
  static const String foundItems = '$baseUrl/items/found';
  static const String itemsByCategory = '$baseUrl/items/category/:categoryId';
}

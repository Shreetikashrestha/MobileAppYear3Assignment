class Campaign {
  final String category;
  final String image;
  final String logo;
  final String brandName;
  final String title;
  final String description;
  final String price;
  final String daysLeft;
  final String location;
  final String interested;

  Campaign({
    required this.category,
    required this.image,
    required this.logo,
    required this.brandName,
    required this.title,
    required this.description,
    required this.price,
    required this.daysLeft,
    required this.location,
    required this.interested,
  });

  // Convert Map to Campaign object
  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      category: map['category'] ?? '',
      image: map['image'] ?? '',
      logo: map['logo'] ?? '',
      brandName: map['brandName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      daysLeft: map['daysLeft'] ?? '',
      location: map['location'] ?? '',
      interested: map['interested'] ?? '',
    );
  }

  // Convert Campaign to Map
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'image': image,
      'logo': logo,
      'brandName': brandName,
      'title': title,
      'description': description,
      'price': price,
      'daysLeft': daysLeft,
      'location': location,
      'interested': interested,
    };
  }
}
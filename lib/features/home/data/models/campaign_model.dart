import 'package:equatable/equatable.dart';

class Campaign extends Equatable {
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

  const Campaign({
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

  @override
  List<Object> get props => [
        category,
        image,
        logo,
        brandName,
        title,
        description,
        price,
        daysLeft,
        location,
        interested,
      ];
}

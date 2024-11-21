class Category {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final String categoryType;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.categoryType,
  });

  // Chuyển đổi Category thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'category_type': categoryType,
    };
  }

  // Chuyển đổi Map thành Category
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      categoryType: map['category_type'],
    );
  }
}

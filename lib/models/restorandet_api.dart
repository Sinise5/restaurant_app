class RestoranDetApiM {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String pictureId;
  final List<Menu> foods;
  final List<Menu> drinks;
  final List<Category> categories;
  final double rating;
  late final List<CustomerReview> customerReviews;

  RestoranDetApiM({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.pictureId,
    required this.foods,
    required this.drinks,
    required this.categories,
    required this.rating,
    required this.customerReviews,
  });

  factory RestoranDetApiM.fromJson(Map<String, dynamic> json) {
    var menuData = json['menus'];
    List<Menu> foodMenus = (menuData['foods'] as List)
        .map((item) => Menu(name: item['name']))
        .toList();
    List<Menu> drinkMenus = (menuData['drinks'] as List)
        .map((item) => Menu(name: item['name']))
        .toList();
    List<Category> categoryList = (json['categories'] as List)
        .map((item) => Category(name: item['name']))
        .toList();
    List<CustomerReview> reviews = (json['customerReviews'] as List)
        .map((item) => CustomerReview.fromJson(item))
        .toList();

    return RestoranDetApiM(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      city: json['city'],
      address: json['address'],
      pictureId: json['pictureId'],
      foods: foodMenus,
      drinks: drinkMenus,
      categories: categoryList,
      rating: json['rating'].toDouble(),
      customerReviews: reviews,
    );
  }

  // Menambahkan toJson untuk mengonversi kembali objek ke format JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'address': address,
      'pictureId': pictureId,
      'menus': {
        'foods': foods.map((food) => {'name': food.name}).toList(),
        'drinks': drinks.map((drink) => {'name': drink.name}).toList(),
      },
      'categories':
          categories.map((category) => {'name': category.name}).toList(),
      'rating': rating,
      'customerReviews':
          customerReviews.map((review) => review.toJson()).toList(),
    };
  }
}

class Menu {
  final String name;

  Menu({required this.name});

  // Menambahkan toJson untuk Menu
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class Category {
  final String name;

  Category({required this.name});

  // Menambahkan toJson untuk Category
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class CustomerReview {
  final String name;
  final String review;
  final String date;

  CustomerReview(
      {required this.name, required this.review, required this.date});

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      name: json['name'],
      review: json['review'],
      date: json['date'],
    );
  }

  // Menambahkan toJson untuk CustomerReview
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'review': review,
      'date': date,
    };
  }
}

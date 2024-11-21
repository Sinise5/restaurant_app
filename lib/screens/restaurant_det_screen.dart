import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/providers/theme_provider.dart';

class RestorandetApi extends StatefulWidget {
  final String restaurantId;

  const RestorandetApi({super.key, required this.restaurantId});

  @override
  _RestorandetApiState createState() => _RestorandetApiState();
}

class _RestorandetApiState extends State<RestorandetApi> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetailsWithConnectivity(provider);
    });
  }

  void _fetchDetailsWithConnectivity(RestaurantProvider provider) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showConnectionError();
      provider.fetchRestaurantDetails(widget.restaurantId);
    } else {
      provider.fetchRestaurantDetails(widget.restaurantId);
    }
    provider.checkRestaurantFavorite(context, widget.restaurantId);
    debugPrint('xxx ${ConnectivityResult.none}  ${widget.restaurantId}   x  ');
  }

  void _showConnectionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No internet connection. Please try again later.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);
    final themeProvider = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: themeProvider.currentTheme.scaffoldBackgroundColor,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (provider.restaurant == null) && (provider.errorInternet)
              ? _buildHeader(context)
              : (provider.errorInternet)
                  ? const Center(
                      child: Text(
                          'No internet connection. Please try again later.'),
                    )
                  : (provider.notfound)
                      ? const Center(
                          child: Text('No data available'),
                        )
                      : provider.restaurant == null
                          ? const Center(
                              child: Text('No data available'),
                            )
                          : provider.errorMessage.isNotEmpty
                              ? Center(child: Text(provider.errorMessage))
                              : SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RestaurantImage(provider: provider),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RestaurantInfo(provider: provider),
                                            const SizedBox(height: 16),
                                            const Text("Menu:",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            RestaurantMenu(provider: provider),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                _showAddReviewDialog(
                                                    context, provider);
                                              },
                                              child: const Text("Add Review"),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text("Customer Reviews:",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            provider != null
                                                ? CustomerReviews(
                                                    provider: provider)
                                                : const Text(
                                                    'Data tidak tersedia'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
    );
  }

  void _showAddReviewDialog(BuildContext context, RestaurantProvider provider) {
    final nameController = TextEditingController();
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeNotifier>(context);
        return AlertDialog(
          title: Text(
            "Add Review",
            style: TextStyle(color: themeProvider.textColor),
          ),
          backgroundColor: themeProvider.currentTheme.scaffoldBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintStyle: TextStyle(
                    color: themeProvider.textColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(
                    Icons.account_circle,
                    color: themeProvider.currentTheme.iconTheme.color,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reviewController,
                decoration: InputDecoration(
                  labelText: 'Review',
                  hintStyle: TextStyle(
                    color: themeProvider.textColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(
                    Icons.reviews_outlined,
                    color: themeProvider.currentTheme.iconTheme.color,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                provider.addReview(
                  restaurantId: widget.restaurantId,
                  name: nameController.text,
                  review: reviewController.text,
                );
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 50, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.black, size: 30),
              ),
              const Text(
                "Restaurant Detail",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.restaurant_outlined,
                  color: Colors.black, size: 30),
            ],
          ),
          const SizedBox(height: 100),
          const Center(
            child: Text(
              'No internet connection. Please try again later.',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantImage extends StatelessWidget {
  final RestaurantProvider provider;

  const RestaurantImage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Image.network(
            'https://restaurant-api.dicoding.dev/images/medium/${provider.restaurant?.pictureId ?? ''}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 30),
          ),
        ),
        Positioned(
          bottom: 15,
          right: 19,
          child: Consumer<RestaurantProvider>(
            builder: (context, provider, child) {
              debugPrint('cek xxx${provider.isFavorite}');
              return GestureDetector(
                onTap: () => provider.toggleFavorite(
                    context, provider.restaurants_data_json),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: Icon(
                    provider.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: provider.isFavorite ? Colors.red : Colors.grey,
                    size: 27,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RestaurantInfo extends StatelessWidget {
  final RestaurantProvider provider;

  const RestaurantInfo({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider.restaurant?.name ?? 'Unknown Restaurant',
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 20),
            const SizedBox(width: 4),
            Text(provider.restaurant!.city ?? 'Unknown Restaurant',
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(width: 10),
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
                "Rating: ${provider.restaurant!.rating ?? 'Unknown Restaurant'}",
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Categories:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: provider.restaurant!.categories.map((category) {
            return Chip(
              label: Text(category.name),
              backgroundColor: Colors.teal[100],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text("Description:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          provider.restaurant!.description ?? 'Unknown Restaurant',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}

class RestaurantMenu extends StatelessWidget {
  final RestaurantProvider provider;

  const RestaurantMenu({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Foods:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        MenuGrid(menuList: provider.restaurant!.foods),
        const SizedBox(height: 16),
        const Text("Drinks:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        MenuGrid(menuList: provider.restaurant!.drinks),
      ],
    );
  }
}

class MenuGrid extends StatelessWidget {
  final List<dynamic> menuList;

  const MenuGrid({super.key, required this.menuList});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final menu = menuList[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                menu.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomerReviews extends StatelessWidget {
  final RestaurantProvider provider;

  const CustomerReviews({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: provider.restaurant!.customerReviews.length,
      itemBuilder: (context, index) {
        final review = provider.restaurant!.customerReviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  review.review,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  review.date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

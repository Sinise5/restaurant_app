import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Function()? onTap;
  final bool isActive;
  final int badgeCount;

  const CustomCard(
    this.icon,
    this.title,
    this.subtitle,
    this.onTap,
    this.isActive,
    this.badgeCount, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget badgeWidget = Positioned(
      top: 25,
      left: 60,
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 1, color: Colors.white),
        ),
        constraints: const BoxConstraints(
          minWidth: 18,
          minHeight: 18,
        ),
        child: Text(
          badgeCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 7, 0, 10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: isActive ? Colors.blue.shade300 : Colors.grey.shade400,
              elevation: 2,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  width: MediaQuery.of(context).size.width - 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(width: 45),
                      Container(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 160,
                          maxWidth: MediaQuery.of(context).size.width - 160,
                          minHeight: 70,
                          maxHeight: 400,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: isActive ? Colors.blue.shade300 : Colors.grey.shade400,
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                ),
                child: Icon(icon, color: Colors.white, size: 50),
              ),
            ),
          ),
          badgeCount > 0 ? badgeWidget : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

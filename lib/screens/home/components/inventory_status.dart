import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/constants.dart';

class InventoryStatus extends StatelessWidget {
  const InventoryStatus({super.key});

  // Simulated API call to fetch inventory data
  Future<Map<String, dynamic>> fetchInventoryData() async {
    return {
      'currentStocks': [
        {'name': 'Round Gallon', 'quantity': 120},
        {'name': 'Slim Gallon', 'quantity': 85},
      ],
      'inventoryDetails': [
        {'title': 'New Orders', 'value': '3'},
        {'title': 'Cancellation Requests', 'value': '0'},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchInventoryData(), // Call the fetch function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final currentStocks = data['currentStocks'] as List<Map<String, dynamic>>;
          final inventoryDetails = data['inventoryDetails'] as List<Map<String, String>>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: inventoryDetails.map((detail) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        detail['title']!,
                        style: const TextStyle(fontSize: 14, color: kPrimaryColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail['value']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 4),
              Divider(thickness: 1, color: Colors.grey[300]),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Current Stocks",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Quantity",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentStocks.length,
                itemBuilder: (context, index) {
                  final stock = currentStocks[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stock['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${stock['quantity']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey[300]),
            ],
          );
        },
      ),
    );
  }
}
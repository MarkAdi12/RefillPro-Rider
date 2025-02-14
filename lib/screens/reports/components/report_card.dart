import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/constants.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
  });

  final List<Map<String, dynamic>> reportDetails = const [
    {'title': 'Delivered', 'value': 10},
    {'title': 'Pick Up Orders', 'value': 5},
    {'title': 'Cancelled', 'value': 2},
    {'title': 'Failed', 'value': 1},
  ];

  final List<Map<String, dynamic>> containerDetails = const [
    {'title': 'Returned Container', 'value': 3},
    {'title': 'Borrowed Container', 'value': 4},
    {'title': 'Damaged Container', 'value': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    reportDetails[0]['title']!,
                    style: const TextStyle(
                        fontSize: 14,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reportDetails[0]['value'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    reportDetails[1]['title']!,
                    style: const TextStyle(
                        fontSize: 14,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reportDetails[1]['value'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    reportDetails[2]['title']!,
                    style: const TextStyle(
                        fontSize: 14,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reportDetails[2]['value'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(

                children: [
                  Text(
                    reportDetails[3]['title']!,
                    style: const TextStyle(
                        fontSize: 14,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reportDetails[3]['value'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 4),
          Divider(thickness: 1, color: Colors.grey[300]),
          const SizedBox(height: 4),
          // Container Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Container Status",
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
            itemCount: containerDetails.length,
            itemBuilder: (context, index) {
              final container = containerDetails[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    container['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${container['value']}",
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
          const SizedBox(height: 8),
          // Total Transaction and Total Cash
          Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Total Transaction',
                  hintText: '15 Orders Completed',
                  hintStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 18),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Total Cash',
                  hintText: '₱450.00',
                  hintStyle: TextStyle(
                      fontFamily: 'arial',
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 18),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Record Payment',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: () {}, child: Text('Record Cash'))
        ],
      ),
    );
  }
}

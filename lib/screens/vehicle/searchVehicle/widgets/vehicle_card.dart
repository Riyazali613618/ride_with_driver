import 'package:flutter/material.dart';

import '../../../../api/api_model/vehicle/search_vehicles.dart';


class VehicleCard extends StatelessWidget {
  final VehicleOwner owner;

  const VehicleCard({super.key, required this.owner});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(owner.firstName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                Text('⭐ ${owner.rating}'),
                Text('Min Charge ₹${owner.minimumCharges}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

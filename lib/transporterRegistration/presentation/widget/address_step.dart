// lib/features/transporter_registration/presentation/widgets/address_step.dart
import 'package:flutter/material.dart';

import '../../domain/Validators.dart';

class AddressStep extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController pincodeController;
  final Function(String) onPincodeEntered;
  final Function(String?) onStateChanged;
  final Function(String?) onCityChanged;
  final List<String> states;
  final List<String> cities;
  final VoidCallback onNext;

  const AddressStep({
    super.key,
    required this.addressController,
    required this.pincodeController,
    required this.onPincodeEntered,
    required this.onStateChanged,
    required this.onCityChanged,
    required this.states,
    required this.cities,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            TextFormField(
              controller: addressController,
              validator: (v) => Validators.required(v, 'Address'),
              decoration: InputDecoration(labelText: 'Address Line'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: pincodeController,
              validator: Validators.pincode,
              maxLength: 6,
              decoration: InputDecoration(labelText: 'Pincode'),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                if (v.length == 6) onPincodeEntered(v);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onStateChanged,
              validator: (v) => Validators.required(v, 'State'),
              decoration: const InputDecoration(labelText: 'State'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: onCityChanged,
              validator: (v) => Validators.required(v, 'City'),
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const Spacer(),
            ElevatedButton(onPressed: onNext, child: const Text('Continue')),
          ],
        ),
      ),
    );
  }
}

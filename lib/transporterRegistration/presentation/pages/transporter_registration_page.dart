// lib/features/transporter_registration/presentation/pages/transporter_registration_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../transporter_form_cubit.dart';
import '../transporter_form_state.dart';
import '../widget/address_step.dart';
import '../widget/document_step.dart';

class TransporterRegistrationPage extends StatelessWidget {
  const TransporterRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransporterFormCubit(),
      child: BlocBuilder<TransporterFormCubit, TransporterFormState>(
        builder: (context, state) {
          final cubit = context.read<TransporterFormCubit>();

          return Scaffold(
            appBar: AppBar(title: const Text('Transporter Registration')),
            body: Stack(
              children: [
                PageView(
                  controller: PageController(initialPage: state.currentStep),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    AddressStep(
                      addressController: TextEditingController(),
                      pincodeController: TextEditingController(),
                      states: ['Delhi', 'Maharashtra'],
                      cities: ['Mumbai', 'Pune'],
                      onPincodeEntered: (p) {},
                      onStateChanged: (_) {},
                      onCityChanged: (_) {},
                      onNext: cubit.nextStep,
                    ),
                    DocumentStep(
                      gstController: TextEditingController(),
                      isVerified: false,
                      isVerifying: false,
                      onVerify: () {},
                      onNext: cubit.nextStep,
                      onPermitUploaded: (url) {},
                    ),
                  ],
                ),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }
}

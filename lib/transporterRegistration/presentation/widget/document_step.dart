// lib/features/transporter_registration/presentation/widgets/document_step.dart
import 'package:flutter/material.dart';

import '../../../components/media_uploader_widget.dart';
import '../../domain/Validators.dart';

class DocumentStep extends StatelessWidget {
  final TextEditingController gstController;
  final bool isVerified;
  final bool isVerifying;
  final VoidCallback onVerify;
  final VoidCallback onNext;
  final Function(String) onPermitUploaded;

  const DocumentStep({
    super.key,
    required this.gstController,
    required this.isVerified,
    required this.isVerifying,
    required this.onVerify,
    required this.onNext,
    required this.onPermitUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Documents', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: gstController,
                  maxLength: 15,
                  validator: Validators.gst,
                  decoration: const InputDecoration(labelText: 'GST Number'),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isVerifying ? null : onVerify,
                child: isVerifying
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator())
                    : Text(isVerified ? 'Verified' : 'Verify'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MediaUploader(
            label: 'Transportation Permit (Optional)',
            kind: "transporter",
            showPreview: true,
            showDirectImage: true,
            initialUrl: /*_transporterModel.transportationPermit*/"",
            onMediaUploaded:onPermitUploaded,
            required: false,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
          ),
          const Spacer(),
          ElevatedButton(onPressed: onNext, child: const Text('Continue')),
        ],
      ),
    );
  }
}

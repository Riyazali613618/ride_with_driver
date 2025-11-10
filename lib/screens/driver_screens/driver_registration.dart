import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../../components/dotted_border.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isOwner = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildUserTypeToggle(),
            // const SizedBox(height: 20),
            // isOwner ? const OwnerForm() :
            //
            const DriverForm(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorConstants.primaryColor,
      elevation: 0,
      leading: CupertinoNavigationBarBackButton(
        color: ColorConstants.white,
      ),
      title: const Row(
        children: [
          Text(
            ' Fill the Form ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: const [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: null,
        ),
      ],
    );
  }

  Widget _buildUserTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton('Owner', isOwner),
          ),
          Expanded(
            child: _buildToggleButton('Driver', !isOwner),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOwner = text == 'Owner';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstants.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class OwnerForm extends StatefulWidget {
  const OwnerForm({Key? key}) : super(key: key);

  @override
  State<OwnerForm> createState() => _OwnerFormState();
}

class _OwnerFormState extends State<OwnerForm> {
  final TextEditingController _businessNameController =
      TextEditingController(text: 'Enter Business Name');
  final TextEditingController _contactPersonController =
      TextEditingController(text: 'Enter Contact person name');
  final TextEditingController _businessOwnerController =
      TextEditingController(text: 'Enter Business owner name');
  final TextEditingController _mobileController =
      TextEditingController(text: 'Enter Phone Number');
  final TextEditingController _emailController =
      TextEditingController(text: 'Enter Email');
  final TextEditingController _establishmentController =
      TextEditingController(text: '20/06/2022');
  final TextEditingController _experienceController =
      TextEditingController(text: '3');
  final TextEditingController _addressController =
      TextEditingController(text: 'Gurugram, India');
  final TextEditingController _registrationController =
      TextEditingController(text: '12345ASD12');
  final TextEditingController _aadharController =
      TextEditingController(text: '12345ASD12');
  final TextEditingController _panController =
      TextEditingController(text: '12345ASD12');
  final TextEditingController _vehiclesController =
      TextEditingController(text: '10');
  final TextEditingController _bioController =
      TextEditingController(text: 'Tell me about your Self');

  String selectedGender = 'Female';
  String selectedCountryCode = '+234';
  String selectedLocation = 'Gurugram';
  bool agreementAccepted = false;

  List<FileUploadItem> uploadedFiles = [
    FileUploadItem('Car image_JPEG', '200 KB', 0.4),
    FileUploadItem('Registrations_Resume.pdf', '200 KB', 1.0),
    FileUploadItem('Owner_JPEG', '200 KB', 1.0),
    FileUploadItem('Business Office front img_JPEG', '200 KB', 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormFields(),
        const SizedBox(height: 24),
        _buildFileUploadSection(),
        const SizedBox(height: 16),
        _buildAgreementSection(),
        const SizedBox(height: 16),
        _buildViewSubscriptionsButton(),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _businessNameController,
          label: 'Business Name',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _contactPersonController,
          label: 'Contact person',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _businessOwnerController,
          label: 'Business Owner name',
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
            'Gender', selectedGender, ['Female', 'Male', 'Other']),
        const SizedBox(height: 16),
        _buildPhoneNumberField(),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Email id',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _establishmentController,
          label: 'Establishment date/year',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _experienceController,
          label: 'Experience (Years)',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _addressController,
          label: 'Address(full address)',
        ),
        const SizedBox(height: 16),
        _buildDropdownField('Served location(city/town)', selectedLocation,
            ['Gurugram', 'Delhi', 'Noida']),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _registrationController,
          label: 'Registration number',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _aadharController,
          label: 'Aadhar card',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _vehiclesController,
          label: 'No. of vehicles',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _bioController,
          label: 'Add Bio',
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Number',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              child: _buildDropdownField(
                  '', selectedCountryCode, ['+234', '+91', '+1']),
            ),
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                    hintStyle:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
                fontSize: 14, color: ColorConstants.appBlue.withAlpha(100)),
          ),
          const SizedBox(height: 5),
        ],
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  if (label == 'Gender') {
                    selectedGender = newValue;
                  } else if (label == 'Served location(city/town)') {
                    selectedLocation = newValue;
                  } else if (label == '') {
                    selectedCountryCode = newValue;
                  }
                });
              }
            },
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUploadContainer(),
        const SizedBox(height: 16),
        ...uploadedFiles.map((file) => _buildUploadedFile(file)).toList(),
      ],
    );
  }

  Widget _buildUploadContainer() {
    return CustomPaint(
      isComplex: true,
      painter: DottedBorderPainter(),
      child: Container(
          height: 120.0,
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: ColorConstants.greyLight.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.cloud_upload,
                    color: ColorConstants.primaryColor,
                    size: 24.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    style: TextStyle(letterSpacing: 1, wordSpacing: 1),
                    children: [
                      TextSpan(
                        text: 'Click to Upload',
                        style: TextStyle(
                          color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text: ' or drag and drop',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text(
                  '(Max. File size: 25 MB)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildUploadedFile(FileUploadItem file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.doc_text),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name),
                Text(
                  file.size,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: file.progress,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          file.progress == 1.0
                              ? ColorConstants.appColorGreen
                              : ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                        width:
                            8), // Add some spacing between progress bar and text
                    Text(
                      '${(file.progress * 100).toInt()}%',
                      // Convert progress to percentage
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (file.progress == 1.0)
            Icon(CupertinoIcons.check_mark_circled_solid,
                color: ColorConstants.appColorGreen)
          else
            Icon(
              CupertinoIcons.delete_simple,
              size: 20,
              color: ColorConstants.appBlue.withAlpha(150),
            ),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Row(
      children: [
        Checkbox(
          value: agreementAccepted,
          onChanged: (value) {
            setState(() {
              agreementAccepted = value!;
            });
          },
          activeColor: ColorConstants.primaryColor,
        ),
        const Text(
          'Agreement acceptation',
          style: TextStyle(
            color: ColorConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildViewSubscriptionsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: const Text(
          'View Subscriptionsddddddddd',
          style: TextStyle(fontSize: 16, color: ColorConstants.white),
        ),
      ),
    );
  }
}

class DriverForm extends StatefulWidget {
  const DriverForm({Key? key}) : super(key: key);

  @override
  State<DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  final TextEditingController _fullNameController =
      TextEditingController(text: 'Shivangi Raj');
  final TextEditingController _mobileController =
      TextEditingController(text: '08085472417');
  final TextEditingController _emailController =
      TextEditingController(text: 'ABC@gmail.com');
  final TextEditingController _experienceController =
      TextEditingController(text: '3');
  final TextEditingController _addressController =
      TextEditingController(text: 'Gurugram, India');
  final TextEditingController _licenseController =
      TextEditingController(text: '12345ASD12');
  final TextEditingController _aadharController =
      TextEditingController(text: '12345ASD12');
  final TextEditingController _panController =
      TextEditingController(text: '12345ASD12');
  final TextEditingController _chargeController =
      TextEditingController(text: '1000');
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String selectedGender = 'Female';
  String selectedCountryCode = '+234';
  String selectedLanguage = 'English, Hindi';
  String selectedLocation = 'Gurugram';
  String selectedVehicleType = 'SUV, Bus, Truck';
  String selectedCurrency = 'INR';
  bool agreementAccepted = false;

  List<FileUploadItem> uploadedFiles = [
    FileUploadItem('Aadhar Card_Resume.pdf', '200 KB', 0.4),
    FileUploadItem('Driving Licence_Resume.pdf', '200 KB', 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormFields(),
        const SizedBox(height: 20),
        _buildFileUploadSection(),
        const SizedBox(height: 20),
        _buildAgreementSection(),
        const SizedBox(height: 20),
        _buildViewSubscriptionsButton(),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _fullNameController,
          label: 'Full name',
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
            'Gender', selectedGender, ['Female', 'Male', 'Other']),
        const SizedBox(height: 16),
        _buildDateOfBirth(),
        const SizedBox(height: 16),
        _buildPhoneNumberField(),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Email id',
        ),
        const SizedBox(height: 16),
        _buildDropdownField('Language spoken', selectedLanguage,
            ['English, Hindi', 'English', 'Hindi']),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _experienceController,
          label: 'Experience (Years)',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _addressController,
          label: 'Address(full address)',
        ),
        const SizedBox(height: 16),
        _buildDropdownField('Served location(city/town)', selectedLocation,
            ['Gurugram', 'Delhi', 'Noida']),
        const SizedBox(height: 16),
        _buildDropdownField('Familiar with vehicle type', selectedVehicleType,
            ['SUV, Bus, Truck', 'Car', 'Bike']),
        const SizedBox(height: 16),
        _buildLicenseField(),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _aadharController,
          label: 'Aadhar card',
        ),
        const SizedBox(height: 16),
        _buildMinimumChargeField(),
      ],
    );
  }

  Widget _buildDateOfBirth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth (DOB)',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _dayController,
                hint: 'Day',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                controller: _monthController,
                hint: 'Month',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                controller: _yearController,
                hint: 'Year',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Number',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              child: _buildDropdownField(
                  '', selectedCountryCode, ['+234', '+91', '+1']),
            ),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLicenseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driving license',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _licenseController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Verify Now',
                style: TextStyle(color: ColorConstants.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMinimumChargeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum charge',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              child: _buildDropdownField(
                  '', selectedCurrency, ['INR', 'USD', 'EUR']),
            ),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _chargeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: ColorConstants.appBlue.withAlpha(100),
            ),
          ),
          SizedBox(
            height: 5,
          )
        ],
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  switch (label) {
                    case 'Gender':
                      selectedGender = newValue;
                      break;
                    case 'Language spoken':
                      selectedLanguage = newValue;
                      break;
                    case 'Served location(city/town)':
                      selectedLocation = newValue;
                      break;
                    case 'Familiar with vehicle type':
                      selectedVehicleType = newValue;
                      break;
                    case '':
                      if (items.contains('+234')) {
                        selectedCountryCode = newValue;
                      } else {
                        selectedCurrency = newValue;
                      }
                      break;
                  }
                });
              }
            },
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUploadContainer(),
        const SizedBox(height: 16),
        ...uploadedFiles.map((file) => _buildUploadedFile(file)).toList(),
      ],
    );
  }

  Widget _buildUploadContainer() {
    return CustomPaint(
      isComplex: true,
      painter: DottedBorderPainter(),
      child: Container(
          height: 120.0,
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: ColorConstants.greyLight.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.cloud_upload,
                    color: ColorConstants.primaryColor,
                    size: 24.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    style: TextStyle(letterSpacing: 1, wordSpacing: 1),
                    children: [
                      TextSpan(
                        text: 'Click to Upload',
                        style: TextStyle(
                          color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text: ' or drag and drop',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text(
                  '(Max. File size: 25 MB)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildUploadedFile(FileUploadItem file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.doc_text),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name),
                Text(
                  file.size,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: file.progress,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          file.progress == 1.0
                              ? ColorConstants.appColorGreen
                              : ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                        width:
                            8), // Add some spacing between progress bar and text
                    Text(
                      '${(file.progress * 100).toInt()}%',
                      // Convert progress to percentage
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (file.progress == 1.0)
            Icon(CupertinoIcons.check_mark_circled_solid,
                color: ColorConstants.appColorGreen)
          else
            Icon(
              CupertinoIcons.delete_simple,
              size: 20,
              color: ColorConstants.appBlue.withAlpha(150),
            ),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Row(
      children: [
        Checkbox(
          value: agreementAccepted,
          onChanged: (value) {
            setState(() {
              agreementAccepted = value!;
            });
          },
          activeColor: ColorConstants.primaryColor,
        ),
        const Text(
          'Agreement acceptation',
          style: TextStyle(
            color: ColorConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildViewSubscriptionsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => PlanSelectionScreen()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          ),
        ),
        child: const Text(
          'Next',
          style: TextStyle(fontSize: 16, color: ColorConstants.white),
        ),
      ),
    );
  }
}

Widget _buildViewSubscriptionsButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'View Subscriptions',
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.label = '',
    this.hint,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: ColorConstants.appBlue,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
        ],
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            style: TextStyle(
                fontSize: 12,
                color: ColorConstants.appBlue.withAlpha(100),
                fontWeight: FontWeight.w500),
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  fontSize: 12,
                  color: ColorConstants.appBlue,
                  fontWeight: FontWeight.w500),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: ColorConstants.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FileUploadItem {
  final String name;
  final String size;
  final double progress;

  FileUploadItem(this.name, this.size, this.progress);
}

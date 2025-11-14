import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/plan/presentation/screens/plan_selection_screen.dart';
import '../bloc/plan_bloc.dart';
import '../bloc/plan_event.dart';

class UserTypeScreen extends StatelessWidget {
  final List<String> userTypes = [
    "DRIVER",
    "E_RICKSHAW",
    "AUTO_RICKSHAW",
    "TAXI",
    "TRANSPORTER"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select User Type")),
      body: ListView.builder(
        itemCount: userTypes.length,
        itemBuilder: (context, index) {
          final type = userTypes[index];
          return ListTile(
            title: Text(type),
            onTap: () {
              context.read<PlanBloc>().add(FetchUserStatusEvent(type));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlanSelectionScreen(category: type),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/plan/presentation/screens/plan_selection_screen.dart';
import '../bloc/plan_bloc.dart';
import '../bloc/plan_event.dart';
import '../bloc/plan_state.dart';

class UserTypeScreen extends StatelessWidget {
  final List<String> userTypes = [
    "DRIVER",
    "E_RICKSHAW",
    "AUTO_RICKSHAW",
    "TAXI",
    "TRANSPORTER"
  ];
  String selectType = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select User Type")),
      body: BlocListener<PlanBloc, PlanState>(
        listener: (context, state) {
          if (!state.loading && state.statusData != null) {
            checkStatus(context);
          }

          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        child: ListView.builder(
          itemCount: userTypes.length,
          itemBuilder: (context, index) {
            final type = userTypes[index];
            return ListTile(
              title: Text(type),
              onTap: () {
                context.read<PlanBloc>().add(FetchUserStatusEvent(selectType));
              },
            );
          },
        ),
      ),
    );
  }

  void checkStatus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlanSelectionScreen(category: selectType),
      ),
    );
  }
}

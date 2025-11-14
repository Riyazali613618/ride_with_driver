import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/plan/presentation/widgets/plan_card.dart';
import '../bloc/plan_bloc.dart';
import '../bloc/plan_state.dart';
import '../bloc/plan_event.dart';

class PlanSelectionScreen extends StatefulWidget {
  final String category;

  const PlanSelectionScreen({super.key, required this.category});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  final pageController = PageController(viewportFraction: 0.80,initialPage: 1);

  @override
  void initState() {
    super.initState();
    context.read<PlanBloc>().add(FetchPlansEvent(
          widget.category,
          "68dabd590b3041213387d616",
          "68e7bd9c20a588293b4cbd0a",
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose Your Subscription Plan")),
      body: BlocBuilder<PlanBloc, PlanState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          if (state.plans == null) {
            return const Center(child: Text("No plans available"));
          }

          return PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.plans!.length,
            pageSnapping: true,
            clipBehavior: Clip.none,
            controller: pageController,
            itemBuilder: (context, index) {
              final plan = state.plans![index];
              return Center(
                child: PlanCard(plan: plan,category:widget.category),
              );
            },
          );
        },
      ),
    );
  }
}

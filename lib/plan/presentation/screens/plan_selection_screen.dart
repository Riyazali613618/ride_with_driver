import 'package:carousel_slider/carousel_slider.dart';
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
  final pageController = PageController(viewportFraction: 0.80, initialPage: 1);
  int currentIndex = 0;
  final List<Map<String, dynamic>> plans = [
    {
      "title": "Starter Plan",
      "validity": "Validity 1 Month",
      "price": "₹ 100",
      "offer": "60% Off",
      "benefits": [
        "Unlimited client calls",
        "Unlimited chats",
        "Unlimited Quotation Request",
        "Booking Dashboard",
        "Add and edit vehicles"
      ]
    },
    {
      "title": "Popular Plan",
      "validity": "Validity 3 Months",
      "price": "₹ 100",
      "offer": "75% Off",
      "benefits": [
        "Unlimited client calls",
        "Unlimited chats",
        "Unlimited Quotation Request",
        "Booking Dashboard",
        "Add and edit vehicles"
      ]
    },
    {
      "title": "Best Value Plan",
      "validity": "Validity 12 Months",
      "price": "₹ 100",
      "offer": "85% Off",
      "benefits": [
        "Unlimited client calls",
        "Unlimited chats",
        "Unlimited Quotation Request",
        "Booking Dashboard",
        "Add and edit vehicles"
      ]
    },
  ];
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

          return Center(
            child: CarouselSlider.builder(
              itemCount: plans.length,
              itemBuilder: (context, index, realIdx) {
                final plan = state.plans![index];
                return _planCard(plans[index], index == currentIndex);
            
              },
              options: CarouselOptions(
                height: 380,
                enlargeCenterPage: false,
                viewportFraction: 0.60,

                onPageChanged: (index, reason) {
                  setState(() => currentIndex = index);
                },
              ),
            ),
          );
          /*PageView.builder(
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
          )*/
          ;
        },
      ),
    );
  }
}


Widget _planCard(Map<String, dynamic> data, bool isActive) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: const EdgeInsets.all( 6),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isActive ? Colors.purple : Colors.grey.shade300,
      ),
      boxShadow: isActive
          ? [
        BoxShadow(
            color: Colors.purple.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 3)
      ]
          : [],
      gradient: isActive
          ? LinearGradient(
        colors: [Colors.purple.shade50, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )
          : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data["title"],
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(data["validity"],
            style: const TextStyle(fontSize: 12, color: Colors.black87)),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(data["price"],
                style:
                const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple),
              ),
              child: Text(
                data["offer"],
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.purple,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text("Benefits:",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...List.generate(
          data["benefits"].length,
              (i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data["benefits"][i],
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Center(
          child: Container(
            width: 160,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.orange],
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Continue",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}


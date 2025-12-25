import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:r_w_r/components/app_loader.dart';
import 'package:r_w_r/features/newDashboard/dashboard_model.dart';
import 'package:speedometer_chart/speedometer_chart.dart';

import '../../features/vehicles/presentation/pages/vehicles_list_page.dart';

class SummaryCards extends StatelessWidget {
  final DashboardMetrics data;
  const SummaryCards( {required this.data,super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                title: "Total Revenue",
                amount: "₹ ${data.totalRevenue}",
                subtitle: "Total earnings from all Bookings",
                color: Color(0xFF2ECC71),
                icon: Image.asset(
                  "assets/img/money_bag.png",
                  width: 15,
                  height: 15,
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: _InfoCard(
                title: "Outstanding Amount",
                amount: "₹ ${data.totalOutstandingAmount}",
                subtitle: "Pending amount to be received",
                color: Color(0xFF3498DB),
                icon: Image.asset(
                  "assets/img/money_bag.png",
                  width: 15,
                  height: 15,
                  color: AppColors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SmallCard(
                title: "Pending Quotations",
                value: "${data.pendingQuotationCount}",
                subtitle: "Awaiting client response",
                color: Color(0xFF6C5CE7),
                icon: SvgPicture.asset(
                  "assets/img/edit_doc.svg",
                  width: 18,
                  height: 18,
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: _SmallCard(
                title: "Quote Requests",
                value: "${data.quoteRequestCount}",
                subtitle: "New Requests from Client",
                color: Color(0xFFF2994A),
                icon: SvgPicture.asset(
                  "assets/img/edit_doc_red.svg",
                  width: 18,
                  height: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(width: 4),
        Row(
          children: [
            Expanded(
              child: _SmallCard(
                title: "Completed Trips",
                value: "${data.bookingCompletedCount}",
                subtitle: "",
                color: Color(0xFF27AE60),
                icon: SvgPicture.asset("assets/img/done.svg",
                    width: 18, height: 18),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SpeedometerChart(
                dimension: 150,
                minValue: 0,
                maxValue: 100,
                value: 75,
                titleMargin: 0,
                graphColor: [Colors.red, Colors.yellow, Colors.green],
                pointerColor: Colors.black,
              ),
            )
          ],
        ),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                callBack: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => VehiclesListingPage(),));
                },
                title: "Manage Vehicles",
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFFFF758C)],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionCard(
                callBack: () {},
                title: "Upcoming booking",
                background: const Color(0xFF2D3436),
                icon: Icons.visibility,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Color color;
  final Widget icon;

  const _InfoCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              icon
            ],
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final Widget icon;

  const _SmallCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              icon
            ],
          ),
          const SizedBox(height: 4),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 6,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final LinearGradient? gradient;
  final Color? background;
  final IconData? icon;
  final Function callBack;

  const _ActionCard({
    required this.title,
    this.gradient,
    required this.callBack,
    this.background,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callBack();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: gradient,
          color: background,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 4),
            if (icon != null) Icon(icon, size: 12, color: Colors.white),
            if (icon != null) const SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

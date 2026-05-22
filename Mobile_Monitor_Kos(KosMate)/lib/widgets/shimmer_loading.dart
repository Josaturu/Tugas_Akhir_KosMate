import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB), // Grey 200
      highlightColor: const Color(0xFFF3F4F6), // Grey 100
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  final bool isOwner;
  const DashboardSkeleton({super.key, this.isOwner = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Kamar Card / Summary Card
            const ShimmerBox(width: double.infinity, height: 130, borderRadius: 20),
            const SizedBox(height: 18),
            // Billing Summary / Monitoring Card
            const ShimmerBox(width: double.infinity, height: 140, borderRadius: 20),
            const SizedBox(height: 25),
            // Title Menu
            const ShimmerBox(width: 100, height: 20),
            const SizedBox(height: 12),
            // Menu Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const ShimmerBox(width: double.infinity, height: 80, borderRadius: 15),
            ),
            const SizedBox(height: 25),
            // Title Recent
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 120, height: 20),
                ShimmerBox(width: 80, height: 20),
              ],
            ),
            const SizedBox(height: 12),
            // Recent Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ShimmerBox(width: 50, height: 50, borderRadius: 12),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 150, height: 16),
                          SizedBox(height: 6),
                          ShimmerBox(width: 100, height: 12),
                        ],
                      ),
                    ),
                    ShimmerBox(width: 70, height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  final int itemCount;
  const ListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: const Row(
            children: [
              ShimmerBox(width: 45, height: 45, borderRadius: 12),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 160, height: 16),
                    SizedBox(height: 6),
                    ShimmerBox(width: 100, height: 12),
                  ],
                ),
              ),
              ShimmerBox(width: 60, height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomGridSkeleton extends StatelessWidget {
  const RoomGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.82,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: double.infinity, height: 110, borderRadius: 20),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 80, height: 15),
                  SizedBox(height: 6),
                  ShimmerBox(width: 110, height: 12),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 60, height: 14),
                      ShimmerBox(width: 40, height: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportSkeleton extends StatelessWidget {
  const ReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance Shimmer Card
          const ShimmerBox(width: double.infinity, height: 120, borderRadius: 20),
          const SizedBox(height: 20),
          // Subtitle
          const ShimmerBox(width: 140, height: 18),
          const SizedBox(height: 12),
          // Chart Mock Shimmer Box
          const ShimmerBox(width: double.infinity, height: 200, borderRadius: 20),
          const SizedBox(height: 25),
          // Another Subtitle
          const ShimmerBox(width: 160, height: 18),
          const SizedBox(height: 12),
          // List Item Shimmers
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ShimmerBox(width: 40, height: 40, borderRadius: 10),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 120, height: 15),
                        SizedBox(height: 6),
                        ShimmerBox(width: 80, height: 12),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 60, height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar Shimmer
          const Center(
            child: ShimmerBox(width: 100, height: 100, borderRadius: 50),
          ),
          const SizedBox(height: 15),
          // Name Shimmer
          const Center(
            child: ShimmerBox(width: 160, height: 20),
          ),
          const SizedBox(height: 8),
          // Role Shimmer
          const Center(
            child: ShimmerBox(width: 100, height: 14),
          ),
          const SizedBox(height: 35),
          // Information Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  ShimmerBox(width: 40, height: 40, borderRadius: 12),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 80, height: 12),
                        SizedBox(height: 6),
                        ShimmerBox(width: 150, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

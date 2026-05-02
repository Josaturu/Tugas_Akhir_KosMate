import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showDrawerButton;
  final List<Widget>? actions;
  final Widget? content; // Untuk konten tambahan di bawah title (seperti Stat Cards)

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showDrawerButton = false,
    this.actions,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris Tombol Navigasi & Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  else if (showDrawerButton)
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    )
                  else
                    const SizedBox(width: 48), // Spacer jika tidak ada tombol kiri

                  Row(children: actions ?? []),
                ],
              ),
              
              const SizedBox(height: 15),
              
              // Judul & Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),

              // Konten Tambahan (Stat Cards, dll)
              if (content != null) ...[
                const SizedBox(height: 25),
                content!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

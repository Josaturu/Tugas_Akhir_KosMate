import 'package:flutter/material.dart';

class GlobalSliverHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final Widget? headerAvatar; // Foto profil (kiri)
  final Widget? centerContent; // Konten tengah (untuk profil besar)
  final List<Widget>? actions;
  final double expandedHeight;

  const GlobalSliverHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.headerAvatar,
    this.centerContent,
    this.actions,
    this.expandedHeight = 100.0, // Default tinggi untuk dashboard/standar
  });

  @override
  Widget build(BuildContext context) {
    // Leading button default (jika showBackButton true)
    Widget? leadingBtn;
    if (showBackButton && Navigator.canPop(context)) {
      leadingBtn = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        onPressed: () => Navigator.pop(context),
      );
    }

    return SliverAppBar(
      expandedHeight: centerContent != null ? 240.0 : expandedHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFF8F9FA),
      automaticallyImplyLeading: false,
      leading: leadingBtn,
      title: centerContent == null && title != null
          ? Row(
              children: [
                if (headerAvatar != null) ...[
                  headerAvatar!,
                  const SizedBox(width: 15),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            )
          : null,
      actions: actions,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final top = constraints.biggest.height;
          final statusBarHeight = MediaQuery.of(context).padding.top;
          final minHeight = kToolbarHeight + statusBarHeight;
          final progress = (top - minHeight) / ((centerContent != null ? 240.0 : expandedHeight) - minHeight);
          final clampedProgress = progress.clamp(0.0, 1.0);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Background Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
              ),

              // Watermark / Aksen Dekoratif
              Positioned(
                right: -20,
                top: -10,
                child: Opacity(
                  opacity: clampedProgress * 0.15,
                  child: const Icon(Icons.home_work_rounded, size: 120, color: Colors.white),
                ),
              ),

              // Konten Tengah (Untuk Halaman Profile)
              if (centerContent != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: clampedProgress,
                    child: Padding(
                      padding: EdgeInsets.only(top: statusBarHeight + 10),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: centerContent,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

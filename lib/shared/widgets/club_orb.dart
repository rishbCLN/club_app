import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/extensions.dart';

class ClubOrb extends StatefulWidget {
  const ClubOrb({
    super.key,
    required this.clubColor,
    required this.clubName,
    this.logoUrl,
    this.size = 64.0,
    this.isPulsing = false,
    this.onTap,
    this.showLabel = false,
  });

  final Color clubColor;
  final String clubName;
  final String? logoUrl;
  final double size;
  final bool isPulsing;
  final VoidCallback? onTap;
  final bool showLabel;

  @override
  State<ClubOrb> createState() => _ClubOrbState();
}

class _ClubOrbState extends State<ClubOrb> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _opacityAnim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ClubOrb old) {
    super.didUpdateWidget(old);
    if (widget.isPulsing && !old.isPulsing) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isPulsing && old.isPulsing) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orb = GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size + 20,
            height: widget.size + 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse ring 2
                if (widget.isPulsing)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Transform.scale(
                      scale: _scaleAnim.value * 1.12,
                      child: Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.clubColor
                                .withOpacity(_opacityAnim.value * 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Outer pulse ring 1
                if (widget.isPulsing)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Transform.scale(
                      scale: _scaleAnim.value,
                      child: Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.clubColor
                                .withOpacity(_opacityAnim.value * 0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Orb body
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.clubColor.withOpacity(0.35),
                        widget.clubColor.withOpacity(0.08),
                        NexusColors.surface,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    border: Border.all(
                      color: widget.clubColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.clubColor.withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildOrbContent(),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showLabel) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: widget.size + 20,
              child: Text(
                widget.clubName,
                style: NexusText.tag.copyWith(
                  color: NexusColors.textSecondary,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    return orb;
  }

  Widget _buildOrbContent() {
    if (widget.logoUrl != null && widget.logoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.logoUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _initials(),
        errorWidget: (_, __, ___) => _initials(),
      );
    }
    return _initials();
  }

  Widget _initials() {
    return Center(
      child: Text(
        widget.clubName.initials,
        style: NexusText.tag.copyWith(
          color: widget.clubColor,
          fontSize: widget.size * 0.28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

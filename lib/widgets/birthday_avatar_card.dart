import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/wellness.dart';

class BirthdayAvatarCard extends StatelessWidget {
  final BirthdayMember member;
  const BirthdayAvatarCard({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isToday = member.daysUntil == 0;

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isToday
                    ? const Color(0xFF10b981)
                    : const Color(0xFFe2e8f0),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: member.thumbnail != null && member.thumbnail!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: member.thumbnail!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _InitialsAvatar(member.firstname),
                      placeholder: (_, __) => _InitialsAvatar(member.firstname),
                    )
                  : _InitialsAvatar(member.firstname),
            ),
          ),
          const SizedBox(height: 5),
          // First name only
          Text(
            member.firstname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 3),
          // Days chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFFd1fae5)
                  : const Color(0xFFf1f5f9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isToday ? 'Today! \u{1F382}' : 'In ${member.daysUntil}d',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? const Color(0xFF059669)
                    : const Color(0xFF64748b),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  const _InitialsAvatar(this.name);

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: const Color(0xFFe0e7ff),
      child: Center(
        child: Text(initial,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6366f1),
            )),
      ),
    );
  }
}

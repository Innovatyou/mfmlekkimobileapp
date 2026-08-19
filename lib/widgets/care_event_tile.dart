import 'package:flutter/material.dart';
import 'package:higherground/models/wellness.dart';
import 'package:intl/intl.dart';

class CareEventTile extends StatelessWidget {
  final CareEvent event;
  const CareEventTile({Key? key, required this.event}) : super(key: key);

  static const _types = {
    'call':    _TypeMeta(Icons.phone_rounded,       Color(0xFF6366f1), 'Phone Call'),
    'visit':   _TypeMeta(Icons.home_rounded,         Color(0xFF10b981), 'Home Visit'),
    'email':   _TypeMeta(Icons.email_rounded,        Color(0xFFf59e0b), 'Email'),
    'prayer':  _TypeMeta(Icons.self_improvement,     Color(0xFF8b5cf6), 'Prayer'),
    'message': _TypeMeta(Icons.chat_bubble_rounded,  Color(0xFF06b6d4), 'Message'),
    'other':   _TypeMeta(Icons.favorite_rounded,     Color(0xFFec4899), 'Pastoral Care'),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _types[event.eventType] ?? _types['other']!;

    final isSelfRequest = event.note.startsWith('[Member Request]');
    final noteText = isSelfRequest ? 'You requested this' : event.note;
    final showCreatedBy = !event.createdBy.contains('(self-requested)');
    final dateStr = DateFormat('MMM d, y').format(event.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon pill
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(meta.icon, color: meta.color, size: 18),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(meta.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: meta.color)),
                    const Spacer(),
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF94a3b8))),
                  ],
                ),
                if (noteText.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(noteText,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF475569))),
                ],
                if (showCreatedBy && event.createdBy.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text('From ${event.createdBy}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94a3b8),
                          fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeMeta {
  final IconData icon;
  final Color color;
  final String label;
  const _TypeMeta(this.icon, this.color, this.label);
}

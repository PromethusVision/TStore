enum EngagementTargetType {
  product,
  shop,
  category,
  search,
  reward,
  messages,
  notifications,
}

/// Shared, allowlisted campaign/notification destination; never an arbitrary URL.
class EngagementTarget {
  const EngagementTarget(this.type, [this.value = '']);
  final EngagementTargetType type;
  final String value;

  static EngagementTarget? parse(String? type, String? value) {
    final targetType = EngagementTargetType.values
        .where((t) => t.name == type)
        .firstOrNull;
    if (targetType == null) return null;
    final normalized = (value ?? '').trim();
    if (normalized.length > 160 || RegExp(r'[\x00-\x1f]').hasMatch(normalized))
      return null;
    if ([
          EngagementTargetType.product,
          EngagementTargetType.shop,
          EngagementTargetType.category,
        ].contains(targetType) &&
        !RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(normalized))
      return null;
    if ([
          EngagementTargetType.reward,
          EngagementTargetType.messages,
          EngagementTargetType.notifications,
        ].contains(targetType) &&
        normalized.isNotEmpty)
      return null;
    return EngagementTarget(targetType, normalized);
  }
}

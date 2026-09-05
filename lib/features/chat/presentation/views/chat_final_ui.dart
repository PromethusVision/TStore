part of 'chat_view.dart';

class _ChatFinalHeader extends StatelessWidget {
  const _ChatFinalHeader({required this.receiverName});
  final String receiverName;

  @override
  Widget build(BuildContext context) => Padding(
    key: const Key('customer-chat-header'),
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        EsnaftaVarSurfaceIconButton(
          buttonKey: const Key('customer-chat-back-button'),
          icon: Icons.arrow_back_rounded,
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: EsnaftaVarColors.primarySoft,
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            color: EsnaftaVarColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                receiverName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Mağaza ile görüşme',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EsnaftaVarColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ChatFinalDate extends StatelessWidget {
  const _ChatFinalDate({required this.date});
  final DateTime date;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _formatFullDate(date),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: EsnaftaVarColors.textMuted),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    ),
  );
}

Widget _buildChatFinalBubble(_MessageBubble bubble, BuildContext context) {
  final message = bubble.message;
  final isMine = bubble.isMine;
  final maxWidth =
      (MediaQuery.sizeOf(context).width.clamp(0, 430).toDouble() - 32) * 0.86;
  return Align(
    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      key: Key('chat-message-${message.id}'),
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMine ? EsnaftaVarColors.primarySoft : EsnaftaVarColors.surface,
        border: isMine
            ? null
            : Border.all(color: EsnaftaVarColors.borderDefault),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(EsnaftaVarRadii.large),
          topRight: const Radius.circular(EsnaftaVarRadii.large),
          bottomLeft: Radius.circular(isMine ? EsnaftaVarRadii.large : 4),
          bottomRight: Radius.circular(isMine ? 4 : EsnaftaVarRadii.large),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(message.content, style: Theme.of(context).textTheme.bodyMedium),
          if (message.createdAt != null || isMine) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.createdAt != null)
                  Text(
                    _formatTime(message.createdAt!),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: EsnaftaVarColors.textSecondary,
                    ),
                  ),
                if (message.createdAt != null && isMine)
                  const SizedBox(width: 6),
                if (isMine) ...[
                  ExcludeSemantics(
                    child: Icon(
                      message.isRead
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 16,
                      color: EsnaftaVarColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    message.isRead ? 'Okundu' : 'Gönderildi',
                    key: Key('chat-message-status-${message.id}'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: EsnaftaVarColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

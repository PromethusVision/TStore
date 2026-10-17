import 'package:flutter/material.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';

/// OS transport enrollment is separate from server service/marketing consent.
class PushDeviceControls extends StatelessWidget {
  const PushDeviceControls({super.key, required this.coordinator});
  final PushCoordinator coordinator;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: coordinator,
    builder: (context, _) {
      final status = coordinator.status;
      final pending = !coordinator.available;
      final cleanup = status == PushClientStatus.cleanupRequired;
      final active = status == PushClientStatus.registered;
      final message = pending
          ? 'Telefon bildirimi hizmeti henüz etkin değil. Bildirimlerini uygulama içinden takip edebilirsin.'
          : switch (status) {
              PushClientStatus.enabling =>
                'Telefon bildirimi bağlantısı kuruluyor…',
              PushClientStatus.disabling =>
                'Telefon bildirimi bağlantısı kaldırılıyor…',
              PushClientStatus.registered =>
                'Bu cihazın bağlantısı kuruldu. Gösterim, telefon izinlerine ve bildirim tercihlerine bağlıdır.',
              PushClientStatus.denied =>
                'Telefon izni alınamadı. İzin ayarını kontrol edip yeniden deneyebilirsin.',
              PushClientStatus.cleanupRequired =>
                'Önceki bağlantı tamamlanamadı. Yeniden bağlanmadan önce bağlantıyı temizle.',
              _ =>
                'Bu cihazı bağlamak için telefon bildirim iznini aç. Kampanya tercihin değişmez.',
            };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu cihazdaki bildirimler',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Semantics(liveRegion: true, child: Text(message)),
          if (!pending) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('push-device-action'),
              onPressed: coordinator.busy
                  ? null
                  : () async {
                      if (active || cleanup) {
                        try {
                          await coordinator.disable();
                        } catch (_) {
                          // Coordinator exposes a safe, retryable cleanup state.
                        }
                      } else {
                        await coordinator.enable();
                      }
                    },
              child: Text(
                cleanup
                    ? 'Bağlantıyı temizle'
                    : active
                    ? 'Bu cihazda telefon bildirimini kapat'
                    : 'Telefon bildirimini aç',
              ),
            ),
          ],
          if (coordinator.busy) const LinearProgressIndicator(),
        ],
      );
    },
  );
}

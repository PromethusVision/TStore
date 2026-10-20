import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'reward_view_session.dart';

class RewardReservationCard extends StatefulWidget {
  const RewardReservationCard({
    super.key,
    required this.repository,
    required this.cartId,
    required this.revision,
    this.currentUserId,
    this.sessionChanges,
  });
  final RewardProgramRepository repository;
  final String cartId, revision;
  final String? Function()? currentUserId;
  final Stream<String?>? sessionChanges;
  @override
  State<RewardReservationCard> createState() => _RewardReservationCardState();
}

class _RewardReservationCardState extends State<RewardReservationCard>
    with WidgetsBindingObserver {
  RewardReservation? _value;
  String? _error;
  bool _busy = false;
  bool _inFlight = false, _queued = false;
  int _generation = 0;
  final _elapsed = Stopwatch();
  Timer? _timer;
  late RewardViewSession _session;
  bool get _current => _session.current;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bind();
    _read();
  }

  void _bind() {
    _session = RewardViewSession(
      repository: widget.repository,
      owner: widget.currentUserId?.call(),
      currentUser: widget.currentUserId,
      changes: widget.sessionChanges,
      onLost: () {
        if (!mounted) return;
        _generation++;
        _timer?.cancel();
        setState(() {
          _value = null;
          _error = null;
          _busy = false;
          _queued = false;
        });
      },
    );
  }

  @override
  void didUpdateWidget(RewardReservationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != null &&
        widget.currentUserId!() != _session.owner) {
      _session.retire();
    }
    if (!_session.check()) return;
    if (oldWidget.repository != widget.repository) {
      _session.close();
      _bind();
    }
    if (oldWidget.cartId != widget.cartId ||
        oldWidget.revision != widget.revision ||
        oldWidget.repository != widget.repository) {
      _generation++;
      _value = null;
      _error = null;
      _timer?.cancel();
      if (_inFlight) {
        _queued = true;
      } else {
        _read();
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    _session.close();
    _timer?.cancel();
    _elapsed.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _read();
  }

  Future<void> _read({bool startNew = false}) async {
    if (_inFlight || !_session.check()) return;
    _inFlight = true;
    final ticket = ++_generation;
    _timer?.cancel();
    // Conservatively include transport time; the server's deadline never moves.
    _elapsed
      ..reset()
      ..start();
    setState(() {
      _busy = true;
      _error = null;
      _value = null;
    });
    try {
      final result = await widget.repository.reserve(
        widget.cartId,
        startNew: startNew,
      );
      if (!mounted || ticket != _generation || !_session.check()) return;
      setState(() {
        _busy = false;
        result.fold(
          (error) {
            _error = error;
            _value = null;
          },
          (value) {
            _value = value;
          },
        );
      });
      if (_value?.holdsCapacity == true) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted || !_session.check()) {
            _timer?.cancel();
            return;
          }
          setState(() {});
          if (_remaining.inSeconds <= 0) _timer?.cancel();
        });
      }
    } catch (_) {
      if (mounted && ticket == _generation && _session.check()) {
        setState(() {
          _value = null;
          _error =
              'Rezervasyon sonucu doğrulanamadı. Güncel durumu kontrol edin.';
        });
      }
    } finally {
      _inFlight = false;
      if (mounted && _session.check()) {
        setState(() {
          _busy = false;
        });
        if (_queued) {
          _queued = false;
          _read();
        }
      }
    }
  }

  Duration get _remaining =>
      (_value?.remainingAtRead ?? Duration.zero) - _elapsed.elapsed;
  @override
  Widget build(BuildContext context) {
    if (!_current) return const SizedBox.shrink();
    final value = _value;
    if (value?.status == RewardReservationStatus.disabled && !_busy) {
      return const SizedBox.shrink();
    }
    final seconds = _remaining.inSeconds.clamp(0, 3600);
    final timedOut = value?.holdsCapacity == true && seconds == 0;
    final text = switch (value?.status) {
      RewardReservationStatus.reserved =>
        timedOut
            ? 'Rezervasyon süresi doldu. Güncel durumu kontrol edin.'
            : 'Ödül kontenjanı ayrıldı: ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
      RewardReservationStatus.checkoutHold =>
        timedOut
            ? 'QR tamamlama süresi doldu. Güncel durumu kontrol edin.'
            : 'Kontenjanınız açık QR işlemi için korunuyor.',
      RewardReservationStatus.attemptExpired =>
        'Bu alışveriş denemesinin rezervasyon süresi doldu.',
      RewardReservationStatus.noCapacity =>
        'Bu mağazada şu anda ayrılabilecek ödül kontenjanı yok.',
      RewardReservationStatus.belowThreshold =>
        'Sepet şu anda ödül kazanım eşiğini karşılamıyor.',
      _ => 'Ödül kontenjanı kontrol ediliyor.',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ödül rezervasyonu',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            if (_busy) const LinearProgressIndicator(),
            Text(_error ?? text),
            if (value?.holdsCapacity == true && !timedOut)
              const Text(
                'Sepet değişiklikleri süreyi uzatmaz. Kazanım, uygun alışveriş doğrulandığında oluşur.',
              ),
            if (!_busy &&
                (_error != null ||
                    timedOut ||
                    value?.status == RewardReservationStatus.noCapacity))
              TextButton(
                onPressed: _read,
                child: const Text('Durumu kontrol et'),
              ),
            if (!_busy &&
                value?.status == RewardReservationStatus.attemptExpired)
              TextButton(
                onPressed: () => _read(startNew: true),
                child: const Text('Yeni rezervasyon denemesi başlat'),
              ),
          ],
        ),
      ),
    );
  }
}

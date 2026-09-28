import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

enum MerchantSessionStatus {
  checking,
  signedOut,
  denied,
  onboarding,
  ready,
  failure,
}

class MerchantSessionState {
  const MerchantSessionState(
    this.status, {
    this.access,
    this.message,
    this.busy = false,
  });
  final MerchantSessionStatus status;
  final MerchantAccess? access;
  final String? message;
  final bool busy;
}

class MerchantSessionCubit extends Cubit<MerchantSessionState> {
  MerchantSessionCubit({
    required this.repository,
    required this.credentials,
    required Stream<String?> sessionChanges,
    required this.currentUserId,
    this.beforeSignOut,
  }) : super(const MerchantSessionState(MerchantSessionStatus.checking)) {
    _subscription = sessionChanges.listen(
      (id) => reload(quiet: id != null && id == state.access?.user.id),
      onError: (Object _) {
        ++_epoch;
        if (!isClosed) {
          emit(
            const MerchantSessionState(
              MerchantSessionStatus.failure,
              message: 'Oturum doğrulanamadı. Lütfen yeniden deneyin.',
            ),
          );
        }
      },
    );
  }
  final MerchantRepository repository;
  final MerchantCredentials credentials;
  final String? Function() currentUserId;
  final Future<void> Function()? beforeSignOut;
  StreamSubscription<String?>? _subscription;
  int _epoch = 0;
  bool _authBusy = false;

  Future<void> reload({bool quiet = false}) async {
    final epoch = ++_epoch;
    final id = currentUserId();
    if (isClosed) return;
    if (id == null) {
      emit(const MerchantSessionState(MerchantSessionStatus.signedOut));
      return;
    }
    if (!quiet) {
      emit(const MerchantSessionState(MerchantSessionStatus.checking));
    }
    try {
      final result = await repository.loadAccess();
      if (isClosed || epoch != _epoch || currentUserId() != id) return;
      result.fold(
        (error) => emit(
          MerchantSessionState(MerchantSessionStatus.failure, message: error),
        ),
        (access) {
          if (access == null || access.user.id != id) {
            emit(
              const MerchantSessionState(
                MerchantSessionStatus.failure,
                message: merchantSessionChanged,
              ),
            );
          } else if (!access.hasRole ||
              (access.shop != null && !access.canManage)) {
            emit(
              MerchantSessionState(
                MerchantSessionStatus.denied,
                access: access,
              ),
            );
          } else {
            emit(
              MerchantSessionState(
                access.shop == null
                    ? MerchantSessionStatus.onboarding
                    : MerchantSessionStatus.ready,
                access: access,
              ),
            );
          }
        },
      );
    } catch (_) {
      if (!isClosed && epoch == _epoch) {
        emit(
          const MerchantSessionState(
            MerchantSessionStatus.failure,
            message: 'Bağlantı kurulamadı. Lütfen tekrar deneyin.',
          ),
        );
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    if (_authBusy || isClosed) return;
    _authBusy = true;
    emit(
      const MerchantSessionState(MerchantSessionStatus.signedOut, busy: true),
    );
    try {
      final result = await credentials.signIn(email, password);
      if (isClosed) return;
      await result.fold((error) async {
        // Auth may have succeeded while the profile lookup failed. Reload its
        // authoritative access instead of treating it as an anonymous session.
        if (currentUserId() != null) {
          await reload();
        } else {
          emit(
            MerchantSessionState(
              MerchantSessionStatus.signedOut,
              message: error,
            ),
          );
        }
      }, (_) => reload());
    } catch (_) {
      if (!isClosed) {
        emit(
          const MerchantSessionState(
            MerchantSessionStatus.failure,
            message: 'Giriş yapılamadı. Lütfen yeniden deneyin.',
          ),
        );
      }
    } finally {
      _authBusy = false;
    }
  }

  Future<void> signOut() async {
    if (_authBusy || isClosed) return;
    _authBusy = true;
    ++_epoch;
    emit(const MerchantSessionState(MerchantSessionStatus.checking));
    try {
      // Future provider integration must revoke the old binding before logout.
      await beforeSignOut?.call();
      final result = await credentials.signOut();
      if (isClosed) return;
      await result.fold((error) async {
        emit(
          MerchantSessionState(MerchantSessionStatus.failure, message: error),
        );
      }, (_) => reload());
    } catch (_) {
      if (!isClosed) {
        emit(
          const MerchantSessionState(
            MerchantSessionStatus.failure,
            message: 'Güvenli çıkış tamamlanamadı. Yeniden deneyin.',
          ),
        );
      }
    } finally {
      _authBusy = false;
    }
  }

  @override
  Future<void> close() async {
    ++_epoch;
    await _subscription?.cancel();
    return super.close();
  }
}

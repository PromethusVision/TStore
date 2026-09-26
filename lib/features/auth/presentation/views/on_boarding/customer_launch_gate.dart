import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/features/auth/data/services/customer_onboarding_preferences.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/branded_startup_view.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/on_boarding_view.dart';

typedef CustomerLaunchStatusProvider = Future<bool> Function();
typedef CustomerLaunchDestinationBuilder =
    Widget Function(BuildContext context);

Future<bool> _defaultCustomerLaunchStatusProvider() async {
  return CustomerOnboardingPreferences.isCompleted();
}

/// Shared across auth-driven subtree recreation, but not across cold launches.
/// An injectable instance keeps startup timing deterministic in tests.
class CustomerStartupTiming {
  CustomerStartupTiming({this.duration = const Duration(seconds: 2)});
  final Duration duration;
  Future<void>? _ready;
  Future<void> wait() => _ready ??= Future<void>.delayed(duration);
  static final process = CustomerStartupTiming();
}

Future<void> _defaultStartupWait() => CustomerStartupTiming.process.wait();

Widget _defaultOnboardingBuilder(BuildContext context) {
  return const OnBoardingView();
}

Widget _defaultCustomerHomeBuilder(BuildContext context) {
  return const NavigationMenu();
}

class CustomerLaunchGate extends StatefulWidget {
  const CustomerLaunchGate({
    super.key,
    this.statusProvider = _defaultCustomerLaunchStatusProvider,
    this.onboardingBuilder = _defaultOnboardingBuilder,
    this.homeBuilder = _defaultCustomerHomeBuilder,
    this.startupWait = _defaultStartupWait,
  });

  final CustomerLaunchStatusProvider statusProvider;
  final CustomerLaunchDestinationBuilder onboardingBuilder;
  final CustomerLaunchDestinationBuilder homeBuilder;
  final Future<void> Function() startupWait;

  @override
  State<CustomerLaunchGate> createState() => _CustomerLaunchGateState();
}

class _CustomerLaunchGateState extends State<CustomerLaunchGate> {
  late final Future<bool> _shouldOpenHome;

  @override
  void initState() {
    super.initState();
    _shouldOpenHome = _load();
  }

  Future<bool> _load() async {
    final startup = widget.startupWait();
    bool completed;
    try {
      completed = await widget.statusProvider();
    } catch (_) {
      // Storage failure must not block discovery or replace an incoming route.
      completed = true;
    }
    await startup;
    return completed;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldOpenHome,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const BrandedStartupView();
        }

        if (snapshot.hasError || snapshot.data == true) {
          return widget.homeBuilder(context);
        }

        return widget.onboardingBuilder(context);
      },
    );
  }
}

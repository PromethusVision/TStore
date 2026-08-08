import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/data/services/customer_onboarding_preferences.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/on_boarding_view.dart';

typedef CustomerLaunchStatusProvider = Future<bool> Function();
typedef CustomerLaunchDestinationBuilder =
    Widget Function(BuildContext context);

Future<bool> _defaultCustomerLaunchStatusProvider() async {
  if (SupabaseService.instance.currentUser != null) {
    try {
      await CustomerOnboardingPreferences.markCompleted();
    } catch (_) {
      // An authenticated customer must never be blocked by local storage.
    }
    return true;
  }

  return CustomerOnboardingPreferences.isCompleted();
}

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
  });

  final CustomerLaunchStatusProvider statusProvider;
  final CustomerLaunchDestinationBuilder onboardingBuilder;
  final CustomerLaunchDestinationBuilder homeBuilder;

  @override
  State<CustomerLaunchGate> createState() => _CustomerLaunchGateState();
}

class _CustomerLaunchGateState extends State<CustomerLaunchGate> {
  late final Future<bool> _shouldOpenHome;

  @override
  void initState() {
    super.initState();
    _shouldOpenHome = widget.statusProvider();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldOpenHome,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _CustomerLaunchLoadingView();
        }

        if (snapshot.hasError || snapshot.data == true) {
          return widget.homeBuilder(context);
        }

        return widget.onboardingBuilder(context);
      },
    );
  }
}

class _CustomerLaunchLoadingView extends StatelessWidget {
  const _CustomerLaunchLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: Key('customer-launch-loading'),
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomerBrandWordmark(fontSize: 30),
            SizedBox(height: CustomerHomeV1Tokens.space20),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CustomerHomeV1Tokens.petrol,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

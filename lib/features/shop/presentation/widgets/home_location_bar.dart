import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';

class HomeLocationBar extends StatelessWidget {
  const HomeLocationBar({
    super.key,
    required this.isAuthenticated,
    required this.onTap,
  });

  final bool isAuthenticated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      CustomerSavedLocationsCubit,
      CustomerSavedLocationsState
    >(
      builder: (context, state) {
        final location = _defaultLocation(state);
        final isLoading =
            isAuthenticated &&
            (state is CustomerSavedLocationsInitial ||
                state is CustomerSavedLocationsLoading);

        final title = location?.name.trim().isNotEmpty == true
            ? location!.name.trim()
            : 'Konumunu seç';
        final detail = location?.addressText.trim().isNotEmpty == true
            ? location!.addressText.trim()
            : state is CustomerSavedLocationsError
            ? 'Konum yüklenemedi, tekrar denemek için dokun'
            : isAuthenticated
            ? 'Yakınındaki mağazaları görmek için dokun'
            : 'Yakınındakiler için giriş yap ve konumunu seç';

        return Material(
          key: const Key('home-location-bar'),
          color: CustomerHomeV1Tokens.surface,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(
                horizontal: CustomerHomeV1Tokens.space12,
                vertical: CustomerHomeV1Tokens.space8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius16,
                ),
                border: Border.all(color: CustomerHomeV1Tokens.border),
                boxShadow: CustomerHomeV1Tokens.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CustomerHomeV1Tokens.petrol,
                      borderRadius: BorderRadius.circular(
                        CustomerHomeV1Tokens.radius12,
                      ),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: CustomerHomeV1Tokens.onPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: CustomerHomeV1Tokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomerHomeV1Tokens.navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomerHomeV1Tokens.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: CustomerHomeV1Tokens.space8),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: CustomerHomeV1Tokens.petrol,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: CustomerHomeV1Tokens.petrol,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  CustomerSavedLocationEntity? _defaultLocation(
    CustomerSavedLocationsState state,
  ) {
    if (state is! CustomerSavedLocationsLoaded || state.locations.isEmpty) {
      return null;
    }

    for (final location in state.locations) {
      if (location.isDefault) return location;
    }
    return state.locations.first;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            : 'Yakınındaki mağazaları görmek için dokun';

        return Card(
          key: const Key('home-location-bar'),
          margin: EdgeInsets.zero,
          child: ListTile(
            onTap: onTap,
            leading: const Icon(Icons.location_on_outlined),
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/helpers/logger_helper.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    LoggerHelper.info('Event: ${bloc.runtimeType}, ${event.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    LoggerHelper.debug(
      'Transition: ${bloc.runtimeType}, '
      '${transition.currentState.runtimeType} -> '
      '${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    LoggerHelper.error('Error in ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    LoggerHelper.debug(
      'Change: ${bloc.runtimeType}, '
      '${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
    );
  }
}

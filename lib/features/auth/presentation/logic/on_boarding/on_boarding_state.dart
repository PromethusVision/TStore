part of 'on_boarding_cubit.dart';

sealed class OnBoardingState extends Equatable {
  const OnBoardingState();

  @override
  List<Object> get props => [];
}

final class OnBoardingInitial extends OnBoardingState {}

final class OnBoardingUpdateIndicator extends OnBoardingState {
  const OnBoardingUpdateIndicator(this.index);

  final int index;

  @override
  List<Object> get props => [index];
}

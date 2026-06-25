part of 'fitness_snapshot_cubit.dart';

abstract class FitnessSnapshotState extends Equatable {
  const FitnessSnapshotState();
  @override
  List<Object?> get props => [];
}

class FitnessSnapshotInitial extends FitnessSnapshotState {
  const FitnessSnapshotInitial();
}

class FitnessSnapshotLoading extends FitnessSnapshotState {
  const FitnessSnapshotLoading();
}

class FitnessSnapshotLoaded extends FitnessSnapshotState {
  final FitnessSnapshot snapshot;
  const FitnessSnapshotLoaded(this.snapshot);
  @override
  List<Object?> get props => [snapshot];
}

class FitnessSnapshotDisabled extends FitnessSnapshotState {
  const FitnessSnapshotDisabled();
}

class FitnessSnapshotError extends FitnessSnapshotState {
  final String message;
  const FitnessSnapshotError(this.message);
  @override
  List<Object?> get props => [message];
}
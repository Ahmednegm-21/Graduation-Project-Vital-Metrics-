// lib/logic/tips/tips_state.dart

import 'package:equatable/equatable.dart';
import 'package:vital_metrics/data/models/tip_model.dart';

abstract class TipsState extends Equatable {
  const TipsState();
  @override List<Object?> get props => [];
}

class TipsInitial  extends TipsState {}
class TipsLoading  extends TipsState {}

class TipsLoaded extends TipsState {
  final TipModel tip;
  const TipsLoaded(this.tip);
  @override List<Object?> get props => [tip];
}

class TipsError extends TipsState {
  final String message;
  const TipsError(this.message);
  @override List<Object?> get props => [message];
}
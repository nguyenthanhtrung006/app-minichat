import 'package:equatable/equatable.dart';
import '../../domain/entities/register_params.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final RegisterParams params;

  const RegisterSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}

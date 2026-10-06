import 'package:equatable/equatable.dart';
import '../../domain/entities/call_session.dart';

class CallingState extends Equatable {
  final CallSession session;

  const CallingState({required this.session});

  @override
  List<Object?> get props => [session];
}


abstract class CarOwnerEvent {}

class LoadProfile extends CarOwnerEvent {}

class CarOwnerProfileEvent extends CarOwnerEvent {
  final Map<String, dynamic> body;
  CarOwnerProfileEvent(this.body);
}

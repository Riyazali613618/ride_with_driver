abstract class UpgradeablePlansEvent {}

class UpgradeablePlanLoad extends UpgradeablePlansEvent {
  final String type;
  UpgradeablePlanLoad(this.type);
}


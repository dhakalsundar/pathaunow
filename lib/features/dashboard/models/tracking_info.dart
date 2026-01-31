class TrackingInfo {
  final String id;
  final String status;
  final String eta;
  final String from;
  final String to;
  final List<TrackStep> steps;

  TrackingInfo({
    required this.id,
    required this.status,
    required this.eta,
    required this.from,
    required this.to,
    required this.steps,
  });
}

class TrackStep {
  final String title;
  final String time;
  final bool done;
  TrackStep(this.title, this.time, this.done);
}

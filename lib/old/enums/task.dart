enum TaskStatus {
  todo,
  inProgress,
  completed;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

enum TaskSubject {
  physics,
  chemistry,
  biology,
  math;

  String get label {
    switch (this) {
      case TaskSubject.physics:
        return 'PHY';
      case TaskSubject.chemistry:
        return 'CHE';
      case TaskSubject.biology:
        return 'BIO';
      case TaskSubject.math:
        return 'MATH';
    }
  }
}

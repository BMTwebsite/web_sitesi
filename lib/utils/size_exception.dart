/// Layout ve boyutlarla ilgili exception sınıfı
class SizeException implements Exception {
  final String message;
  final String? context;
  final double? attemptedValue;
  final double? minValue;
  final double? maxValue;

  const SizeException(
    this.message, {
    this.context,
    this.attemptedValue,
    this.minValue,
    this.maxValue,
  });

  @override
  String toString() {
    final buffer = StringBuffer('SizeException: $message');
    if (context != null) {
      buffer.write(' (Context: $context)');
    }
    if (attemptedValue != null) {
      buffer.write(' (Attempted: $attemptedValue)');
    }
    if (minValue != null || maxValue != null) {
      buffer.write(' (Range: ${minValue ?? 'unlimited'} - ${maxValue ?? 'unlimited'})');
    }
    return buffer.toString();
  }
}

/// Layout overflow exception
class LayoutOverflowException extends SizeException {
  const LayoutOverflowException({
    String? message,
    String? context,
    double? attemptedValue,
    double? maxValue,
  }) : super(
          message ?? 'Layout overflow detected',
          context: context,
          attemptedValue: attemptedValue,
          maxValue: maxValue,
        );
}

/// Invalid size exception
class InvalidSizeException extends SizeException {
  const InvalidSizeException({
    String? message,
    String? context,
    double? attemptedValue,
    double? minValue,
    double? maxValue,
  }) : super(
          message ?? 'Invalid size value',
          context: context,
          attemptedValue: attemptedValue,
          minValue: minValue,
          maxValue: maxValue,
        );
}


enum PaymentModelType { percent, fixedPerJob, monthlySalary }

class PaymentModel {
  const PaymentModel({required this.type, required this.amount});

  final PaymentModelType type;
  final num amount;

  num calculateEarning(num completedJobAmount) {
    return switch (type) {
      PaymentModelType.percent => completedJobAmount * amount / 100,
      PaymentModelType.fixedPerJob => amount,
      PaymentModelType.monthlySalary => 0,
    };
  }
}

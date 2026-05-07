import '../../categories/domain/service_category.dart';
import '../../payments/domain/payment_model.dart';
import 'city.dart';
import 'master_access.dart';

class Master {
  const Master({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.city,
    required this.categories,
    required this.access,
    required this.paymentModel,
    required this.balance,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final City city;
  final List<ServiceCategory> categories;
  final MasterAccess access;
  final PaymentModel paymentModel;
  final num balance;

  String get fullName => '$firstName $lastName'.trim();
}

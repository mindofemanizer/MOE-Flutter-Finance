import 'package:equatable/equatable.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';

/// Configuration for MOE Finance module.
class MoeFinanceConfig extends Equatable {
  final String apiUrl;
  final CurrencyCode defaultCurrency;
  final bool enableMultiCurrency;

  const MoeFinanceConfig({
    required this.apiUrl,
    this.defaultCurrency = CurrencyCode.IDR,
    this.enableMultiCurrency = true,
  });

  @override
  List<Object?> get props => [apiUrl, defaultCurrency, enableMultiCurrency];
}

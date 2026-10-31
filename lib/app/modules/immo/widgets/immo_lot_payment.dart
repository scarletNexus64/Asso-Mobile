import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_design.dart';
import '../../../data/models/real_estate_models.dart';
import 'immo_summary_row.dart';
import 'immo_widgets.dart';

/// Ce que l'acheteur prend sur un terrain vendu au morceau : [quantity]
/// morceaux du lot choisi, ou tout ce qui reste en vente ([whole]).
class ImmoLotChoice {
  const ImmoLotChoice({this.quantity = 1, this.whole = false});

  final int quantity;
  final bool whole;

  static const single = ImmoLotChoice();

  bool get isMultiple => whole || quantity > 1;

  /// Champs ajoutés à la réservation (rien pour un seul morceau).
  Map<String, dynamic> get apiFields => {
    if (whole) 'whole': true,
    if (!whole && quantity > 1) 'quantity': quantity,
  };

  /// « Parcelle × 3 », « Tout le terrain (2 morceaux) » ou le lot seul.
  String label(RealEstateUnit? unit, {int? lots}) {
    if (whole) {
      return 'immo.lots.whole_label'.trParams({'count': '${lots ?? ''}'});
    }
    final name = unit?.label ?? '';
    return quantity > 1 ? '$name × $quantity' : name;
  }
}

/// « Prix du lot » ou « Prix des 3 morceaux ».
String immoLotPriceLabel(int count) => count > 1
    ? 'immo.lots.price_of'.trParams({'count': '$count'})
    : 'immo.quote.lot_price'.tr;

/// Aperçu du paiement de [count] morceaux identiques ; le devis fait foi.
RealEstateLotPayment immoLotPaymentTimes(RealEstateLotPayment p, int count) =>
    count <= 1
    ? p
    : RealEstateLotPayment(
        lotPrice: p.lotPrice * count,
        depositPercent: p.depositPercent,
        depositAmount: p.depositAmount * count,
        fees: p.fees * count,
        totalToPay: p.totalToPay * count,
        balanceDue: p.balanceDue * count,
      );

/// Découpage à afficher pour le devis [q] : celui du morceau si l'API l'a
/// fourni pour ce même montant, sinon déduit du devis (qui fait foi).
RealEstateLotPayment immoLotPayment(RealEstateQuote q, RealEstateUnit? unit) {
  final payment = unit?.payment;
  return payment != null && payment.totalToPay == q.total
      ? payment
      : RealEstateLotPayment.fromQuote(q);
}

/// Paiement d'un morceau de terrain : prix, acompte, frais, montant payé
/// maintenant et reste réglé au cabinet. Montants fournis par l'API.
class ImmoLotPaymentDetails extends StatelessWidget {
  const ImmoLotPaymentDetails({
    super.key,
    required this.payment,
    this.showLotPrice = true,
    this.pricePerM2,
    this.lotCount = 1,
  });

  final RealEstateLotPayment payment;
  final bool showLotPrice;

  /// Prix au m² du morceau (FCFA), affiché au-dessus du prix du lot.
  final double? pricePerM2;

  /// Nombre de morceaux payés (libellé « Prix des N morceaux »).
  final int lotCount;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          if (showLotPrice && pricePerM2 != null)
            ImmoSummaryRow(
              label: 'immo.quote.price_per_m2'.tr,
              value: immoPerM2(pricePerM2!),
            ),
          if (showLotPrice)
            ImmoSummaryRow(
              label: immoLotPriceLabel(lotCount),
              value: immoPrice(payment.lotPrice),
            ),
          ImmoSummaryRow(
            label: 'immo.quote.deposit'.trParams({
              'percent': payment.depositPercent.toStringAsFixed(0),
            }),
            value: immoPrice(payment.depositAmount),
          ),
          ImmoSummaryRow(
            label: 'immo.quote.fees'.tr,
            value: immoPrice(payment.fees),
            help: 'immo.quote.commission_help'.tr,
          ),
          const Divider(height: AppDesign.space5),
          ImmoSummaryRow(
            label: 'immo.quote.pay_now'.tr,
            value: immoPrice(payment.totalToPay),
            bold: true,
          ),
          ImmoSummaryRow(
            label: 'immo.quote.balance_due'.tr,
            value: immoPrice(payment.balanceDue),
            secondary: true,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_design.dart';
import '../../../data/models/real_estate_models.dart';
import 'immo_summary_row.dart';
import 'immo_widgets.dart';

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
  });

  final RealEstateLotPayment payment;
  final bool showLotPrice;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          if (showLotPrice)
            ImmoSummaryRow(
              label: 'immo.quote.lot_price'.tr,
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

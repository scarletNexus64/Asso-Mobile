import 'package:asso/app/data/models/real_estate_models.dart';
import 'package:asso/app/modules/immo/controllers/immo_home_controller.dart';
import 'package:flutter_test/flutter_test.dart';

RealEstateListing _land(Map<String, dynamic> extra) =>
    RealEstateListing.fromJson({
      'id': 1,
      'type': 'land',
      'title': 'Terrain',
      'city': 'Douala',
      ...extra,
    });

void main() {
  test('uses the API rate per m² and keeps the total price', () {
    final p = ImmoLandPrice.of(
      _land({'price': 25000000, 'price_per_m2': 25000, 'surface_m2': 1000}),
    );
    expect(p.perM2, 25000);
    expect(p.total, 25000000);
    expect(p.perLot, isFalse);
  });

  test('derives the rate from the total when the API omits it', () {
    final p = ImmoLandPrice.of(_land({'price': 10000000, 'surface_m2': 500}));
    expect(p.perM2, 20000);
    expect(p.total, 10000000);
  });

  test('a lot with a surface range has no exact rate', () {
    final listing = _land({'price': 9000000});
    final unit = RealEstateUnit.fromJson({
      'id': 2,
      'label': 'Lot A',
      'price': 9000000,
      'surface_min': 300,
      'surface_max': 400,
    });
    final p = ImmoLandPrice.of(listing, unit: unit);
    expect(p.perM2, isNull);
    expect(p.total, 9000000);
  });

  test('per-lot sale: rate of the cheapest lot and its price', () {
    final p = ImmoLandPrice.of(
      _land({
        'price': 20000000,
        'subdivision': {
          'sale_mode': 'per_lot',
          'lots_total': 8,
          'lots_available': 8,
          'lot_surface_min': 1000,
          'lot_price_from': 20000000,
        },
      }),
    );
    expect(p.perLot, isTrue);
    expect(p.from, isTrue);
    expect(p.perM2, 20000);
    expect(p.total, 20000000);
  });

  test('per-lot detail: rate and price come from the same, cheapest lot', () {
    final p = ImmoLandPrice.of(
      _land({
        'price': 2500000,
        'price_per_m2': 7500,
        'subdivision': {
          'sale_mode': 'per_lot',
          'lots_total': 2,
          'lots_available': 2,
          'lot_surface_min': 300,
          'lot_surface_max': 400,
          'lot_price_from': 2500000,
        },
        'units': [
          {
            'id': 1,
            'label': 'A',
            'surface_min': 300,
            'surface_max': 300,
            'price': 2500000,
            'price_per_m2': 8333.3333,
          },
          {
            'id': 2,
            'label': 'B',
            'surface_min': 400,
            'surface_max': 400,
            'price': 3000000,
            'price_per_m2': 7500,
          },
        ],
      }),
    );
    expect(p.total, 2500000);
    expect(p.perM2!.round(), 8333);
    expect(p.lotSurface, 300);
    expect(p.from, isTrue);
  });
}

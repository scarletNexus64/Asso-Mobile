/// Liste des principales villes du Cameroun
class CameroonCities {
  static const List<String> all = [
    'Toutes les villes',
    'Yaoundé',
    'Douala',
    'Garoua',
    'Bamenda',
    'Maroua',
    'Bafoussam',
    'Ngaoundéré',
    'Bertoua',
    'Kribi',
    'Limbé',
    'Edéa',
    'Kumba',
    'Nkongsamba',
    'Buea',
    'Ebolowa',
    'Dschang',
    'Foumban',
    'Loum',
    'Kumbo',
    'Mbouda',
    'Mbalmayo',
    'Sangmélima',
    'Bafang',
    'Baham',
    'Bandjoun',
    'Bangangté',
    'Mokolo',
    'Tcholliré',
    'Kousséri',
    'Guidiguis',
    'Kaélé',
    'Yagoua',
    'Mora',
    'Guider',
    'Pitoa',
    'Maga',
    'Meiganga',
    'Tibati',
    'Tignère',
    'Banyo',
    'Abong-Mbang',
    'Batouri',
    'Yokadouma',
    'Lomié',
    'Ambam',
    'Kribi',
    'Akonolinga',
    'Obala',
    'Eseka',
  ];

  /// Recherche de villes
  static List<String> search(String query) {
    if (query.isEmpty) return all;

    final lowerQuery = query.toLowerCase();
    return all.where((city) =>
      city.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}

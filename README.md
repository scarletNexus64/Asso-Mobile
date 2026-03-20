# Asso E-commerce

Application mobile e-commerce développée avec Flutter et GetX.

## Structure du Projet

Le projet utilise l'architecture GetX Pattern avec la structure suivante :

```
lib/
├── app/
│   ├── core/
│   │   ├── utils/          # Utilitaires et helpers
│   │   ├── values/         # Constantes et valeurs
│   │   └── widgets/        # Widgets réutilisables
│   ├── data/
│   │   ├── models/         # Modèles de données
│   │   ├── providers/      # Providers API
│   │   └── repositories/   # Repositories
│   ├── modules/
│   │   └── home/           # Module Home (exemple)
│   │       ├── bindings/   # Dependency injection
│   │       ├── controllers/# Business logic
│   │       └── views/      # UI
│   └── routes/
│       ├── app_pages.dart  # Configuration des routes
│       └── app_routes.dart # Noms des routes
├── app_theme_system.dart   # Système de thème responsive
└── main.dart               # Point d'entrée

```

## Technologies Utilisées

- **Flutter** - Framework UI
- **GetX** (^4.7.3) - State management, navigation, dependency injection
- **get_cli** (^1.9.1) - CLI pour générer du code GetX

## Fonctionnalités

- Architecture GetX Pattern propre et scalable
- Système de thème dark/light automatique
- Design responsive (mobile, tablet, desktop)
- Navigation déclarative avec GetX
- Structure prête pour l'e-commerce

## Commandes Utiles

### Générer une nouvelle page
```bash
get create page:product
```

### Générer un nouveau controller
```bash
get create controller:cart
```

### Générer un provider
```bash
get create provider:api
```

### Lancer l'application
```bash
flutter run
```

### Lancer les tests
```bash
flutter test
```

## Getting Started

1. Installer les dépendances :
   ```bash
   flutter pub get
   ```

2. Lancer l'application :
   ```bash
   flutter run
   ```

## Prochaines Étapes

Le projet est maintenant configuré et prêt pour le développement. Vous pouvez commencer à créer vos pages e-commerce (produits, panier, checkout, etc.).

class LanguageService {
  static const Map<String, String> languageNames = {
    'en': 'English',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
  };

  static const Map<String, Map<String, String>> translations = {
    // Home Screen
    'good_morning': {
      'en': 'Good Morning',
      'de': 'Guten Morgen',
      'es': 'Buenos Días',
      'fr': 'Bonjour',
    },
    'good_afternoon': {
      'en': 'Good Afternoon',
      'de': 'Guten Nachmittag',
      'es': 'Buenas Tardes',
      'fr': 'Bon Après-midi',
    },
    'good_evening': {
      'en': 'Good Evening',
      'de': 'Guten Abend',
      'es': 'Buenas Noches',
      'fr': 'Bonsoir',
    },
    'ready_amazing': {
      'en': 'Ready to make today amazing?',
      'de': 'Bereit, den Tag fantastisch zu machen?',
      'es': '¿Lista para hacer este día increíble?',
      'fr': 'Prête à rendre cette journée incroyable?',
    },
    'daily_motivation': {
      'en': 'Daily Motivation',
      'de': 'Tägliche Motivation',
      'es': 'Motivación Diaria',
      'fr': 'Motivation Quotidienne',
    },
    'how_feeling': {
      'en': 'How are you feeling today?',
      'de': 'Wie fühlst du dich heute?',
      'es': '¿Cómo te sientes hoy?',
      'fr': 'Comment te sens-tu aujourd\'hui?',
    },
    'recent_activity': {
      'en': 'Recent Activity',
      'de': 'Letzte Aktivitäten',
      'es': 'Actividad Reciente',
      'fr': 'Activité Récente',
    },

    // Navigation
    'home': {
      'en': 'Home',
      'de': 'Home',
      'es': 'Inicio',
      'fr': 'Accueil',
    },
    'todos': {
      'en': 'ToDos',
      'de': 'ToDos',
      'es': 'Tareas',
      'fr': 'Tâches',
    },
    'notes': {
      'en': 'Notes',
      'de': 'Notizen',
      'es': 'Notas',
      'fr': 'Notes',
    },
    'goals': {
      'en': 'Goals',
      'de': 'Ziele',
      'es': 'Metas',
      'fr': 'Objectifs',
    },

    // Settings
    'settings': {
      'en': 'Settings',
      'de': 'Einstellungen',
      'es': 'Configuración',
      'fr': 'Paramètres',
    },
    'welcome_back': {
      'en': 'Welcome Back!',
      'de': 'Willkommen zurück!',
      'es': '¡Bienvenida de nuevo!',
      'fr': 'Bienvenue!',
    },
    'keep_shining': {
      'en': 'Keep shining ✨',
      'de': 'Bleib strahlend ✨',
      'es': 'Sigue brillando ✨',
      'fr': 'Continue de briller ✨',
    },
    'notifications': {
      'en': 'Notifications',
      'de': 'Benachrichtigungen',
      'es': 'Notificaciones',
      'fr': 'Notifications',
    },
    'app_settings': {
      'en': 'App Settings',
      'de': 'App-Einstellungen',
      'es': 'Configuración de la App',
      'fr': 'Paramètres de l\'App',
    },
    'language': {
      'en': 'Language',
      'de': 'Sprache',
      'es': 'Idioma',
      'fr': 'Langue',
    },
    'theme': {
      'en': 'Theme',
      'de': 'Design',
      'es': 'Tema',
      'fr': 'Thème',
    },
    'privacy_security': {
      'en': 'Privacy & Security',
      'de': 'Datenschutz & Sicherheit',
      'es': 'Privacidad y Seguridad',
      'fr': 'Confidentialité et Sécurité',
    },
    'data': {
      'en': 'Data',
      'de': 'Daten',
      'es': 'Datos',
      'fr': 'Données',
    },
    'about': {
      'en': 'About',
      'de': 'Über',
      'es': 'Acerca de',
      'fr': 'À propos',
    },
  };

  static String translate(String key, String languageCode) {
    if (translations.containsKey(key)) {
      return translations[key]?[languageCode] ?? translations[key]?['en'] ?? key;
    }
    return key;
  }
}

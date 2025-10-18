// Translation System (i18n)
const translations = {
    en: {
        header: {
            title: "CloudResilient Infrastructure 🌍",
            subtitle: "Multi-Region Azure Deployment Project"
        },
        cards: {
            region: {
                title: "Region Information",
                current: "Current Region",
                status: "Service Status",
                lastUpdate: "Last Update"
            },
            database: {
                title: "Database",
                connection: "Connection Status",
                visitors: "Visitor Count",
                backupType: "Backup Type"
            },
            system: {
                title: "System Information",
                hosting: "Hosting Type",
                cdn: "CDN",
                https: "HTTPS"
            },
            actions: {
                title: "Actions"
            }
        },
        status: {
            checking: "Checking...",
            connecting: "Connecting...",
            connected: "Connected",
            enabled: "Enabled",
            secure: "Secure",
            online: "Online",
            offline: "Offline",
            error: "Error"
        },
        stats: {
            uptime: "Uptime",
            responseTime: "Response Time",
            activeRegions: "Active Regions"
        },
        buttons: {
            refresh: "🔄 Refresh Data",
            testFailover: "🔁 Test Failover",
            viewLogs: "📊 View Logs",
            increment: "➕ Increment Counter"
        },
        footer: {
            built: "Built with ❤️ using Azure Infrastructure as Code (Bicep)"
        },
        messages: {
            refreshing: "Refreshing data...",
            refreshed: "Data refreshed successfully!",
            failoverTesting: "Testing failover...",
            failoverSuccess: "Switched to {region}!",
            counterIncremented: "Counter incremented!",
            counterError: "Failed to update counter",
            logsComingSoon: "Logs dashboard coming soon...",
            loadError: "Failed to load data",
            notAvailable: "Not available"
        }
    },
    ar: {
        header: {
            title: "CloudResilient Infrastructure 🌍",
            subtitle: "Multi-Region Azure Deployment Project"
        },
        cards: {
            region: {
                title: "معلومات المنطقة",
                current: "المنطقة الحالية",
                status: "حالة الخدمة",
                lastUpdate: "آخر تحديث"
            },
            database: {
                title: "قاعدة البيانات",
                connection: "حالة الاتصال",
                visitors: "عدد الزيارات",
                backupType: "نوع النسخ الاحتياطي"
            },
            system: {
                title: "معلومات النظام",
                hosting: "نوع الاستضافة",
                cdn: "شبكة CDN",
                https: "بروتوكول HTTPS"
            },
            actions: {
                title: "الإجراءات"
            }
        },
        status: {
            checking: "جاري الفحص...",
            connecting: "جاري الاتصال...",
            connected: "متصل",
            enabled: "مفعّل",
            secure: "آمن",
            online: "متصل",
            offline: "غير متصل",
            error: "خطأ"
        },
        stats: {
            uptime: "مدة التشغيل",
            responseTime: "زمن الاستجابة",
            activeRegions: "المناطق النشطة"
        },
        buttons: {
            refresh: "🔄 تحديث البيانات",
            testFailover: "🔁 اختبار التبديل",
            viewLogs: "📊 عرض السجلات",
            increment: "➕ زيادة العداد"
        },
        footer: {
            built: "صُنع بـ ❤️ باستخدام Azure Infrastructure as Code (Bicep)"
        },
        messages: {
            refreshing: "جاري تحديث البيانات...",
            refreshed: "تم التحديث بنجاح!",
            failoverTesting: "جاري اختبار التبديل...",
            failoverSuccess: "تم التبديل إلى {region}!",
            counterIncremented: "تم زيادة العداد!",
            counterError: "فشل تحديث العداد",
            logsComingSoon: "سيتم فتح لوحة السجلات قريباً...",
            loadError: "فشل تحميل البيانات",
            notAvailable: "غير متاح"
        }
    },
    de: {
        header: {
            title: "CloudResilient Infrastructure 🌍",
            subtitle: "Multi-Region Azure Deployment Projekt"
        },
        cards: {
            region: {
                title: "Regionsinformationen",
                current: "Aktuelle Region",
                status: "Dienststatus",
                lastUpdate: "Letzte Aktualisierung"
            },
            database: {
                title: "Datenbank",
                connection: "Verbindungsstatus",
                visitors: "Besucherzähler",
                backupType: "Backup-Typ"
            },
            system: {
                title: "Systeminformationen",
                hosting: "Hosting-Typ",
                cdn: "CDN",
                https: "HTTPS"
            },
            actions: {
                title: "Aktionen"
            }
        },
        status: {
            checking: "Überprüfen...",
            connecting: "Verbinden...",
            connected: "Verbunden",
            enabled: "Aktiviert",
            secure: "Sicher",
            online: "Online",
            offline: "Offline",
            error: "Fehler"
        },
        stats: {
            uptime: "Verfügbarkeit",
            responseTime: "Antwortzeit",
            activeRegions: "Aktive Regionen"
        },
        buttons: {
            refresh: "🔄 Daten aktualisieren",
            testFailover: "🔁 Failover testen",
            viewLogs: "📊 Protokolle anzeigen",
            increment: "➕ Zähler erhöhen"
        },
        footer: {
            built: "Mit ❤️ erstellt mit Azure Infrastructure as Code (Bicep)"
        },
        messages: {
            refreshing: "Daten werden aktualisiert...",
            refreshed: "Daten erfolgreich aktualisiert!",
            failoverTesting: "Failover wird getestet...",
            failoverSuccess: "Zu {region} gewechselt!",
            counterIncremented: "Zähler erhöht!",
            counterError: "Fehler beim Aktualisieren des Zählers",
            logsComingSoon: "Protokoll-Dashboard kommt bald...",
            loadError: "Fehler beim Laden der Daten",
            notAvailable: "Nicht verfügbar"
        }
    },
    fr: {
        header: {
            title: "CloudResilient Infrastructure 🌍",
            subtitle: "Multi-Region Azure Deployment Project"
        },
        cards: {
            region: {
                title: "Informations de la Région",
                current: "Région Actuelle",
                status: "État du Service",
                lastUpdate: "Dernière Mise à Jour"
            },
            database: {
                title: "Base de Données",
                connection: "État de la Connexion",
                visitors: "Nombre de Visiteurs",
                backupType: "Type de Sauvegarde"
            },
            system: {
                title: "Informations Système",
                hosting: "Type d'Hébergement",
                cdn: "CDN",
                https: "HTTPS"
            },
            actions: {
                title: "Actions"
            }
        },
        status: {
            checking: "Vérification...",
            connecting: "Connexion...",
            connected: "Connecté",
            enabled: "Activé",
            secure: "Sécurisé",
            online: "En ligne",
            offline: "Hors ligne",
            error: "Erreur"
        },
        stats: {
            uptime: "Disponibilité",
            responseTime: "Temps de Réponse",
            activeRegions: "Régions Actives"
        },
        buttons: {
            refresh: "🔄 Actualiser les Données",
            testFailover: "🔁 Tester le Basculement",
            viewLogs: "📊 Voir les Journaux",
            increment: "➕ Incrémenter le Compteur"
        },
        footer: {
            built: "Créé avec ❤️ en utilisant Azure Infrastructure as Code (Bicep)"
        },
        messages: {
            refreshing: "Actualisation des données...",
            refreshed: "Données actualisées avec succès!",
            failoverTesting: "Test du basculement...",
            failoverSuccess: "Basculé vers {region}!",
            counterIncremented: "Compteur incrémenté!",
            counterError: "Échec de la mise à jour du compteur",
            logsComingSoon: "Tableau de bord des journaux bientôt disponible...",
            loadError: "Échec du chargement des données",
            notAvailable: "Non disponible"
        }
    }
};

// i18n Manager
class I18n {
    constructor() {
        this.currentLang = localStorage.getItem('language') || 'en';
        this.init();
    }

    init() {
        // Set initial language
        this.setLanguage(this.currentLang, false);

        // Setup language switcher buttons
        document.querySelectorAll('.lang-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const lang = e.target.dataset.lang;
                this.setLanguage(lang);
            });
        });
    }

    setLanguage(lang, saveToStorage = true) {
        if (!translations[lang]) {
            console.error(`Language ${lang} not found`);
            return;
        }

        this.currentLang = lang;

        // Save to localStorage
        if (saveToStorage) {
            localStorage.setItem('language', lang);
        }

        // Update HTML attributes
        document.documentElement.lang = lang;
        document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';

        // Update active button
        document.querySelectorAll('.lang-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.lang === lang);
        });

        // Translate all elements
        this.translatePage();
    }

    translatePage() {
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.dataset.i18n;
            const translation = this.getTranslation(key);

            if (translation) {
                element.textContent = translation;
            }
        });
    }

    getTranslation(key) {
        const keys = key.split('.');
        let value = translations[this.currentLang];

        for (const k of keys) {
            if (value && value[k]) {
                value = value[k];
            } else {
                console.warn(`Translation key not found: ${key}`);
                return key;
            }
        }

        return value;
    }

    // Get translation with variable replacement
    t(key, vars = {}) {
        let translation = this.getTranslation(key);

        // Replace variables like {region}
        Object.keys(vars).forEach(varKey => {
            translation = translation.replace(`{${varKey}}`, vars[varKey]);
        });

        return translation;
    }
}

// Initialize i18n when DOM is ready
let i18n;
document.addEventListener('DOMContentLoaded', () => {
    i18n = new I18n();
});
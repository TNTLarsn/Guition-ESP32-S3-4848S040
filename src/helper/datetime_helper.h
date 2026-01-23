// DateTime Helper für deutsche Datums- und Zeitformatierung
// Verwendung in ESPHome Lambdas: DateTimeHelper::get_weekday(), etc.

#pragma once
#include <string>
#include <cstdio>

namespace DateTimeHelper {

// Deutsche Wochentage (Sonntag = 1, Samstag = 7)
inline const char* get_weekday(int day_of_week) {
    static const char* days[] = {
        "Sonntag", "Montag", "Dienstag", "Mittwoch",
        "Donnerstag", "Freitag", "Samstag"
    };
    if (day_of_week < 1 || day_of_week > 7) return "---";
    return days[day_of_week - 1];
}

// Deutsche Monatsnamen (Januar = 1, Dezember = 12)
inline const char* get_month(int month) {
    static const char* months[] = {
        "Januar", "Februar", "März", "April", "Mai", "Juni",
        "Juli", "August", "September", "Oktober", "November", "Dezember"
    };
    if (month < 1 || month > 12) return "---";
    return months[month - 1];
}

// Formatiert Datum als "Montag, 15. März 2026"
inline std::string format_date_full(int day_of_week, int day, int month, int year) {
    char buf[64];
    snprintf(buf, sizeof(buf), "%s, %d. %s %d",
             get_weekday(day_of_week), day, get_month(month), year);
    return std::string(buf);
}

// Formatiert Datum als "15. März 2026" (ohne Wochentag)
inline std::string format_date_short(int day, int month, int year) {
    char buf[48];
    snprintf(buf, sizeof(buf), "%d. %s %d", day, get_month(month), year);
    return std::string(buf);
}

// Formatiert Datum als "15.03.2026"
inline std::string format_date_numeric(int day, int month, int year) {
    char buf[16];
    snprintf(buf, sizeof(buf), "%02d.%02d.%d", day, month, year);
    return std::string(buf);
}

// Formatiert Uhrzeit als "22:45 Uhr"
inline std::string format_time_24h(int hour, int minute) {
    char buf[16];
    snprintf(buf, sizeof(buf), "%02d:%02d Uhr", hour, minute);
    return std::string(buf);
}

// Formatiert Uhrzeit als "22:45" (ohne "Uhr")
inline std::string format_time_simple(int hour, int minute) {
    char buf[8];
    snprintf(buf, sizeof(buf), "%02d:%02d", hour, minute);
    return std::string(buf);
}

// Formatiert Uhrzeit als "22:45:30"
inline std::string format_time_with_seconds(int hour, int minute, int second) {
    char buf[12];
    snprintf(buf, sizeof(buf), "%02d:%02d:%02d", hour, minute, second);
    return std::string(buf);
}

} // namespace DateTimeHelper

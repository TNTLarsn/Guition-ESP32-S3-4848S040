#pragma once
#include <string>
#include <cstring>

// MDI Icon Helper Klasse für die Konvertierung von Home Assistant Icon-Namen
// zu Unicode-Codepoints für die MaterialDesignIcons-Webfont
//
// Verwendet ein statisches Array mit binärer Suche statt std::map,
// um Stack Overflow bei der Initialisierung zu vermeiden.

// Struktur für Icon-Einträge (kompakt, keine dynamische Allokation)
struct MdiIconEntry {
    const char* name;
    uint32_t codepoint;
};

// Statisches, alphabetisch sortiertes Array der häufigsten MDI Icons
// WICHTIG: Muss alphabetisch sortiert sein für binäre Suche!
// Quelle: https://pictogrammers.com/library/mdi/
static const MdiIconEntry MDI_ICONS[] = {
    {"air-conditioner", 0xF0003},
    {"air-filter", 0xF0D43},
    {"air-humidifier", 0xF1099},
    {"air-humidifier-off", 0xF1466},
    {"air-purifier", 0xF0D44},
    {"alarm", 0xF0020},
    {"alarm-bell", 0xF078E},
    {"alarm-check", 0xF0021},
    {"alarm-light", 0xF078F},
    {"alarm-light-off", 0xF171E},
    {"alarm-light-outline", 0xF0BEC},
    {"alarm-off", 0xF0022},
    {"alert", 0xF0026},
    {"alert-circle", 0xF0027},
    {"alert-circle-outline", 0xF05D6},
    {"arrow-down", 0xF0045},
    {"arrow-left", 0xF004D},
    {"arrow-right", 0xF0054},
    {"arrow-up", 0xF005D},
    {"battery", 0xF0079},
    {"battery-alert", 0xF007A},
    {"battery-charging", 0xF0084},
    {"bed", 0xF02E3},
    {"bell", 0xF009A},
    {"bell-off", 0xF009B},
    {"bell-outline", 0xF0A99},
    {"bell-ring", 0xF009C},
    {"blinds", 0xF00AC},
    {"blinds-open", 0xF1011},
    {"bluetooth", 0xF00AF},
    {"bluetooth-off", 0xF00B2},
    {"brightness-6", 0xF00A2},
    {"brightness-7", 0xF00A3},
    {"camera", 0xF0100},
    {"car", 0xF00B9},
    {"car-electric", 0xF0B4C},
    {"cast", 0xF00EC},
    {"cast-connected", 0xF00ED},
    {"cctv", 0xF07AE},
    {"ceiling-light", 0xF0769},
    {"ceiling-light-outline", 0xF17C7},
    {"check", 0xF012C},
    {"check-circle", 0xF05E0},
    {"chevron-down", 0xF0140},
    {"chevron-left", 0xF0141},
    {"chevron-right", 0xF0142},
    {"chevron-up", 0xF0143},
    {"clock", 0xF0954},
    {"clock-outline", 0xF0150},
    {"close", 0xF0156},
    {"close-circle", 0xF0159},
    {"cloud", 0xF015F},
    {"cog", 0xF0493},
    {"cogs", 0xF08D6},
    {"counter", 0xF0199},
    {"curtains", 0xF1846},
    {"curtains-closed", 0xF1847},
    {"desk-lamp", 0xF095F},
    {"dishwasher", 0xF0AAC},
    {"door", 0xF081A},
    {"door-closed", 0xF081C},
    {"door-open", 0xF081B},
    {"eye", 0xF0208},
    {"eye-off", 0xF0209},
    {"fan", 0xF0210},
    {"fan-off", 0xF081D},
    {"fire", 0xF0238},
    {"flash", 0xF0241},
    {"flash-off", 0xF0242},
    {"floor-lamp", 0xF08DD},
    {"fridge", 0xF0290},
    {"garage", 0xF06D9},
    {"garage-open", 0xF06DA},
    {"gate", 0xF0299},
    {"gate-open", 0xF1170},
    {"gauge", 0xF029A},
    {"heart", 0xF02D1},
    {"help-circle", 0xF02D7},
    {"home", 0xF02DC},
    {"home-assistant", 0xF07D0},
    {"home-outline", 0xF06A1},
    {"information", 0xF02FC},
    {"lamp", 0xF06B5},
    {"lamp-outline", 0xF17D0},
    {"laptop", 0xF0322},
    {"led-strip", 0xF07D6},
    {"led-strip-variant", 0xF1051},
    {"light-switch", 0xF097E},
    {"lightbulb", 0xF1802},
    {"lightbulb-group", 0xF1253},
    {"lightbulb-off", 0xF0E4F},
    {"lightbulb-on", 0xF06E8},
    {"lightbulb-outline", 0xF0336},
    {"lightning-bolt", 0xF140B},
    {"lock", 0xF033E},
    {"lock-open", 0xF033F},
    {"menu", 0xF035C},
    {"microphone", 0xF036C},
    {"microphone-off", 0xF036D},
    {"minus", 0xF0374},
    {"molecule-co2", 0xF07E4},
    {"monitor", 0xF0379},
    {"motion-sensor", 0xF0D91},
    {"music", 0xF075A},
    {"pause", 0xF03E4},
    {"phone", 0xF03F2},
    {"play", 0xF040A},
    {"plus", 0xF0415},
    {"power", 0xF0425},
    {"power-plug", 0xF06A5},
    {"power-plug-off", 0xF06A6},
    {"power-socket", 0xF1107},
    {"radiator", 0xF0438},
    {"radiator-off", 0xF0AD8},
    {"refresh", 0xF0450},
    {"reload", 0xF0453},
    {"robot-vacuum", 0xF070D},
    {"router-wireless", 0xF0469},
    {"server", 0xF048B},
    {"shield", 0xF0498},
    {"shield-home", 0xF068A},
    {"shower", 0xF09A0},
    {"skip-next", 0xF04AD},
    {"skip-previous", 0xF04AE},
    {"smoke-detector", 0xF0392},
    {"snowflake", 0xF0717},
    {"sofa", 0xF04C4},
    {"speaker", 0xF04C3},
    {"speaker-off", 0xF04C4},
    {"spotlight", 0xF0601},
    {"star", 0xF04CE},
    {"stop", 0xF04DB},
    {"string-lights", 0xF12BA},
    {"television", 0xF0502},
    {"television-off", 0xF0831},
    {"thermometer", 0xF050F},
    {"thermostat", 0xF0393},
    {"timer", 0xF051A},
    {"toggle-switch", 0xF0521},
    {"toggle-switch-off", 0xF0522},
    {"toilet", 0xF09AB},
    {"tools", 0xF1064},
    {"track-light", 0xF0914},
    {"tree", 0xF0531},
    {"umbrella", 0xF0576},
    {"vacuum", 0xF19F0},
    {"video", 0xF0567},
    {"video-off", 0xF0568},
    {"volume-high", 0xF057E},
    {"volume-low", 0xF057F},
    {"volume-medium", 0xF0580},
    {"volume-mute", 0xF0581},
    {"volume-off", 0xF0581},
    {"wall-sconce", 0xF091C},
    {"washing-machine", 0xF072A},
    {"water", 0xF058C},
    {"water-alert", 0xF1502},
    {"water-boiler", 0xF0F92},
    {"water-heater", 0xF1A46},
    {"water-percent", 0xF0592},
    {"water-pump", 0xF058E},
    {"weather-cloudy", 0xF0590},
    {"weather-fog", 0xF0591},
    {"weather-lightning", 0xF0593},
    {"weather-night", 0xF0594},
    {"weather-partly-cloudy", 0xF0595},
    {"weather-rainy", 0xF0597},
    {"weather-snowy", 0xF0598},
    {"weather-sunny", 0xF0599},
    {"weather-windy", 0xF059D},
    {"wifi", 0xF05A9},
    {"wifi-off", 0xF05AA},
    {"window-closed", 0xF05AC},
    {"window-open", 0xF05AD},
    {"window-shutter", 0xF111C},
    {"window-shutter-open", 0xF111E},
    {"wrench", 0xF0AD3},
};

static const size_t MDI_ICONS_COUNT = sizeof(MDI_ICONS) / sizeof(MDI_ICONS[0]);

class MdiIconHelper {
public:
    // Konvertiert einen MDI Icon-String (z.B. "mdi:lightbulb") zu einem Unicode-String
    std::string convert_mdi_icon(const std::string& icon_name) {
        // Entferne "mdi:" Präfix falls vorhanden
        const char* name = icon_name.c_str();
        if (icon_name.length() > 4 && strncmp(name, "mdi:", 4) == 0) {
            name += 4;
        }
        
        // Binäre Suche im sortierten Array
        int left = 0;
        int right = MDI_ICONS_COUNT - 1;
        
        while (left <= right) {
            int mid = left + (right - left) / 2;
            int cmp = strcmp(name, MDI_ICONS[mid].name);
            
            if (cmp == 0) {
                return codepoint_to_utf8(MDI_ICONS[mid].codepoint);
            } else if (cmp < 0) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }
        
        // Fallback: Lightbulb Icon
        return codepoint_to_utf8(0xF1802);
    }

private:
    // Konvertiert einen Unicode-Codepoint zu einem UTF-8 String
    static std::string codepoint_to_utf8(uint32_t codepoint) {
        std::string result;
        if (codepoint <= 0x7F) {
            result += static_cast<char>(codepoint);
        } else if (codepoint <= 0x7FF) {
            result += static_cast<char>(0xC0 | (codepoint >> 6));
            result += static_cast<char>(0x80 | (codepoint & 0x3F));
        } else if (codepoint <= 0xFFFF) {
            result += static_cast<char>(0xE0 | (codepoint >> 12));
            result += static_cast<char>(0x80 | ((codepoint >> 6) & 0x3F));
            result += static_cast<char>(0x80 | (codepoint & 0x3F));
        } else {
            result += static_cast<char>(0xF0 | (codepoint >> 18));
            result += static_cast<char>(0x80 | ((codepoint >> 12) & 0x3F));
            result += static_cast<char>(0x80 | ((codepoint >> 6) & 0x3F));
            result += static_cast<char>(0x80 | (codepoint & 0x3F));
        }
        return result;
    }
};

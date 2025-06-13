#!/bin/bash

echo "🔍 Prüfe auf aktive Sleepblocker…"
ASSERTIONS=$(pmset -g assertions)

WARNUNG=0

# Prüfe spezifische Zeilen
check_blocker() {
    local name="$1"
    local count
    count=$(echo "$ASSERTIONS" | awk "/$name/ { if (\$2 != 0) print }")
    if [[ -n "$count" ]]; then
        echo "⚠️  Sleepblocker aktiv: $name"
        WARNUNG=1
    fi
}

check_blocker "PreventUserIdleSystemSleep"
check_blocker "PreventSystemSleep"
check_blocker "ExternalMedia"
check_blocker "coreaudiod"
check_blocker "powerd"
check_blocker "AudioTap"
check_blocker "tcpkeepalive"

# Ergebnis
if [ $WARNUNG -eq 0 ]; then
    echo -e "\n✅ Keine aktiven Sleepblocker gefunden – du kannst den Deckel schließen."
else
    echo -e "\n❌ Achtung: Es gibt Prozesse oder Geräte, die den Schlafmodus verhindern könnten!"
fi
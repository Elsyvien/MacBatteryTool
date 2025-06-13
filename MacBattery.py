import subprocess
import time
import re

def get_battery():
    output = subprocess.check_output(["pmset", "-g", "batt"]).decode()
    match = re.search(r'(\d+)%', output)
    if match:
        return int(match.group(1))
    else:
        raise RuntimeError("Konnte Batteriestand nicht ermitteln.")

print("Messung startet. Bitte nicht laden oder große Tasks starten.")
start = time.time()
start_percent = get_battery()

# Testweise kurze Messzeit für Debugging
time.sleep(60)  # 1 Minute

#start_percent = 80 zum testen
#time.sleep(2)
#end_percent = 79

end_percent = get_battery()
duration = (time.time() - start) / 3600  # Stunden
verbrauch = (start_percent - end_percent) / duration

print(f"Verbrauch: {verbrauch:.2f} %/h")

if verbrauch < 2:
    print("→ Sehr gut.")
elif verbrauch < 6:
    print("→ Normal.")
else:
    print("→ Hoch.")

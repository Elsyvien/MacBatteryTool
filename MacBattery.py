import subprocess
import time
import re

def get_charge():
    output = subprocess.check_output(["ioreg", "-n", "AppleSmartBattery", "-r"]).decode()
    current = None
    max_cap = None
    for line in output.splitlines():
        m = re.search(r'"CurrentCapacity" = (\d+)', line)
        if m:
            current = int(m.group(1))
        m = re.search(r'"MaxCapacity" = (\d+)', line)
        if m:
            max_cap = int(m.group(1))
    if current is not None and max_cap is not None and max_cap > 0:
        return current, max_cap
    raise RuntimeError("Konnte Batteriestand nicht ermitteln.")

print("Messung startet. Bitte nicht laden oder große Tasks starten.")
start = time.time()
start_charge, max_cap = get_charge()

# Testweise kurze Messzeit für Debugging
time.sleep(60)  # 1 Minute

#start_charge = 8000 zum testen
#time.sleep(2)
#end_charge = 7990

end_charge, _ = get_charge()
duration = (time.time() - start) / 3600  # Stunden
verbrauch = ((start_charge - end_charge) * 100 / max_cap) / duration

print(f"Verbrauch: {verbrauch:.2f} %/h")

if verbrauch < 2:
    print("→ Sehr gut.")
elif verbrauch < 6:
    print("→ Normal.")
else:
    print("→ Hoch.")

# Automation & Climate Strategy

How the [Automated Snail Terrarium](README.md) actually regulates itself: what
each output does, the exact settings to enter in the Climate Panel Pro web UI,
and how to tune them from the 24 h history.

Read [HARDWARE.md](HARDWARE.md) first — this document assumes the wiring is done
and each output has been manually toggled and verified.

---

## 1. Control model

The firmware gives each output one of four control modes:

| Mode | Behaviour | Used here for |
|---|---|---|
| **Manual** | On/off from the dashboard | Commissioning, overrides |
| **Sensor** | Compares temp or humidity to a setpoint with a hysteresis dead-band | Mist maker, fan (humidity ceiling) |
| **Schedule** | Daily on/off clock times | Photoperiod (if not using the circadian channel) |
| **Interval** | Cyclic on for X, off for Y | Fan air-exchange pulses |

Layered on top of any mode:

- **Invert (NC)** — flips output polarity (see [HARDWARE.md §6](HARDWARE.md)).
- **Active-time window** — gates *any* mode to a time-of-day range. Use it to
  stop the mister running at night when the tank is already cool and near-saturated.
- **Minimum switch interval (anti-short-cycle)** — refuses to change state again
  until N seconds have passed. **Essential for the mist maker.**
- **Sensor-fault failsafe** — if the SHT31-D goes missing or fails CRC for 60 s,
  every automated output is forced **off**. A dead sensor must not mean an
  endlessly fogging tank.

---

## 2. Output configuration

Enter these in the web UI (Settings → Outputs). Values assume a temperate species
(*Cornu aspersum*) — adjust the temperature band for warmer species.

### Output 1 — Mist maker (humidity floor)

| Setting | Value |
|---|---|
| Name | `Mist maker` |
| Control mode | **Sensor** |
| Source | Humidity |
| Direction | **Below** setpoint |
| Setpoint | **78 %RH** |
| Hysteresis | **6 %** → on below 78 %, off at 84 % |
| Min switch interval | **300 s** (5 min) |
| Active window | **06:00 – 22:00** |

**Why:** the fogger is the only thing that raises humidity, so it tracks the
floor. The wide 6 % dead-band and the 5 min anti-short-cycle stop it from
chattering as the plume drifts past the sensor — an ultrasonic disc hates rapid
cycling, and short bursts fog the sensor without wetting the substrate.

The active window keeps it quiet overnight, when a sealed tank cools and rises
toward saturation on its own. If overnight humidity actually sags in your room,
widen the window.

### Output 2 — Fan (humidity ceiling + air exchange)

The fan does two jobs, and the firmware gives one mode per output. Pick the one
that matches the problem you actually have:

**Option A — humidity ceiling (start here):**

| Setting | Value |
|---|---|
| Name | `Fan` |
| Control mode | **Sensor** |
| Source | Humidity |
| Direction | **Above** setpoint |
| Setpoint | **90 %RH** |
| Hysteresis | **6 %** → on above 90 %, off at 84 % |
| Min switch interval | **120 s** |

**Option B — timed air exchange (if the tank goes stagnant but never hits 90 %):**

| Setting | Value |
|---|---|
| Control mode | **Interval** |
| On time | **3 min** |
| Off time | **90 min** |
| Active window | **06:00 – 22:00** |

**Best of both:** if you fit a third XY-MOS and a second fan — or split one fan
across two outputs is not possible — the cleanest answer is **Option A on Output 2**
plus a spare output on **Interval** driving the same fan through a diode-OR. In
practice, start with Option A and only add timed exchange if you see mould.

> The dead-bands are deliberately arranged so the mister (off at 84 %) and the
> fan (on at 90 %) **never fight each other**. Keep at least 4–6 % between them.

### Output 3 — LED strip (circadian light)

Configured under **Settings → Neon light**, not as a normal output:

| Setting | Value |
|---|---|
| Mode | **Auto** (circadian) |
| Sunrise | **07:00** |
| Sunset | **19:00** |
| Night level | **0 %** |
| Time zone | your local TZ |
| Channels | **1** (single warm-white) |

Brightness ramps sunrise → peaks at solar noon → eases to the night level after
sunset. Until the clock first syncs over NTP, Auto falls back to the manual
brightness value, so the light is never stuck off waiting for time.

**12 h photoperiod** suits both the moss and the snails. Snails are nocturnal —
they will do most of their moving after the lights drop, which is normal and not
a sign of a problem.

### Output 4 — spare

Leave PCF8574 **P4** free and wired. The obvious future addition is a small
heat mat on **Sensor / temperature / below 19 °C / 1.5 °C hysteresis** if the
room gets cold in winter.

---

## 3. Why these numbers

| Choice | Reasoning |
|---|---|
| Humidity floor **78 %**, ceiling **90 %** | Below ~70 % snails seal into their shells and stop eating; above ~95 % the tank grows mould and the substrate sours. 78–90 % sits comfortably inside that with room for sensor error. |
| Hysteresis **6 %** | Fogger plumes are locally saturated. A narrow band makes the output chatter every time the plume crosses the sensor. |
| Min switch **300 s** on the mister | Ultrasonic transducers degrade under rapid cycling, and a 10-second burst humidifies the air without ever reaching the substrate. |
| Mister window **06:00–22:00** | A sealed tank cools overnight and its RH climbs on its own. Misting into that just condenses on the glass. |
| Fan hysteresis arranged **below** the mister's off-point | Prevents the two outputs oscillating against each other — the classic humidifier/dehumidifier fight. |
| Photoperiod **12 h** | Enough for moss photosynthesis without pushing algae; matches a temperate seasonal midpoint. |
| Temperature **20–22 °C** | *Cornu aspersum* comfort band. Above ~26 °C is stressful, above 30 °C is dangerous. |

---

## 4. Commissioning: the empty-tank week

**Do not put animals in until this passes.** Set the tank up fully — substrate,
moss, hides, water dish — and run it empty for **7 days**.

| Day | What to check |
|:--:|---|
| 1 | Every output responds manually. Nothing is stuck on. Mister reservoir full. |
| 1 | Sensor reads plausibly: room air ≈ 40–60 %RH before you close the lid. |
| 2–3 | Humidity settles inside 78–90 % and *stays* there without the mister running constantly. |
| 3 | No condensation film blocking your view of the whole front glass — that means over-misting. |
| 4–7 | Temperature stays 18–24 °C across the full day/night swing. |
| 7 | Read the **24 h history graph**: humidity should look like a shallow sawtooth, not a square wave or a flat line pinned at 95 %. |
| 7 | No mould on the substrate or hides. Any fuzz = increase fan time before adding snails. |
| 7 | Check the per-output **run-time counters**. A mister running > 2 h/day means the tank leaks humidity — improve the lid seal rather than misting harder. |

---

## 5. Tuning from the history graph

The 24 h graph tells you what to change:

| Pattern | Diagnosis | Fix |
|---|---|---|
| Humidity sawtooth is very **fast and shallow** | Hysteresis too narrow, or sensor in the fog plume | Widen hysteresis to 8 %; move the sensor away from the fogger |
| Humidity **pinned at 95 %+**, never falls | Not enough air exchange | Lower the fan setpoint to 88 %, or add the interval pulse |
| Humidity **sags every afternoon** | Room heating / LED warmth driving it off | Widen the mister's active window; check the lid seal |
| Mister runs **almost continuously** | Tank leaks humidity badly | Seal the lid; reduce ventilation holes; do **not** just raise the setpoint |
| Mister and fan **alternate rapidly** | Their dead-bands overlap | Push them apart: mister off at 84 %, fan on at 90 % |
| Temperature **spikes with the LED** | Strip is heating the tank | Lower peak brightness, or move the strip outside the glass |
| Humidity **flatlines** exactly | Sensor fault — check for the FAULT reading | Recheck I²C wiring and pull-ups ([HARDWARE.md §10](HARDWARE.md)) |

---

## 6. Failure modes worth designing against

| Failure | Consequence | Mitigation |
|---|---|---|
| Mist maker runs dry | Transducer burns out in minutes | Keep the reservoir above the minimum line; the active window and min-switch interval cap daily run time; check weekly |
| SHT31-D dies or drifts | Endless fogging or a bone-dry tank | Firmware failsafe forces outputs off after 60 s of fault — verify it by unplugging the sensor during commissioning |
| WiFi drops | — | Automation runs entirely on-device; WiFi is only for the dashboard. Nothing stops. |
| Power loss | Outputs off, tank coasts | A sealed 47 L tank holds its humidity for many hours. Settings persist in flash and reload on boot. |
| PCF8574 brown-out | **All outputs turn on at once** | Decoupling caps ([HARDWARE.md §6](HARDWARE.md)) + the firmware's 250 ms port refresh |
| Fan fails | Stagnant, mould | Weekly visual check; mould is visible long before it is dangerous |
| Over-misting | Sour substrate, drowned eggs | Watch the run-time counters, not just the instantaneous reading |

**Verify the failsafe during commissioning.** Unplug the SHT31-D with the mister
armed and confirm that after 60 s the output drops and the UI shows FAULT. This
is the single most important test in the whole build.

---

## 7. Routine maintenance

| Interval | Task |
|---|---|
| Daily | Glance at the dashboard: temp, humidity, output run-times |
| Weekly | Refill the mist maker reservoir; check for mould; feed and clean |
| Weekly | Confirm the sensor reading matches a second thermometer/hygrometer |
| Monthly | Wipe the ultrasonic disc (mineral scale kills output — use distilled water to slow it) |
| Monthly | Clear the fan of substrate dust |
| Quarterly | Re-check the 24 h history against the targets; re-tune if the room's season changed |
| Yearly | Replace the substrate; inspect the LED strip's seal for water ingress |

Using **distilled or deionised water** in the mist maker roughly triples the time
between descaling and keeps mineral dust off the moss.

---

*Setpoints here are a starting point, not gospel. Watch the animals: a snail that
stays sealed in its shell wants more humidity; one glued to the lid away from the
substrate usually wants less heat.*

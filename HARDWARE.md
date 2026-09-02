# Hardware & Wiring — Automated Snail Terrarium

Everything needed to build the electronics for the
[Automated Snail Terrarium](README.md). Every pin here mirrors a `#define` in
[`esp8266-climate-pro.ino`](https://github.com/MiladKarandish/esp8266-climate-pro) —
the firmware is the source of truth; this document tracks it.

> This is an **entirely low-voltage build** (3.3 V logic, 5–24 V loads). Nothing
> here switches mains. Keep it that way unless you are qualified to do otherwise.

---

## 1. Bill of materials

### Core electronics

| Qty | Part | Spec / notes |
|:--:|---|---|
| 1 | **ESP-01 / ESP-01S (ESP8266)** | ESP-01**S** = 1 MB flash — **required** for OTA updates |
| 1 | **SHT31-D breakout** | I²C temp + humidity, addr **0x44** (or 0x45); firmware auto-detects |
| 1 | **PCF8574 module** | I²C 8-bit I/O expander, addr **0x20** (A0/A1/A2 → GND) |
| 2 | **XY-MOS 400 W MOSFET module** | High-power N-MOSFET switch, PWM-capable trigger input |
| 1 | **Third switch — see §5** | A 3rd XY-MOS, or a small logic-level N-MOSFET board |
| 1 | **USB-serial adapter** | CH340 / CP2102 / FTDI at **3.3 V logic** — first flash only |

### Loads

| Qty | Part | Typical spec — **confirm yours** |
|:--:|---|---|
| 1 | **Ultrasonic mist maker, 550 mL/h** | Commonly **24 V DC, 0.5–1 A**; some modules are 12 V |
| 1 | **Fan** | 5 V or 12 V DC, 0.1–0.3 A (40–80 mm) |
| 1 | **Neon LED strip, 1 m** | Analog (**not** WS2812/addressable), 12 V, ~0.5–1 A/m, **IP65+** |

### Passives & power

| Qty | Part | Purpose |
|:--:|---|---|
| 2 | 4.7 kΩ resistor | I²C pull-ups on SDA and SCL → 3.3 V |
| 1 | 10 kΩ resistor | ESP-01 CH_PD (EN) pull-up → 3.3 V |
| 1 | 10 kΩ resistor | (optional) ESP-01 RST pull-up → 3.3 V |
| 3 | 4.7 kΩ resistor | Pull-ups on the PCF8574 output pins — **see §6, this is not optional** |
| 1 | 0.1 µF ceramic | PCF8574 decoupling, **at the chip** — see §6 |
| 1 | 100 µF electrolytic | Bulk cap on the PCF8574 / 3.3 V rail |
| 1 | Main PSU | See §4 — sized from your mist maker's voltage |
| 1–2 | Buck converter (e.g. MP1584 / LM2596) | Step down to 12 V and/or 3.3 V |
| 1 | 3.3 V regulator ≥ 500 mA | ESP-01 is power-sensitive; do **not** feed it 5 V |

---

## 2. Signal glossary

| Signal | Meaning | Level |
|---|---|---|
| **SDA** | I²C data — shared by SHT31-D **and** PCF8574 | 3.3 V |
| **SCL** | I²C clock — shared by both | 3.3 V |
| **P0…P7** | PCF8574 expander outputs — drive the MOSFET module triggers | 3.3 V (see §6) |
| **GPIO3 (RX)** | ESP-01 PWM output → LED MOSFET gate | 3.3 V |
| **CH_PD / EN** | ESP-01 chip enable — must be HIGH to run | 3.3 V |
| **GPIO0** | I²C SDA in normal use; **tie LOW at boot to flash** | 3.3 V |
| **GND** | Ground — **every module shares one common ground** | 0 V |

**The golden rule:** ESP, sensor, expander, MOSFET modules and every power
supply share one common GND. Without it nothing works reliably.

---

## 3. Pin map (TL;DR)

```
ESP-01                     PCF8574 @ 0x20
  GPIO0  = SDA  ──────┬──► SHT31-D SDA
  GPIO2  = SCL  ──────┼──► SHT31-D SCL          P2 → MOSFET #1 trigger  (Mist maker)
  GPIO3  = LED PWM    └──► PCF8574 SDA/SCL      P3 → MOSFET #2 trigger  (Fan)
  GPIO1  = TX (free, serial log)                P4 → MOSFET #3 trigger  (spare / heater)
  CH_PD  = 3.3 V via 10 kΩ                      P0,P1,P5,P6,P7 → free
  VCC    = 3.3 V (≥500 mA)
```

Firmware `#define`s these live behind:

| Wire | `#define` | Value |
|---|---|---|
| SDA | `SDA_PIN` | `0` |
| SCL | `SCL_PIN` | `2` |
| LED PWM | `LED_PIN` | `3` |
| Expander enable | `USE_PCF8574` | `1` |
| Expander address | `PCF_ADDR` | `0x20` |
| Output → pin | `PCF_BIT[]` | `{2, 3, 4, …}` |
| Load polarity | `RELAY_ACTIVE_LOW` | `1` direct-drive · **`0`** if you invert per §6 |

> `USE_PCF8574 1` is what makes this build possible: it moves the outputs off
> TX/RX, which frees **GPIO3 for LED PWM** and raises `MAX_OUTPUTS` from 2 to 8.

---

## 4. Power

### Budget

| Rail | Consumer | Draw |
|---|---|---|
| 3.3 V | ESP-01 (WiFi TX peaks) | ~80 mA avg, **300 mA peak** |
| 3.3 V | SHT31-D | < 1 mA |
| 3.3 V | PCF8574 | < 100 µA (+ pull-up currents) |
| 12 V | LED strip, 1 m | 0.5–1.0 A |
| 12 V | Fan | 0.1–0.3 A |
| 24 V | Mist maker, 550 mL/h | 0.5–1.0 A |

**Total worst case ≈ 24 W.** Size the PSU with ≥30 % headroom.

### Recommended topology

Confirm the mist maker's voltage first — it decides the layout.

**If the mist maker is 24 V:**

```
  24 V 3 A PSU ──┬──────────────────────────────► Mist maker (via MOSFET #1)
                 │
                 ├──[buck → 12 V]──┬────────────► LED strip (via MOSFET #3, PWM)
                 │                 └────────────► Fan (via MOSFET #2)
                 │
                 └──[buck → 3.3 V]──────────────► ESP-01 + SHT31-D + PCF8574
```

**If the mist maker is 12 V:** drop the 24 V rail entirely — one **12 V 3 A PSU**
feeds all three loads directly, with a single buck to 3.3 V for the logic.

### Power rules

- **Never power the ESP-01 from 5 V.** It is a 3.3 V part with no on-board regulator.
- **Never back-feed load current through the MCU rail.** Loads take their power
  from the PSU; the MCU only drives gates.
- Give the ESP-01 its own regulator output or a well-decoupled tap — WiFi TX
  bursts brown it out on a shared, sagging rail.
- Fit the bulk + ceramic caps on the 3.3 V rail near the ESP-01 **and** the
  PCF8574 (§6).

---

## 5. Output allocation — and the third-switch gap

There are **three switched loads** but the parts list has **two** XY-MOS modules.

| Output | Load | Switch | Driven from | Why |
|:--:|---|---|---|---|
| 1 | Mist maker | XY-MOS #1 | PCF8574 **P2** | Highest current, on/off only |
| 2 | Fan | XY-MOS #2 | PCF8574 **P3** | On/off only |
| 3 | LED strip | **needs a 3rd** | ESP-01 **GPIO3** | Must be **PWM** for the circadian dim curve |

**Options for the third switch:**

1. **Buy a third XY-MOS module** — simplest, identical wiring, PWM-capable. ✅ recommended
2. **Use a bare logic-level N-MOSFET** (IRLZ44N, AO3400) + 220 Ω gate resistor +
   10 kΩ gate pull-down. The LED strip is only ~1 A, so a 400 W module is overkill
   anyway — this is the cheap path.
3. **Drop dimming** and put the LED on PCF8574 P4 as plain on/off. You lose the
   sunrise/sunset curve; the moss and the snails only get a hard on/off photoperiod.

Nothing else in the build changes whichever you pick.

---

## 6. ⚠️ Driving MOSFET modules from the PCF8574 — read this

The PCF8574's outputs are **quasi-bidirectional**: they sink strongly (25 mA)
but source only **~100 µA** through a weak internal pull-up. An XY-MOS trigger
input has its own gate pull-down resistor. That pull-down against a 100 µA
source will **not** pull the gate to a valid logic HIGH — the MOSFET stays off,
or worse, sits half-on and cooks.

**Fix — one of:**

- **External pull-up (simplest):** fit a **4.7 kΩ resistor from each used PCF8574
  pin to 3.3 V**. The pin now idles HIGH strongly and pulls LOW hard. Verify with
  a multimeter that the trigger sees > 2.5 V when idle.
- **Verify with a scope/meter before connecting the load.** Measure the trigger
  voltage in both states with the module attached. If HIGH < 2.5 V, the pull-up
  is too weak — go lower (2.2 kΩ) or add a transistor buffer.

**Polarity:** the XY-MOS trigger is active-**HIGH** (HIGH = load on). The firmware
defaults to `RELAY_ACTIVE_LOW 1`. Either set `#define RELAY_ACTIVE_LOW 0` and
reflash, or leave it and tick **invert (NC)** on each output in the web UI —
whichever you do, **confirm the load is OFF at power-up before leaving it alone.**

**Decouple the PCF8574 — this matters.** The chip has *no reset pin*; any dip in
its VCC below the power-on-reset level silently reverts **all** outputs to HIGH
(0xFF) — which, with active-HIGH modules, turns **every load on at once**. Fit a
**0.1 µF ceramic across VCC↔GND right at the chip**, plus a **10–100 µF bulk cap**
on that rail, and keep VCC/GND on short soldered wire. The firmware re-asserts
the port every 250 ms (`pcfRefreshTask`) as a safety net, but that only shortens
the glitch — clean power is the real fix.

---

## 7. Wiring

### 7.1 ESP-01 pinout (antenna at top)

```
            ┌─────────────────┐
     GND ───┤ ●             ● ├─── VCC (3.3 V)
   GPIO2 ───┤ ●             ● ├─── RST
   GPIO0 ───┤ ●             ● ├─── CH_PD (EN)
RX/GPIO3 ───┤ ●             ● ├─── TX/GPIO1
            └─────────────────┘
```

### 7.2 Logic side

```
   3.3 V ──┬──[10 kΩ]── CH_PD (EN)
           ├──[10 kΩ]── RST            (optional, idle high)
           ├────────── ESP-01 VCC
           ├────────── SHT31-D VCC
           ├────────── PCF8574 VCC     (+ 0.1 µF at the chip, + 100 µF bulk)
           ├──[4.7 kΩ]─ SDA  (bus pull-up)
           └──[4.7 kΩ]─ SCL  (bus pull-up)

   GPIO0 (SDA) ──┬──► SHT31-D SDA
                 └──► PCF8574 SDA
   GPIO2 (SCL) ──┬──► SHT31-D SCL
                 └──► PCF8574 SCL

   PCF8574 A0/A1/A2 ──► GND            (address 0x20)

   GND ──┬── ESP-01 ─┬── SHT31-D ─┬── PCF8574 ─┬── MOSFET modules ─┬── PSU
         └───────────┴────────────┴────────────┴───────────────────┘
                          one common ground
```

### 7.3 Output side

```
   PCF8574 P2 ──[4.7 kΩ → 3.3 V pull-up]──► XY-MOS #1 SIG ──► Mist maker
   PCF8574 P3 ──[4.7 kΩ → 3.3 V pull-up]──► XY-MOS #2 SIG ──► Fan
   ESP-01 GPIO3 ──[220 Ω]──► MOSFET #3 gate ──► LED strip      (PWM)
                     └──[10 kΩ]── GND         (gate pull-down: strip OFF at boot)

   Each XY-MOS module:
      VIN+ / VIN−  ← from the PSU rail for that load
      OUT+ / OUT−  → the load
      SIG / GND    ← control from the PCF8574 (SIG) and common GND
```

The **gate pull-down on the LED channel is not optional** — without it GPIO3
floats during boot and the strip flashes on at full brightness every reset.

### 7.4 Inside vs. outside the tank

| Inside | Outside |
|---|---|
| SHT31-D (mid-height, away from the fogger plume and the LED) | ESP-01, PCF8574, all MOSFET modules |
| LED strip (**IP65+ sealed only**) | Mist maker reservoir + transducer |
| Fan outlet / inlet ducting | PSU and buck converters |

Everything outside lives in a ventilated enclosure. The inside of the tank is a
permanently condensing 90 %RH environment — unsealed electronics corrode in weeks.

**Sensor placement matters more than anything else in this section.** Mount the
SHT31-D at mid-height on a side wall, out of the direct fog stream and out of the
LED's radiated heat. A sensor in the plume reads 95 %RH while the far corner is
at 60 %, and the control loop chases a lie.

---

## 8. Flashing

The ESP-01 needs a **3.3 V logic** USB-serial adapter for the first flash only;
everything after that can go over OTA (`/update` or ArduinoOTA — needs 1 MB flash).

| USB-serial | → ESP-01 |
|---|---|
| 3.3 V | VCC **and** CH_PD (via 10 kΩ) |
| GND | GND |
| TX | ESP-01 RX (GPIO3) |
| RX | ESP-01 TX (GPIO1) |
| — | **GPIO0 → GND** to enter flash mode |

**Sequence:** GPIO0 to GND → power on / pulse RST → release GPIO0 → upload.
An "ESP-01 programmer" dongle with an auto-reset circuit does this for you.

Because the outputs are on the PCF8574, **TX/RX are free during flashing** — no
need to unplug the loads. Do disconnect the **LED MOSFET gate from GPIO3** while
flashing, since GPIO3 is the serial RX line.

---

## 9. I²C address reference

| Device | Address | Notes |
|---|---|---|
| SHT31-D | **0x44** (default) / 0x45 | ADDR pin; firmware auto-detects both |
| PCF8574 | **0x20**–0x27 | A0/A1/A2 jumpers; all-GND = 0x20 |
| PCF8574**A** | 0x38–0x3F | **Different chip variant** — the #1 cause of "outputs don't respond" |

0x44 and 0x20 never collide, so both devices live happily on the same two wires
with a single pair of pull-ups.

---

## 10. First-power-on checklist

1. ☐ All grounds tied together — ESP, sensor, expander, MOSFET modules, every PSU.
2. ☐ ESP-01 on **3.3 V** from a ≥500 mA regulator. Not 5 V. Not a shared sagging rail.
3. ☐ 4.7 kΩ pull-ups on SDA and SCL; 10 kΩ on CH_PD; GPIO0 **not** grounded.
4. ☐ 4.7 kΩ pull-ups on every used PCF8574 output pin (§6).
5. ☐ 0.1 µF at the PCF8574 + bulk cap on the 3.3 V rail (§6).
6. ☐ 10 kΩ gate pull-down on the LED MOSFET (§7.3).
7. ☐ **Loads disconnected.** Power up and measure the trigger voltages first.
8. ☐ Confirm every output reads OFF at rest, then connect the loads one at a time.
9. ☐ Mist maker reservoir **filled above the minimum line** before its first run.
10. ☐ Device makes a `ClimatePro-XXXX` hotspot → join it → set your WiFi.
11. ☐ Open `http://climate-pro.local` → sensor shows plausible numbers.
12. ☐ Toggle each output manually from the UI and confirm the right load responds.
13. ☐ Configure automation per [AUTOMATION.md](AUTOMATION.md), then run the tank
        empty for a week and read the 24 h history before adding animals.

### Troubleshooting

| Symptom | Cause |
|---|---|
| Sensor reads `--` / FAULT | SDA/SCL swapped, or missing 4.7 kΩ pull-ups |
| Outputs don't respond at all | Wrong `PCF_ADDR` — PCF8574A is 0x38, not 0x20 |
| Output on when it should be off | Polarity — flip `RELAY_ACTIVE_LOW` or the UI's invert flag |
| Outputs "blink" / one toggles another | PCF8574 brown-out — fit the decoupling caps (§6) |
| MOSFET warm but load barely runs | Gate not reaching full HIGH — pull-up too weak (§6) |
| LED flashes bright on every reset | Missing 10 kΩ gate pull-down on GPIO3 |
| ESP reboots when a load switches | PSU sag / no common ground / no bulk capacitance |

---

*If you move a wire, update the matching `#define` **and** this file, so
future-you isn't guessing.*

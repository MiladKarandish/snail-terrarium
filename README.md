# Automated Snail Terrarium

A smart, self-regulating snail habitat: a 46 × 28 × 37 cm moss-covered terrarium
with closed-loop humidity, temperature and light control, driven by an ESP8266
running [**Climate Panel Pro**](https://github.com/MiladKarandish/esp8266-climate-pro)
firmware. No cloud, no app — the controller serves its own real-time web
dashboard over WiFi.

> **Status:** design + documentation stage. Hardware is specified; wiring,
> firmware configuration and tuning are in progress.

---

## 1. What this is

Land snails are simple to keep and unforgiving about exactly one thing: **the
climate**. Too dry and they seal themselves into their shells and stop eating;
too wet and stagnant and the tank grows mould and bacteria. Doing that by hand
means misting twice a day, every day, forever.

This project closes the loop:

- An **SHT31-D** sensor reads temperature and relative humidity inside the tank.
- When humidity drops below target, an **ultrasonic mist maker** fogs the tank.
- When humidity overshoots — or on a scheduled interval — a **fan** exchanges air.
- A **neon LED strip** runs a circadian day/night cycle so the live **moss**
  carpet gets a real photoperiod and the snails get a stable dawn/dusk rhythm.
- Everything is visible and adjustable from a phone browser on the local network.

### Design goals

| Goal | How |
|---|---|
| Hold 75–90 %RH without manual misting | SHT31-D → mist maker, hysteresis control |
| Keep air fresh, prevent mould | Fan on humidity ceiling + timed air exchange |
| Real day/night for moss and snails | PWM LED strip on a sunrise/sunset curve |
| Never cook or drown the animals | Sensor-fault failsafe forces outputs off |
| Fully local, no subscriptions | ESP8266 web dashboard, WebSocket, mDNS |
| Repairable and documented | Every pin mirrored in [HARDWARE.md](HARDWARE.md) |

---

## 2. The habitat

| Property | Value |
|---|---|
| Enclosure | Glass/acrylic terrarium, **46 × 28 × 37 cm** (L × W × H) |
| Volume | ≈ **47.7 L** (0.048 m³) |
| Floor area | ≈ **1288 cm²** |
| Substrate | Coco coir / peat + sphagnum, 5–8 cm deep (snails burrow to lay eggs) |
| Planting | Live moss carpet (sheet/cushion moss), optional ferns |
| Furnishing | Cork bark hides, calcium/cuttlebone dish, shallow water dish, food dish |
| Lid | Escape-proof, ventilated — snails climb everything and lift light lids |

### Climate targets

Defaults below assume a temperate species (e.g. *Cornu aspersum*, the common
garden snail). **Confirm against your species** before committing setpoints —
giant African land snails want it warmer (24–27 °C).

| Parameter | Target | Acceptable | Notes |
|---|---|---|---|
| Temperature | **20–22 °C** | 18–24 °C | Above ~26 °C is stressful; above 30 °C dangerous |
| Humidity | **80 %RH** | 75–90 %RH | Below 70 % → snails seal up; above 95 % → mould |
| Photoperiod | **12 h** | 10–14 h | Moss needs light; snails need shaded hides |
| Air exchange | Every 1–2 h | — | Short fan pulses; the tank must not go stagnant |

Full control strategy and setpoint mapping: **[AUTOMATION.md](AUTOMATION.md)**.

---

## 3. Hardware at a glance

| # | Component | Role |
|---|---|---|
| 1 | **ESP8266 (ESP-01)** | Controller — WiFi, web UI, automation logic |
| 2 | **SHT31-D** | I²C temperature + humidity sensor (±0.2 °C, ±2 %RH) |
| 3 | **PCF8574** | I²C 8-bit I/O expander — frees the ESP-01's TX/RX for outputs |
| 4 | **550 mL/h ultrasonic mist maker** | Humidifier — raises RH |
| 5 | **Fan** | Air exchange / circulation — lowers RH, prevents mould |
| 6 | **1 m neon LED strip** | Circadian lighting, analog (non-addressable) |
| 7 | **2 × XY-MOS 400 W MOSFET module** | High-current switches for the loads |
| 8 | Power supply + buck converter | See [HARDWARE.md §Power](HARDWARE.md) |

> ⚠️ **Known gap:** there are **three** switched loads (mist maker, fan, LED
> strip) but only **two** MOSFET modules. A third switch is needed — see
> [HARDWARE.md](HARDWARE.md) for the recommended allocation and options.

Full bill of materials, pin map, wiring diagrams and power budget:
**[HARDWARE.md](HARDWARE.md)**.

---

## 4. System architecture

```
                    ┌──────────────────────────────────────────┐
                    │            TERRARIUM (47.7 L)            │
                    │                                          │
   ┌─────────┐ I²C  │  ┌──────────┐                            │
   │ ESP-01  │◄─────┼──┤ SHT31-D  │  temp + humidity           │
   │ ESP8266 │      │  └──────────┘                            │
   │         │      │                                          │
   │  WiFi   │      │  ┌──────────┐   ┌─────┐   ┌───────────┐  │
   │  web UI │      │  │  Mist    │   │ Fan │   │ LED strip │  │
   └────┬────┘      │  │  maker   │   └──▲──┘   └─────▲─────┘  │
        │ I²C       │  └────▲─────┘      │            │        │
        ▼           └───────┼────────────┼────────────┼────────┘
   ┌─────────┐              │            │            │
   │ PCF8574 │──────────────┴────────────┘            │
   │  0x20   │   on/off via XY-MOS MOSFET modules     │
   └─────────┘                                        │
        ESP-01 GPIO3 (PWM) ─────────────────────────────┘
                            dimmable circadian channel

   Phone / laptop ──WiFi──► http://snail-terrarium.local
```

**Control loop:** read SHT31-D once per second → compare against per-output
setpoints with a hysteresis dead-band → drive outputs through the PCF8574 (on/off)
and GPIO3 (PWM) → broadcast state to every connected browser over WebSocket.

---

## 5. Firmware

The controller runs **Climate Panel Pro (ESP8266 edition)** —
`~/Documents/arduino/esp8266-climate-pro`
([GitHub](https://github.com/MiladKarandish/esp8266-climate-pro)).

Relevant capabilities for this build:

- **Up to 8 independently-controlled outputs**, each named, each with a control
  mode: **Manual**, **Sensor** (temp/hum, above/below setpoint + hysteresis),
  **Schedule** (daily on/off times), or **Interval** (cyclic on/off).
- **Per-output invert (NC)**, an **active-time window** gating any mode, and an
  **anti-short-cycle** minimum switch time — important for the mist maker.
- **Sensor-fault failsafe**: a CRC-failed or missing SHT31-D forces every
  automated output off after 60 s rather than fogging forever.
- **Circadian LED channel** — sunrise → daylight → sunset → night brightness
  curve on an NTP-synced clock, or manual brightness.
- **Captive-portal WiFi setup** (no credentials in code), **mDNS**,
  **OTA updates** (web `/update` + ArduinoOTA), settings persisted in flash.
- **24 h history**, min/avg/max, trend arrows, per-output run-time counters.

Build flags this project requires (top of `esp8266-climate-pro.ino`):

```c
#define USE_PCF8574 1      // outputs on the expander; frees TX/RX, enables LED PWM
#define PCF_ADDR    0x20   // A0/A1/A2 → GND
```

With `USE_PCF8574 1` the firmware also enables `LED_SUPPORTED` on **GPIO3**, and
raises `MAX_OUTPUTS` from 2 to 8.

---

## 6. Repository layout

```
snail-terrarium/
├── README.md        ← you are here: what the project is
├── HARDWARE.md      ← bill of materials, wiring, pin map, power, safety
└── AUTOMATION.md    ← climate strategy, output config, tuning
```

Firmware lives in its own repository:
[`esp8266-climate-pro`](https://github.com/MiladKarandish/esp8266-climate-pro).

---

## 7. Roadmap

- [x] Define enclosure, species targets and component list
- [x] Document hardware, wiring and control strategy
- [ ] Resolve the third-switch gap (mist maker / fan / LED)
- [ ] Confirm mist maker and fan operating voltages, size the PSU
- [ ] Bench-test: ESP-01 + SHT31-D + PCF8574 on one I²C bus
- [ ] Wire loads through the MOSFET modules, verify no brown-out on switching
- [ ] Flash with `USE_PCF8574 1`, configure the four outputs
- [ ] Seal, plant the moss, run empty for 1 week and log the climate
- [ ] Tune hysteresis and fan interval from the 24 h history
- [ ] Introduce the snails

---

## 8. Safety and animal-welfare notes

- **Ultrasonic misters must never run dry** — the disc burns out in minutes.
  Keep the reservoir above the minimum line, and cap run time with the
  firmware's interval/active-window limits.
- **Keep all electronics outside the tank.** The inside is a permanently
  condensing 90 %RH environment; only the sensor and the LED strip go in, and
  the strip must be a sealed (IP65+) type.
- **Fog is not ventilation.** A snail tank that is wet *and* stagnant grows
  mould and pathogenic bacteria fast. The fan cycle is not optional.
- **Shade matters.** Snails are nocturnal and avoid light — always leave cork
  bark or dense moss they can hide under, no matter what the LED is doing.
- **Escape-proofing.** Snails are strong climbers and will find any gap large
  enough for their foot, cable pass-throughs included.
- **Low-voltage only.** Nothing in this build switches mains. If you later add
  a mains heater, that is a different and far more dangerous project — use a
  properly enclosed, rated relay module and follow local electrical code.

---

*Licensed MIT. Firmware pin definitions are the source of truth — if you move a
wire, update the matching `#define` and [HARDWARE.md](HARDWARE.md).*

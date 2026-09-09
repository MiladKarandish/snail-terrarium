# Ultrasonic Mist Maker (550 mL/h) — Technical Datasheet & Integration Guide

Technical specification, electrical characteristics, hydrological operating limits, and control guidelines for the **550 mL/h Ultrasonic Mist Maker / Atomizer Module** sourced from ECA.

- **Vendor Listing:** [ECA E-Shop (ماژول تولید بخار سرد اولتراسونیک اتومیزر 550ml در ساعت)](https://eshop.eca.ir/%D9%85%D8%A7%DA%98%D9%88%D9%84-%D9%88-%D8%B3%D9%86%D8%B3%D9%88%D8%B1-%D8%A8%D8%AE%D8%A7%D8%B1-%D8%B3%D8%B1%D8%AF/3791-%D9%85%D8%A7%DA%98%D9%88%D9%84-%D8%AA%D9%88%D9%84%DB%8C%D8%AF-%D8%A8%D8%AE%D8%A7%D8%B1-%D8%B3%D8%B1%D8%AF-%D8%A7%D9%88%D9%84%D8%AA%D8%B1%D8%A7%D8%B3%D9%88%D9%86%DB%8C%DA%A9-%D8%A7%D8%AA%D9%88%D9%85%DB%8C%D8%B2%D8%B1-550ml-%D8%AF%D8%B1-%D8%B3%D8%A7%D8%B9%D8%AA.html)
- **ECA Product ID / SKU:** `3791`
- **PrestaShop Reference Code:** `3011018004`
- **OEM Platform Equivalents:** CL-24 / DK-24 / MY-011 / M011 (Single-head 45 mm submersible atomizer, plastic housing, no LED)

---

## 1. Quick Reference

| Parameter | Confirmed Value | Tolerance / Range |
|---|---|---|
| **Operating Voltage** | **24.0 V DC** | 22.0 V – 26.0 V DC |
| **Running Current** | **0.75 A** | 0.70 A – 0.85 A (at 24 V, 25 °C water) |
| **Power Consumption** | **~18 W – 20 W** | 24 W maximum rating |
| **Inrush / Startup Current** | **~1.1 A – 1.3 A** | Transient peak during resonance acquisition (~100 ms) |
| **Oscillation Frequency** | **1.70 MHz** | ±40 kHz (1700 kHz bulk acoustic resonance) |
| **Transducer Disc** | **Ø20.0 mm ceramic PZT** | Lead Zirconate Titanate, recessed well mount |
| **Mist Output Rate** | **≥ 450 – 550 mL/h** | Measured with optimal 20–25 mm head above disc at 25 °C |
| **Aerosol Droplet Size** | **1.0 – 5.0 µm** | Sub-micron to fine cold aerosol |
| **Water Operating Temp** | **+5 °C to +45 °C** | Optimal: +20 °C to +30 °C |
| **Dry-Run Protection** | **Integrated conductive probe** | Cuts oscillation when water drops below probe tip |
| **Probe Trigger Level** | **41 mm from vessel base** | Minimum total vessel water depth to start |
| **Optimal Liquid Depth** | **42 mm – 47 mm from base** | ~20 mm – 25 mm liquid column over the recessed disc |
| **Choking Depth** | **> 50 mm from base** | Acoustic energy suppressed; splatters large droplets |
| **Housing Dimensions** | **Ø45.0 mm × 45.0 mm H** | Cylindrical body with central splash-guard collar |
| **Cable Specification** | **1.4 m (1400 ± 20 mm)** | UL2464 24 AWG × 2C, OD 3.8 mm, with sliding rubber bung |
| **Power Connector** | **5.5 × 2.1 mm DC barrel jack** | Female socket, **Center Positive (+)**, **Sleeve GND (-)** |
| **Ingress Protection** | **IP68** (Submersible) | Lower body factory potted in solid black epoxy resin |
| **Total Weight** | **96 g** | Module body, cable, and connector combined |

---

## 2. Electrical Characteristics & Power Integration

### 2.1 Voltage & Polarity
- **Input Type:** Direct Current (**DC only**).
  > **Note:** Some legacy industrial foggers run on 24 V AC via bare step-down transformers. **This unit requires regulated 24 V DC.** It contains an internal high-frequency inverter circuit and will not run on 12 V, 19 V, or AC without internal damage or failure to oscillate.
- **DC Jack Pinout:** Standard 5.5 mm outer diameter, 2.1 mm center pin.
  - **Center Pin:** `+24 V DC`
  - **Outer Sleeve:** `GND (0 V)`
- **PSU Sizing:** Size the dedicated 24 V power supply for **≥ 1.5 A** for a single unit, or **3.0 A** if running buck converters from the same supply to feed 12 V fans and 3.3 V logic rails.

### 2.2 Microcontroller & MOSFET Switching Rules
- **Switching Topology:** Switch the negative lead (`GND`) using a logic-level N-channel MOSFET module (e.g. *XY-MOS 400 W dual N-channel module*, *AO3400*, *IRLZ44N*), or use a relay / high-side P-channel MOSFET switch.
- **⚠️ Prohibition of High-Frequency PWM:**
  - **Never apply high-frequency PWM (e.g. 490 Hz – 20 kHz) to control mist output.**
  - The internal driver is an analog self-oscillating LC inverter (using an RF power BJT/MOSFET tuned to the ceramic disc's 1.7 MHz resonance).
  - It requires **50–200 ms** under continuous DC voltage to stabilize its oscillation tank and build the surface capillary acoustic wave.
  - Chopping the power rail at PWM frequencies causes excessive switching losses, extreme transistor heating, and prevents cavitation.
- **Recommended Control Mode:** **Bang-Bang / Time-Proportional Switching.**
  - Regulate ambient humidity by turning the 24 V supply ON and OFF in macro-intervals:
  - Minimum ON time: **≥ 10 seconds**
  - Minimum OFF time: **≥ 15 seconds**
  - Use an anti-short-cycle timer in firmware to prevent rapid chattering around the humidity threshold.

---

## 3. Hydrological Dynamics & Vessel Geometry

### 3.1 Resolving the "20–75 mm" Specification Confusion
The generic vendor specification typically states *"Water level: 20–75 mm"*.
In real installation, **20–75 mm refers to the height of water above the ceramic disc face**, **not** from the bottom of the container.

Because the ceramic disc sits inside a recessed central well approximately **22 mm above the vessel base**, all critical measurements from the vessel floor are:

```
 Total Depth
 from Base
   ▲
   │
55 ┼ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  Choking / Splatter Zone (>50 mm)
50 ┼ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  Heavy hydrostatic head dampens cavitation; throws drops
   │
47 ┼ ───────────────────────────────────────  Optimal Upper Limit (Cap ON)
   │ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  SWEET SPOT (42–47 mm)
44 ┼ ───────────────────────────────────────  Optimal Lower Limit (Cap OFF)
   │
41 ┼ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  Safety Probe Threshold (~41 mm)
   │                                          Unit shuts down below this line
   │            ┌─────────┐
   │            │ ░░░░░░░ │  <-- Splash guard / collar (top at 45 mm)
   │            │         │
22 ┼ ─ ─ ─ ─ ─ ─┤ [PIEZO] ├─ ─ ─ ─ ─ ─ ─ ─ ─  Piezo disc surface (~22 mm from floor)
   │      ┌─────┘         └─────┐
   │      │   Potted Chassis    │
 0 ┴ ─────┴─────────────────────┴───────────  Vessel Floor (0 mm)
```

1. **Safety Cut-Off Line (`41 mm` total depth):**
   - The metal pin protruding upward beside the central chimney is an electrical conductivity sensor.
   - It requires liquid contact between the probe tip and the grounded casing to bias the oscillator on.
   - When liquid drops below **41 mm**, the circuit opens and oscillation halts instantly.
   - *(Note: Some vendor descriptions claim this module lacks a water sensor. That is factually incorrect; physical inspection confirms the conductive sensing probe is present).*
2. **Optimal Mist Band (`42 mm – 47 mm` total depth):**
   - Highest mist output occurs when the water column standing directly above the ceramic disc is **20 mm to 25 mm** deep.
   - At this level, ultrasonic energy efficiently focuses at the liquid-air interface to generate high-density capillary wave micro-droplets without bubbling violently.
3. **Choking Threshold (`> 50 mm` total depth):**
   - As water depth exceeds 50 mm from the base (> 28 mm above the disc), hydrostatic head pressure absorbs the acoustic shock waves.
   - Mist production drops sharply, and the module throws coarse water droplets instead of a dry fog.
4. **Effective Working Bandwidth:**
   - The functional operating window is only **~6 mm to 10 mm** wide (between probe cut-off at 41 mm and acoustic damping at ~50 mm).
   - In an open, unregulated chamber, evaporation will consume this band in a short time. A **constant-level replenishment system** (such as an external Mariotte siphon bottle or float valve) is strongly recommended for automated systems.

---

## 4. Mechanical & Dimensional Details

```
              ┌─── Ø 20 mm Disc ───┐
              ▼                    ▼
          ┌───────┐            ┌───────┐
          │       │  [Probe]   │       │
          │       │    │       │       │
          │       └──┐ │ ┌─────┘       │ ◄── Splash collar / chimney
   45 mm  │          │ │ │             │
          │   ┌──────┴─┴─┴──────┐      │
          ├───┘                 └───┬──┤ ◄── Cable entry with strain relief
          │                         │  │
          │   Solid Epoxy Potted    │  │
          │    Driver Circuitry     │  │
          └─────────────────────────┴──┘
          ◄────────── Ø 45 mm ─────────►
```

- **Outer Diameter:** 45.0 mm.
- **Overall Height:** 45.0 mm (from base feet to the top edge of the splash collar).
- **Base Cylinder Height:** ~25.0 mm.
- **Collar / Chimney Height:** ~20.0 mm above main body shoulder.
- **Disc Recess:** ~23.0 mm below the top edge of the collar.
- **Cable:**
  - Standard length: **1.40 m** (1400 ± 20 mm).
  - Marking: `AWM 2464 24AWG 80°C 300V VW-1`.
  - Outer diameter: **3.8 mm**.
  - Pass-Through Seal: Includes a sliding conical rubber bung (OD tapering from ~14 mm to ~11 mm, with an 8 mm center collar) suitable for sealing against a chamfered hole in a chamber wall.
- **Repairability / Serviceability:**
  - **Non-serviceable assembly.**
  - The transducer cavity and bottom electronics are factory-potted in rigid black epoxy resin to achieve IP68 submersion protection.
  - The ceramic disc is bonded and sealed with factory compound; it does not utilize an accessible screw-retaining ring. If the disc fractures, the entire module must be replaced as a consumable unit.

---

## 5. Water Quality & Operational Maintenance

### 5.1 Water Chemistry
- **Recommended Water:** **Demineralized, Deionized, or Reverse Osmosis (RO) water.**
- **Impact of Tap / Hard Water:**
  - Tap water dissolved minerals (calcium, magnesium) precipitate on the vibrating face of the ceramic disc due to intense local cavitation heat.
  - Mineral scale creates acoustic impedance mismatches, cuts mist output by >50 % within weeks, and creates hot-spots that crack the ceramic element.
  - Mineral aerosols from hard water also leave white mineral dust in the terrarium / enclosure.

### 5.2 Descaling & Cleaning Protocol
1. Disconnect 24 V power before removing the module from water.
2. If mineral deposits or biological films appear:
   - Submerge the head in a **50:50 solution of warm water and white vinegar** (or 5% citric acid solution) for **20–30 minutes**.
   - Gently wipe the surface of the ceramic disc and the metal probe using a **soft cotton swab**.
   - **Never** use steel wire, razor blades, metallic screwdrivers, or abrasive pads, as scratching the gold/silver electrode film on the disc will permanently ruin it.
3. Rinse thoroughly with clean RO water before placing back into service.

### 5.3 Duty Cycle Guidelines
- **Continuous Operation Limit:** Do not run continuously for more than **8 to 10 hours** without resting. In intermittent terrarium climate control (e.g. 1–3 minutes per humidity cycle), component lifespan is maximized.
- **Transducer Lifespan:** Rated for **3,000 to 5,000 hours** of cumulative oscillation under clean water conditions.

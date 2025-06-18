# Star-Delta Motor Starter PLC Program

This repository contains a PLC program written in Structured Text (ST) that implements a **Star-Delta motor starting sequence**. The program includes safety mechanisms, timer-controlled transitions, alarm handling, and status indicators for a 3-phase induction motor.

---

## 📋 Program Overview

The `PLC_PRG` program is designed to:

- Start a motor using the **Star-Delta** starting method.
- Monitor auxiliary contact feedback to ensure correct operation.
- Automatically transition from Star to Delta after a configurable time.
- Raise an alarm and stop the motor if any abnormal condition occurs.
- Display system status using indicator lamps.

---

## 🔧 Functional Description

### **Inputs**

| Variable | Description |
|----------|-------------|
| `start_pushbutton` | Starts the motor sequence |
| `stop_pushbutton` | Stops the motor immediately |
| `reset_pushbutton` | Resets an active alarm |
| `overload_protection` | Triggered if overload is detected |
| `main_auxiliary_latch` | Feedback from main contactor |
| `star_auxiliary_latch` | Feedback from star contactor |
| `delta_auxiliary_latch` | Feedback from delta contactor |

### **Outputs**

| Variable | Description |
|----------|-------------|
| `main_contact_coil` | Activates the main contactor |
| `star_contact_coil` | Activates the star contactor |
| `delta_contact_coil` | Activates the delta contactor |
| `motor_running` | Indicates motor is running (any stage) |
| `stop_lamp` | Lit when motor is not running |
| `alarm_lamp` | Lit when alarm is latched or overload is active |

---

## 🕹️ Operating Sequence

1. **Start Pushbutton Pressed**
   - Main and Star contactors are energized.
   - Star mode engages the motor.

2. **Timer Expires (Default: 5s)**
   - Star contactor disengages.
   - Delta contactor engages.
   - Motor runs in Delta mode.

3. **Stop Pushbutton or Alarm**
   - All contactors de-energize.
   - Alarm condition (if any) latches and must be reset.

4. **Reset**
   - Clears latched alarm when reset button is pressed.

---

## 🚨 Alarm Conditions

The alarm is activated if:

- Main contactor is on but no feedback.
- Star contactor is on but no feedback.
- Delta contactor is on but no feedback.
- Overload condition is detected.

After 5 seconds of continuous fault, the alarm latches.

---

## 💡 Status Indicators

- **`stop_lamp`** – ON when all contactors are OFF.
- **`alarm_lamp`** – ON when alarm is latched or overload is triggered.
- **`motor_running`** – ON if any contactor (main, star, delta) is active.

---

## 🛠️ Future Improvements

- Introduce state-machine based control (`motor_state`) for cleaner transitions.
- Add debounce logic for mechanical inputs.
- Implement configurable timer values via HMI or external parameters.
- Add interlocks for contactor safety delays.

---

**Author:** [Okere Prince N.]

**Contact:** [https://www.linkedin.com/in/prince-okere-686912177/]

---

PROGRAM PLC_PRG
// This program is designed to control a motor using a star-delta starting method.
VAR
    // Internal variables for the PLC program
    process_timer: TON; // Timer for the main contact coil
    prcess_timer_active: BOOL; // Indicates if the timer is active
    process_timer_donebit: BOOL;  // Process Timer donebit when time has elapsed

    // Alarm and status variables
    alarm_timer: TON;   // Timer for the main contact coil
    alarm_active: BOOL; // Indicates if the alarm is active
    alarm_latch: BOOL;  // Latch for the alarm state
    alarm_timer_donebit: BOOL; // Alarm Timer donebit when time has elapsed
END_VAR

VAR_INPUT
    // Main inputs for the PLC program
    start_pushbutton: BOOL;
    Emergency_stop: BOOL;
    //reset_pushbutton: BOOL;

    // Protection inputs
    overload_protection: BOOL;

    // Additional inputs can be defined here
    main_auxiliary_latch: BOOL;
    star_auxiliary_latch: BOOL;
    delta_auxiliary_latch: BOOL;
END_VAR

VAR_OUTPUT
    // Contact coils Output for the motor control
    main_contact_coil: BOOL; // Main contact coil for the motor
    star_contact_coil: BOOL; // Star contact coil for the motor
    delta_contact_coil: BOOL; // Delta contact coil for the motor

    // Indicators for the motor status
    motor_running: BOOL; // Indicates if the motor is running

    // Lamps outputs
    stop_lamp: BOOL;
    alarm_lamp: BOOL;
END_VAR


// Initialize Process Control
IF start_pushbutton AND NOT alarm_latch THEN
    star_contact_coil := TRUE;
END_IF;

IF star_contact_coil THEN
    main_contact_coil := TRUE;
    delta_contact_coil := FALSE;
END_IF;
    
IF Emergency_stop OR overload_protection THEN
    main_contact_coil := FALSE;
    star_contact_coil := FALSE;
    delta_contact_coil := FALSE;
END_IF;

(* Process alarm engages when main contact and auxiliary contact isn't in sync *)
prcess_timer_active := main_contact_coil AND main_auxiliary_latch AND NOT overload_protection;
process_timer(IN := prcess_timer_active, PT := T#5S, Q => process_timer_donebit);

IF process_timer_donebit THEN
    star_contact_coil := FALSE;
    delta_contact_coil := TRUE;
    main_contact_coil := TRUE;
END_IF;

(*	Alarm Monitoring: Motor Contactor On but Aux Contact Not On
    Alarm condition if motor contact is engaged without aux contact *)
alarm_active := (main_contact_coil AND NOT main_auxiliary_latch)
                OR (star_contact_coil AND NOT star_auxiliary_latch)
                OR (delta_contact_coil AND NOT delta_auxiliary_latch)
                OR overload_protection;
alarm_timer(IN := alarm_active, PT := T#5S, Q => alarm_timer_donebit);

//All stays on if Fault precedes
alarm_latch := alarm_timer_donebit;

//We make use of this code incase we want to incorperate Reset Pushbutton to the system
(*
IF alarm_timer.Q THEN
alarm_latch := TRUE;
END_IF;

IF reset_pushbutton THEN
alarm_latch := FALSE;
END_IF;
*)

// Process Status Indicators
// Stop lamp status
stop_lamp := overload_protection OR NOT main_contact_coil OR NOT star_contact_coil OR NOT delta_contact_coil;
// Alarm lamp status
alarm_lamp := alarm_latch OR overload_protection;
// Motor running status
motor_running := main_auxiliary_latch AND delta_auxiliary_latch AND NOT alarm_latch;

(* This code is a PLC program that implements a star-delta motor starting sequence with alarm handling and status indicators.
    It uses timers and contact coils to control the motor's operation based on input conditions such as pushbuttons and overload protection.
    The program also manages alarm states and provides visual indicators for the motor's status.
    The program is structured to ensure safe operation of the motor, with clear logic for starting. *)
PROGRAM PLC_PRG
    // This program is designed to control a motor using a star-delta starting method.
    VAR
        // Internal variables for the PLC program
        main_timer: TON; // Timer for the main contact coil
        timer_active: BOOL; // Indicates if the timer is active

        // Alarm and status variables
        alarm_timer: TON;   // Timer for the main contact coil
        alarm_active: BOOL; // Indicates if the alarm is active
        alarm_latch: BOOL;  // Latch for the alarm state
    END_VAR

    VAR_INPUT
        // Main inputs for the PLC program
        start_pushbutton: BOOL;
        stop_pushbutton: BOOL;
        reset_pushbutton: BOOL;

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

    IF start_pushbutton AND NOT alarm_latch THEN
        star_contact_coil := TRUE;
    END_IF;

    IF stop_pushbutton OR alarm_latch THEN
        main_contact_coil := FALSE;
        star_contact_coil := FALSE;
        delta_contact_coil := FALSE;
    END_IF;

    IF star_contact_coil THEN
        main_contact_coil := TRUE;
        delta_contact_coil := FALSE;
    END_IF;

    timer_active := main_contact_coil AND main_auxiliary_latch AND NOT overload_protection;
    main_timer(IN := timer_active, PT := T#5s);

    IF main_timer.Q THEN
        star_contact_coil := FALSE;
        delta_contact_coil := TRUE;
        main_contact_coil := TRUE;
    END_IF;

    alarm_active := (main_contact_coil AND NOT main_auxiliary_latch)
                OR (star_contact_coil AND NOT star_auxiliary_latch)
                OR (delta_contact_coil AND NOT delta_auxiliary_latch)
                OR overload_protection;
    alarm_timer(IN := alarm_active, PT := T#5s);

    IF alarm_timer.Q THEN
        alarm_latch := TRUE;
    END_IF;

    IF reset_pushbutton THEN
        alarm_latch := FALSE;
    END_IF;

    // Process Status Indicators
    // Stop lamp status
    stop_lamp := NOT main_contact_coil AND NOT star_contact_coil AND NOT delta_contact_coil;
    // Alarm lamp status
    alarm_lamp := alarm_latch OR overload_protection;
    // Motor running status
    motor_running := main_contact_coil OR star_contact_coil OR delta_contact_coil;
END_PROGRAM
// This code is a PLC program that implements a star-delta motor starting sequence with alarm handling and status indicators. It uses timers and contact coils to control the motor's operation based on input conditions such as pushbuttons and overload protection. The program also manages alarm states and provides visual indicators for the motor's status.
// The program is structured to ensure safe operation of the motor, with clear logic for starting,
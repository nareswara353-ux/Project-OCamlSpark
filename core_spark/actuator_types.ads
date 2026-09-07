package Actuator_Types with SPARK_Mode, Pure is
   type Actuator_ID is (Left_Aileron, Right_Aileron, Elevator, Rudder);
   subtype Deflection_Range is Float range -1.0 .. 1.0;
   type Command is record
      Target_Deflection : Deflection_Range;
      Rate_Limit        : Float range 0.0 .. 1.0;
   end record;
   type Limit_Record is record
      Max_Deflection : Deflection_Range;
      Min_Deflection : Deflection_Range;
   end record;
   type Health_Status is (Healthy, Degraded, Failed);
end Actuator_Types;

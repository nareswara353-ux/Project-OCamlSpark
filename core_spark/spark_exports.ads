with Interfaces.C;
with Actuator_Types; use Actuator_Types;
with Actuator_Commands;
with Redundancy_Voter;
with Health_Monitor; use Health_Monitor;
with Actuator_Limits;
with Actuator_Controller;
with Power_Distribution;
with Debug_Interface;

package Spark_Exports with SPARK_Mode is
   use type Interfaces.C.int;
   use type Interfaces.C.unsigned_char;

   type C_Command is record
      Target_Deflection : Interfaces.C.C_float;
      Rate_Limit        : Interfaces.C.C_float;
   end record
   with Convention => C;

   type C_Limits is record
      Max_Deflection : Interfaces.C.C_float;
      Min_Deflection : Interfaces.C.C_float;
   end record
   with Convention => C;

   type C_Actuator_State is record
      Current_Deflection : Interfaces.C.C_float;
      Current_Mode       : Interfaces.C.int;
      Last_Command       : C_Command;
      Health             : Interfaces.C.int;
      Limit              : C_Limits;
   end record
   with Convention => C;

   type C_Channel_Health is record
      Position    : Interfaces.C.int;
      Temperature : Interfaces.C.int;
      Current     : Interfaces.C.int;
      Hydraulic   : Interfaces.C.int;
   end record
   with Convention => C;

   type C_Bus_Load is record
      Current_Load : Interfaces.C.C_float;
      Max_Capacity : Interfaces.C.C_float;
   end record
   with Convention => C;

   function Spark_Validate_Command
     (Current, Target, Max_Rate, Max_Def, Min_Def : Interfaces.C.C_float)
      return Interfaces.C.unsigned_char
   with Export, Convention => C, External_Name => "spark_validate_command";

   function Spark_Apply_Limits
     (Cmd : C_Command; Limits : C_Limits)
      return C_Command
   with Export, Convention => C, External_Name => "spark_apply_limits";

   function Spark_Is_Within_Limits
     (Value : Interfaces.C.C_float; Limits : C_Limits)
      return Interfaces.C.unsigned_char
   with Export, Convention => C, External_Name => "spark_is_within_limits";

   function Spark_Check_Overall_Status
     (Pos, Temp, Curr, Hyd : Interfaces.C.int)
      return Interfaces.C.int
   with Export, Convention => C, External_Name => "spark_check_overall_status";

   function Spark_Majority_Vote
     (C1, C2, C3 : C_Command; Limits : C_Limits)
      return C_Command
   with Export, Convention => C, External_Name => "spark_majority_vote";

   function Spark_Is_Consensus
     (C1, C2, C3 : C_Command; Tolerance : Interfaces.C.C_float)
      return Interfaces.C.unsigned_char
   with Export, Convention => C, External_Name => "spark_is_consensus";

   function Spark_Get_Current_Deflection
     (ID : Interfaces.C.int)
      return Interfaces.C.C_float
   with Export, Convention => C, External_Name => "spark_get_current_deflection";

   function Spark_Get_Temperature
     (ID : Interfaces.C.int)
      return Interfaces.C.C_float
   with Export, Convention => C, External_Name => "spark_get_temperature";

   function Spark_Get_Hydraulic_Pressure
     (ID : Interfaces.C.int)
      return Interfaces.C.C_float
   with Export, Convention => C, External_Name => "spark_get_hydraulic_pressure";

   function Spark_Get_Channel_Health
     (ID : Interfaces.C.int)
      return C_Channel_Health
   with Export, Convention => C, External_Name => "spark_get_channel_health";

   function Spark_Get_Overall_Status
     (ID : Interfaces.C.int)
      return Interfaces.C.int
   with Export, Convention => C, External_Name => "spark_get_overall_status";

   function Spark_Allocate_Power
     (ID : Interfaces.C.int; Required_Power : Interfaces.C.C_float)
      return Interfaces.C.unsigned_char
   with Export, Convention => C, External_Name => "spark_allocate_power";

   function Spark_Get_Bus_Load
     (Bus : Interfaces.C.int)
      return C_Bus_Load
   with Export, Convention => C, External_Name => "spark_get_bus_load";

   function Spark_Is_Bus_Overloaded
     (Bus : Interfaces.C.int)
      return Interfaces.C.unsigned_char
   with Export, Convention => C, External_Name => "spark_is_bus_overloaded";

   function Spark_Shed_Load
     (Bus, ID : Interfaces.C.int)
      return Interfaces.C.unsigned_char
   with Export, Convention => C, External_Name => "spark_shed_load";

   function Spark_Get_Power_Status
     (ID : Interfaces.C.int)
      return Interfaces.C.int
   with Export, Convention => C, External_Name => "spark_get_power_status";

   function Spark_Init
     (Limits : C_Limits)
      return C_Actuator_State
   with Export, Convention => C, External_Name => "spark_init";

   function Spark_Step
     (State : C_Actuator_State; Cmd : C_Command)
      return C_Actuator_State
   with Export, Convention => C, External_Name => "spark_step";

   function Spark_Fault_Handler
     (State : C_Actuator_State)
      return C_Actuator_State
   with Export, Convention => C, External_Name => "spark_fault_handler";

   function Spark_Emergency_Stop
     (State : C_Actuator_State)
      return C_Actuator_State
   with Export, Convention => C, External_Name => "spark_emergency_stop";

   function Spark_Is_Safe
     (State : C_Actuator_State)
      return Interfaces.C.unsigned_char
   with Export, Convention => C, External_Name => "spark_is_safe";

end Spark_Exports;

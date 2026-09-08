with Actuator_Types; use Actuator_Types;
with Actuator_Commands; use Actuator_Commands;
with Health_Monitor; use Health_Monitor;

package Actuator_Controller with SPARK_Mode is
   type Controller_State is (Idle, Active, Fault, Emergency);

   type Actuator_State is record
      Current_Deflection : Deflection_Range;
      Current_Mode       : Controller_State;
      Last_Command       : Command;
      Health             : Health_Status;
      Limit              : Limit_Record;
   end record;

   function Init (Limits : Limit_Record) return Actuator_State
   with
      Pre  => Limits.Max_Deflection >= Limits.Min_Deflection,
      Post => Init'Result.Current_Mode = Idle and
              Init'Result.Current_Deflection = 0.0 and
              Init'Result.Health = Healthy;

   function Step (State : Actuator_State; Cmd : Command) return Actuator_State
   with
      Pre  => (State.Current_Mode /= Fault or State.Current_Mode /= Emergency) and
              Is_Valid (Cmd, State.Limit),
      Post => Step'Result.Current_Mode = Active and
              Step'Result.Current_Deflection = Apply_Limits (Cmd, State.Limit).Target_Deflection;

   function Fault_Handler (State : Actuator_State) return Actuator_State
   with
      Pre  => State.Current_Mode = Active,
      Post => Fault_Handler'Result.Current_Mode = Fault;

   function Emergency_Stop (State : Actuator_State) return Actuator_State
   with
      Post => Emergency_Stop'Result.Current_Mode = Emergency and
              Emergency_Stop'Result.Current_Deflection = 0.0;

   function Is_Safe (State : Actuator_State) return Boolean
   with
      Post => Is_Safe'Result =
         (State.Current_Mode /= Fault and
          State.Current_Mode /= Emergency and
          State.Health = Healthy and
          State.Current_Deflection <= State.Limit.Max_Deflection and
          State.Current_Deflection >= State.Limit.Min_Deflection);
end Actuator_Controller;

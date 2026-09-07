with Actuator_Types;
with Actuator_Commands;
with Redundancy_Voter;
with Health_Monitor;
with Actuator_Limits;

package Actuator_Pkg with SPARK_Mode is
   pragma Ghost;

   subtype Safe_Deflection is Actuator_Types.Deflection_Range
      with Dynamic_Predicate =>
         Safe_Deflection <= Actuator_Limits.Max_Deflection and
         Safe_Deflection >= Actuator_Limits.Min_Deflection;

   subtype Safe_Command is Actuator_Types.Command
      with Dynamic_Predicate =>
         Actuator_Commands.Is_Valid (Safe_Command,
            (Max_Deflection => Actuator_Limits.Max_Deflection,
             Min_Deflection => Actuator_Limits.Min_Deflection));

   function Global_Invariant (Cmd : Safe_Command) return Boolean is
      (Actuator_Commands.Is_Within_Rate (0.0, Cmd.Target_Deflection, 0.1));
end Actuator_Pkg;

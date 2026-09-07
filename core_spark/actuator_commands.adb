with Ada.Numerics; use Ada.Numerics;

package body Actuator_Commands with SPARK_Mode is
   function Is_Valid (Cmd : Command; Limits : Limit_Record) return Boolean is
   begin
      return (Cmd.Target_Deflection <= Limits.Max_Deflection and
              Cmd.Target_Deflection >= Limits.Min_Deflection and
              Cmd.Rate_Limit in 0.0 .. 1.0);
   end Is_Valid;

   function Apply_Limits (Cmd : Command; Limits : Limit_Record) return Command is
      Clamped_Target : Deflection_Range;
   begin
      if Cmd.Target_Deflection > Limits.Max_Deflection then
         Clamped_Target := Limits.Max_Deflection;
      elsif Cmd.Target_Deflection < Limits.Min_Deflection then
         Clamped_Target := Limits.Min_Deflection;
      else
         Clamped_Target := Cmd.Target_Deflection;
      end if;
      return (Target_Deflection => Clamped_Target,
              Rate_Limit        => Cmd.Rate_Limit);
   end Apply_Limits;

   function Is_Within_Rate (Current, Target : Deflection_Range; Max_Rate : Float) return Boolean is
   begin
      return (abs (Target - Current) <= Max_Rate);
   end Is_Within_Rate;

   function Validate_Command (Current, Target : Deflection_Range; Limits : Limit_Record; Max_Rate : Float) return Boolean is
   begin
      return (Target <= Limits.Max_Deflection and
              Target >= Limits.Min_Deflection and
              abs (Target - Current) <= Max_Rate);
   end Validate_Command;
end Actuator_Commands;

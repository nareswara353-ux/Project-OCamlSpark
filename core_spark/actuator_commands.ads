with Actuator_Types; use Actuator_Types;

package Actuator_Commands with SPARK_Mode is
   function Is_Valid (Cmd : Command; Limits : Limit_Record) return Boolean
   with
      Pre  => (Limits.Max_Deflection >= Limits.Min_Deflection),
      Post => Is_Valid'Result =
         (Cmd.Target_Deflection <= Limits.Max_Deflection and
          Cmd.Target_Deflection >= Limits.Min_Deflection and
          Cmd.Rate_Limit in 0.0 .. 1.0);

   function Apply_Limits (Cmd : Command; Limits : Limit_Record) return Command
   with
      Pre  => (Limits.Max_Deflection >= Limits.Min_Deflection),
      Post =>
         (Apply_Limits'Result.Target_Deflection <= Limits.Max_Deflection and
          Apply_Limits'Result.Target_Deflection >= Limits.Min_Deflection and
          Apply_Limits'Result.Rate_Limit = Cmd.Rate_Limit);

   function Is_Within_Rate (Current, Target : Deflection_Range; Max_Rate : Float) return Boolean
   with
      Post => Is_Within_Rate'Result =
         (abs (Target - Current) <= Max_Rate);

   function Validate_Command (Current, Target : Deflection_Range; Limits : Limit_Record; Max_Rate : Float) return Boolean
   with
      Pre  => (Limits.Max_Deflection >= Limits.Min_Deflection and Max_Rate >= 0.0),
      Post => Validate_Command'Result =
         (Target <= Limits.Max_Deflection and
          Target >= Limits.Min_Deflection and
          abs (Target - Current) <= Max_Rate);
end Actuator_Commands;

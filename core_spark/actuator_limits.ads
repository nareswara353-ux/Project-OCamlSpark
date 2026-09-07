with Actuator_Types; use Actuator_Types;

package Actuator_Limits with SPARK_Mode is
   Max_Deflection : constant Deflection_Range := 0.95;
   Min_Deflection : constant Deflection_Range := -0.95;

   function Is_Within_Limits (Value : Deflection_Range) return Boolean
   with
      Post => Is_Within_Limits'Result =
         (Value <= Max_Deflection and Value >= Min_Deflection);

   function Is_Deflection_Safe (Value : Deflection_Range; Limits : Limit_Record) return Boolean
   with
      Pre  => (Limits.Max_Deflection >= Limits.Min_Deflection),
      Post => Is_Deflection_Safe'Result =
         (Value <= Limits.Max_Deflection and Value >= Limits.Min_Deflection);
end Actuator_Limits;

package body Actuator_Limits with SPARK_Mode is
   function Is_Within_Limits (Value : Deflection_Range) return Boolean is
   begin
      return (Value <= Max_Deflection and Value >= Min_Deflection);
   end Is_Within_Limits;

   function Is_Deflection_Safe (Value : Deflection_Range; Limits : Limit_Record) return Boolean is
   begin
      return (Value <= Limits.Max_Deflection and Value >= Limits.Min_Deflection);
   end Is_Deflection_Safe;
end Actuator_Limits;

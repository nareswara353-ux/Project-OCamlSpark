with Actuator_Commands; use Actuator_Commands;

package body Redundancy_Voter with SPARK_Mode is
   function Majority_Vote (Cmd1, Cmd2, Cmd3 : Command; Limits : Limit_Record) return Command is
      V1 : Deflection_Range := Cmd1.Target_Deflection;
      V2 : Deflection_Range := Cmd2.Target_Deflection;
      V3 : Deflection_Range := Cmd3.Target_Deflection;
      Median_Value : Deflection_Range;
   begin
      if (V1 >= V2 and V1 <= V3) or (V1 <= V2 and V1 >= V3) then
         Median_Value := V1;
      elsif (V2 >= V1 and V2 <= V3) or (V2 <= V1 and V2 >= V3) then
         Median_Value := V2;
      else
         Median_Value := V3;
      end if;
      return (Target_Deflection => Median_Value, Rate_Limit => Cmd1.Rate_Limit);
   end Majority_Vote;

   function Is_Consensus (Cmd1, Cmd2, Cmd3 : Command; Tolerance : Deflection_Range) return Boolean is
   begin
      return (abs (Cmd1.Target_Deflection - Cmd2.Target_Deflection) <= Tolerance and
              abs (Cmd2.Target_Deflection - Cmd3.Target_Deflection) <= Tolerance and
              abs (Cmd1.Target_Deflection - Cmd3.Target_Deflection) <= Tolerance);
   end Is_Consensus;

   function Mismatch_Detected (Cmd1, Cmd2, Cmd3 : Command; Tolerance : Deflection_Range) return Boolean is
   begin
      return not Is_Consensus (Cmd1, Cmd2, Cmd3, Tolerance);
   end Mismatch_Detected;
end Redundancy_Voter;

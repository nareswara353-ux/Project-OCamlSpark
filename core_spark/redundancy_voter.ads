with Actuator_Types; use Actuator_Types;

package Redundancy_Voter with SPARK_Mode is
   function Majority_Vote (Cmd1, Cmd2, Cmd3 : Command; Limits : Limit_Record) return Command
   with
      Pre  => (Limits.Max_Deflection >= Limits.Min_Deflection and
               Is_Valid (Cmd1, Limits) and
               Is_Valid (Cmd2, Limits) and
               Is_Valid (Cmd3, Limits)),
      Post =>
         (Majority_Vote'Result.Target_Deflection <= Limits.Max_Deflection and
          Majority_Vote'Result.Target_Deflection >= Limits.Min_Deflection and
          Majority_Vote'Result.Rate_Limit in 0.0 .. 1.0);

   function Is_Consensus (Cmd1, Cmd2, Cmd3 : Command; Tolerance : Deflection_Range) return Boolean
   with
      Pre  => (Tolerance >= 0.0),
      Post => Is_Consensus'Result =
         (abs (Cmd1.Target_Deflection - Cmd2.Target_Deflection) <= Tolerance and
          abs (Cmd2.Target_Deflection - Cmd3.Target_Deflection) <= Tolerance and
          abs (Cmd1.Target_Deflection - Cmd3.Target_Deflection) <= Tolerance);

   function Mismatch_Detected (Cmd1, Cmd2, Cmd3 : Command; Tolerance : Deflection_Range) return Boolean
   with
      Pre  => (Tolerance >= 0.0),
      Post => Mismatch_Detected'Result =
         not (abs (Cmd1.Target_Deflection - Cmd2.Target_Deflection) <= Tolerance and
              abs (Cmd2.Target_Deflection - Cmd3.Target_Deflection) <= Tolerance and
              abs (Cmd1.Target_Deflection - Cmd3.Target_Deflection) <= Tolerance);
end Redundancy_Voter;

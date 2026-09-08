with Actuator_Commands; use Actuator_Commands;

package body Actuator_Controller with SPARK_Mode is
   function Init (Limits : Limit_Record) return Actuator_State is
   begin
      return (Current_Deflection => 0.0,
              Current_Mode       => Idle,
              Last_Command       => (Target_Deflection => 0.0, Rate_Limit => 0.0),
              Health             => Healthy,
              Limit              => Limits);
   end Init;

   function Step (State : Actuator_State; Cmd : Command) return Actuator_State is
      Validated_Cmd : Command := Apply_Limits (Cmd, State.Limit);
   begin
      return (Current_Deflection => Validated_Cmd.Target_Deflection,
              Current_Mode       => Active,
              Last_Command       => Validated_Cmd,
              Health             => State.Health,
              Limit              => State.Limit);
   end Step;

   function Fault_Handler (State : Actuator_State) return Actuator_State is
   begin
      return (Current_Deflection => State.Current_Deflection,
              Current_Mode       => Fault,
              Last_Command       => State.Last_Command,
              Health             => Failed,
              Limit              => State.Limit);
   end Fault_Handler;

   function Emergency_Stop (State : Actuator_State) return Actuator_State is
   begin
      return (Current_Deflection => 0.0,
              Current_Mode       => Emergency,
              Last_Command       => (Target_Deflection => 0.0, Rate_Limit => 0.0),
              Health             => State.Health,
              Limit              => State.Limit);
   end Emergency_Stop;

   function Is_Safe (State : Actuator_State) return Boolean is
   begin
      return (State.Current_Mode /= Fault and
              State.Current_Mode /= Emergency and
              State.Health = Healthy and
              State.Current_Deflection <= State.Limit.Max_Deflection and
              State.Current_Deflection >= State.Limit.Min_Deflection);
   end Is_Safe;
end Actuator_Controller;

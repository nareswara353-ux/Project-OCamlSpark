with Ada.Text_IO; use Ada.Text_IO;
with Actuator_Types; use Actuator_Types;
with Actuator_Commands; use Actuator_Commands;
with Actuator_Controller; use Actuator_Controller;
with Actuator_Limits; use Actuator_Limits;
with Redundancy_Voter; use Redundancy_Voter;
with Power_Distribution; use Power_Distribution;
with Debug_Interface; use Debug_Interface;

procedure Main with SPARK_Mode is
   Limits : constant Limit_Record :=
     (Max_Deflection => Max_Deflection, Min_Deflection => Min_Deflection);
   State : Actuator_State := Init (Limits);
   Cmd : Command;
   Voted : Command;
   Safe_Flag : Boolean;
begin
   Put_Line ("SPARK Actuator Controller Runtime");
   Put_Line ("Initial mode: Idle");

   Cmd := (Target_Deflection => 0.25, Rate_Limit => 0.10);
   State := Step (State, Cmd);
   Put_Line ("Step 1: deflection = " & Float'Image (State.Current_Deflection));

   Cmd := (Target_Deflection => 0.55, Rate_Limit => 0.10);
   State := Step (State, Cmd);
   Put_Line ("Step 2: deflection = " & Float'Image (State.Current_Deflection));

   Voted := Majority_Vote (
     (Target_Deflection => 0.40, Rate_Limit => 0.10),
     (Target_Deflection => 0.50, Rate_Limit => 0.10),
     (Target_Deflection => 0.60, Rate_Limit => 0.10),
     Limits);
   Put_Line ("Voted deflection = " & Float'Image (Voted.Target_Deflection));

   Safe_Flag := Is_Safe (State);
   Put_Line ("Safety check: " & Boolean'Image (Safe_Flag));

   if not Is_Channel_Operational (Get_Channel_Health (Left_Aileron)) then
     State := Fault_Handler (State);
     Put_Line ("Fault detected on Left_Aileron");
   end if;

   State := Emergency_Stop (State);
   Put_Line ("Emergency stop executed, deflection = " &
             Float'Image (State.Current_Deflection));

   Put_Line ("Pressure Left_Aileron = " &
             Float'Image (Get_Hydraulic_Pressure (Left_Aileron)));

   if Allocate_Power (Left_Aileron, 25.0) then
     Put_Line ("Power allocated successfully");
   end if;

   if Is_Bus_Overloaded (Bus_A) then
     Put_Line ("Bus A overloaded, shedding load");
     if Shed_Load (Bus_A, Left_Aileron) then
       Put_Line ("Load shed completed");
     end if;
   end if;

   Put_Line ("Controller runtime completed");
end Main;

with AUnit.Test_Suites; use AUnit.Test_Suites;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with AUnit.Assertions; use AUnit.Assertions;
with Actuator_Commands; use Actuator_Commands;
with Redundancy_Voter; use Redundancy_Voter;
with Health_Monitor; use Health_Monitor;
with Actuator_Limits; use Actuator_Limits;
with Actuator_Controller; use Actuator_Controller;

package body Spark_Tests is
   type Test_Validate_Command is new Test_Case with null record;
   function Name (T : Test_Validate_Command) return Message_String;
   procedure Run (T : in out Test_Validate_Command);

   type Test_Majority_Vote is new Test_Case with null record;
   function Name (T : Test_Majority_Vote) return Message_String;
   procedure Run (T : in out Test_Majority_Vote);

   type Test_Health_Status is new Test_Case with null record;
   function Name (T : Test_Health_Status) return Message_String;
   procedure Run (T : in out Test_Health_Status);

   type Test_Limits is new Test_Case with null record;
   function Name (T : Test_Limits) return Message_String;
   procedure Run (T : in out Test_Limits);

   type Test_Controller is new Test_Case with null record;
   function Name (T : Test_Controller) return Message_String;
   procedure Run (T : in out Test_Controller);

   function Name (T : Test_Validate_Command) return Message_String is
   begin
      return new String'("Test Validate Command");
   end Name;

   procedure Run (T : in out Test_Validate_Command) is
      Limits : Limit_Record := (Max_Deflection => 0.9, Min_Deflection => -0.9);
      Cmd_OK : Command := (Target_Deflection => 0.5, Rate_Limit => 0.5);
      Cmd_High : Command := (Target_Deflection => 1.5, Rate_Limit => 0.5);
   begin
      Assert (Is_Valid (Cmd_OK, Limits), "Valid command should be true");
      Assert (not Is_Valid (Cmd_High, Limits), "Invalid command should be false");
   end Run;

   function Name (T : Test_Majority_Vote) return Message_String is
   begin
      return new String'("Test Majority Vote");
   end Name;

   procedure Run (T : in out Test_Majority_Vote) is
      Limits : Limit_Record := (Max_Deflection => 1.0, Min_Deflection => -1.0);
      C1 : Command := (Target_Deflection => 0.4, Rate_Limit => 0.5);
      C2 : Command := (Target_Deflection => 0.5, Rate_Limit => 0.5);
      C3 : Command := (Target_Deflection => 0.6, Rate_Limit => 0.5);
      Result : Command;
   begin
      Result := Majority_Vote (C1, C2, C3, Limits);
      Assert (Result.Target_Deflection = 0.5, "Median should be 0.5");
   end Run;

   function Name (T : Test_Health_Status) return Message_String is
   begin
      return new String'("Test Health Status");
   end Name;

   procedure Run (T : in out Test_Health_Status) is
      H_Healthy : Channel_Health := (Position => OK, Temperature => OK, Current => OK, Hydraulic => OK);
      H_Failed  : Channel_Health := (Position => Critical, Temperature => OK, Current => OK, Hydraulic => OK);
   begin
      Assert (Is_Channel_Operational (H_Healthy), "Healthy channel should be operational");
      Assert (not Is_Channel_Operational (H_Failed), "Failed channel should not be operational");
      Assert (Overall_Status (H_Healthy) = Healthy, "All OK => Healthy");
      Assert (Overall_Status (H_Failed) = Failed, "Critical => Failed");
   end Run;

   function Name (T : Test_Limits) return Message_String is
   begin
      return new String'("Test Limits");
   end Name;

   procedure Run (T : in out Test_Limits) is
      Limits : Limit_Record := (Max_Deflection => 0.95, Min_Deflection => -0.95);
   begin
      Assert (Is_Within_Limits (0.5), "0.5 should be within limits");
      Assert (not Is_Within_Limits (1.2), "1.2 should exceed max");
      Assert (Is_Deflection_Safe (0.5, Limits), "0.5 safe in limits record");
      Assert (not Is_Deflection_Safe (1.0, Limits), "1.0 not safe");
   end Run;

   function Name (T : Test_Controller) return Message_String is
   begin
      return new String'("Test Controller");
   end Name;

   procedure Run (T : in out Test_Controller) is
      Limits : Limit_Record := (Max_Deflection => 0.9, Min_Deflection => -0.9);
      State : Actuator_State := Init (Limits);
      Cmd : Command := (Target_Deflection => 0.7, Rate_Limit => 0.3);
      New_State : Actuator_State;
   begin
      Assert (State.Current_Mode = Idle, "Init should set Idle mode");
      New_State := Step (State, Cmd);
      Assert (New_State.Current_Mode = Active, "Step should set Active mode");
      Assert (New_State.Current_Deflection = 0.7, "Deflection should be 0.7");
      Assert (Is_Safe (New_State), "State should be safe after valid step");
   end Run;

   function Suite return Access_Test_Suite is
      Suite_Ptr : Access_Test_Suite := new Test_Suite;
   begin
      Add_Test (Suite_Ptr, new Test_Validate_Command);
      Add_Test (Suite_Ptr, new Test_Majority_Vote);
      Add_Test (Suite_Ptr, new Test_Health_Status);
      Add_Test (Suite_Ptr, new Test_Limits);
      Add_Test (Suite_Ptr, new Test_Controller);
      return Suite_Ptr;
   end Suite;
end Spark_Tests;

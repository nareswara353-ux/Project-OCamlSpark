with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with AUnit.Run;
with AUnit.Reporter.Text;
with Spark_Tests;

procedure Spark_Runner is
   procedure Run_Suite is new AUnit.Run.Test_Runner (Spark_Tests.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Run_Suite (Reporter);
   if AUnit.Run.Last_Status = AUnit.Run.Success then
      Put_Line ("SPARK test suite passed");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Success);
   else
      Put_Line ("SPARK test suite failed");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Spark_Runner;

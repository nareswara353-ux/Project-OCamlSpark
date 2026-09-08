package body Power_Distribution with SPARK_Mode is
   type Actuator_Power_Record is array (Actuator_ID) of Float;
   Actuator_Power : Actuator_Power_Record := (others => 0.0);

   function Allocate_Power (ID : Actuator_ID; Required_Power : Float) return Boolean is
   begin
      if Required_Power <= 100.0 and Required_Power >= 0.0 then
         Actuator_Power (ID) := Required_Power;
         return True;
      else
         return False;
      end if;
   end Allocate_Power;

   function Get_Bus_Load (Bus : Power_Bus) return Bus_Load is
      Total_Load : Float := 0.0;
      Capacity   : Float;
   begin
      case Bus is
         when Bus_A | Bus_B =>
            Capacity := 100.0;
         when Emergency_Bus =>
            Capacity := 50.0;
      end case;
      for ID in Actuator_ID loop
         Total_Load := Total_Load + Actuator_Power (ID);
      end loop;
      return (Current_Load => Total_Load, Max_Capacity => Capacity);
   end Get_Bus_Load;

   function Is_Bus_Overloaded (Bus : Power_Bus) return Boolean is
      Load : Bus_Load := Get_Bus_Load (Bus);
   begin
      return Load.Current_Load > 0.8 * Load.Max_Capacity;
   end Is_Bus_Overloaded;

   function Shed_Load (Bus : Power_Bus; ID : Actuator_ID) return Boolean is
      pragma Unreferenced (Bus);
   begin
      Actuator_Power (ID) := 0.0;
      return not Is_Bus_Overloaded (Bus);
   end Shed_Load;

   function Get_Power_Status (ID : Actuator_ID) return Load_Status is
      Power : Float := Actuator_Power (ID);
   begin
      if Power = 0.0 then
         return Critical;
      elsif Power > 80.0 then
         return Overloaded;
      else
         return Normal;
      end if;
   end Get_Power_Status;
end Power_Distribution;

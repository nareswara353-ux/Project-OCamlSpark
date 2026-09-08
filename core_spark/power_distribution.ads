with Actuator_Types; use Actuator_Types;

package Power_Distribution with SPARK_Mode is
   type Power_Bus is (Bus_A, Bus_B, Emergency_Bus);
   type Load_Status is (Normal, Overloaded, Critical);

   type Bus_Load is record
      Current_Load : Float range 0.0 .. 100.0;
      Max_Capacity : Float range 0.0 .. 100.0;
   end record;

   function Allocate_Power (ID : Actuator_ID; Required_Power : Float) return Boolean
   with
      Pre  => Required_Power >= 0.0,
      Post => Allocate_Power'Result = (Required_Power <= 100.0);

   function Get_Bus_Load (Bus : Power_Bus) return Bus_Load
   with
      Global => null,
      Post   => Get_Bus_Load'Result.Current_Load <= Get_Bus_Load'Result.Max_Capacity;

   function Is_Bus_Overloaded (Bus : Power_Bus) return Boolean
   with
      Global => null,
      Post   => Is_Bus_Overloaded'Result =
         (Get_Bus_Load (Bus).Current_Load > 0.8 * Get_Bus_Load (Bus).Max_Capacity);

   function Shed_Load (Bus : Power_Bus; ID : Actuator_ID) return Boolean
   with
      Pre  => Is_Bus_Overloaded (Bus),
      Post => Shed_Load'Result = (not Is_Bus_Overloaded (Bus));

   function Get_Power_Status (ID : Actuator_ID) return Load_Status
   with
      Global => null;
end Power_Distribution;

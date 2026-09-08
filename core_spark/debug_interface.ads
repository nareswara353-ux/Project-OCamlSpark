with Actuator_Types; use Actuator_Types;
with Health_Monitor; use Health_Monitor;

package Debug_Interface with SPARK_Mode is
   function Get_Current_Deflection (ID : Actuator_ID) return Deflection_Range
   with
      Global => null,
      Post   => Get_Current_Deflection'Result in Deflection_Range;

   function Get_Temperature (ID : Actuator_ID) return Float
   with
      Global => null,
      Post   => Get_Temperature'Result in -40.0 .. 150.0;

   function Get_Hydraulic_Pressure (ID : Actuator_ID) return Float
   with
      Global => null,
      Post   => Get_Hydraulic_Pressure'Result in 0.0 .. 5000.0;

   function Get_Channel_Health (ID : Actuator_ID) return Channel_Health
   with
      Global => null;

   function Get_Overall_Status (ID : Actuator_ID) return Health_Status
   with
      Global => null;
end Debug_Interface;

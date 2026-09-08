package body Debug_Interface with SPARK_Mode is
   function Get_Current_Deflection (ID : Actuator_ID) return Deflection_Range is
      (case ID is
         when Left_Aileron => 0.0,
         when Right_Aileron => 0.0,
         when Elevator => 0.0,
         when Rudder => 0.0);

   function Get_Temperature (ID : Actuator_ID) return Float is
      (case ID is
         when Left_Aileron => 25.0,
         when Right_Aileron => 26.0,
         when Elevator => 24.0,
         when Rudder => 23.0);

   function Get_Hydraulic_Pressure (ID : Actuator_ID) return Float is
      (case ID is
         when Left_Aileron => 3000.0,
         when Right_Aileron => 3000.0,
         when Elevator => 3000.0,
         when Rudder => 3000.0);

   function Get_Channel_Health (ID : Actuator_ID) return Channel_Health is
      (case ID is
         when Left_Aileron => (Position => OK, Temperature => OK, Current => OK, Hydraulic => OK),
         when Right_Aileron => (Position => OK, Temperature => OK, Current => OK, Hydraulic => OK),
         when Elevator => (Position => OK, Temperature => OK, Current => OK, Hydraulic => OK),
         when Rudder => (Position => OK, Temperature => OK, Current => OK, Hydraulic => OK));

   function Get_Overall_Status (ID : Actuator_ID) return Health_Status is
      (Healthy);
end Debug_Interface;

with Interfaces.C; use Interfaces.C;

package body Spark_Exports is

   function To_Native_Command (C : C_Command) return Command is
     (Target_Deflection => Deflection_Range (C.Target_Deflection),
      Rate_Limit        => Float (C.Rate_Limit));

   function To_Native_Limits (C : C_Limits) return Limit_Record is
     (Max_Deflection => Deflection_Range (C.Max_Deflection),
      Min_Deflection => Deflection_Range (C.Min_Deflection));

   function To_C_Command (N : Command) return C_Command is
     (Target_Deflection => C_float (N.Target_Deflection),
      Rate_Limit        => C_float (N.Rate_Limit));

   function To_C_Limits (N : Limit_Record) return C_Limits is
     (Max_Deflection => C_float (N.Max_Deflection),
      Min_Deflection => C_float (N.Min_Deflection));

   function To_Actuator_ID (ID : int) return Actuator_Types.Actuator_ID is
     (case ID is
        when 0 => Actuator_Types.Left_Aileron,
        when 1 => Actuator_Types.Right_Aileron,
        when 2 => Actuator_Types.Elevator,
        when others => Actuator_Types.Rudder);

   function To_Sensor_Health (V : int) return Health_Monitor.Sensor_Health is
     (case V is
        when 0 => Health_Monitor.OK,
        when 1 => Health_Monitor.Warning,
        when others => Health_Monitor.Critical);

   function To_Health_Status (V : int) return Actuator_Types.Health_Status is
     (case V is
        when 0 => Actuator_Types.Healthy,
        when 1 => Actuator_Types.Degraded,
        when others => Actuator_Types.Failed);

   function To_Controller_State (V : int) return Actuator_Controller.Controller_State is
     (case V is
        when 0 => Actuator_Controller.Idle,
        when 1 => Actuator_Controller.Active,
        when 2 => Actuator_Controller.Fault,
        when others => Actuator_Controller.Emergency);

   function To_State_Int (S : Actuator_Controller.Controller_State) return int is
     (case S is
        when Actuator_Controller.Idle => 0,
        when Actuator_Controller.Active => 1,
        when Actuator_Controller.Fault => 2,
        when Actuator_Controller.Emergency => 3);

   function To_Health_Int (H : Actuator_Types.Health_Status) return int is
     (case H is
        when Actuator_Types.Healthy => 0,
        when Actuator_Types.Degraded => 1,
        when Actuator_Types.Failed => 2);

   function To_Load_Status_Int (L : Power_Distribution.Load_Status) return int is
     (case L is
        when Power_Distribution.Normal => 0,
        when Power_Distribution.Overloaded => 1,
        when Power_Distribution.Critical => 2);

   function Spark_Validate_Command
     (Current, Target, Max_Rate, Max_Def, Min_Def : C_float)
      return unsigned_char
   is
      Limits : constant Limit_Record :=
        (Max_Deflection => Deflection_Range (Max_Def),
         Min_Deflection => Deflection_Range (Min_Def));
      Result : constant Boolean :=
        Actuator_Commands.Validate_Command
          (Deflection_Range (Current), Deflection_Range (Target),
           Limits, Float (Max_Rate));
   begin
      if Result then
         return 1;
      else
         return 0;
      end if;
   end Spark_Validate_Command;

   function Spark_Apply_Limits
     (Cmd : C_Command; Limits : C_Limits)
      return C_Command
   is
      Native_Cmd : constant Command := To_Native_Command (Cmd);
      Native_Lim : constant Limit_Record := To_Native_Limits (Limits);
      Result : constant Command :=
        Actuator_Commands.Apply_Limits (Native_Cmd, Native_Lim);
   begin
      return To_C_Command (Result);
   end Spark_Apply_Limits;

   function Spark_Is_Within_Limits
     (Value : C_float; Limits : C_Limits)
      return unsigned_char
   is
      Native_Lim : constant Limit_Record := To_Native_Limits (Limits);
      Result : constant Boolean :=
        Actuator_Limits.Is_Deflection_Safe
          (Deflection_Range (Value), Native_Lim);
   begin
      if Result then
         return 1;
      else
         return 0;
      end if;
   end Spark_Is_Within_Limits;

   function Spark_Check_Overall_Status
     (Pos, Temp, Curr, Hyd : int)
      return int
   is
      H : constant Health_Monitor.Channel_Health :=
        (Position    => To_Sensor_Health (Pos),
         Temperature => To_Sensor_Health (Temp),
         Current     => To_Sensor_Health (Curr),
         Hydraulic   => To_Sensor_Health (Hyd));
      S : constant Actuator_Types.Health_Status :=
        Health_Monitor.Overall_Status (H);
   begin
      return To_Health_Int (S);
   end Spark_Check_Overall_Status;

   function Spark_Majority_Vote
     (C1, C2, C3 : C_Command; Limits : C_Limits)
      return C_Command
   is
      NC1 : constant Command := To_Native_Command (C1);
      NC2 : constant Command := To_Native_Command (C2);
      NC3 : constant Command := To_Native_Command (C3);
      NL  : constant Limit_Record := To_Native_Limits (Limits);
      R   : constant Command :=
        Redundancy_Voter.Majority_Vote (NC1, NC2, NC3, NL);
   begin
      return To_C_Command (R);
   end Spark_Majority_Vote;

   function Spark_Is_Consensus
     (C1, C2, C3 : C_Command; Tolerance : C_float)
      return unsigned_char
   is
      NC1 : constant Command := To_Native_Command (C1);
      NC2 : constant Command := To_Native_Command (C2);
      NC3 : constant Command := To_Native_Command (C3);
      R   : constant Boolean :=
        Redundancy_Voter.Is_Consensus
          (NC1, NC2, NC3, Deflection_Range (Tolerance));
   begin
      if R then
         return 1;
      else
         return 0;
      end if;
   end Spark_Is_Consensus;

   function Spark_Get_Current_Deflection
     (ID : int) return C_float
   is
      V : constant Deflection_Range :=
        Debug_Interface.Get_Current_Deflection (To_Actuator_ID (ID));
   begin
      return C_float (V);
   end Spark_Get_Current_Deflection;

   function Spark_Get_Temperature
     (ID : int) return C_float
   is
      V : constant Float :=
        Debug_Interface.Get_Temperature (To_Actuator_ID (ID));
   begin
      return C_float (V);
   end Spark_Get_Temperature;

   function Spark_Get_Hydraulic_Pressure
     (ID : int) return C_float
   is
      V : constant Float :=
        Debug_Interface.Get_Hydraulic_Pressure (To_Actuator_ID (ID));
   begin
      return C_float (V);
   end Spark_Get_Hydraulic_Pressure;

   function Spark_Get_Channel_Health
     (ID : int) return C_Channel_Health
   is
      H : constant Health_Monitor.Channel_Health :=
        Debug_Interface.Get_Channel_Health (To_Actuator_ID (ID));
      function To_Int (S : Health_Monitor.Sensor_Health) return int is
        (case S is
           when Health_Monitor.OK => 0,
           when Health_Monitor.Warning => 1,
           when Health_Monitor.Critical => 2);
   begin
      return (Position    => To_Int (H.Position),
              Temperature => To_Int (H.Temperature),
              Current     => To_Int (H.Current),
              Hydraulic   => To_Int (H.Hydraulic));
   end Spark_Get_Channel_Health;

   function Spark_Get_Overall_Status
     (ID : int) return int
   is
      S : constant Actuator_Types.Health_Status :=
        Debug_Interface.Get_Overall_Status (To_Actuator_ID (ID));
   begin
      return To_Health_Int (S);
   end Spark_Get_Overall_Status;

   function Spark_Allocate_Power
     (ID : int; Required_Power : C_float)
      return unsigned_char
   is
      R : constant Boolean :=
        Power_Distribution.Allocate_Power
          (To_Actuator_ID (ID), Float (Required_Power));
   begin
      if R then
         return 1;
      else
         return 0;
      end if;
   end Spark_Allocate_Power;

   function Spark_Get_Bus_Load
     (Bus : int) return C_Bus_Load
   is
      B : constant Power_Distribution.Power_Bus :=
        (case Bus is
           when 0 => Power_Distribution.Bus_A,
           when 1 => Power_Distribution.Bus_B,
           when others => Power_Distribution.Emergency_Bus);
      L : constant Power_Distribution.Bus_Load :=
        Power_Distribution.Get_Bus_Load (B);
   begin
      return (Current_Load => C_float (L.Current_Load),
              Max_Capacity => C_float (L.Max_Capacity));
   end Spark_Get_Bus_Load;

   function Spark_Is_Bus_Overloaded
     (Bus : int) return unsigned_char
   is
      B : constant Power_Distribution.Power_Bus :=
        (case Bus is
           when 0 => Power_Distribution.Bus_A,
           when 1 => Power_Distribution.Bus_B,
           when others => Power_Distribution.Emergency_Bus);
      R : constant Boolean := Power_Distribution.Is_Bus_Overloaded (B);
   begin
      if R then
         return 1;
      else
         return 0;
      end if;
   end Spark_Is_Bus_Overloaded;

   function Spark_Shed_Load
     (Bus, ID : int) return unsigned_char
   is
      B : constant Power_Distribution.Power_Bus :=
        (case Bus is
           when 0 => Power_Distribution.Bus_A,
           when 1 => Power_Distribution.Bus_B,
           when others => Power_Distribution.Emergency_Bus);
      R : constant Boolean :=
        Power_Distribution.Shed_Load (B, To_Actuator_ID (ID));
   begin
      if R then
         return 1;
      else
         return 0;
      end if;
   end Spark_Shed_Load;

   function Spark_Get_Power_Status
     (ID : int) return int
   is
      S : constant Power_Distribution.Load_Status :=
        Power_Distribution.Get_Power_Status (To_Actuator_ID (ID));
   begin
      return To_Load_Status_Int (S);
   end Spark_Get_Power_Status;

   function Spark_Init
     (Limits : C_Limits) return C_Actuator_State
   is
      NL : constant Limit_Record := To_Native_Limits (Limits);
      S  : constant Actuator_Controller.Actuator_State :=
        Actuator_Controller.Init (NL);
   begin
      return (Current_Deflection => C_float (S.Current_Deflection),
              Current_Mode       => To_State_Int (S.Current_Mode),
              Last_Command       => To_C_Command (S.Last_Command),
              Health             => To_Health_Int (S.Health),
              Limit              => To_C_Limits (S.Limit));
   end Spark_Init;

   function Spark_Step
     (State : C_Actuator_State; Cmd : C_Command)
      return C_Actuator_State
   is
      NS : constant Actuator_Controller.Actuator_State :=
        (Current_Deflection => Deflection_Range (State.Current_Deflection),
         Current_Mode       => To_Controller_State (State.Current_Mode),
         Last_Command       => To_Native_Command (State.Last_Command),
         Health             => To_Health_Status (State.Health),
         Limit              => To_Native_Limits (State.Limit));
      NC : constant Command := To_Native_Command (Cmd);
      R  : constant Actuator_Controller.Actuator_State :=
        Actuator_Controller.Step (NS, NC);
   begin
      return (Current_Deflection => C_float (R.Current_Deflection),
              Current_Mode       => To_State_Int (R.Current_Mode),
              Last_Command       => To_C_Command (R.Last_Command),
              Health             => To_Health_Int (R.Health),
              Limit              => To_C_Limits (R.Limit));
   end Spark_Step;

   function Spark_Fault_Handler
     (State : C_Actuator_State) return C_Actuator_State
   is
      NS : constant Actuator_Controller.Actuator_State :=
        (Current_Deflection => Deflection_Range (State.Current_Deflection),
         Current_Mode       => To_Controller_State (State.Current_Mode),
         Last_Command       => To_Native_Command (State.Last_Command),
         Health             => To_Health_Status (State.Health),
         Limit              => To_Native_Limits (State.Limit));
      R  : constant Actuator_Controller.Actuator_State :=
        Actuator_Controller.Fault_Handler (NS);
   begin
      return (Current_Deflection => C_float (R.Current_Deflection),
              Current_Mode       => To_State_Int (R.Current_Mode),
              Last_Command       => To_C_Command (R.Last_Command),
              Health             => To_Health_Int (R.Health),
              Limit              => To_C_Limits (R.Limit));
   end Spark_Fault_Handler;

   function Spark_Emergency_Stop
     (State : C_Actuator_State) return C_Actuator_State
   is
      NS : constant Actuator_Controller.Actuator_State :=
        (Current_Deflection => Deflection_Range (State.Current_Deflection),
         Current_Mode       => To_Controller_State (State.Current_Mode),
         Last_Command       => To_Native_Command (State.Last_Command),
         Health             => To_Health_Status (State.Health),
         Limit              => To_Native_Limits (State.Limit));
      R  : constant Actuator_Controller.Actuator_State :=
        Actuator_Controller.Emergency_Stop (NS);
   begin
      return (Current_Deflection => C_float (R.Current_Deflection),
              Current_Mode       => To_State_Int (R.Current_Mode),
              Last_Command       => To_C_Command (R.Last_Command),
              Health             => To_Health_Int (R.Health),
              Limit              => To_C_Limits (R.Limit));
   end Spark_Emergency_Stop;

   function Spark_Is_Safe
     (State : C_Actuator_State) return unsigned_char
   is
      NS : constant Actuator_Controller.Actuator_State :=
        (Current_Deflection => Deflection_Range (State.Current_Deflection),
         Current_Mode       => To_Controller_State (State.Current_Mode),
         Last_Command       => To_Native_Command (State.Last_Command),
         Health             => To_Health_Status (State.Health),
         Limit              => To_Native_Limits (State.Limit));
      R : constant Boolean := Actuator_Controller.Is_Safe (NS);
   begin
      if R then
         return 1;
      else
         return 0;
      end if;
   end Spark_Is_Safe;

end Spark_Exports;

package body Health_Monitor with SPARK_Mode is
   function Is_Channel_Operational (H : Channel_Health) return Boolean is
   begin
      return (H.Position /= Critical and H.Temperature /= Critical and
              H.Current /= Critical and H.Hydraulic /= Critical);
   end Is_Channel_Operational;

   function Overall_Status (H : Channel_Health) return Health_Status is
   begin
      if H.Position = OK and H.Temperature = OK and
         H.Current = OK and H.Hydraulic = OK
      then
         return Healthy;
      elsif H.Position = Critical or H.Temperature = Critical or
            H.Current = Critical or H.Hydraulic = Critical
      then
         return Failed;
      else
         return Degraded;
      end if;
   end Overall_Status;
end Health_Monitor;

with Actuator_Types; use Actuator_Types;

package Health_Monitor with SPARK_Mode is
   type Sensor_Health is (OK, Warning, Critical);

   type Channel_Health is record
      Position : Sensor_Health;
      Temperature : Sensor_Health;
      Current : Sensor_Health;
      Hydraulic : Sensor_Health;
   end record;

   function Is_Channel_Operational (H : Channel_Health) return Boolean
   with
      Post => Is_Channel_Operational'Result =
         (H.Position /= Critical and H.Temperature /= Critical and
          H.Current /= Critical and H.Hydraulic /= Critical);

   function Overall_Status (H : Channel_Health) return Health_Status
   with
      Post =>
         (if H.Position = OK and H.Temperature = OK and
             H.Current = OK and H.Hydraulic = OK
          then Overall_Status'Result = Healthy
          elsif H.Position = Critical or H.Temperature = Critical or
                H.Current = Critical or H.Hydraulic = Critical
          then Overall_Status'Result = Failed
          else Overall_Status'Result = Degraded);
end Health_Monitor;

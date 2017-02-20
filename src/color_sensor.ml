module CS =
  LegoEv3ColorSensor.LegoEv3ColorSensor
    (struct
      let name = "sensor"
      let multiple_connection = true
    end)
    (struct let input_port = Port.Input1 end)

let read_color () = Color.make (CS.raw_color_components ())

let connect () =
  CS.connect ();
  CS.set_mode CS.RGB_RAW

let disconnect () = CS.disconnect ()

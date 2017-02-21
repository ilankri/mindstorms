module CS =
  LegoEv3ColorSensor.LegoEv3ColorSensor
    (struct
      let name = "color_sensor"
      let multiple_connection = true
    end)
    (struct let input_port = Port.Input1 end)

let read_color () =
  CS.set_mode CS.RGB_RAW;
  Color.make (CS.raw_color_components ())

let connect () = CS.connect ()

let disconnect () = CS.disconnect ()

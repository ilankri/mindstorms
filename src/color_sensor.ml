module CS =
  LegoEv3ColorSensor.LegoEv3ColorSensor
    (struct
      let name = "color_sensor"
      let multiple_connection = false
    end)
    (struct let input_port = Port.Input1 end)

let read_color () =
  CS.set_mode CS.RGB_RAW;
  Color.make (CS.raw_color_components ())

let connect () = CS.connect ()

let disconnect () =
  CS.set_mode CS.COL_REFLECT;
  CS.disconnect ()

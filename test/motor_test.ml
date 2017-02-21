let main =
  Dual_motor.connect ();
  Dual_motor.set_speed 25;
  Dual_motor.move_forward ();
  Unix.sleep 5;
  Dual_motor.disconnect ();
  exit 0

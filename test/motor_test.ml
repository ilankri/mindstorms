let main =
  Dual_motor.connect ();
  Dual_motor.set_speed 90;
  Dual_motor.move_forward ();
  Unix.sleep 5;
  Dual_motor.stop ();
  Dual_motor.disconnect ();
  exit 0

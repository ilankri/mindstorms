let main =
  Dual_motor.connect ();
  Dual_motor.start ();
  Dual_motor.set_speed 20;
  Unix.sleep 5;
  Dual_motor.stop ();
  Dual_motor.disconnect ();
  exit 0

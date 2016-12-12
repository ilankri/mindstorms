FROM ev3dev/ev3dev-jessie-ev3-generic:2016-10-17

# Install packages to compile OCaml programs.
RUN apt-get -y install make ocaml ocaml-native-compilers

USER robot
WORKDIR /home/robot

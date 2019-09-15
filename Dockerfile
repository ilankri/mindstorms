FROM ev3dev/ev3dev-stretch-ev3-generic

# Install packages to compile OCaml programs.
RUN apt-get -y install make opam ocaml ocaml-native-compilers
RUN opam init -y
RUN opam update && opam install -y dune

USER robot
WORKDIR /home/robot

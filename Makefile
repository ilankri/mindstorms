SHELL = /bin/sh
SCP = scp

srcdir = src
testdir = test
builddir = _build

# OCamlbuild variables.
OCAMLBUILD = ocamlbuild
NEXT = native
BEXT = byte
DEBUGFLAG = -g
OCAMLCFLAGS = -cflags $(DEBUGFLAG),-annot,-bin-annot,-w,+a
OCAMLLFLAGS = -lflag $(DEBUGFLAG)
# OCAMLLIBS = -lib unix

# Docker variables.
DOCKER = docker
EV3_IMG = ev3

# Robot-specific variables.
ROBOT_HOME = /home/robot
ROBOT_USR = robot

# If there is a problem with this hostname, override this variable when
# invoking make, e.g.: ROBOT_IP=169.254.156.21 make [target].
ROBOT_IP = ev3dev.local

# Target basenames.
TARGETS = $(addprefix $(srcdir)/, color_recognition)	\
		$(addprefix $(testdir)/, motor_test legoEv3Button_test)

# Native targets.
NTARGETS = $(addsuffix .$(NEXT),$(TARGETS))

# Bytecode targets.
BTARGETS = $(addsuffix .$(BEXT),$(TARGETS))

# Auxiliary functions.
build = $(OCAMLBUILD) -no-links $(OCAMLCFLAGS) $(OCAMLLFLAGS) $(OCAMLLIBS)
clean = $(OCAMLBUILD) -clean
export-to-robot = $(SCP) $(addprefix $(builddir)/,$(1))		\
			$(ROBOT_USR)@$(ROBOT_IP):$(ROBOT_HOME)

.SUFFIXES:
.PHONY: all $(NTARGETS) $(BTARGETS) export-native	\
	export-byte doc ev3 clean

# Generate suitable executable for the robot using Docker.
all: ev3
	$(DOCKER) run --rm -v $$PWD:$(ROBOT_HOME) $(EV3_IMG) $(MAKE) $(NTARGETS)

# Export native executables to the robot via SSH.
export-native: all
	$(call export-to-robot,$(NTARGETS))

# Export bytecode executables to the robot via SSH.
export-byte: $(BTARGETS)
	$(call export-to-robot,$^)

# Generate documentation.
doc:
	$(OCAMLBUILD) ev3.docdir/index.html

# Generate Docker image to compile OCaml code for the robot.
ev3:
	$(DOCKER) build -t $(EV3_IMG) .

# Generic rule.
$(NTARGETS) $(BTARGETS):
	$(build) $@

# Cleaning rule.
clean:
	$(clean)

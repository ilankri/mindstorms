SHELL = /bin/sh
SCP = scp

srcdir = src
builddir = _build/default/src

DUNE = dune
NEXT = exe
BEXT = bc

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
TARGETS = $(addprefix $(srcdir)/, learn_colors follow_line		\
		color_test motor_test legoEv3Button_test hello_ev3)

# Native targets.
NTARGETS = $(addsuffix .$(NEXT),$(TARGETS))

# Bytecode targets.
BTARGETS = $(addsuffix .$(BEXT),$(TARGETS))

# Auxiliary functions.
export-to-robot = $(SCP) $(addprefix $(builddir)/,$(1))		\
			$(ROBOT_USR)@$(ROBOT_IP):$(ROBOT_HOME)

.SUFFIXES:
.PHONY: all all-byte $(NTARGETS) $(BTARGETS) export-native	\
	export-byte ev3 clean

# Generate suitable executable for the robot using Docker.
all: ev3
	$(DOCKER) run --rm -v $$PWD:$(ROBOT_HOME) $(EV3_IMG)		\
		sh -c $$(eval opam config env) && $(MAKE) $(NTARGETS)

# Export native executables to the robot via SSH.
export-native: all
	$(call export-to-robot,$(NTARGETS))

# Export bytecode executables to the robot via SSH.
export-byte: $(BTARGETS)
	$(call export-to-robot,$^)

# Generate Docker image to compile OCaml code for the robot.
ev3:
	$(DOCKER) build -t $(EV3_IMG) .

# Generic rules.
all-byte: $(BTARGETS)

$(NTARGETS) $(BTARGETS):
	$(DUNE) build $@

# Cleaning rule.
clean:
	$(DUNE) clean

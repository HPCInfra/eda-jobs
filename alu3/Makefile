.PHONY: lint build run wave submit clean openroad synth pnr gui

SRCS = alu.v
TB   = alu_tb.v
OUT  = alu_tb.out
VCD  = alu_tb.vcd

lint:
	iverilog -Wall -t null $(SRCS) $(TB)

build:
	iverilog -Wall -o $(OUT) $(SRCS) $(TB)

run: build
	vvp $(OUT)

wave: run
	gtkwave $(VCD) alu_tb.gtkw &

openroad: 
	openroad -gui

# Compile on head node first, then submit array job
submit: build
	mkdir -p results
	sbatch tests.sh


# Synthesis (Yosys)
synth: $(SRCS)
	yosys -s synth.ys

# Place and Route
pnr: synth
	openroad -exit flow.tcl

gui: 
	openroad -gui

clean:
	rm -f $(OUT) $(VCD)
	rm -f results/*.out results/*.err
	rmdir results
	rm -f alu_synth.v alu_routed.def alu_routed.odb

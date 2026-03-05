.PHONY: lint build run wave submit clean

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

# Compile on head node first, then submit array job
submit: build
	mkdir -p results
	sbatch tests.sh

clean:
	rm -f $(OUT) $(VCD)
	rm -f results/*.out results/*.err

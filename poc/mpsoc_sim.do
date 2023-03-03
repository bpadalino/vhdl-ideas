vlib mpsoc_sim

vcom -work mpsoc_sim -2019 -dbg ../interfaces/amba/axi/axi4.vhdl
vcom -work mpsoc_sim -2019 -dbg ../interfaces/amba/axi/axi4mm.vhdl
vcom -work mpsoc_sim -2019 -dbg ../interfaces/amba/axi/axi4mm-body.vhdl
vcom -work mpsoc_sim -2019 -dbg ../interfaces/amba/axi/axi4l.vhdl
vcom -work mpsoc_sim -2019 -dbg ../interfaces/amba/axi/axi4s.vhdl

vcom -work mpsoc_sim -2019 -dbg ../util/memory.vhdl

vcom -work mpsoc_sim -2019 -dbg ../bfm/axi4mm_bfm.vhdl

vcom -work mpsoc_sim -2019 -dbg ./mpsoc.vhdl

vcom -work mpsoc_sim -2019 -dbg ./mpsoc_sim.vhdl

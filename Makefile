# This file is covered by the MIT License, see the LICENSE file for details

# TODO -- VERILATOR_ROOT doesn't work with system install (#4 in POD)

default: tb_obj_dir/Vfoo_tb

tb_obj_dir/Vfoo_tb: libfoo.so
	make -C tb_obj_dir/ -f Vfoo_tb.mk VM_USER_LDLIBS="-L ${PWD} -lfoo"

VERILATOR_C_FLAGS= -I.  -MMD -I${VERILATOR_ROOT}/include -I${VERILATOR_ROOT}/include/vltstd -DVL_PRINTF=printf -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=1 -faligned-new -Wno-bool-operation -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable -Wno-shadow -fPIC

verilated.o: ${VERILATOR_ROOT}/include/verilated.cpp
	${CXX} ${VERILATOR_C_FLAGS} -c -o $@ $<

verilated_dpi.o: ${VERILATOR_ROOT}/include/verilated_dpi.cpp
	${CXX} ${VERILATOR_C_FLAGS} -c -o $@ $<

# TODO -- do we even need this?
verilated_vcd_c.o: ${VERILATOR_ROOT}/include/verilated_vcd_c.cpp
	${CXX} ${VERILATOR_C_FLAGS} -c -o $@ $<

libfoo.so: foo_impl.sv foo.cpp tb_obj_dir/Vfoo_tb__Dpi.h verilated.o verilated_dpi.o verilated_vcd_c.o
	${VERILATOR_ROOT}/bin/verilator --trace --cc foo_impl.sv -CFLAGS '-fPIC'
	make -C obj_dir/ -f Vfoo_impl.mk
	g++ -fPIC -shared foo.cpp -I tb_obj_dir/ -I obj_dir/ -I ${VERILATOR_ROOT}/include/ -I ${VERILATOR_ROOT}/include/vltstd/ obj_dir/Vfoo_impl__ALL.a -o libfoo.so verilated.o verilated_dpi.o verilated_vcd_c.o

tb_obj_dir/Vfoo_tb__Dpi.h: foo_tb.sv foo.sv tb.cpp
	${VERILATOR_ROOT}/bin/verilator --trace --exe foo_tb.sv foo.sv --top-module foo_tb --Mdir tb_obj_dir tb.cpp --cc

.PHONY: clean run xsim

xsim: libfoo.so
	xvlog --sv foo_tb.sv foo.sv
	xelab foo_tb --debug all --sv_lib libfoo --dpi_absolute
	xsim work.foo_tb -t xsim.tcl

run:
	LD_LIBRARY_PATH=${PWD} tb_obj_dir/Vfoo_tb

clean:
	rm -rf obj_dir
	rm -rf tb_obj_dir
	rm -f *.so
	rm -f *.o
	rm -f *.d
	rm -f *.vcd
	rm -f *.jou
	rm -f *.log
	rm -f *.pb
	rm -rf xsim.dir
	rm -f webtalk.*
	rm -f vivado_*str
	rm -f work.*wdb

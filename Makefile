# This file is covered by the MIT License, see the LICENSE file for details

# TODO -- VERILATOR_ROOT doesn't work with system install (#4 in POD)

ifdef VLT_PROT
LIB_DIR=dpi_prot_obj_dir/
TB_OBJ_DIR=tb_prot_obj_dir
else
LIB_DIR=
TB_OBJ_DIR=tb_obj_dir
endif

ifdef VLT_DYN
VLT_LIB=${LIB_DIR}libfoo.so
LIB_PATH=LD_LIBRARY_PATH=${PWD}/${LIB_DIR}
VLT_FLAGS=--dpi-protect-shared
else
VLT_LIB=${LIB_DIR}libfoo.a
endif

default: ${TB_OBJ_DIR}/Vfoo_tb

foo_hack.o: foo_hack.cpp
	g++ -I${VERILATOR_ROOT}/include/vltstd -c -o $@ $<

libfoo_hack.a: foo_hack.o
	ar rc $@ $<

ifdef VLT_PROT
dpi_prot_obj_dir/foo.cpp: foo_impl.sv
	${VERILATOR_ROOT}/bin/verilator --cc foo_impl.sv -Mdir dpi_prot_obj_dir --dpi-protect foo ${VLT_FLAGS}

${VLT_LIB}: dpi_prot_obj_dir/foo.cpp
	make -C dpi_prot_obj_dir/ -f Vfoo_impl.mk
else
VERILATOR_C_FLAGS= $(M32) -I.  -MMD -I${VERILATOR_ROOT}/include -I${VERILATOR_ROOT}/include/vltstd -DVL_PRINTF=printf -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=1 -faligned-new -Wno-bool-operation -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable -Wno-shadow -fPIC

verilated.o: ${VERILATOR_ROOT}/include/verilated.cpp
	${CXX} ${VERILATOR_C_FLAGS} -c -o $@ $<

verilated_dpi.o: ${VERILATOR_ROOT}/include/verilated_dpi.cpp
	${CXX} ${VERILATOR_C_FLAGS} -c -o $@ $<

# TODO -- do we even need this?
verilated_vcd_c.o: ${VERILATOR_ROOT}/include/verilated_vcd_c.cpp
	${CXX} ${VERILATOR_C_FLAGS} -c -o $@ $<

libfoo.so: foo_impl.sv foo.cpp verilated.o verilated_dpi.o verilated_vcd_c.o
	${VERILATOR_ROOT}/bin/verilator --cc foo_impl.sv -CFLAGS '-fPIC'
	make -C obj_dir/ -f Vfoo_impl.mk
	${CXX} $(M32) -fPIC -shared foo.cpp -I obj_dir/ -I ${VERILATOR_ROOT}/include/ -I ${VERILATOR_ROOT}/include/vltstd/ obj_dir/Vfoo_impl__ALL.a -o libfoo.so verilated.o verilated_dpi.o verilated_vcd_c.o

libfoo.a: foo_impl.sv foo.cpp verilated.o verilated_dpi.o verilated_vcd_c.o
	${VERILATOR_ROOT}/bin/verilator --cc foo_impl.sv -Mdir static_obj_dir
	make -C static_obj_dir/ -f Vfoo_impl.mk
	${CXX} $(M32) foo.cpp -I static_obj_dir/ -I ${VERILATOR_ROOT}/include/ -I ${VERILATOR_ROOT}/include/vltstd/ -c -o libfoo.o
	ar rc $@ verilated.o verilated_dpi.o verilated_vcd_c.o static_obj_dir/Vfoo_impl__ALLcls.o static_obj_dir/Vfoo_impl__ALLsup.o libfoo.o
endif

${TB_OBJ_DIR}/Vfoo_tb.mk: ${LIB_DIR}foo.sv foo_tb.sv tb.cpp
	${VERILATOR_ROOT}/bin/verilator --trace --exe $^ --top-module foo_tb --Mdir ${TB_OBJ_DIR} --cc

${TB_OBJ_DIR}/Vfoo_tb: ${VLT_LIB} ${TB_OBJ_DIR}/Vfoo_tb.mk
	make -C ${TB_OBJ_DIR}/ -f Vfoo_tb.mk VM_USER_LDLIBS="-L ${PWD}/${LIB_DIR} -lfoo"

.PHONY: clean run xsim

xsim: ${LIB_DIR}libfoo.so
	xvlog --sv foo_tb.sv ${LIB_DIR}foo.sv
	xelab foo_tb --debug all --sv_lib ${LIB_DIR}libfoo --dpi_absolute
	xsim work.foo_tb -t xsim.tcl

msim: ${LIB_DIR}libfoo.so
	vlib work
	vlog -sv foo_tb.sv +define+MODELSIM ${LIB_DIR}foo.sv
	vsim -c work.foo_tb -gblso ${LIB_DIR}libfoo.so -do "run -a; quit"

run:
	${LIB_PATH} ${TB_OBJ_DIR}/Vfoo_tb

clean:
	rm -rf *obj_dir
	rm -f *.so
	rm -f *.a
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

# This file is covered by the MIT License, see the LICENSE file for details

# TODO -- VERILATOR_ROOT doesn't work with system install (#4 in POD)

default: tb_obj_dir/Vfoo_tb

tb_obj_dir/Vfoo_tb: libfoo.so
	make -C tb_obj_dir/ -f Vfoo_tb.mk VM_USER_LDLIBS="-L ${PWD} -lfoo"

libfoo.so: foo_impl.sv foo.cpp tb_obj_dir/Vfoo_tb__Dpi.h
	${VERILATOR_ROOT}/bin/verilator --trace --cc foo_impl.sv -CFLAGS '-fPIC'
	make -C obj_dir/ -f Vfoo_impl.mk
	g++ -fPIC -shared foo.cpp -I tb_obj_dir/ -I obj_dir/ -I ${VERILATOR_ROOT}/include/ -I ${VERILATOR_ROOT}/include/vltstd/ obj_dir/Vfoo_impl__ALL.a -o libfoo.so

tb_obj_dir/Vfoo_tb__Dpi.h: foo_tb.sv foo.sv tb.cpp
	${VERILATOR_ROOT}/bin/verilator --trace --exe foo_tb.sv foo.sv --top-module foo_tb --Mdir tb_obj_dir tb.cpp --cc

.PHONY: clean run

run:
	LD_LIBRARY_PATH=${PWD} tb_obj_dir/Vfoo_tb

clean:
	rm -rf obj_dir
	rm -rf tb_obj_dir
	rm -f *.so
	rm -f *.vcd

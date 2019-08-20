// This file is covered by the MIT License, see the LICENSE file for details

// Library which will hide foo_impl.sv via C++ compilation, etc.

// This just fills in the DPI functions imported in the foo.sv wrapper

// NB: this is just an example, ideally this would be automatically
//   generated from foo_impl.sv

#include "Vfoo_impl.h"
// TODO -- this externs DPI functions, maybe don't do that here
#include "Vfoo_tb__Dpi.h"

void* create_foo (const char* scope) {
    assert(sizeof(WData) == sizeof(svBitVecVal));
    Vfoo_impl* foo = new Vfoo_impl(scope);
    return foo;
}

void eval_foo (
    void* fooPtr,
    const svBitVecVal* a,
    unsigned char clk,
    const svBitVecVal* long_in,
    svBitVecVal* long_out,
    svBitVecVal* x)
{
    Vfoo_impl* foo = static_cast<Vfoo_impl*>(fooPtr);
    memcpy(&foo->a, a, 2*sizeof(svBitVecVal));
    memcpy(foo->long_in, long_in, 5*sizeof(svBitVecVal));
    foo->clk = clk;
    foo->eval();
    memcpy(x, &foo->x, 2*sizeof(svBitVecVal));
    memcpy(long_out, foo->long_out, 5*sizeof(svBitVecVal));
}

void final_foo (void* fooPtr) {
    Vfoo_impl* foo = static_cast<Vfoo_impl*>(fooPtr);
    foo->final();
    delete foo;
}

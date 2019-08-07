// This file is covered by the MIT License, see the LICENSE file for details

// Library which will hide foo_impl.sv via C++ compilation, etc.

// This just fills in the DPI functions imported in the foo.sv wrapper

// NB: this is just an example, ideally this would be automatically
//   generated from foo_impl.sv

#include "Vfoo_impl.h"
// TODO -- this externs DPI functions, maybe don't do that here
#include "Vfoo_tb__Dpi.h"

void* create_foo (const char* scope) {
    Vfoo_impl* foo = new Vfoo_impl(scope);
    return foo;
}

void eval_foo (
    void* fooPtr,
    int a,
    unsigned char clk,
    int* x)
{
    Vfoo_impl* foo = static_cast<Vfoo_impl*>(fooPtr);
    foo->a = a;
    foo->clk = clk;
    foo->eval();
    *x = foo->x;
}

void final_foo (void* fooPtr) {
    Vfoo_impl* foo = static_cast<Vfoo_impl*>(fooPtr);
    foo->final();
    delete foo;
}

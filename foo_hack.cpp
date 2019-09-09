// This file is covered by the MIT License, see the LICENSE file for details

// Library which will hide foo_impl.sv via C++ compilation, etc.

// This just fills in the DPI functions imported in the foo.sv wrapper

// NB: this is just an example, ideally this would be automatically
//   generated from foo_impl.sv

#include "svdpi.h"
#include <string.h>

class foo_impl {
  public:
    uint64_t a;
    uint64_t x;
    int clk;
    int old_clk;
    void eval() {
        if (clk && !old_clk) x = x + a + 1;
        old_clk = clk;
    }
    foo_impl():
        a(0), x(0), clk(0), old_clk(0) {}
};

extern "C" {

void* create_foo (const char* scope) {
    foo_impl* foo = new foo_impl;
    return foo;
}

void comb_update_foo (
    void* fooPtr,
    const svBitVecVal* a,
    const svBitVecVal* long_in,
    svBitVecVal* long_out,
    svBitVecVal* x)
{
    foo_impl* foo = static_cast<foo_impl*>(fooPtr);
    memcpy(&foo->a, a, 2*sizeof(svBitVecVal));
    foo->eval();
    memcpy(x, &foo->x, 2*sizeof(svBitVecVal));
}

void seq_update_foo (
    void* fooPtr,
    unsigned char clk,
    svBitVecVal* long_out,
    svBitVecVal* x)
{
    foo_impl* foo = static_cast<foo_impl*>(fooPtr);
    foo->clk = clk;
    foo->eval();
    memcpy(x, &foo->x, 2*sizeof(svBitVecVal));
}

void final_foo (void* fooPtr) {
    foo_impl* foo = static_cast<foo_impl*>(fooPtr);
    delete foo;
}

}

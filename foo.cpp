// This file is covered by the MIT License, see the LICENSE file for details

// Library which will hide foo_impl.sv via C++ compilation, etc.

// This just fills in the DPI functions imported in the foo.sv wrapper

// NB: this is just an example, ideally this would be automatically
//   generated from foo_impl.sv

#include "Vfoo_impl.h"
#include "svdpi.h"

#ifdef MODELSIM
#include <map>
#include <string>

// ModelSim can't use the chandle in the always block
// TODO -- make this a vector instead (faster but leakier)
std::map<std::string, Vfoo_impl*> scopeMap;

#endif

extern "C" {

#ifdef MODELSIM

// TODO -- seems like this should just slow down other simulators, but XSim
//         reports an exception from lookup_foo()
void* lookup_foo (const char* scope) {
    Vfoo_impl* foo = scopeMap.at(std::string(scope));
    return foo;
}
#endif

void* create_foo (const char* scope) {
    assert(sizeof(WData) == sizeof(svBitVecVal));
    Vfoo_impl* foo = new Vfoo_impl(scope);
#ifdef MODELSIM
    scopeMap[std::string(scope)] = foo;
#endif
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

}

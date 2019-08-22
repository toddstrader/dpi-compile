# DPI protected Verilog proof of concept

A non-broken and open source friendly way to distribute protected Verilog simulation models.

## The basic idea

Encrypted Verilog is unusable to open source tools like Verilator.  Beyond that, the Verilog
encryption scheme is basically worthless.  See https://acmccs.github.io/papers/p1533-chhotarayA.pdf
for futher details.  Or if you prefer more practical evidence, spend a little while researching
actual attacks on encrypted RTL.

This is a proof of concept for a utility which would use Verilator to compile a protected
Verilog module into a DPI-accessible shared object.  While the compiled object could be analyzed,
this approach provides little to no opportunity for the plaintext Verilog to be exposed.

Beyond compiling the protected module, the tool would do the following:
* Create a black-box Verilog wrapper to be instantiated by the end user
* Create a C++ wrapper for the library

The black-box module will call imported DPI functions which the shared object will implement.
Given this, the IP provider would deliver the black-box Verilog module and the compiled shared
object to the end user.  The end user would then instantiate the black-box module and pass the
shared object to the DPI-capable simulator of their choice.  The protected Verilog will not be
visible to the end user, but they will be able to simulate it and observe the I/O.

## Things this doesn't attempt to solve
* Protected VHDL simulation models (though something similar is probably possible via the FLI)
* Protected RTL for synthesis, etc.

## Issues/Things to do
* Continue researching to verify this doesn't already exist
* Determine if there are any fundamental flaws in the idea
* Figure out if this would be part of Verilator or a separate tool
* Research obfuscation techniques on compiled C++
* Analyze clocks, etc. to minize unnecessary DPI calls in the wrapper module
* Advertise these details (e.g. clocks) for Verilator and other simulators to improve scheduling
* Handle parametric modules by enabling Verilator to create classes with constructor-time parameters

The last one is a doozy.  However, it could have potentially useful knock-on effects.  Mainly,
it would allow Verilator users to avoid separately compiling large designs with different
parameters.  Of course, it would be quite complicted to implement and would probably have
run-time implications.

## Example

A simple example is provided to demonstrate how this would work.  foo_impl.sv is the module the
IP provider whishes to protect.  foo.sv and foo.cpp have been constructed by hand, but the proposal
is that a tool would generate them.  foo_tb.sv and tb.cpp comprise an example testbench which
demonstrates the functionality of this proposal, but would be outside the scope of the tool.

## Trying it out

Simply run the following:

```
make
make run
```

You may need to set `VERILATOR_ROOT` depending on your Verilator installation method.

## See also

There's been some discussion of this project here:
https://www.veripool.org/boards/3/topics/3037?r=3042#message-3042

## TODO
- [ ] Add a mode to Verilator to only produce the DPI header
- [ ] Have the Verilator Perl wrapper call bin/verilator again to create the DPI header when called with --dpi-protect
- [ ] Handle C++ ABI differences (maybe build multiple libraries?)
- [ ] Wrap the Verilator runtime in a per-library namespace to avoid collisions

# CL Overload

Inspired by [generic-cl](https://github.com/alex-gutev/generic-cl) and  [specialization-store](https://github.com/markcox80/specialization-store), this library provides support for overloading common simple functions (in many other languages usually references as "operators") based on types. Supports user defined specializations as well. It also tries to be as strictly typed as possible, resulting in compile-time errors/warnings in case types are mismatched. However, there are ways to relax the restrictions in places where it would make sense (such as different numeric types comparison).


# Implementations support
It currently works properly (i.e without overhead) anywhere, where both introspect-environment and specialization-store both work.

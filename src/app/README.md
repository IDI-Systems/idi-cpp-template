# ACRE Core Library

The ACRE Core Library (or Core for short hand) is the primary engine functionality that is universal to any specific sim or voice platform.

## Structure

The structure of the core should enable the resultant binary to either be a static library consumed by other binaries or a dynamic library loaded by other libraries.

Individual components of the core should be contained in folders related to their functionality. Each should be considered a separate element and compile as a static library consumed by the main Core binary.

Inter-core file includes should be defined in an `include` folder. The public API, which are any function calls that a consumer would call, should be defined in a `public` includes folder inside of the `include` folder.

```
core
    - component
        -include
            -public
```

A more detailed description follows below for the parts of the file tree.

### component

This is any component that will be used in the core library. This includes things like the sound engine, ECS, signal propagation models, and other things critical to the operation of ACRE.

### include

This folder should contain any files that other components in the ACRE library will use _or_ that will be linked into another application that is also compiling the ACRE core library.

### public

Inside of the include folder is a public include folder. This folder should contains any include definitions that will be used by an external project that is including the ACRE core as a DLL/Shared Object or as a pre-compiled static library.
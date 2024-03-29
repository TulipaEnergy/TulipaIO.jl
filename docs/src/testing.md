# Notes on writing tests

## Testing for exceptions and errors

We should also test error handling, this is particularly important
since `TulipaIO` is user-facing.  We follow two principles:

1. throw a relevant [`Exception`][1], if one doesn't exist, we can
   create one that emits a relevant message; see [`exceptions.jl`][2]
   and its uses in the codebase.

2. to test an exception, we test both the exception type, and the
   generated message.  This is done with `@test_throws`.  While
   testing the type has been supported in Julia 1.6 (LTS),
   unfortunately testing the message has only been supported since
   [Julia 1.8][3], also the test has to be done by repeating the
   error.  So the guideline is to test exceptions like this example
   from `test-pipeline.jl`:

   ```julia
   @test_throws DimensionMismatch TIO.set_tbl_col(args...; opts...)
   if (VERSION.major >= 1) && (VERSION.minor >= 8)
       @test_throws [r"Length.+different", r"index.+value"] TIO.set_tbl_col(args...; opts...)
   end
   ```

[1]: https://docs.julialang.org/en/v1/manual/control-flow/#Exception-Handling
[2]: https://github.com/TulipaEnergy/TulipaIO.jl/blob/main/src/exceptions.jl
[3]: https://docs.julialang.org/en/v1/stdlib/Test/#Test.@test_throws

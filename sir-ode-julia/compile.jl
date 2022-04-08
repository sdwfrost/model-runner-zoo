using PackageCompiler

create_sysimage(
    [:OrdinaryDiffEq, :DiffEqCallbacks, :Optim, :JSON, :JSONSchema],
    sysimage_path="sys_complete.so",
    precompile_execution_file="model.jl" # the new line
)

# To generate SPIRV IR

using oneAPI

# kernel to add 2 vectors...
function vadd(a, b, c)
           i = get_global_id()
           @inbounds c[i] = a[i] + b[i]
           return
       end
     
# defines the array to be added
a = oneArray(rand(Float32, 10));
b = oneArray(rand(Float32, 10));

# result array
c = similar(a);

# @device_code_spirv generates spirv and @oneapi optimizes for gpu
@device_code_spirv @oneapi vadd(a, b, c)






# To generate LLVM IR
using LLVM

# Define the vector addition kernel
function vadd(a, b, c)
    i = get_global_id(1)
    @inbounds c[i] = a[i] + b[i]
end

# Generate LLVM IR
llvm_code = code_llvm(vadd, (oneAPI.DeviceArray{Float32, 1}, oneAPI.DeviceArray{Float32, 1}, oneAPI.DeviceArray{Float32, 1}))


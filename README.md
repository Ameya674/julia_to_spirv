
# Julia to OpenCL flavour SPIRV IR using oneAPI.jl 

oneAPI.jl is a a Julia package for programming accelerators with the oneAPI programming model. It is currently only compatible with a few selected Intel GPUs.

The important component of this package from the compiler perspective is the julia to SPIRV IR compiler provided by the GPUCompiler.jl package. This package is not meant for end users.

My sytem has Ubuntu22.04, aRyzen 7 CPU and an Nvidia Geforce GTX 1650 GPU. Hence I will be connecting to a remote Intel(R) Arc(TM) A770 Graphics GPU over a VPN network.

Follow the steps to use the oneAPI.jl package. Skips any step if you have already installed something or already have already completed it.

## 1) Install Tailscale network and join the network
Open the terminal and enter the commands
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --login-server https://headscale.von-neumann.ai
```
## 2) Connect to the Intel GPU
```bash
ssh <user_account>@<ip_addr_of_gpu>
```
## 3) Install oneAPI Basekit
Donwload the installer
```bash
wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/9a98af19-1c68-46ce-9fdd-e249240c7c42/l_BaseKit_p_2024.2.0.634_offline.sh
```
Run the installer
```bash
sudo sh ./l_BaseKit_p_2024.2.0.634_offline.sh -a --silent --cli --eula accept
```
Setup the environment for oneAPI tools
```bash
source /opt/intel/oneapi/setvars.sh
```

## 4) Install Julia
Donwload the tar file
```bash
wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.1-linux-x86_64.tar.gz
```
Extract the binaries
```bash
tar zxvf julia-1.8.1-linux-x86_64.tar.gz
```
Open the bash script with
```bash
nano ~/.bashrc
```
Add Julia to your path by pasting this in the file
```bash 
. . .
export PATH="$PATH:{path to julia binaries}"
```
Once you're done, save and exit by pressing `Ctrl+O` then `Ctrl+X`.

To effect this change
```bash
source ~/.bashrc
```

You can Julia in REPL (read-eval-print-loop) by doing `Julia`or write code files with .jl extension

## 5) Installing the oneAPI.jl package
Enter the Julia  REPL mode and press `]`
Install the package
```bash
add oneAPI
```

## 6) Write the Julia Kernel
Create a Julia file and copy the given script. You can also do this in REPL mode
```bash
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
```

Run the code by `julia <filename.jl>`

This will generate the OpenCL flavoured SPIRV IR for the given Julia code
```bash
julia> @device_code_spirv @oneapi vadd(a, b, c)
// GPUCompiler.CompilerJob{GPUCompiler.SPIRVCompilerTarget, oneAPI.oneAPICompilerParams}(MethodInstance for vadd(::oneDeviceVector{Float32, 1}, ::oneDeviceVector{Float32, 1}, ::oneDeviceVector{Float32, 1}), CompilerConfig for GPUCompiler.SPIRVCompilerTarget, 0x0000000000007ecf)

; SPIR-V
; Version: 1.0
; Generator: Khronos LLVM/SPIR-V Translator; 14
; Bound: 43
; Schema: 0
               OpCapability Addresses
               OpCapability Linkage
               OpCapability Kernel
               OpCapability Int64
               OpCapability Int8
          %1 = OpExtInstImport "OpenCL.std"
               OpMemoryModel Physical64 OpenCL
               OpEntryPoint Kernel %37 "_Z4vadd14oneDeviceArrayI7Float32Li1ELi1EES_IS0_Li1ELi1EES_IS0_Li1ELi1EE" %__spirv_BuiltInGlobalInvocationId
               OpExecutionMode %37 ContractionOff
               OpSource OpenCL_C 200000
               OpName %__spirv_BuiltInGlobalInvocationId "__spirv_BuiltInGlobalInvocationId"
               OpName %_Z4vadd14oneDeviceArrayI7Float32Li1ELi1EES_IS0_Li1ELi1EES_IS0_Li1ELi1EE "_Z4vadd14oneDeviceArrayI7Float32Li1ELi1EES_IS0_Li1ELi1EES_IS0_Li1ELi1EE"
               OpName %conversion "conversion"
               OpDecorate %__spirv_BuiltInGlobalInvocationId LinkageAttributes "__spirv_BuiltInGlobalInvocationId" Import
               OpDecorate %__spirv_BuiltInGlobalInvocationId Constant
               OpDecorate %__spirv_BuiltInGlobalInvocationId BuiltIn GlobalInvocationId
               OpDecorate %_Z4vadd14oneDeviceArrayI7Float32Li1ELi1EES_IS0_Li1ELi1EES_IS0_Li1ELi1EE LinkageAttributes "_Z4vadd14oneDeviceArrayI7Float32Li1ELi1EES_IS0_Li1ELi1EES_IS0_Li1ELi1EE" Export
               OpDecorate %16 FuncParamAttr ByVal
               OpDecorate %17 FuncParamAttr ByVal
               OpDecorate %18 FuncParamAttr ByVal
               OpDecorate %38 FuncParamAttr ByVal
               OpDecorate %39 FuncParamAttr ByVal
               OpDecorate %40 FuncParamAttr ByVal
      %ulong = OpTypeInt 64 0
      %uchar = OpTypeInt 8 0
    %ulong_1 = OpConstant %ulong 1
    %v3ulong = OpTypeVector %ulong 3
%_ptr_Input_v3ulong = OpTypePointer Input %v3ulong
       %void = OpTypeVoid
%_ptr_CrossWorkgroup_uchar = OpTypePointer CrossWorkgroup %uchar
%_arr_ulong_ulong_1 = OpTypeArray %ulong %ulong_1
  %_struct_8 = OpTypeStruct %_ptr_CrossWorkgroup_uchar %ulong %_arr_ulong_ulong_1 %ulong
  %_struct_7 = OpTypeStruct %_struct_8
%_ptr_Function__struct_7 = OpTypePointer Function %_struct_7
         %14 = OpTypeFunction %void %_ptr_Function__struct_7 %_ptr_Function__struct_7 %_ptr_Function__struct_7
      %float = OpTypeFloat 32
%_ptr_CrossWorkgroup_float = OpTypePointer CrossWorkgroup %float
%_ptr_Function__ptr_CrossWorkgroup_float = OpTypePointer Function %_ptr_CrossWorkgroup_float
%__spirv_BuiltInGlobalInvocationId = OpVariable %_ptr_Input_v3ulong Input
%_Z4vadd14oneDeviceArrayI7Float32Li1ELi1EES_IS0_Li1ELi1EES_IS0_Li1ELi1EE = OpFunction %void None %14
         %16 = OpFunctionParameter %_ptr_Function__struct_7
         %17 = OpFunctionParameter %_ptr_Function__struct_7
         %18 = OpFunctionParameter %_ptr_Function__struct_7
 %conversion = OpLabel
         %20 = OpLoad %v3ulong %__spirv_BuiltInGlobalInvocationId Aligned 32
         %21 = OpCompositeExtract %ulong %20 0
         %25 = OpBitcast %_ptr_Function__ptr_CrossWorkgroup_float %16
         %26 = OpLoad %_ptr_CrossWorkgroup_float %25 Aligned 8
         %27 = OpInBoundsPtrAccessChain %_ptr_CrossWorkgroup_float %26 %21
         %28 = OpLoad %float %27 Aligned 4
         %29 = OpBitcast %_ptr_Function__ptr_CrossWorkgroup_float %17
         %30 = OpLoad %_ptr_CrossWorkgroup_float %29 Aligned 8
         %31 = OpInBoundsPtrAccessChain %_ptr_CrossWorkgroup_float %30 %21
         %32 = OpLoad %float %31 Aligned 4
         %33 = OpFAdd %float %28 %32
         %34 = OpBitcast %_ptr_Function__ptr_CrossWorkgroup_float %18
         %35 = OpLoad %_ptr_CrossWorkgroup_float %34 Aligned 8
         %36 = OpInBoundsPtrAccessChain %_ptr_CrossWorkgroup_float %35 %21
               OpStore %36 %33 Aligned 4
               OpReturn
               OpFunctionEnd
         %37 = OpFunction %void None %14
         %38 = OpFunctionParameter %_ptr_Function__struct_7
         %39 = OpFunctionParameter %_ptr_Function__struct_7
         %40 = OpFunctionParameter %_ptr_Function__struct_7
         %41 = OpLabel
         %42 = OpFunctionCall %void %_Z4vadd14oneDeviceArrayI7Float32Li1ELi1EES_IS0_Li1ELi1EES_IS0_Li1ELi1EE %38 %39 %40
               OpReturn
               OpFunctionEnd
```

You can also generate the LLVM IR for the given code by using the following script but just `add LLVM` by going into package mode

```bash
# To generate LLVM IR
using LLVM

# Define the vector addition kernel
function vadd(a, b, c)
    i = get_global_id(1)
    @inbounds c[i] = a[i] + b[i]
end

# Generate LLVM IR
llvm_code = code_llvm(vadd, (oneAPI.DeviceArray{Float32, 1}, oneAPI.DeviceArray{Float32, 1}, oneAPI.DeviceArray{Float32, 1}))
```

This will generate the LLVM IR
```bash
;  @ REPL[2]:1 within `vadd`
define nonnull {}* @japi1_vadd_199({}* %0, {}** %1, i32 %2) #0 {
top:
  %3 = alloca [3 x {}*], align 8
  %gcframe3 = alloca [5 x {}*], align 16
  %gcframe3.sub = getelementptr inbounds [5 x {}*], [5 x {}*]* %gcframe3, i64 0, i64 0
  %.sub = getelementptr inbounds [3 x {}*], [3 x {}*]* %3, i64 0, i64 0
  %4 = bitcast [5 x {}*]* %gcframe3 to i8*
  call void @llvm.memset.p0i8.i32(i8* noundef nonnull align 16 dereferenceable(40) %4, i8 0, i32 40, i1 false)
  %5 = alloca {}**, align 8
  store volatile {}** %1, {}*** %5, align 8
  %thread_ptr = call i8* asm "movq %fs:0, $0", "=r"() #2
  %ppgcstack_i8 = getelementptr i8, i8* %thread_ptr, i64 -8
  %ppgcstack = bitcast i8* %ppgcstack_i8 to {}****
  %pgcstack = load {}***, {}**** %ppgcstack, align 8
  %6 = bitcast [5 x {}*]* %gcframe3 to i64*
  store i64 12, i64* %6, align 16
  %7 = getelementptr inbounds [5 x {}*], [5 x {}*]* %gcframe3, i64 0, i64 1
  %8 = bitcast {}** %7 to {}***
  %9 = load {}**, {}*** %pgcstack, align 8
  store {}** %9, {}*** %8, align 8
  %10 = bitcast {}*** %pgcstack to {}***
  store {}** %gcframe3.sub, {}*** %10, align 8
  %11 = load {}*, {}** %1, align 8
  %12 = getelementptr inbounds {}*, {}** %1, i64 1
  %13 = load {}*, {}** %12, align 8
  %14 = getelementptr inbounds {}*, {}** %1, i64 2
  %15 = load {}*, {}** %14, align 8
;  @ REPL[2]:2 within `vadd`
  %16 = load atomic {}*, {}** @0 unordered, align 8
  %.not = icmp eq {}* %16, null
  br i1 %.not, label %notfound, label %found

notfound:                                         ; preds = %top
  %17 = call {}* @ijl_get_binding_or_error({}* nonnull inttoptr (i64 124846190800624 to {}*), {}* nonnull inttoptr (i64 124846430132352 to {}*))
  store atomic {}* %17, {}** @0 release, align 8
  br label %found

found:                                            ; preds = %notfound, %top
  %18 = phi {}* [ %16, %top ], [ %17, %notfound ]
  %19 = bitcast {}* %18 to {}**
  %20 = getelementptr inbounds {}*, {}** %19, i64 1
  %21 = load atomic {}*, {}** %20 unordered, align 8
  %.not1 = icmp eq {}* %21, null
  br i1 %.not1, label %err, label %ok

err:                                              ; preds = %found
  call void @ijl_undefined_var_error({}* inttoptr (i64 124846430132352 to {}*))
  unreachable

ok:                                               ; preds = %found
  %22 = getelementptr inbounds [5 x {}*], [5 x {}*]* %gcframe3, i64 0, i64 2
  store {}* %21, {}** %22, align 16
  store {}* inttoptr (i64 124846428156000 to {}*), {}** %.sub, align 8
  %23 = call nonnull {}* @ijl_apply_generic({}* nonnull %21, {}** nonnull %.sub, i32 1)
  %24 = getelementptr inbounds [5 x {}*], [5 x {}*]* %gcframe3, i64 0, i64 4
  store {}* %23, {}** %24, align 16
;  @ REPL[2]:3 within `vadd`
  store {}* %11, {}** %.sub, align 8
  %25 = getelementptr inbounds [3 x {}*], [3 x {}*]* %3, i64 0, i64 1
  store {}* %23, {}** %25, align 8
  %26 = call nonnull {}* @ijl_apply_generic({}* inttoptr (i64 124846191920400 to {}*), {}** nonnull %.sub, i32 2)
  %27 = getelementptr inbounds [5 x {}*], [5 x {}*]* %gcframe3, i64 0, i64 3
  store {}* %26, {}** %27, align 8
  store {}* %13, {}** %.sub, align 8
  store {}* %23, {}** %25, align 8
  %28 = call nonnull {}* @ijl_apply_generic({}* inttoptr (i64 124846191920400 to {}*), {}** nonnull %.sub, i32 2)
  store {}* %28, {}** %22, align 16
  store {}* %26, {}** %.sub, align 8
  store {}* %28, {}** %25, align 8
  %29 = call nonnull {}* @ijl_apply_generic({}* inttoptr (i64 124846192287776 to {}*), {}** nonnull %.sub, i32 2)
  store {}* %29, {}** %22, align 16
  store {}* %15, {}** %.sub, align 8
  store {}* %29, {}** %25, align 8
  %30 = getelementptr inbounds [3 x {}*], [3 x {}*]* %3, i64 0, i64 2
  store {}* %23, {}** %30, align 8
  %31 = call nonnull {}* @ijl_apply_generic({}* inttoptr (i64 124846191745744 to {}*), {}** nonnull %.sub, i32 3)
  %32 = load {}*, {}** %7, align 8
  %33 = bitcast {}*** %pgcstack to {}**
  store {}* %32, {}** %33, align 8
  ret {}* %29
}
```

Hence we have successfully compiled SPIRV IR and LLVM IR from Julia!!
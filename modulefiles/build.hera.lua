prepend_path("MODULEPATH", "/apps/spack/modules/linux-rocky9-x86_64/Core")

load("intel-oneapi-compilers/2024.2.1")

prepend_path("MODULEPATH", "/contrib/spack-stack/spack-stack-1.9.2/envs/ue-oneapi-2024.2.1/install/modulefiles/Core")

load("stack-oneapi/2024.2.1")
load("intel-oneapi-compilers/2023.2.0")
load("jasper/2.0.32")
load("libpng/1.6.37")
load("cmake/3.30.2")

load("python/3.11")

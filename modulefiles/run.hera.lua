prepend_path("MODULEPATH", "/scratch1/NCEPDEV/nems/role.epic/spack-stack/spack-stack-1.6.0/envs/unified-env-rocky8/install/modulefiles/Core/")

load("stack-intel/2021.5.0")
load("python/3.11.6")
load("hpss/hpss")
load("awscli-v2/2.13.22")

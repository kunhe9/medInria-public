################################################################################
#
# medInria
#
# Copyright (c) INRIA 2013. All rights reserved.
# See LICENSE.txt for details.
# 
#  This software is distributed WITHOUT ANY WARRANTY; without even
#  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#  PURPOSE.
#
################################################################################

function(onnxruntime_project)
set(ep onnxruntime)

## #############################################################################
## List the dependencies of the project
## #############################################################################

list(APPEND ${ep}_dependencies 
  ""
  )

## #############################################################################
## Prepare the project
## ############################################################################# 

EP_Initialisation(${ep} 
  USE_SYSTEM OFF 
  BUILD_SHARED_LIBS ON
  REQUIRED_FOR_PLUGINS OFF
  )

if (NOT USE_SYSTEM_${ep})

## #############################################################################
## Set up versioning control
## #############################################################################


set(git_url ${GITHUB_PREFIX}microsoft/onnxruntime.git)
set(git_tag v1.15.1)


## #############################################################################
## Add specific cmake arguments for configuration step of the project
## #############################################################################

# set compilation flags
#set(cmake_args
#  ${ep_common_cache_args}
#  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE_externals_projects}
#  -DCMAKE_C_FLAGS=${${ep}_c_flags}
#  -DCMAKE_CXX_FLAGS=${${ep}_cxx_flags}
#  -DCMAKE_SHARED_LINKER_FLAGS=${${ep}_shared_linker_flags}  
#  -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
#  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS_${ep}}
#  )

## #############################################################################
## Add external-project
## #############################################################################
epComputPath(${ep})
#./build.sh --config RelWithDebInfo --build_shared_lib --parallel --compile_no_warning_as_error --skip_submodule_sync

ExternalProject_Add(${ep}
  PREFIX ${EP_PATH_SOURCE}
  SOURCE_DIR ${EP_PATH_SOURCE}/${ep}
  BINARY_DIR ${build_path}
  TMP_DIR ${tmp_path}
  STAMP_DIR ${stamp_path}

  GIT_REPOSITORY ${git_url}
  GIT_TAG ${git_tag}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ${EP_PATH_SOURCE}/${ep}/build.sh
      --config RelWithDebInfo
      --build_shared_lib
      --parallel
      --compile_no_warning_as_error
      --skip_submodule_sync
  DEPENDS ${${ep}_dependencies}
  INSTALL_COMMAND ""
  BUILD_ALWAYS 1
  )

## #############################################################################
## Set variable to provide infos about the project
## #############################################################################

ExternalProject_Get_Property(${ep} binary_dir)
set(${ep}_DIR ${binary_dir} PARENT_SCOPE)

endif() #NOT USE_SYSTEM_ep

endfunction()

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

function(medInria_project)

set(ep medInria)

## #############################################################################
## List the dependencies of the project
## #############################################################################

list(APPEND ${ep}_dependencies 
  dtk 
  DCMTK 
  ITK 
  VTK 
  TTK 
  QtDCM
  RPI
  LogDemons
  pyncpp
  )

if (USE_DTKIMAGING)
  list(APPEND ${ep}_dependencies
       dtkImaging
       )
endif()
  
## #############################################################################
## Prepare the project
## ############################################################################# 

EP_Initialisation(${ep}  
  USE_SYSTEM OFF 
  BUILD_SHARED_LIBS ON
  REQUIRED_FOR_PLUGINS ON
  )


if (NOT USE_SYSTEM_${ep})
## #############################################################################
## Add specific cmake arguments for configuration step of the project
## #############################################################################

# set compilation flags
if (UNIX)
  set(${ep}_c_flags "${${ep}_c_flags} -Wall")
  set(${ep}_cxx_flags "${${ep}_cxx_flags} -Wall -Wno-unknown-pragmas")
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(${ep}_cxx_flags "${${ep}_cxx_flags} -Wno-inconsistent-missing-override")
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
  set(${ep}_cxx_flags "${${ep}_cxx_flags} -fpermissive")
endif()

set(${ep}_BUILD_TYPE Debug CACHE STRING "Build type configuration specific to medInria.")

set(cmake_args
   ${ep_common_cache_args}
  -DCMAKE_BUILD_TYPE=${${ep}_BUILD_TYPE}
  -DCMAKE_C_FLAGS=${${ep}_c_flags}
  -DCMAKE_CXX_FLAGS=${${ep}_cxx_flags}
  -DCMAKE_SHARED_LINKER_FLAGS=${${ep}_shared_linker_flags}  
  -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS_${ep}}
  -DUSE_DTKIMAGING:BOOL=${USE_DTKIMAGING}
  -DUSE_OSPRay:BOOL=${USE_OSPRay}
  -DUSE_Python:BOOL=${USE_Python}
  -DmedInria_VERSION:STRING=${${PROJECT_NAME}_VERSION}
  -DBUILD_ALL_PLUGINS=OFF
  -DBUILD_COMPOSITEDATASET_PLUGIN=OFF
  -DBUILD_EXAMPLE_PLUGINS=OFF
  -DEXPIRATION_TIME=${EXPIRATION_TIME}
  )

set(cmake_cache_args
  -DDCMTK_DIR:PATH=${DCMTK_DIR}
  -Ddtk_DIR:PATH=${dtk_DIR}
  -DITK_DIR:PATH=${ITK_DIR}
  -DQtDCM_DIR:PATH=${QtDCM_DIR}
  -DRPI_DIR:PATH=${RPI_DIR}
  -DTTK_DIR:PATH=${TTK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DQt5_DIR:PATH=${Qt5_DIR}
  -DLogDemons_DIR:PATH=${LogDemons_DIR}
  -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
  )

set(cmake_cache_args
  -DDCMTK_DIR:PATH=${DCMTK_DIR}
  -Ddtk_DIR:PATH=${dtk_DIR}
  -DITK_DIR:PATH=${ITK_DIR}
  -DQtDCM_DIR:PATH=${QtDCM_DIR}
  -DRPI_DIR:PATH=${RPI_DIR}
  -DTTK_DIR:PATH=${TTK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DQt5_DIR:PATH=${Qt5_DIR}
  -DLogDemons_DIR:PATH=${LogDemons_DIR}
  -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
  )

set(cmake_cache_args
  -DDCMTK_DIR:PATH=${DCMTK_DIR}
  -Ddtk_DIR:PATH=${dtk_DIR}
  -DITK_DIR:PATH=${ITK_DIR}
  -DQtDCM_DIR:PATH=${QtDCM_DIR}
  -DRPI_DIR:PATH=${RPI_DIR}
  -DTTK_DIR:PATH=${TTK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DQt5_DIR:PATH=${Qt5_DIR}
  -DLogDemons_DIR:PATH=${LogDemons_DIR}
  -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
  )

if (${USE_FFmpeg})
  list(APPEND cmake_args
  -DUSE_FFmpeg=${USE_FFmpeg})
endif()

if (USE_DTKIMAGING)
  set(cmake_args
    ${cmake_args}
    -DdtkImaging_DIR:PATH=${dtkImaging_DIR}
    )
endif()

if (USE_Python)
  list(APPEND cmake_cache_args
      -Dpyncpp_DIR:PATH=${pyncpp_DIR}
      )
endif()
  
## #############################################################################
## Add external-project
## #############################################################################

ExternalProject_Add(${ep}
  SOURCE_DIR ${medInria_SOURCE_DIR}
  BINARY_DIR ${medInria_BINARY_DIR}
  STAMP_DIR ${medinria_Stamp_DIR}
  UPDATE_COMMAND ""
  CMAKE_GENERATOR ${gen}
  CMAKE_GENERATOR_PLATFORM ${CMAKE_GENERATOR_PLATFORM}
  CMAKE_ARGS ${cmake_args}
  CMAKE_CACHE_ARGS ${cmake_cache_args}
  DEPENDS ${${ep}_dependencies}
  INSTALL_COMMAND ""
  BUILD_ALWAYS 1
  )

## #############################################################################
## Set variable to provide infos about the project
## #############################################################################

ExternalProject_Get_Property(${ep} binary_dir)
set(${ep}_DIR ${binary_dir} PARENT_SCOPE)

ExternalProject_Get_Property(${ep} source_dir)
set(${ep}_SOURCE_DIR ${source_dir} PARENT_SCOPE)
  
  
if (WIN32)
  file(TO_NATIVE_PATH ${ITK_DIR}                 ITK_BIN_BASE)
  file(TO_NATIVE_PATH ${VTK_DIR}                 VTK_BIN_BASE)
  file(TO_NATIVE_PATH ${dtk_DIR}                 DTK_BIN_BASE)
  file(TO_NATIVE_PATH ${QtDCM_DIR}               DCM_BIN_BASE)
  file(TO_NATIVE_PATH ${_qt5Core_install_prefix} QT5_BIN_BASE)
  file(TO_NATIVE_PATH ${medInria_BINARY_DIR}     MED_BIN_BASE)
  file(TO_NATIVE_PATH ${pyncpp_DIR}              PYNCPP_BIN_BASE)
  
  set(CONFIG_MODE $<$<CONFIG:debug>:Debug>$<$<CONFIG:release>:Release>$<$<CONFIG:MinSizeRel>:MinSizeRel>$<$<CONFIG:RelWithDebInfo>:RelWithDebInfo>)
  
  set(MED_BIN_BASE ${MED_BIN_BASE}\\${CONFIG_MODE}\\bin)  
  
  add_custom_command(TARGET ${ep}
        POST_BUILD
        COMMAND for %%I in ( ${ITK_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) 
        COMMAND for %%I in ( ${VTK_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) 
        COMMAND for %%I in ( ${DTK_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
        COMMAND for %%I in ( ${DCM_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
        COMMAND for %%I in ( ${QT5_BIN_BASE}\\bin\\*.dll                 ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) 
        COMMAND for %%I in ( ${PYTHON_BIN_BASE}\\bin\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
        COMMAND for %%I in ( ${PYTHON_BIN_BASE}\\bin\\DLLs ${PYTHON_BIN_BASE}\\bin\\Lib ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /d /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /d /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
     )
endif()



endif() #NOT USE_SYSTEM_ep

endfunction()

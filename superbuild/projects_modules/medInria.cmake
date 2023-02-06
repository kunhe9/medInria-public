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

if (UNIX)
    set(${ep}_cxx_flags "${${ep}_cxx_flags} -Wall -Wno-unknown-pragmas")
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(${ep}_cxx_flags "${${ep}_cxx_flags} -Wno-inconsistent-missing-override")
endif()

if (MSVC)
    set(${ep}_cxx_flags "${${ep}_cxx_flags} /Zc:__cplusplus")
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

   # External settings
  -DSETTINGS_QRC_DIRECTORY=${SETTINGS_QRC_DIRECTORY}
  -DAPPLICATION_NAME=${APPLICATION_NAME}
  -DORGANIZATION_NAME=${ORGANIZATION_NAME}
  -DORGANIZATION_DOMAIN=${ORGANIZATION_DOMAIN}
  -DPROJECT_CONTACT=${PROJECT_CONTACT}
  -DPACKAGE_VENDOR=${PACKAGE_VENDOR}
  -DDOCUMENTATION_URL="${DOCUMENTATION_URL}"
  -DPROJECT_DESCRIPTION=${PROJECT_DESCRIPTION}
  -DLARGE_LOGO_DARK_THEME=${LARGE_LOGO_DARK_THEME}
  -DLARGE_LOGO_LIGHT_THEME=${LARGE_LOGO_LIGHT_THEME}
  -DWINDOW_ICON=${WINDOW_ICON}
  -DWINDOW_ICON_PATH=${WINDOW_ICON_PATH}
  -DABOUT_FILE=${ABOUT_FILE}
  -DRELEASE_NOTES=${RELEASE_NOTES}
  -DADDITIONAL_AUTHORS_LIST="${ADDITIONAL_AUTHORS_LIST}"
  -DDESCRIPTION_HOMEPAGE=${DESCRIPTION_HOMEPAGE}
  -DDESCRIPTION_PACKAGING=${DESCRIPTION_PACKAGING}
  -DLICENSE_FILE=${LICENSE_FILE}
  -DLICENSE_EXTERNAL_FILE=${LICENSE_EXTERNAL_FILE}
  -DLICENSE_FILE_PATH=${LICENSE_FILE_PATH}
  -DREADME_FILE=${README_FILE}
  -DWELCOME_FILE=${WELCOME_FILE}
  )

set(cmake_cache_args
  -DDCMTK_ROOT:PATH=${DCMTK_ROOT}
  -Ddtk_ROOT:PATH=${dtk_ROOT}
  -DITK_ROOT:PATH=${ITK_ROOT}
  -DQtDCM_ROOT:PATH=${QtDCM_ROOT}
  -DRPI_ROOT:PATH=${RPI_ROOT}
  -DTTK_ROOT:PATH=${TTK_ROOT}
  -DVTK_ROOT:PATH=${VTK_ROOT}
  -DQt5_DIR:PATH=${Qt5_DIR}
  -DLogDemons_ROOT:PATH=${LogDemons_ROOT}
  -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
  )

if (${USE_FFmpeg})
  list(APPEND cmake_args
  -DUSE_FFmpeg=${USE_FFmpeg})
endif()

if (USE_DTKIMAGING)
  set(cmake_args
    ${cmake_args}
    -DdtkImaging_ROOT:PATH=${dtkImaging_ROOT}
    )
endif()

if (USE_Python)
  list(APPEND cmake_cache_args
      -Dpyncpp_ROOT:PATH=${pyncpp_ROOT}
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

if (WIN32)
  file(REAL_PATH ${TTK_DIR}/../../../ _TTK_DIR)
  file(TO_NATIVE_PATH ${ITK_ROOT}                ITK_BIN_BASE)
  file(TO_NATIVE_PATH ${VTK_ROOT}                VTK_BIN_BASE)
  file(TO_NATIVE_PATH ${TTK_ROOT}                TTK_BIN_BASE)
  file(TO_NATIVE_PATH ${dtk_ROOT}                DTK_BIN_BASE)
  file(TO_NATIVE_PATH ${QtDCM_ROOT}              DCM_BIN_BASE)
  file(TO_NATIVE_PATH ${_qt5Core_install_prefix} QT5_BIN_BASE)
  file(TO_NATIVE_PATH ${medInria_BINARY_DIR}     MED_BIN_BASE)
  file(TO_NATIVE_PATH ${pyncpp_ROOT}             PYNCPP_BIN_BASE)
  
  set(CONFIG_MODE $<$<CONFIG:debug>:Debug>$<$<CONFIG:release>:Release>$<$<CONFIG:MinSizeRel>:MinSizeRel>$<$<CONFIG:RelWithDebInfo>:RelWithDebInfo>)
  
  set(MED_BIN_BASE ${MED_BIN_BASE}\\${CONFIG_MODE}\\bin)  
  
  add_custom_command(TARGET ${ep}
        POST_BUILD
        COMMAND for %%I in ( ${ITK_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) 
        COMMAND for %%I in ( ${VTK_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) 
        COMMAND for %%I in ( ${DTK_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
        COMMAND for %%I in ( ${DCM_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
        COMMAND for %%I in ( ${TTK_BIN_BASE}\\bin\\*.dll )                 do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
        COMMAND for %%I in ( ${QT5_BIN_BASE}\\bin\\*.dll )                 do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) 
        COMMAND for %%I in ( ${PYNCPP_BIN_BASE}\\bin\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
        )
endif()



endif() #NOT USE_SYSTEM_ep

set(${ep}_ROOT ${medInria_BINARY_DIR} PARENT_SCOPE)

endfunction()

################################################################################
#
# medInria

# Copyright (c) INRIA 2013. All rights reserved.

# See LICENSE.txt for details in the root of the sources or:
# https://github.com/medInria/medInria-public/blob/master/LICENSE.txt

# This software is distributed WITHOUT ANY WARRANTY; without even
# the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.
#
################################################################################


## #############################################################################
## Options
## #############################################################################
if(BUILD_APPLI STREQUAL "MUSICardio")
    option(BUILD_ALL_PLUGINS
      "Build all Medinria plugins (overrides individual selections)"
      ON
      )
elseif(BUILD_APPLI STREQUAL "SPOTCardio")
    option(BUILD_ALL_PLUGINS
      "Build all Medinria plugins (overrides individual selections)"
      OFF
      )
endif()


option(BUILD_EXAMPLE_PLUGINS
  "Enable this if you want to build the examples"
  OFF
  )

option(BUILD_COMPOSITEDATASET_PLUGIN
  "Enable this if you want to build compositeDataSet plugin"
  OFF
  )


## #############################################################################
## list plugins
## #############################################################################

## ADD here any new plugin with a default compilation value,
## you want to include in the build,
# set(PLUGIN_LIST
#   legacy/diffeomorphicDemons                                             ON  
#   legacy/iterativeClosestPoint                                           ON
#   legacy/itkDataDiffusionGradientList                                    ON
#   legacy/itkDataImage                                                    ON
#   legacy/itkDataSHImage                                                  ON
#   legacy/itkDataTensorImage                                              ON
#   legacy/itkFilters                                                      ON
#   legacy/itkINRDataImageReader                                           ON
#   legacy/itkINRDataImageWriter                                           ON
#   legacy/itkProcessRegistrationOptimus                                   ON
#   legacy/LCCLogDemons                                                    ON  
#   legacy/manualRegistration                                              ON
#   legacy/medAlgorithmPaint                                               ON
#   legacy/medBinaryOperation                                              ON
#   legacy/medCreateMeshFromMask                                           ON
#   legacy/medFilteringWorkspaceL                                          ON
#   legacy/medMaskApplication                                              ON
#   legacy/medMeshingWorkspace                                             ON
#   legacy/medN4BiasCorrection                                             ON
#   legacy/medRegistrationWorkspace                                        ON
#   legacy/medRemeshing                                                    ON
#   legacy/medSegmentation                                                 ON
#   legacy/medSegmentationWorkspace                                        ON
#   legacy/medVtkFibersData                                                ON
#   legacy/medVtkView                                                      ON
#   legacy/meshManipulation                                                ON
#   legacy/meshMapping                                                     ON
#   legacy/polygonRoi                                                      ON
#   legacy/qtdcmDataSource                                                 ON
#   legacy/reformat                                                        ON
#   legacy/undoRedoRegistration                                            ON
#   legacy/variationalSegmentation                                         ON
#   legacy/voiCutter                                                       ON
#   legacy/vtkDataMesh                                                     ON
#   legacy/medExportVideo                                                  ON
#   process/arithmetic_operation                                           ON
#   process/bias_correction                                                ON
#   process/dwi_basic_thresholding                                         ON
#   process/itkDWIBrainMaskCalculatorProcess                               ON
#   process/ttkTensorEstimationProcess                                     ON
#   process/ttkTensorScalarMapsProcess                                     ON
#   process/ttkTensorTractographyProcess                                   ON
#   process/mask_image                                                     ON
#   process/morphomath_operation                                           ON
#   process/single_filter                                                  ON
#   )

set(ALL_PLUGINS
  legacy/diffeomorphicDemons
  legacy/iterativeClosestPoint
  legacy/itkDataDiffusionGradientList
  legacy/itkDataImage 
  legacy/itkDataSHImage
  legacy/itkDataTensorImage
  legacy/itkFilters
  legacy/itkINRDataImageReader
  legacy/itkINRDataImageWriter
  legacy/itkProcessRegistrationOptimus
  legacy/LCCLogDemons
  legacy/manualRegistration
  legacy/medAlgorithmPaint
  legacy/medBinaryOperation
  legacy/medCreateMeshFromMask
  legacy/medFilteringWorkspaceL
  legacy/medMaskApplication
  legacy/medMeshingWorkspace
  legacy/medN4BiasCorrection
  legacy/medRegistrationWorkspace
  legacy/medRemeshing       
  legacy/medSegmentation
  legacy/medSegmentationWorkspace
  legacy/medVtkFibersData
  legacy/medVtkView
  legacy/meshManipulation
  legacy/meshMapping
  legacy/polygonRoi
  legacy/qtdcmDataSource
  legacy/reformat
  legacy/undoRedoRegistration
  legacy/variationalSegmentation
  legacy/voiCutter
  legacy/vtkDataMesh
  legacy/medExportVideo
  process/arithmetic_operation
  process/bias_correction
  process/dwi_basic_thresholding
  process/itkDWIBrainMaskCalculatorProcess
  process/ttkTensorEstimationProcess
  process/ttkTensorScalarMapsProcess
  process/ttkTensorTractographyProcess
  process/mask_image
  process/morphomath_operation
  process/single_filter
  )

set(MUSICardio_DISABLED
  )

set(SPOTCardio_DISABLED
  legacy/diffeomorphicDemons
  legacy/iterativeClosestPoint
  legacy/itkDataDiffusionGradientList
  legacy/itkDataSHImage
  legacy/itkDataTensorImage
  legacy/itkFilters
  legacy/itkINRDataImageReader
  legacy/itkINRDataImageWriter
  legacy/itkProcessRegistrationOptimus
  legacy/LCCLogDemons
  legacy/manualRegistration
  legacy/medAlgorithmPaint
  legacy/medBinaryOperation
  legacy/medCreateMeshFromMask
  legacy/medFilteringWorkspaceL
  legacy/medMaskApplication
  legacy/medMeshingWorkspace
  legacy/medN4BiasCorrection
  legacy/medRegistrationWorkspace
  legacy/medRemeshing
  legacy/medVtkFibersData
  legacy/meshManipulation
  legacy/meshMapping
  legacy/qtdcmDataSource
  legacy/reformat
  legacy/undoRedoRegistration
  legacy/variationalSegmentation
  legacy/voiCutter
  legacy/vtkDataMesh
  legacy/medExportVideo
  process/arithmetic_operation
  process/bias_correction
  process/dwi_basic_thresholding
  process/itkDWIBrainMaskCalculatorProcess
  process/ttkTensorEstimationProcess
  process/ttkTensorScalarMapsProcess
  process/ttkTensorTractographyProcess
  process/mask_image
  process/morphomath_operation
  process/single_filter
)

message(STATUS "DEBUG: BUILD_APPLI='${BUILD_APPLI}'")

if(BUILD_APPLI STREQUAL "MUSICardio")
    message(STATUS "Build MUSICardio")
elseif(BUILD_APPLI STREQUAL "SPOTCardio")
    message(STATUS "Build SPOTCardio")
elseif(NOT DEFINED BUILD_APPLI)
    set(BUILD_APPLI "SPOTCardio" CACHE STRING "Choose application: MUSICardio / SPOTCardio")
endif()

message(STATUS "DEBUG: BUILD_APPLI='${BUILD_APPLI}'")

function(generate_plugin_list appli)
  set(result)
  set(disabled_list "${appli}_DISABLED")

  foreach(plugin ${ALL_PLUGINS})

    set(state ON)
    list(FIND disabled_list ${plugin} idx)
    if(NOT idx EQUAL -1)
      set(state OFF)
    endif()

    list(APPEND result ${plugin} ${state})

  endforeach()

  set(PLUGIN_LIST ${result} PARENT_SCOPE)

endfunction()

generate_plugin_list(${BUILD_APPLI})

  if(USE_DTKIMAGING)
    set(PLUGIN_LIST
      ${PLUGIN_LIST}
      medITKImageDTKImageConverter ON
      medImagingCompatibility ON
      )    
  endif()
message(STATUS "Final PLUGIN_LIST: ${PLUGIN_LIST}")
## #############################################################################
## process plugins
## #############################################################################

## see cmake/module/add_plugin.cmake
add_plugins(
  ${PLUGIN_LIST}
  )

if(BUILD_COMPOSITEDATASET_PLUGIN)
  add_subdirectory(medCompositeDataSets)
endif()

if (BUILD_EXAMPLE_PLUGINS)
  add_subdirectory(legacy/examples)
endif()

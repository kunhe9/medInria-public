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

option(BUILD_ALL_PLUGINS
  "Build all Medinria plugins (overrides individual selections)"
  OFF
  )

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
set(PLUGIN_LIST
  legacy/diffeomorphicDemons                                             OFF
  legacy/iterativeClosestPoint                                           OFF
  legacy/itkDataDiffusionGradientList                                    OFF
  legacy/itkDataImage                                                    ON
  legacy/itkDataSHImage                                                  OFF
  legacy/itkDataTensorImage                                              OFF
  legacy/itkFilters                                                      OFF
  legacy/itkINRDataImageReader                                           OFF
  legacy/itkINRDataImageWriter                                           OFF
  legacy/itkProcessRegistrationOptimus                                   OFF
  legacy/LCCLogDemons                                                    OFF
  legacy/manualRegistration                                              OFF
  legacy/medAlgorithmPaint                                               OFF
  legacy/medBinaryOperation                                              OFF
  legacy/medCreateMeshFromMask                                           OFF
  legacy/medFilteringWorkspaceL                                          OFF
  legacy/medMaskApplication                                              OFF
  legacy/medMeshingWorkspace                                             OFF
  legacy/medN4BiasCorrection                                             OFF
  legacy/medRegistrationWorkspace                                        OFF
  legacy/medRemeshing                                                    OFF
  legacy/medSegmentation                                                 ON
  legacy/medSegmentationWorkspace                                        ON
  legacy/medVtkFibersData                                                OFF
  legacy/medVtkView                                                      ON
  legacy/meshManipulation                                                OFF
  legacy/meshMapping                                                     OFF
  legacy/polygonRoi                                                      OFF
  legacy/qtdcmDataSource                                                 OFF
  legacy/reformat                                                        OFF
  legacy/undoRedoRegistration                                            OFF
  legacy/variationalSegmentation                                         OFF
  legacy/voiCutter                                                       OFF
  legacy/vtkDataMesh                                                     OFF
  legacy/medExportVideo                                                  OFF
  process/dwi_basic_thresholding                                         OFF
  process/itkDWIBrainMaskCalculatorProcess                               OFF
  process/ttkTensorEstimationProcess                                     OFF
  process/ttkTensorScalarMapsProcess                                     OFF
  process/ttkTensorTractographyProcess                                   OFF
  process/mask_image                                                     OFF
  )

  if(USE_DTKIMAGING)
    set(PLUGIN_LIST
      ${PLUGIN_LIST}
      medITKImageDTKImageConverter ON
      medImagingCompatibility ON
      )    
  endif()

## #############################################################################
## process plugins
## #############################################################################

## see cmake/module/add_plugin.cmake
add_plugins(${PLUGIN_LIST}
  )

if(BUILD_COMPOSITEDATASET_PLUGIN)
  add_subdirectory(medCompositeDataSets)
endif()

if (BUILD_EXAMPLE_PLUGINS)
  add_subdirectory(legacy/examples)
endif()

/*=========================================================================

 MedInria

 Copyright (c) INRIA 2013. All rights reserved.
 See LICENSE.txt for details.
 
  This software is distributed WITHOUT ANY WARRANTY; without even
  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  PURPOSE.

=========================================================================*/


#pragma once

#include "vtkRenderingAddOnExport.h"

#include<vector>
#include<iostream>

// vtk includes
#include <vtkRenderingAddOn/vtkViewImage2D.h>
#include <vtkImageTracerWidget.h>
#include <vtkImageData.h>
#include <vtkLookupTable.h>
#include <vtkRenderingAddOn/vtkImageTracerWidgetCallback.h>


class VTK_RENDERINGADDON_EXPORT vtkViewImage2DWithTracer: public vtkViewImage2D
{
  
 public:
  
  static vtkViewImage2DWithTracer* New();
  vtkTypeRevisionMacro(vtkViewImage2DWithTracer, vtkViewImage2D);
  

  virtual void PrepareForDelete();


  /**
     Activate/Deactivate the manual tracing interactor.
   */
  virtual void SetManualTracing (int val);
  vtkBooleanMacro (ManualTracing, int);
  vtkGetMacro (ManualTracing, int);
  
  
  /**
     Switch On/Off the tracer visibility.
  */
  virtual void SetManualTracingVisibility (int a);
  vtkBooleanMacro (ManualTracingVisibility, int);
  vtkGetMacro (ManualTracingVisibility, int);
  
  
  virtual void SetImage(vtkImageData* image);

  
  /**
     This method takes the polydata generated by the tracing
     widget and transform it into a binary image, with the
     label/color specified by the user.
  */
  virtual void ValidateTracing();


  /** Set a new entry in the LUT */
  virtual void SetLUTValue (const int&,
			    const double&,
			    const double&,
			    const double&,
			    const double&);

  
  virtual void SetCurrentLabel (const double& val)
  {    
    this->CurrentLabel = val;
    if( val==0.0 )
    {
      this->CurrentLabel = 255.0; // erase label
    }
  }


  vtkGetMacro (CurrentLabel, double);
  

  vtkGetObjectMacro (Tracing, vtkImageData);

  
  vtkGetObjectMacro (LUT, vtkLookupTable);
  

  vtkGetObjectMacro (TracerWidget, vtkImageTracerWidget);
  
  
  virtual void PrintSelf(ostream& os, vtkIndent indent);

  /**
     Switch between radiological (left is right and right is left) and
     neurological (left is left and right is right) conventions.
  */
  virtual void SetConventionsToRadiological();

  /**
     Switch between radiological (left is right and right is left) and
     neurological (left is left and right is right) conventions.
  */
  virtual void SetConventionsToNeurological();
  
 protected:
  vtkViewImage2DWithTracer();
  ~vtkViewImage2DWithTracer();

  virtual void Initialize ();
  virtual void Uninitialize ();


 private:

  // for manual tracing
  vtkImageTracerWidgetCallback*   TracerCbk;
  vtkImageTracerWidget*           TracerWidget;
  vtkImageData*                   Tracing;
  vtkLookupTable*                 LUT;
  double                          CurrentLabel;

  int ManualTracing;
  int ManualTracingVisibility;
  
};
  




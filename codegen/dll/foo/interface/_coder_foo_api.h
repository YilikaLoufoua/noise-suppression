//
// Student License - for use by students to meet course requirements and
// perform academic research at degree granting institutions only.  Not
// for government, commercial, or other organizational use.
//
// _coder_foo_api.h
//
// Code generation for function 'foo'
//

#ifndef _CODER_FOO_API_H
#define _CODER_FOO_API_H

// Include files
#include "foo_spec.h"
#include "emlrt.h"
#include "tmwtypes.h"
#include <algorithm>
#include <cstring>

// Variable Declarations
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

// Function Declarations
void foo(real_T A[3], real_T B[3], real_T C[3]);

void foo_api(const mxArray *const prhs[2], const mxArray **plhs);

void foo_atexit();

void foo_initialize();

void foo_terminate();

void foo_xil_shutdown();

void foo_xil_terminate();

#endif
// End of code generation (_coder_foo_api.h)

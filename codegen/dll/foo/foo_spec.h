//
// Student License - for use by students to meet course requirements and
// perform academic research at degree granting institutions only.  Not
// for government, commercial, or other organizational use.
//
// foo_spec.h
//
// Code generation for function 'foo'
//

#ifndef FOO_SPEC_H
#define FOO_SPEC_H

// Include files
#ifdef FOO_XIL_BUILD
#if defined(_MSC_VER) || defined(__LCC__)
#define FOO_DLL_EXPORT __declspec(dllimport)
#else
#define FOO_DLL_EXPORT __attribute__((visibility("default")))
#endif
#elif defined(BUILDING_FOO)
#if defined(_MSC_VER) || defined(__LCC__)
#define FOO_DLL_EXPORT __declspec(dllexport)
#else
#define FOO_DLL_EXPORT __attribute__((visibility("default")))
#endif
#else
#define FOO_DLL_EXPORT
#endif

#endif
// End of code generation (foo_spec.h)

//
// Created by yuriit on 3/12/26.
//

#ifndef RULES_ML_TOOLCHAIN_SECOND_LIBRARY_H
#define RULES_ML_TOOLCHAIN_SECOND_LIBRARY_H

// TODO: Fix compilation issues connected to below lines
//#if define(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__) || defined(__WIN32) && !defined(__CYGWIN_)
// This will emmit LNK4217 warning on Windows, but it is intentional for now
//__declspec(dllimport) extern int second_global;
//#else
extern int second_global;
//#endif

int second_func(int x);
int second_global_func();

#endif //RULES_ML_TOOLCHAIN_SECOND_LIBRARY_H
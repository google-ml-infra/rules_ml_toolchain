#ifndef _SECOND_LIBRARY_H_
#define _SECOND_LIBRARY_H_

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
// This will emmit LNK4217 warning on Windows, but it is intentional for now
__declspec(dllimport) extern int second_global;
#else
extern int second_global;
#endif

int second_func(int x);
int second_global_func();

#endif  // _SECOND_LIBRARY_H_

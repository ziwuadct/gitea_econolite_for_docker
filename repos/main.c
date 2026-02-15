#include <stdio.h>
#include <string.h>

#ifndef GIT_VERSION
#define GIT_VERSION "unknown"
#endif

int main(void)
{
    printf("Git version: %s\n", GIT_VERSION);
#if defined(RELEASE)
    printf("Build type: RELEASE\n");
#else
    printf("Build type: Linux native\n");
#endif
    return 0;
}
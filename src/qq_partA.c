#include "qq_common.h"

static void version(void)
{
    puts("#=============#");
    puts("# version 2.0 #");
    puts("#=============#");
}

void say_hello(const char* name)
{
    version();
    printf("### Hello %s! \n", name);
}

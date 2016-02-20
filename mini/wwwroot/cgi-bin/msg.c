#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<sys/stat.h>
#include<unistd.h>

int main (int argc, char *argv[])
{
#if 0
    printf ("Content-type: text/html\r\n\r\n");
    printf ("<HTML><HEAD>\r\n");
    printf ("<TITLE>Is Laura There?</TITLE>\r\n");
    printf ("</HEAD><BODY>\r\n");
    printf ("<P>msg:%s\r\n", argv[1]);
    printf ("</BODY></HTML>\r\n");
#endif
    printf ("Content-type: text/html\r\n\r\n");
    printf ("%s", argv[1]);

    return 1;
}

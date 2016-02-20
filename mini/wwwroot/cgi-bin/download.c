#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<sys/stat.h>
#include<unistd.h>

#define MAX_FILE_LEN  (1024*30)
#define DOWNLOAD_FILE_PATH  "/home/usrc/mini_httpd-1.19/mini/wwwroot/apk/"
#define DOWNLOAD_FILE_NAME  "BBDogTest.apk"


int main(int argc, char *argv[])
{
    FILE *fp;
    char filebuf[MAX_FILE_LEN];
    char cmd[512];
    struct stat sb;
    int n;
    char  buff[65535];

    sprintf (cmd, "%s%s", DOWNLOAD_FILE_PATH, DOWNLOAD_FILE_NAME);
    stat (cmd, &sb); //取待下载文件的大小

    //输出HTTP头信息，输出附加下载文件、文件长度以及内容类型
    printf ("Content-Disposition:attachment;filename=%s", DOWNLOAD_FILE_NAME);
    printf ("\r\n");
    printf ("Content-Length:%d", sb.st_size);
    printf ("\r\n");
    //  printf("Content-Type:application/octet-stream %c%c", 13,10); (ascii:"13--\r", "10--\n") 与下一行等同
    printf ("Content-Type:application/octet-stream\r\n");
    printf ("\r\n");

    sprintf (cmd, "%s%s", DOWNLOAD_FILE_PATH, DOWNLOAD_FILE_NAME);
    
    fp = fopen (cmd, "r");
    while ( (n = fread (&buff, sizeof (char), 65535, fp)) > 0)
    {
        fwrite (buff, 1, n, stdout);
    }

    return 1;
}

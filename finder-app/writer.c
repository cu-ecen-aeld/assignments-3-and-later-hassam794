#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <syslog.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[]){
    // openlog("writer", LOG_PID | LOG_CONS, LOG_USER);
    openlog("writer",0, LOG_USER);
    
    int fd;
    if(argc!=3){
        syslog(LOG_ERR, "Parameter mismatch: ./writer <directory> <string>");
        printf("Parameter mismatch: ./writer <directory> <string>\n");
        exit(EXIT_FAILURE);
    }
    
    fd = open(argv[1], O_CREAT | O_WRONLY | O_TRUNC,0744);
    if(fd==-1){
        syslog(LOG_ERR, "Failed to Open or Create a file");
        perror("Error");
        exit(EXIT_FAILURE);
    }


    syslog(LOG_DEBUG,"Writing %s to %s",argv[2],argv[1]);
    ssize_t wr = write(fd,argv[2],strlen(argv[2]));
    if(wr==-1){
        syslog(LOG_ERR,"Unable to write string %s to file %s \n",argv[2],argv[1]);
        perror("Error");
        exit(EXIT_FAILURE);
    } 
    return 0;
}


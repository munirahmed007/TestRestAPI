//
//  SimpleHttpServer.m
//  TestAssignment
//
//  Created by Munir Ahmed on 22/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import "SimpleHttpServer.h"
#import "CBHttpServerController.h"

#include <stdio.h>
#include <errno.h>
#include <sys/socket.h>
#include <resolv.h>
#include <arpa/inet.h>
#include <errno.h>

#define MY_PORT		8080
#define MAXBUF		1024

#define RESPONSE_200 "HTTP/1.0 200 OK\r\nContent-Length: 0\r\n\r\n"
#define RESPONSE_500 "HTTP/1.0 500 Internal Server Error\r\nContent-Length: 0\r\n\r\n"

@implementation SimpleHttpServer

- (void) startServer
{
    int sockfd;
    struct sockaddr_in sock;
    char buffer[MAXBUF];
    
    if ( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0 )
    {
        return;
    }
    
    bzero(&sock, sizeof(sock));
    sock.sin_family = AF_INET;
    sock.sin_port = htons(MY_PORT);
    sock.sin_addr.s_addr = INADDR_ANY;
    
    if ( bind(sockfd, (struct sockaddr*)&sock, sizeof(sock)) != 0 )
    {
        return;
    }
    
    if ( listen(sockfd, 20) != 0 )
    {
    }
    
    int clientfd;
    struct sockaddr_in client_addr;
    int addrlen=sizeof(client_addr);
    
    while (1) {
        
        clientfd = accept(sockfd, (struct sockaddr*)&client_addr, &addrlen);
        printf("%s:%d connected\n", inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));
        
        recv(clientfd, buffer, MAXBUF, 0);
        
        if ([[CBHttpServerController sharedController] timeout])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                close(clientfd);
            });
            return;
        }
        else {
            if ([[CBHttpServerController sharedController] statusCode] == 200){
                send(clientfd, RESPONSE_200, strlen(RESPONSE_200) , 0);
                
            }
            
            else if ([[CBHttpServerController sharedController] statusCode] == 500){
                send(clientfd, RESPONSE_500, strlen(RESPONSE_500) , 0);
            }
            close(clientfd);
        }
    }
    close(sockfd);
}
@end

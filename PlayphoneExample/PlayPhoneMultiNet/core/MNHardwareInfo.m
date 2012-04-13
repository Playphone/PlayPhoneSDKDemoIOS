//
//  MNHardwareInfo.m
//  MultiNet client
//
//  Copyright 2012 PlayPhone. All rights reserved.
//

#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "MNTools.h"
#import "MNHardwareInfo.h"

#define MN_MAC_ADDR_LEN (6)

NSString* MNHardwareGetWiFiMACAddress (void) {
    int           mib[6];
    unsigned int  wiFiIfIndex;
    size_t        buffer_len;
    void         *buffer;
    unsigned char mac_buffer[MN_MAC_ADDR_LEN];

    wiFiIfIndex = if_nametoindex("en0");

    if (wiFiIfIndex == 0) {
        return nil; // unable to find WiFi interface
    }

    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    mib[5] = (int)wiFiIfIndex;

    if (sysctl(mib,MNDeclaredArraySize(mib),NULL,&buffer_len,NULL,0) != 0) {
        return nil; // sysctl failed, unable to get required buffer size
    }

    buffer = malloc(buffer_len);

    if (buffer == NULL) {
        return nil; // out of memory
    }

    NSString* mac = nil;

    if (sysctl(mib,MNDeclaredArraySize(mib),buffer,&buffer_len,NULL,0) == 0) {
        struct if_msghdr   *ifMsgHeader = (struct if_msghdr*)buffer;
        struct sockaddr_dl *sockAddress = (struct sockaddr_dl*)(ifMsgHeader + 1);

        memcpy(mac_buffer,sockAddress->sdl_data + sockAddress->sdl_nlen,sizeof(mac_buffer));
        
        mac = [NSString stringWithFormat: @"%02hhX:%02hhX:%02hhX:%02hhX:%02hhX:%02hhX",
                mac_buffer[0],mac_buffer[1],mac_buffer[2],
                mac_buffer[3],mac_buffer[4],mac_buffer[5]];
    }

    free(buffer);

    return mac;
}

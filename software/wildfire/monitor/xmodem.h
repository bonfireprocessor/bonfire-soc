// XMODEM for eLua

#ifndef __XMODEM_H__
#define __XMODEM_H__

#include "type.h"
#include "platform.h"

// XMODEM constants
#define XMODEM_INITIAL_BUFFER_SIZE    1024
#define XMODEM_INCREMENT_AMMOUNT      512

// xmodem timeout/retry parameters
#define XMODEM_TIMEOUT                4000000
#define XMODEM_RETRY_LIMIT            20

// error return codes
#define XMODEM_ERROR_REMOTECANCEL     (-1)
#define XMODEM_ERROR_OUTOFSYNC        (-2)
#define XMODEM_ERROR_RETRYEXCEED      (-3)
#define XMODEM_ERROR_OUTOFMEM         (-4)

typedef void ( *p_xm_send_func )( u8 );
typedef int ( *p_xm_recv_func )(long);
long xmodem_receive( char *dest,long maxsize );
void xmodem_init( p_xm_send_func send_func, p_xm_recv_func recv_func );

#endif // #ifndef __XMODEM_H__

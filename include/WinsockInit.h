#pragma once

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <winsock2.h>
#include "SocketError.h"

class WinsockInit
{
public:
	WinsockInit()
	{	
		// Info about Winsock init
		WSADATA WsaData;

		int Result;
		Result = WSAStartup(MAKEWORD(2, 2), &WsaData);

		// If Winsock init failed
		if (Result != 0)
		{
			throw SocketError(Result);
		}
	}

	// Copy constructor
	WinsockInit(const WinsockInit& other) = delete;

	// Copy asingment
	WinsockInit& operator = (const WinsockInit& other) = delete;

	~WinsockInit()
	{
		// WS2_32 terminate
		WSACleanup();
	}
};
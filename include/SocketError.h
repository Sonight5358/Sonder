#pragma once

#include <stdexcept>
#include <string>

class SocketError : public std::runtime_error
{
private:
	int errorCode;

public:
	explicit SocketError(int code) 
		: std::runtime_error("socket error: " + std::to_string(code)), errorCode(code)
	{

	}

	int code() const 
	{
		return errorCode;
	}
};
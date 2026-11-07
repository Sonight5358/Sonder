#pragma once

#include <stdexcept>
#include <string>

class HandshakeError : public std::runtime_error
{
public:
	using std::runtime_error::runtime_error;
};
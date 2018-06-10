#include <iostream>
#include <string>

#include "../../../../include/c++/overlay.h"

int main()
{
	SetParam("process", "gfxtest.exe");

	struct _{
		_() : _id(TextCreate("Arial", 12, false, false, 200, 200, 0xFF00FFFF, "Hello world", true, true)) { }
		~_() { TextDestroy(_id); }

		int _id;
	} __;

	std::string input;
	std::cout << "Enter 'exit' to close the application!" << std::endl;

	while (input != "exit")
	{
		std::cout << "Enter new text: ";
		std::getline(std::cin, input, '\n');

		TextSetString(__._id, input.c_str());
	}
}
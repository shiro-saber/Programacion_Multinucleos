#include <iostream> 
#include "thrust_samples.h"

int main(void)
{
	int major = THRUST_MAJOR_VERSION;
	int minor = THRUST_MINOR_VERSION;

	std::cout << "Thrust v" << major << "." << minor << std::endl;
	
	/*generateThrustSequence();
	Thrust_sort();
	Thrust_basic_transformations();
	Thrust_function_transform();
	Thrust_zip_iterator();*/
	Thrust_zip_pointers();
	std::cin.get();
}

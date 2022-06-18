#include <stdlib.h>

class Point {
public:
	Point(int NX, int NY) {
		X = NX;
		Y = NY;
	}

private:
	int X;
	int Y;
};

Point* __main(int X, int Y) {
	return new Point(X, Y);
}
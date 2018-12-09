int testing = 0x1;

int test(int var) {
	int temp = testing;
	testing = var;
	return temp;
}
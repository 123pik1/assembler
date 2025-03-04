#include <stdio.h>
void* wystapienia(void* obszar, unsigned int n);
int main() {
	char obszar[20] = { 1, 2, 3, 4, 5, 6, 7, 7, 7, 7, 8, 9, 10, 11, 12, 13, 3, 4, 5, 6 };
	wystapienia(obszar, 20);
	return 0;
}
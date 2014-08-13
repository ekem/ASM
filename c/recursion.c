#include <stdio.h>

void f(int i) {
	if(i == -3) return;

	printf(">%d\n", i);
	f(i-1);
	printf("%d\n", i);
}

int main() {
	f(5);
	return 0;
}


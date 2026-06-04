#include "stdint.h"

void *memcpy(void *dest, const void *src, uint32_t n) {
	char *destc = dest;
	const char *srcc = src;

	while(n--)
		*destc++ = *srcc++;
	return dest;
}

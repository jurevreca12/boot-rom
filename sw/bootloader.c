#include "spi.h"
#include "flash.h"
#include "mem.h"

#define RAM_ADDR 0x80000000



int main() {
    uint32_t flash_addr;
    uint32_t size;
    uint32_t data_size;
    uint32_t *size_p = &size;
    uint32_t hex_data[64];
    uint8_t status;
    uint32_t *dest_addr;

    spi_init();
    
    do {
    	status = flash_init();
    } while (status != 0);
    flash_addr = 0;
    flash_read_memory(flash_addr, (uint8_t *) size_p, 4);
    // printf("Need to load %x bytes!\r\n", size*4);

    data_size = size;
    size *= 4;
    flash_addr += 0x4;
    
    dest_addr = (uint32_t *) RAM_ADDR;
    while(size > 64) {
    	flash_read_memory(flash_addr, (uint8_t *) hex_data, 64);
    	memcpy(dest_addr, hex_data, 64);
    	dest_addr += 16;
    	flash_addr += 64;
    	size -= 64;
    }
    
    if(size != 0) {
    	flash_read_memory(flash_addr, (uint8_t *) hex_data, size);
    	memcpy(dest_addr, hex_data, size);
    }

    goto *(uint32_t *)RAM_ADDR;

    while (1) {
	flash_addr++;
    }
    return 0;
}

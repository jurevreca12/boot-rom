#include "spi.h"
#include "flash.h"
#include "mem.h"

#define RAM_ADDR 0x80000000


int main() {
    uint32_t flash_addr;
    uint32_t num_bytes; // First 4 bytes of flash contain the hex size
    uint8_t  hex_data[64];
    uint8_t  status;
    uint8_t* dest_addr;
    spi_init();
    do {
        status = flash_init();
    } while(status == 0);

    flash_addr = 0;
    flash_read_memory(flash_addr, (uint8_t *)(&num_bytes), 4);
    // printf("Need to load %x bytes!\r\n", num_bytes);
    flash_addr += 0x4;
    
    dest_addr = (uint8_t *) RAM_ADDR;
    while(num_bytes > 64) {
    	flash_read_memory(flash_addr, (uint8_t *) hex_data, 64);
    	memcpy(dest_addr, hex_data, 64);
    	dest_addr += 64;
    	flash_addr += 64;
    	num_bytes -= 64;
    }
    
    if(num_bytes != 0) {
    	flash_read_memory(flash_addr, (uint8_t *) hex_data, num_bytes);
    	memcpy(dest_addr, hex_data, num_bytes);
    }

    goto *(uint32_t *)RAM_ADDR;

    while (1) {
	flash_addr++;
    }
    return 0;
}

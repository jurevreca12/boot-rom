#pragma once

#include <stdint.h>

#define READ_ID 0x9E
#define READ    0x03

uint8_t flash_init();
void flash_read_memory(uint32_t start_addr, uint8_t *data, uint32_t num_of_data);
void flash_send_address(uint32_t addr);

#pragma once

#include "stdint.h"

#define SPI_TX_DATA_REG_OFFSET 		0
#define SPI_RX_DATA_REG_OFFSET 		4
#define SPI_DIV_CLK_REG_OFFSET		8
#define SPI_SS_REG_OFFSET		12
#define SPI_CTRL_REG_OFFSET		16

#define SPI_START_WRITING		0x1
#define SPI_START_READING		0x2
#define SPI_DONE			0x8

void spi_init();
void spi_select(uint8_t slave);
void spi_unselect();
void spi_write(uint8_t data);
void spi_read(uint8_t *data, uint8_t bytes);

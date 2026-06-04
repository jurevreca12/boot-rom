#include "spi.h"
#include "config.h"
#include "util.h"

// SPI Divisor calculation
#define SPI_DIVISOR(clk_freq_i, spi_freq_i) ((clk_freq_i) / (spi_freq_i * 2) - 1)

void spi_init() {
    // SPI Divisor assignment
    const uint16_t divisor = SPI_DIVISOR(CLK_FREQ, SPI_FREQ);
    
    // Set divisior to SPI div clk reg
    *reg8(SPI_BASE_ADDR, SPI_DIV_CLK_REG_OFFSET) = divisor;

    // Clear control register
    *reg8(SPI_BASE_ADDR, SPI_CTRL_REG_OFFSET) = 0x0;
}

void spi_select(uint8_t slave) {
    // Set slave select
    *reg8(SPI_BASE_ADDR, SPI_SS_REG_OFFSET) = slave;
}

void spi_unselect() {
    // Clear slave select
    *reg8(SPI_BASE_ADDR, SPI_SS_REG_OFFSET) = 0x0;
}

// Assumes the caller takes care of driving slave select
void spi_write(uint8_t data) {
    // Set data to TX data register
    *reg8(SPI_BASE_ADDR, SPI_TX_DATA_REG_OFFSET) = data;

    // Start SPI transaction
    *reg8(SPI_BASE_ADDR, SPI_CTRL_REG_OFFSET) = SPI_START_WRITING;

    // Wait for SPI done transaction
    while (*reg8(SPI_BASE_ADDR, SPI_CTRL_REG_OFFSET) != SPI_DONE);

    // Acknowledge SPI done transaction
    *reg8(SPI_BASE_ADDR, SPI_CTRL_REG_OFFSET) = 0x0;
}

// Assumes the caller takes care of driving slave select
void spi_read(uint8_t *data, uint8_t bytes) {
    
    for(uint8_t i = 0; i < bytes; i++) {
        // Start reading on SPI
        *reg8(SPI_BASE_ADDR, SPI_CTRL_REG_OFFSET) = SPI_START_READING;

        // Wait for SPI transaction to complete
        while (*reg8(SPI_BASE_ADDR, SPI_CTRL_REG_OFFSET) != SPI_DONE);

        // Acknowledge SPI done transaction
        *reg8(SPI_BASE_ADDR, SPI_CTRL_REG_OFFSET) = 0x0;

        // Get data from RX register
        data[i] = *reg8(SPI_BASE_ADDR, SPI_RX_DATA_REG_OFFSET);
    }    
}

//-----------------------------------------------------------------------------
// Title         : ROM_MODULE
//-----------------------------------------------------------------------------
// File          : test_rom.sv
//-----------------------------------------------------------------------------
// Description :
// Auto-generated bootrom from gen_bootrom.py
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2021 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------

// Auto-generated code
module test_rom #(
    parameter ADDR_WIDTH=32,
    parameter DATA_WIDTH=32
) (
   input logic                   CLK,
   input logic                   CEN,
   input logic  [ADDR_WIDTH-1:0] A,
   output logic [DATA_WIDTH-1:0] Q
);

    localparam   NUM_WORDS = 2**ADDR_WIDTH;
    logic [ADDR_WIDTH-1:0] A_Q;

    const logic [6:0][DATA_WIDTH-1:0] MEM = {
	32'b00000000000000000000000000000000,
        32'b00000000000000000000000000000000,
        32'b00000000000000000000000000000000,
        32'b00000000000000000000000000000000,
        32'b00000000000000000000000000000000,
        32'b00000000000000000000000000000000,
        32'b00000000000000000000000000000000
    };

    always_ff @(posedge CLK)
    begin
      if (CEN == 1'b0)
        A_Q <= A;
    end

    assign Q = MEM[A_Q];

endmodule

module obi_rom #(
  parameter  int ADDR_WIDTH=32,
  parameter  int DATA_WIDTH=32,
  parameter  int MEM_SIZE_WORDS=256,
  localparam int NBytes=(DATA_WIDTH / 8)
) (
  input  logic                  clk_i,
  input  logic                  rstn_i,

  input  logic                  obi_areq_i,
  output logic                  obi_agnt_o,
  input  logic [ADDR_WIDTH-1:0] obi_aaddr_i,
  input  logic [DATA_WIDTH-1:0] obi_awdata_i,

  input  logic                  obi_awe_i,
  input  logic [NBytes-1:0]     obi_abe_i,

  output logic                  obi_rvalid_o,
  input  logic                  obi_rready_i,
  output logic [DATA_WIDTH-1:0] obi_rdata_o,
  output logic                  obi_err_o
);
  localparam int MemAddrWidth=$clog2(MEM_SIZE_WORDS);

  // OBI states
  typedef enum logic {
    eOBI_IDLE,      // Waiting for instructions
    eOBI_READING    // OBI read transfer
  } obi_state_t;

  obi_state_t obi_state, obi_state_next;

  logic obi_a_fire, obi_r_fire, obi_a_read, obi_a_write;
  logic obi_started_reading, obi_done;
  logic obi_err;

  assign obi_a_fire = obi_areq_i   && obi_agnt_o;
  assign obi_r_fire = obi_rvalid_o && obi_rready_i;
  assign obi_a_read = obi_a_fire   && ~obi_awe_i; // What happens on write?
  assign obi_a_write = obi_a_fire  &&  obi_awe_i;

  assign obi_err =  obi_a_write || (obi_a_read && (obi_aaddr_i[MemAddrWidth+1:2] >= MEM_SIZE_WORDS));

  register obi_err_reg (.clk(clk_i), .rstn(rstn_i), .ce(obi_a_fire), .in(obi_err), .out(obi_err_o));
  assign obi_agnt_o   = (obi_state == eOBI_IDLE);
  assign obi_rvalid_o = (obi_state == eOBI_READING);

  bootrom #(
    .ADDR_WIDTH     (MemAddrWidth),
    .DATA_WIDTH     (DATA_WIDTH)
  ) bootrom_inst (
      .CLK          (clk_i),
      .CEN          (obi_a_read),
      .A            (obi_aaddr_i[MemAddrWidth+1:2]),
      .Q            (obi_rdata_o)
  );

  always_comb begin
    obi_started_reading = (obi_state == eOBI_IDLE)    && obi_a_fire;
    obi_done            = (obi_state == eOBI_READING) && obi_r_fire;
  end

  always_comb begin
    obi_state_next = obi_started_reading ? eOBI_READING : obi_state;
    obi_state_next = obi_done            ? eOBI_IDLE    : obi_state_next;
  end

  register #(.DTYPE(obi_state_t), .RESET_VALUE(eOBI_IDLE)) obi_state_inst (.clk(clk_i), .rstn(rstn_i), .ce(1'b1), .in(obi_state_next), .out(obi_state));

endmodule


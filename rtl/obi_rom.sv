module obi_rom #(
  parameter  int ADDR_WIDTH=32,
  parameter  int DATA_WIDTH=32,
  parameter  int MEM_SIZE_WORDS=1024
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
  output logic [DATA_WIDTH-1:0] obi_rdata_o
);

  localparam int NBytes=(DATA_WIDTH / 8);
  localparam int MemAddrWidth=$clog2(MEM_SIZE_WORDS);

  // OBI states
  typedef enum reg [0:0] {
    eOBI_IDLE,       // Waiting for instructions
    eOBI_READING    // OBI read transfer
  } obi_state_t;

  obi_state_t obi_state, obi_state_next;

  logic obi_a_fire, obi_a_read;
  logic obi_started_reading, obi_done;

  logic [DATA_WIDTH-1:0] obi_read_value;

  logic [DATA_WIDTH-1:0] mem_data;
  logic [ADDR_WIDTH-1:0] mem_addr;

  assign obi_a_fire = obi_areq_i && obi_agnt_o;
  assign obi_a_read = obi_a_fire && ~obi_awe_i; // What happens on write?

  register #(.DTYPE(logic[DATA_WIDTH-1:0])) obi_rdata_o_inst (.clk(clk_i), .rstn(rstn_i && obi_a_read), .ce(obi_a_read), .in(obi_read_value), .out(obi_rdata_o));

  
  assign obi_read_value = mem_data;
  assign obi_agnt_o = (obi_state == eOBI_IDLE);
  assign obi_rvalid_o = (obi_state == eOBI_READING);

  always_comb begin
    obi_started_reading = obi_state == eOBI_IDLE && obi_a_read;
    obi_done            = obi_rvalid_o && obi_rready_i;
  end

  always_comb begin
    obi_state_next = obi_started_reading ? eOBI_READING : obi_state;
    obi_state_next = obi_done            ? eOBI_IDLE    : obi_state_next;
  end

  register #(.DTYPE(obi_state_t), .RESET_VALUE(eOBI_IDLE)) obi_state_inst (.clk(clk_i), .rstn(rstn_i), .ce(1'b1), .in(obi_state_next), .out(obi_state));

  bootrom #(
    .ADDR_WIDTH     (ADDR_WIDTH),
    .DATA_WIDTH     (DATA_WIDTH)
    ) _mem_ (
      .CLK          (clk_i),
      .CEN          (obi_a_read),
      .A            (mem_addr),
      .Q            (mem_data)
  );

endmodule;

module miriscv_tracing (

    // Clock and Reset
    input  logic         clk_i,
    input  logic         arstn_i,

    // Boot address
    input  logic  [31:0] boot_addr_i,

    // Instruction memory interface
    input  logic         instr_rvalid_i,
    input  logic  [31:0] instr_rdata_i,
    output logic         instr_req_o,
    output logic  [31:0] instr_addr_o,

    // Data memory interface
    input   logic        data_rvalid_i,
    input   logic [31:0] data_rdata_i,
    output  logic        data_req_o,
    output  logic        data_we_o,
    output  logic [ 3:0] data_be_o,
    output  logic [31:0] data_addr_o,
    output  logic [31:0] data_wdata_o
);

    logic [ 1 - 1:0] rvfi_valid;
    logic [64 - 1:0] rvfi_order;
    logic [32 - 1:0] rvfi_insn;
    logic [ 1 - 1:0] rvfi_trap;
    logic [ 1 - 1:0] rvfi_halt;
    logic [ 1 - 1:0] rvfi_intr;
    logic [ 2 - 1:0] rvfi_mode;
    logic [ 2 - 1:0] rvfi_ixl;
    logic [ 5 - 1:0] rvfi_rs1_addr;
    logic [ 5 - 1:0] rvfi_rs2_addr;
    logic [ 5 - 1:0] rvfi_rs3_addr;
    logic [32 - 1:0] rvfi_rs1_rdata;
    logic [32 - 1:0] rvfi_rs2_rdata;
    logic [32 - 1:0] rvfi_rs3_rdata;
    logic [ 5 - 1:0] rvfi_rd_addr;
    logic [32 - 1:0] rvfi_rd_wdata;
    logic [32 - 1:0] rvfi_pc_rdata;
    logic [32 - 1:0] rvfi_pc_wdata;
    logic [32 - 1:0] rvfi_mem_addr;
    logic [ 4 - 1:0] rvfi_mem_rmask;
    logic [ 4 - 1:0] rvfi_mem_wmask;
    logic [32 - 1:0] rvfi_mem_rdata;
    logic [32 - 1:0] rvfi_mem_wdata;

  miriscv_core #(
    .RVFI                   ( 1              )
  ) u_miriscv_core (

      // Clock and Reset
      .clk_i                ( clk_i          ),
      .arstn_i              ( arstn_i        ),

      // Boot address
      .boot_addr_i          ( boot_addr_i    ),

      // Instruction memory interface
      .instr_rvalid_i       ( instr_rvalid_i ),
      .instr_rdata_i        ( instr_rdata_i  ),
      .instr_req_o          ( instr_req_o    ),
      .instr_addr_o         ( instr_addr_o   ),

      // Data memory interface
      .data_rvalid_i        ( data_rvalid_i  ),
      .data_rdata_i         ( data_rdata_i   ),
      .data_req_o           ( data_req_o     ),
      .data_we_o            ( data_we_o      ),
      .data_be_o            ( data_be_o      ),
      .data_addr_o          ( data_addr_o    ),
      .data_wdata_o         ( data_wdata_o   ),

      // RVFI
      .rvfi_valid_o         ( rvfi_valid     ),
      .rvfi_order_o         ( rvfi_order     ),
      .rvfi_insn_o          ( rvfi_insn      ),
      .rvfi_trap_o          ( rvfi_trap      ),
      .rvfi_halt_o          ( rvfi_halt      ),
      .rvfi_intr_o          ( rvfi_intr      ),
      .rvfi_mode_o          ( rvfi_mode      ),
      .rvfi_ixl_o           ( rvfi_ixl       ),
      .rvfi_rs1_addr_o      ( rvfi_rs1_addr  ),
      .rvfi_rs2_addr_o      ( rvfi_rs2_addr  ),
      .rvfi_rs1_rdata_o     ( rvfi_rs1_rdata ),
      .rvfi_rs2_rdata_o     ( rvfi_rs2_rdata ),
      .rvfi_rd_addr_o       ( rvfi_rd_addr   ),
      .rvfi_rd_wdata_o      ( rvfi_rd_wdata  ),
      .rvfi_pc_rdata_o      ( rvfi_pc_rdata  ),
      .rvfi_pc_wdata_o      ( rvfi_pc_wdata  ),
      .rvfi_mem_addr_o      ( rvfi_mem_addr  ),
      .rvfi_mem_rmask_o     ( rvfi_mem_rmask ),
      .rvfi_mem_wmask_o     ( rvfi_mem_wmask ),
      .rvfi_mem_rdata_o     ( rvfi_mem_rdata ),
      .rvfi_mem_wdata_o     ( rvfi_mem_wdata )

  );

  ibex_tracer u_ibex_tracer (

      .clk_i          ( clk_i          ),
      .rst_ni         ( arstn_i        ),

      .hart_id_i      ( 'b0            ),

      .rvfi_valid     ( rvfi_valid     ),
      .rvfi_order     ( rvfi_order     ),
      .rvfi_insn      ( rvfi_insn      ),
      .rvfi_trap      ( rvfi_trap      ),
      .rvfi_halt      ( rvfi_halt      ),
      .rvfi_intr      ( rvfi_intr      ),
      .rvfi_mode      ( rvfi_mode      ),
      .rvfi_ixl       ( rvfi_ixl       ),
      .rvfi_rs1_addr  ( rvfi_rs1_addr  ),
      .rvfi_rs2_addr  ( rvfi_rs2_addr  ),
      .rvfi_rs3_addr  (                ),
      .rvfi_rs1_rdata ( rvfi_rs1_rdata ),
      .rvfi_rs2_rdata ( rvfi_rs2_rdata ),
      .rvfi_rs3_rdata (                ),
      .rvfi_rd_addr   ( rvfi_rd_addr   ),
      .rvfi_rd_wdata  ( rvfi_rd_wdata  ),
      .rvfi_pc_rdata  ( rvfi_pc_rdata  ),
      .rvfi_pc_wdata  ( rvfi_pc_wdata  ),
      .rvfi_mem_addr  ( rvfi_mem_addr  ),
      .rvfi_mem_rmask ( rvfi_mem_rmask ),
      .rvfi_mem_wmask ( rvfi_mem_wmask ),
      .rvfi_mem_rdata ( rvfi_mem_rdata ),
      .rvfi_mem_wdata ( rvfi_mem_wdata )

  );

endmodule

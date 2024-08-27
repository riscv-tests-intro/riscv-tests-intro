interface miriscv_rvfi_intf (
    input logic clk,
    input logic arst_n
);

    // RVFI signals
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

    function void get_bus_status (
        miriscv_test_pkg::miriscv_rvfi_item t
    );
      t.rvfi_valid      = rvfi_valid;
      t.rvfi_order      = rvfi_order;
      t.rvfi_insn       = rvfi_insn;
      t.rvfi_trap       = rvfi_trap;
      t.rvfi_halt       = rvfi_halt;
      t.rvfi_intr       = rvfi_intr;
      t.rvfi_mode       = rvfi_mode;
      t.rvfi_ixl        = rvfi_ixl;
      t.rvfi_rs1_addr   = rvfi_rs1_addr;
      t.rvfi_rs2_addr   = rvfi_rs2_addr;
      t.rvfi_rs3_addr   = rvfi_rs3_addr;
      t.rvfi_rs1_rdata  = rvfi_rs1_rdata;
      t.rvfi_rs2_rdata  = rvfi_rs2_rdata;
      t.rvfi_rs3_rdata  = rvfi_rs3_rdata;
      t.rvfi_rd_addr    = rvfi_rd_addr;
      t.rvfi_rd_wdata   = rvfi_rd_wdata;
      t.rvfi_pc_rdata   = rvfi_pc_rdata;
      t.rvfi_pc_wdata   = rvfi_pc_wdata;
      t.rvfi_mem_addr   = rvfi_mem_addr;
      t.rvfi_mem_rmask  = rvfi_mem_rmask;
      t.rvfi_mem_wmask  = rvfi_mem_wmask;
      t.rvfi_mem_rdata  = rvfi_mem_rdata;
      t.rvfi_mem_wdata  = rvfi_mem_wdata;
    endfunction

    task wait_clks(input int num);
      repeat (num) @(posedge clk);
    endtask

    task wait_neg_clks(input int num);
      repeat (num) @(negedge clk);
    endtask
  
endinterface
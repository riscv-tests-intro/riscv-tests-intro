class miriscv_rvfi_item;

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

endclass
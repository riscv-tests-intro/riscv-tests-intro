class miriscv_mem_item;

    logic        instr_rvalid;
    logic [31:0] instr_rdata;
    logic        instr_req;
    logic [31:0] instr_addr;

    logic        data_rvalid;
    logic [31:0] data_rdata;
    logic        data_req;
    logic [31:0] data_wdata;
    logic [31:0] data_addr;
    logic        data_we;
    logic [ 3:0] data_be;

endclass
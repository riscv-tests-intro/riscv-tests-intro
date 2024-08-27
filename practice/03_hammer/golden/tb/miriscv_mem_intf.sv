interface miriscv_mem_intf (
    input logic clk,
    input logic arst_n
);

    // Instruction memory signals
    logic        instr_rvalid;
    logic [31:0] instr_rdata;
    logic        instr_req;
    logic [31:0] instr_addr;

    // Data memory signals
    logic        data_rvalid;
    logic [31:0] data_rdata;
    logic        data_req;
    logic [31:0] data_wdata;
    logic [31:0] data_addr;
    logic        data_we;
    logic [ 3:0] data_be;

    function void get_bus_status (
        miriscv_test_pkg::miriscv_mem_item t
    );
        t.instr_rvalid = instr_rvalid;
        t.instr_rdata  = instr_rdata;
        t.instr_req    = instr_req;
        t.instr_addr   = instr_addr;
        t.data_rvalid  = data_rvalid;
        t.data_rdata   = data_rdata;
        t.data_req     = data_req;
        t.data_wdata   = data_wdata;
        t.data_addr    = data_addr;
        t.data_we      = data_we;
        t.data_be      = data_be;
    endfunction

    task wait_clks(input int num);
      repeat (num) @(posedge clk);
    endtask

    task wait_neg_clks(input int num);
      repeat (num) @(negedge clk);
    endtask
  
endinterface
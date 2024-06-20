module miriscv_tb_top;

    import miriscv_test_pkg::*;

    // Clock period
    parameter CLK_PERIOD = 10;

    // Clock and reset
    logic clk;
    logic arstn;

    // Interface
    miriscv_mem_intf intf(clk, arstn);

    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2) clk = ~clk;
        end
    end

    initial begin
        arstn <= 0;
        repeat(10) @(posedge clk);
        arstn <= 1;
    end

    // DUT
    miriscv_tracing DUT (

        // Clock and reset
        .clk_i          ( clk               ),
        .arstn_i        ( arstn             ),

        // Boot address
        .boot_addr_i    ( `BOOT_ADDR        ),

        // Instruction memory interface
        .instr_rvalid_i ( intf.instr_rvalid ),
        .instr_rdata_i  ( intf.instr_rdata  ),
        .instr_req_o    ( intf.instr_req    ),
        .instr_addr_o   ( intf.instr_addr   ),

        // Data memory interface
        .data_rvalid_i  ( intf.data_rvalid ),
        .data_rdata_i   ( intf.data_rdata  ),
        .data_req_o     ( intf.data_req    ),
        .data_we_o      ( intf.data_we     ),
        .data_be_o      ( intf.data_be     ),
        .data_addr_o    ( intf.data_addr   ),
        .data_wdata_o   ( intf.data_wdata  )

    );

    initial begin
        string       dump;
        miriscv_test test;
        // Save waveforms
        if(!$value$plusargs("dump=%s", dump)) begin
            dump = "waves.vcd";
        end
        $dumpfile(dump);
        $dumpvars;
        // Create and run test
        test = new(intf);
        test.run();
    end

endmodule

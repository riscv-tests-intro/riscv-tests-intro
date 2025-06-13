module miriscv_tb_top;

    import miriscv_test_pkg::*;

    // Clock period
    parameter CLK_PERIOD = 10;

    // Clock and reset
    logic clk;
    logic arstn;

    // Interfaces
    miriscv_mem_intf  mem_intf (clk, arstn);
    miriscv_rvfi_intf rvfi_intf(clk, arstn);

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
    miriscv_core #(
        .RVFI                 ( 1                        )
    ) u_miriscv_core (

        // Clock and Reset
        .clk_i                ( clk                      ),
        .arstn_i              ( arstn                    ),

        // Boot address
        .boot_addr_i          ( `BOOT_ADDR               ),

        // Instruction memory interface
        .instr_rvalid_i       ( mem_intf.instr_rvalid    ),
        .instr_rdata_i        ( mem_intf.instr_rdata     ),
        .instr_req_o          ( mem_intf.instr_req       ),
        .instr_addr_o         ( mem_intf.instr_addr      ),

        // Data memory interface
        .data_rvalid_i        ( mem_intf.data_rvalid     ),
        .data_rdata_i         ( mem_intf.data_rdata      ),
        .data_req_o           ( mem_intf.data_req        ),
        .data_we_o            ( mem_intf.data_we         ),
        .data_be_o            ( mem_intf.data_be         ),
        .data_addr_o          ( mem_intf.data_addr       ),
        .data_wdata_o         ( mem_intf.data_wdata      ),

        // RVFI
        .rvfi_valid_o         ( rvfi_intf.rvfi_valid     ),
        .rvfi_order_o         ( rvfi_intf.rvfi_order     ),
        .rvfi_insn_o          ( rvfi_intf.rvfi_insn      ),
        .rvfi_trap_o          ( rvfi_intf.rvfi_trap      ),
        .rvfi_halt_o          ( rvfi_intf.rvfi_halt      ),
        .rvfi_intr_o          ( rvfi_intf.rvfi_intr      ),
        .rvfi_mode_o          ( rvfi_intf.rvfi_mode      ),
        .rvfi_ixl_o           ( rvfi_intf.rvfi_ixl       ),
        .rvfi_rs1_addr_o      ( rvfi_intf.rvfi_rs1_addr  ),
        .rvfi_rs2_addr_o      ( rvfi_intf.rvfi_rs2_addr  ),
        .rvfi_rs1_rdata_o     ( rvfi_intf.rvfi_rs1_rdata ),
        .rvfi_rs2_rdata_o     ( rvfi_intf.rvfi_rs2_rdata ),
        .rvfi_rd_addr_o       ( rvfi_intf.rvfi_rd_addr   ),
        .rvfi_rd_wdata_o      ( rvfi_intf.rvfi_rd_wdata  ),
        .rvfi_pc_rdata_o      ( rvfi_intf.rvfi_pc_rdata  ),
        .rvfi_pc_wdata_o      ( rvfi_intf.rvfi_pc_wdata  ),
        .rvfi_mem_addr_o      ( rvfi_intf.rvfi_mem_addr  ),
        .rvfi_mem_rmask_o     ( rvfi_intf.rvfi_mem_rmask ),
        .rvfi_mem_wmask_o     ( rvfi_intf.rvfi_mem_wmask ),
        .rvfi_mem_rdata_o     ( rvfi_intf.rvfi_mem_rdata ),
        .rvfi_mem_wdata_o     ( rvfi_intf.rvfi_mem_wdata )

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
        test = new(mem_intf, rvfi_intf);
        test.run();
    end

endmodule
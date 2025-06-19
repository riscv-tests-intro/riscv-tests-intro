class miriscv_compare_logger;

    protected int log_fd;

    function new(string log);
        log_fd = $fopen(log, "w");
        log_fd.write("\nMIRISCV vs Spike step-and-compare log\n");
    endfunction

    virtual function void log(
        time                retire_time,
        miriscv_insn_info_s info,
        miriscv_rvfi_item   rvfi_trans,
        bit                 compare_result
    );
        string msg;
        msg = $sformatf("Retire time: %t", retire_time);
        msg = {msg, $sformatf("\nSpike PC: %8h insn: %8h (%s) \nMIRISCV PC: %8h insn: %8h",
            cur_insn_info.pc, cur_insn_info.bits, cur_insn_info.str, t.rvfi_pc_rdata, t.rvfi_insn)};
        msg = {msg, $sformatf("\nSpike RD x%0d: %8h \nMIRISCV RD x%0d: %8h",
            t.rvfi_rd_addr, cur_insn_info.rd, t.rvfi_rd_addr, t.rvfi_rd_wdata)};
        msg = compare_result ? {"\n\nPASSED at ", msg} : {"\n\nFAILED at ", msg};
        log_fd.write(msg);
    endfunction

endclass

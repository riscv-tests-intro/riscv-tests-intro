class miriscv_scoreboard;

    mailbox#(miriscv_rvfi_item) rvfi_mbx;

    chandle hammer;

    protected int unsigned retire_cnt;

    protected miriscv_insn_info_s cur_insn_info;

    protected miriscv_compare_logger logger;

    virtual function void init(string elf, bit [31:0] pc);
        string compare_log;
        hammer = hammer_init(elf);
        hammer_set_PC(hammer, pc);
        $display("Spike was initialized with PC: %8h", pc);
        if($value$plusargs("compare_log=%s", compare_log)) begin
            logger = new(compare_log);
        end
    endfunction

    virtual function int unsigned get_retire_cnt();
        return retire_cnt;
    endfunction

    virtual function miriscv_insn_info_s get_cur_insn_info();
        return cur_insn_info;
    endfunction

    virtual task run();
      miriscv_rvfi_item t; bit result;
      forever begin
          rvfi_mbx.get(t);
          result = check_pc_and_instr(t);
          hammer_single_step(hammer);
          result = result | check_rd(t);
          if(logger) logger.log($time(), cur_insn_info, t, result);
          retire_cnt = retire_cnt + 1;
      end
    endtask

    virtual function bit check_pc_and_instr(miriscv_rvfi_item t);
        bit result = 1; string msg;
        cur_insn_info.pc   = hammer_get_PC       (hammer);
        cur_insn_info.bits = hammer_get_insn_bits(hammer);
        cur_insn_info.str  = hammer_get_insn_str (hammer);
        if( cur_insn_info.pc !== t.rvfi_pc_rdata ) begin
            msg = "\nPC mismatch! "; result = 0;
        end
        if( cur_insn_info.bits !== t.rvfi_insn ) begin
            msg = {msg, "Instruction mismatch!"}; result = 0;
        end
        if( !result ) begin
            msg = {msg, $sformatf("\nSpike PC: %8h insn: %8h (%s) \nMIRISCV PC: %8h insn: %8h",
                cur_insn_info.pc, cur_insn_info.bits, cur_insn_info.str, t.rvfi_pc_rdata, t.rvfi_insn)};
            $display(msg);
        end
        return result;
    endfunction

    virtual function bit check_rd(miriscv_rvfi_item t);
        bit result = 1; string msg;
        cur_insn_info.rd = hammer_get_gpr(hammer, t.rvfi_rd_addr);
        if( cur_insn_info.rd !== t.rvfi_rd_wdata ) begin
            msg = "\nRD mismatch! ";
            msg = {msg, $sformatf("PC: %8h insn: %8h (%s)",
                cur_insn_info.pc, cur_insn_info.bits, cur_insn_info.str)};
            result = 0;
        end
        if( !result ) begin
            msg = {msg, $sformatf("\nSpike x%0d: %8h \nMIRISCV x%0d: %8h",
                t.rvfi_rd_addr, cur_insn_info.rd, t.rvfi_rd_addr, t.rvfi_rd_wdata)};
            $display(msg);
        end
        return result;
    endfunction
  
endclass
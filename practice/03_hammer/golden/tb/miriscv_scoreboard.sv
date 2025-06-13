class miriscv_scoreboard;

  mailbox#(miriscv_rvfi_item) rvfi_mbx;

  chandle hammer;

  protected int unsigned retire_cnt;

  virtual function void init(string elf, bit [31:0] pc);
    hammer = hammer_init(elf);
    hammer_set_PC(hammer, pc);
    $display("Hammer was initialized with PC: %8h", pc);
  endfunction

  virtual function int unsigned get_retire_cnt();
    return retire_cnt;
  endfunction

  virtual task run();
    miriscv_rvfi_item t; bit result;
    forever begin
      rvfi_mbx.get(t);
      result = check_pc_and_instr(t);
      hammer_single_step(hammer);
      if( result ) void'(check_rd(t));
      retire_cnt = retire_cnt + 1;
    end
  endtask

  virtual function bit check_pc_and_instr(miriscv_rvfi_item t);
    bit result = 1; string msg;
    bit [31:0] hammer_pc, hammer_insn;
    hammer_pc   = hammer_get_PC(hammer);
    hammer_insn = hammer_get_insn_bits(hammer);
    if( hammer_pc !== t.rvfi_pc_rdata ) begin
      msg = "\nPC mismatch! "; result = 0;
    end
    if( hammer_insn !== t.rvfi_insn ) begin
      msg = {msg, "Instruction mismatch!"}; result = 0;
    end
    if( !result ) begin
      msg = {msg, $sformatf("\nHammer  PC: %8h insn: %8h \nMIRISCV PC: %8h insn: %8h",
        hammer_pc, hammer_insn, t.rvfi_pc_rdata, t.rvfi_insn)};
      $display(msg);
    end
    return result;
  endfunction

  virtual function bit check_rd(miriscv_rvfi_item t);
    bit result = 1; string msg;
    bit [31:0] hammer_rd;
    hammer_rd = hammer_get_gpr(hammer, t.rvfi_rd_addr);
    if( hammer_rd !== t.rvfi_rd_wdata ) begin
      msg = "\nRD mismatch! ";
      msg = {msg, $sformatf("PC: %8h insn: %8h",
        t.rvfi_pc_rdata, t.rvfi_insn)};
      result = 0;
    end
    if( !result ) begin
      msg = {msg, $sformatf("\nHammer  x%0d: %8h \nMIRISCV x%0d: %8h",
        t.rvfi_rd_addr, hammer_rd, t.rvfi_rd_addr, t.rvfi_rd_wdata)};
      $display(msg);
    end
    return result;
  endfunction
  
endclass
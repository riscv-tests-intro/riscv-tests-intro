class miriscv_test;

            bit               [31:0] signature_addr;
            int unsigned             timeout_in_cycles = 1000000;

            miriscv_mem_agent        mem_slv;
            mem_model                mem;
            miriscv_mem_seq          mem_slv_seq;
    virtual miriscv_mem_intf         mem_vif;

            miriscv_rvfi_monitor     rvfi_mon;
    virtual miriscv_rvfi_intf        rvfi_vif;

            miriscv_scoreboard       scb;

    function new(
      virtual miriscv_mem_intf  mem_vif,
      virtual miriscv_rvfi_intf rvfi_vif,
    );
      mailbox#(miriscv_mem_item ) mem_reactive_mbx;
      mailbox#(miriscv_mem_item ) mem_slv_mbx;
      mailbox#(miriscv_rvfi_item) rvfi_mbx;
      this.mem_vif             = mem_vif;
      mem                      = new();
      mem_slv                  = new(mem_vif);
      mem_slv_seq              = new();
      mem_reactive_mbx         = new();
      mem_slv_mbx              = new();
      mem_slv.mon.mbx          = mem_reactive_mbx;
      mem_slv_seq.reactive_mbx = mem_reactive_mbx;
      mem_slv_seq.mem          = mem;
      mem_slv.drv.mbx          = mem_slv_mbx;
      mem_slv_seq.mbx          = mem_slv_mbx;
      this.rvfi_vif            = rvfi_vif;
      rvfi_mon                 = new(rvfi_vif);
      scb                      = new();
      rvfi_mbx                 = new();
      rvfi_mon.mbx             = rvfi_mbx;
      scb.rvfi_mbx             = rvfi_mbx;
    endfunction

    function void load_binary_to_mem();
      string      bin;
      bit [ 7:0]  r8;
      bit [31:0]  addr = `BOOT_ADDR;
      int         f_bin;
      void'($value$plusargs("bin=%0s", bin));
      f_bin = $fopen(bin, "rb");
      if (!f_bin) $fatal("Cannot open file %0s", bin);
      while ($fread(r8, f_bin)) begin
        `ifdef MEM_DEBUG
          $display("Init mem [0x%h] = 0x%0h", addr, r8);
        `endif
        mem.write(addr, r8);
        addr++;
      end
    endfunction

    function void hammer_init();
      string elf;
      if(!$value$plusargs("elf=%0s", elf)) begin
        $fatal("Provide hammer elf via +elf plusarg!");
      end
      else begin
        scb.init(elf, `BOOT_ADDR);
      end
    endfunction
    
    virtual task timeout();
      string timeout;
      if($value$plusargs("timeout_in_cycles=%0s", timeout)) begin
        timeout_in_cycles = timeout.atoi();
      end
      repeat(timeout_in_cycles) mem_vif.wait_clks(1);
      $display("%0t Test was finished by timeout", $time());
      $display("Amount of retired instructions checked: %0d", scb.get_retire_cnt());
      $finish();
    endtask

    virtual function void get_signature_addr();
      if(!$value$plusargs("signature_addr=%0h", signature_addr))
        $fatal("You must provide 'signature_addr' via commandline!");
    endfunction

    virtual function bit test_done_cond(miriscv_mem_item t);
      return (
        (t.data_req   ==           1'b1) && 
        (t.data_addr  == signature_addr) && 
        (t.data_we    ==           1'b1) && 
        (t.data_wdata ==          32'b1)
      );
    endfunction

    virtual task wait_for_test_done();
      miriscv_mem_item t = new();
      wait(mem_vif.arst_n === 1);
      forever begin
        mem_vif.wait_clks(1);
        mem_slv.mon.get_data(t);
        if(test_done_cond(t) == 1) break;
      end
      repeat(10) mem_vif.wait_clks(1);
      $display("Test end condition was detected. Test done!");
      $display("Amount of retired instructions checked: %0d", scb.get_retire_cnt());
      $finish();
    endtask
    
    virtual task run();
      get_signature_addr();
      load_binary_to_mem();
      hammer_init();
      fork
        mem_slv.run();
        mem_slv_seq.run();
        rvfi_mon.run();
        scb.run();
        timeout();
        wait_for_test_done();
      join
    endtask

endclass

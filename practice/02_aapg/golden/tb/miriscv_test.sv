class miriscv_test;

            bit               [31:0] signature_addr;
            int unsigned             timeout_in_cycles = 1000000;
            miriscv_mem_agent        slv;
            mem_model                mem;
            miriscv_mem_seq          slv_seq;
    virtual miriscv_mem_intf         vif;

    function new(virtual miriscv_mem_intf vif);
        mailbox#(miriscv_mem_item) reactive_mbx;
        mailbox#(miriscv_mem_item) slv_mbx;
        this.vif             = vif;
        slv                  = new(vif);
        mem                  = new();
        slv_seq              = new();
        reactive_mbx         = new();
        slv_mbx              = new();
        slv.mon.mbx          = reactive_mbx;
        slv_seq.reactive_mbx = reactive_mbx;
        slv_seq.mem          = mem;
        slv.drv.mbx          = slv_mbx;
        slv_seq.mbx          = slv_mbx;
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
    
    virtual task timeout();
        string timeout;
        if($value$plusargs("timeout_in_cycles=%0s", timeout)) begin
          timeout_in_cycles = timeout.atoi();
        end
        repeat(timeout_in_cycles) vif.wait_clks(1);
        $display("%0t Test was finished by timeout", $time());
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
        wait(vif.arst_n === 1);
        forever begin
            vif.wait_clks(1);
            slv.mon.get_data(t);
            if(test_done_cond(t) == 1) break;
        end
        repeat(10) vif.wait_clks(1);
        $display("Test end condition was detected. Test done!");
        $finish();
    endtask
    
    virtual task run();
        get_signature_addr();
        load_binary_to_mem();
        fork
            slv.run();
            slv_seq.run();
            timeout();
            wait_for_test_done();
        join
    endtask

endclass

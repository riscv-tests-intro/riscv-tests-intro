class miriscv_mem_monitor;

    virtual miriscv_mem_intf vif;

    mailbox#(miriscv_mem_item) mbx;

    function new(virtual miriscv_mem_intf vif);
        this.vif = vif;
    endfunction
  
    virtual task run();
        wait(vif.arst_n === 1'b1);
        forever begin
            vif.wait_clks(1);
            get_and_put();
        end
    endtask

    virtual task get_and_put();
      miriscv_mem_item t = new();
      get_data(t);
      mbx.put(t);
    endtask

    virtual task get_data(miriscv_mem_item t);
        vif.get_bus_status (t);
    endtask
  
endclass
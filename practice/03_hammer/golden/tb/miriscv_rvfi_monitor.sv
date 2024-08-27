class miriscv_rvfi_monitor;

    virtual miriscv_rvfi_intf vif;

    mailbox#(miriscv_rvfi_item) mbx;

    function new(virtual miriscv_rvfi_intf vif);
      this.vif = vif;
    endfunction
  
    virtual task run();
      wait(vif.arst_n === 1'b1);
      forever begin
        do begin
            vif.wait_clks(1);
        end
        while(vif.rvfi_valid === 1'b0);
        get_and_put();
      end
    endtask

    virtual task get_and_put();
      miriscv_rvfi_item t = new();
      get_data(t);
      mbx.put(t);
    endtask

    virtual task get_data(miriscv_rvfi_item t);
      vif.get_bus_status (t);
    endtask
  
endclass
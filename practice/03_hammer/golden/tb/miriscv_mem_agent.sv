class miriscv_mem_agent;

    miriscv_mem_driver  drv;
    miriscv_mem_monitor mon;

    function new(virtual miriscv_mem_intf vif);
        drv = new(vif);
        mon = new(vif);
    endfunction

    virtual task run();
        fork
            drv.run();
            mon.run();
        join
    endtask
  
endclass  
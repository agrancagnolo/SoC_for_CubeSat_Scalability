(* Blackbox *)
module adc_comp_latch(
   `ifdef USE_POWER_PINS
        inout vccd1,	// User area 1 1.8V supply
        inout vssd1,	// User area 1 digital ground
    `endif
   input wire clk,
   input wire inp,
   input wire inn,
   output wire comp_trig,
   output wire latch_qn,
   output wire latch_q
   );
endmodule

`default_nettype none

`timescale 1 ns / 1 ps

module test_mixer_tb;
	reg clock;
	reg RSTB;
	reg CSB;
	reg power1, power2;
	reg power3, power4;

    wire gpio;
	wire uart_rx;
    wire [37:0] mprj_io;
	wire uart_pulse;
	reg  toggle;
	reg  [3:0] pulse_counter;

	assign uart_rx    =  mprj_io[6];
	assign mprj_io[7] =  toggle;
	assign uart_pulse =  mprj_io[35];

	always #12.5 clock <= (clock === 1'b0); // Frecuencia del clock 40 MHz
	always #500 toggle <= (toggle === 1'b0);// Frecuencia del pulso 1 MHz.
	
	initial begin
		clock  = 0;
		toggle = 0;
		pulse_counter = 5;
	end
		
	initial begin
		
		$dumpfile("test_mixer.vcd");
		$dumpvars(0, test_mixer_tb);

		repeat (400) begin
			repeat (1000) @(posedge clock);
		end
		$display("%c[1;31m",27);
		$display ("Monitor: Timeout, Test Mega-Project IO Ports (RTL) Failed");
		$display("%c[0m",27);
		$finish;
	end
	
	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;  // Force CSB high
		#2000;
		RSTB <= 1'b1;  // Release reset
		#170000;
		CSB = 1'b0;	   // CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	
	always @(posedge uart_pulse) begin
		pulse_counter <= pulse_counter - 1;
		#1 $display("uart_pulse state = %b ", uart_pulse);
		if (pulse_counter == 0) 
		begin
			wait(uart_pulse==1)
			wait(uart_pulse==0)
			wait(uart_pulse==1)
			$display("Fin Test");
			$finish;
		end
	end


	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	assign mprj_io[3] = 1;  // Force CSB high.
	assign mprj_io[0] = 0;  // Disable debug mode
	
	caravan uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (USER_VDD1V8),
		.vccd2	  (USER_VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        .mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("test_mixer.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);
	tbuart tbuart (
		.ser_rx(uart_rx)
	);
endmodule
`default_nettype wire
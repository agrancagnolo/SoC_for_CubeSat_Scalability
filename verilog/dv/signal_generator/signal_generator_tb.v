// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

module signal_generator_tb;
	reg clock;
	reg RSTB;
	reg CSB;
	reg power1, power2;
	reg power3, power4;

    wire gpio;
    wire [37:0] mprj_io;

	wire [2:0] o_result;
	reg i_test;

	
	// Seleccion de valores
	assign o_result    	=  	mprj_io[9:7];  //Out
	assign mprj_io[37] 	= 	i_test; //In
	
	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	//Clock
	always #12.5 clock <= (clock === 1'b0); 
	
	initial begin
		clock  = 0;
		i_test = 1;
	end
		
	initial begin
		
		$dumpfile("signal_generator.vcd");
		$dumpvars(0, signal_generator_tb);

		// Repeat cycles of 1000⁵ clock edges as needed to complete testbench
		repeat (500) begin
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

	
	always @(posedge o_result[2]) begin
		#1
		$display("MPRJ-IO state = %b ", mprj_io);
		$display("o_result state = %b ", o_result);
		if(o_result[2]) begin
			wait(o_result[0]==0);
			wait(o_result[1]==0);
			wait(o_result[2]==1);
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
		.FILENAME("signal_generator.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);
endmodule
`default_nettype wire
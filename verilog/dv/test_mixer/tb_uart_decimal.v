
    module tb_uart_decimal (
    input  ser_rx,
    output  ser_tx
    );
	reg [3:0] recv_state;
	reg [2:0] recv_divcnt;
	reg [7:0] recv_pattern;
	reg [8*50-1:0] recv_buf_data;	// 50 characters.  Increase as needed for tests.
	reg [8*50-1:0] recv_buf_rev;	
	reg clk;
	integer i; // Variable para el bucle for
	integer hex_value; // Variable para almacenar el valor decimal
	initial begin
		clk <= 1'b0;
		recv_state <= 0;
		recv_divcnt <= 0;
		recv_pattern <= 0;
		recv_buf_data <= 0;
	end
        always #2650 clk <= (clk === 1'b0);  // working for 9600 baud
	always @(posedge clk) begin
		recv_divcnt <= recv_divcnt + 1;
		case (recv_state)
			0: begin
				if (!ser_rx)
					recv_state <= 1;
				recv_divcnt <= 0;
			end
			1: begin
				if (2*recv_divcnt > 3'd3) begin
					recv_state <= 2;
					recv_divcnt <= 0;
				end
			end
			10: begin
				if (recv_divcnt > 3'd3) begin
					// 0x0a = '\n'
					if (recv_pattern == 8'h0a) 
					begin
						// Invert the string before displaying
						for (i = 0; i < 50; i = i + 1) begin
							recv_buf_rev[8*(50-i-1) +: 8] = recv_buf_data[8*i +: 8];
						end
						hex_value = 0;
                        for (i = 0; i < 50; i = i + 1) begin
                            if (recv_buf_data[8*i +: 8] != 8'h00) begin
                                hex_value = hex_value * 16 + (
                                    (recv_buf_data[8*i +: 8] >= "0" && recv_buf_data[8*i +: 8] <= "9") ?
                                    (recv_buf_data[8*i +: 8] - "0") :
                                    (recv_buf_data[8*i +: 8] - "A" + 10)
                                );
                            end
                        end
                        $display("output (Decimal): %d", hex_value);
						recv_buf_data <= 0;
					end else begin
						recv_buf_data <= {recv_buf_data, recv_pattern};
					end
					recv_state <= 0;
				end
			end
			default: begin
				if (recv_divcnt > 3'd3) begin
					recv_pattern <= {ser_rx, recv_pattern[7:1]};
					recv_state <= recv_state + 1;
					recv_divcnt <= 0;
				end
			end
		endcase
	end
    endmodule
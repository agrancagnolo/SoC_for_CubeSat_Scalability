`default_nettype none

module test_mixer #(
    parameter   [31:0]  REG_SET_VALUE_ADDRESS  = 32'h3000_0000,
    parameter   [31:0]  RETURN_VALUE           = 32'h3000_0004, 
    parameter   BITS_8 = 8
    ) (
    `ifdef USE_POWER_PINS
        inout vccd1,
        inout vssd1,
    `endif
   
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output reg [31:0] wbs_dat_o,

    // IOs
    input  [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_in,
    output reg [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_oeb
    
    );
    
    reg [31:0] contador = 0;
    reg [31:0] valor_final = 0;
    reg [1:0]  sent;

    wire   toggle;
    assign toggle = io_in[7];
    
    assign  io_oeb = {(`MPRJ_IO_PADS-`ANALOG_PADS){1'b0}};
    
    initial 
    begin
            io_out = 0;
            sent = 2'b00;
    end
    
    reg [(BITS_8-1):0]reg_set_value;

    always @(posedge wb_clk_i) begin
        if(wb_rst_i)
        begin
            reg_set_value <= {BITS_8{1'b0}};
            sent <= 0;
        end   
        else if(wbs_stb_i && wbs_cyc_i && wbs_we_i)
            case(wbs_adr_i)
                REG_SET_VALUE_ADDRESS:
                    begin
                        reg_set_value <= wbs_dat_i[(BITS_8-1):0]; 
                        if (reg_set_value == 8'd7)
                            begin 
                               //reset_values <= 1;
                               reg_set_value <= {BITS_8{1'b0}};
                               sent <= 2'b00;
                            end
                        if (reg_set_value == 8'd8)
                            begin
                               sent  <= 2'b01;
                               reg_set_value  <= 0;
                            end
                    end
                default:
                    wbs_dat_o <= 32'b0;
            endcase
        else if(wbs_stb_i && wbs_cyc_i && !wbs_we_i)
            case(wbs_adr_i)
                RETURN_VALUE:
                    if (sent == 2'b01)
                    begin
                        wbs_dat_o <= contador; 
                        sent  <= 2'b10;
                    end
                default:
                    wbs_dat_o <= 32'b0;
            endcase
        
    end
    
    always @(posedge toggle) begin

        if(!sent)
        begin
            contador <= contador + 1;
        end
        else if(sent == 2'b10)
        begin
            contador <= 0;
        end
    end
    
    always @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            io_out[24] <= 0;
        end 
        else if(sent  <= 2'b01) 
        begin
            io_out[24] <=  1'b1;
        end
        else io_out[24] <=  1'b0;
    end

    always @(posedge wb_clk_i) begin
        if(wb_rst_i)
            wbs_ack_o <= 0;
        else
            wbs_ack_o <= (wbs_stb_i && (wbs_adr_i == REG_SET_VALUE_ADDRESS || wbs_adr_i == RETURN_VALUE));
    end

endmodule


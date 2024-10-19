`default_nettype none



module signal_generator #(
    parameter PASO_DEF = 32'h5FA4,
    parameter [31:0] ENABLE_ADDRESS     = 32'h3000_0000, // read
    parameter [31:0] FREQUENCY_ADDRESS  = 32'h3000_0004, // read
    parameter [31:0] PHI_P_ADDRESS      = 32'h3000_0008, // write
    parameter [31:0] PHI_L1_ADDRESS     = 32'h3000_000C, // write
    parameter [31:0] PHI_L2_ADDRESS     = 32'h3000_0010, // write
    parameter [31:0] PHI_R_ADDRESS      = 32'h3000_0014, // write
    parameter [31:0] CLOCK_ADDRESS      = 32'h3000_0018, // read
    parameter [31:0] RETURN_ADDRESS     = 32'h3000_001C  // read
    ) (
    `ifdef USE_POWER_PINS
        inout vccd1,	// User area 1 1.8V supply
        inout vssd1,	// User area 1 digital ground
    `endif
   // Wishbone Slave ports (WB MI A)
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

    // "PUERTOS"
    wire         i_test;
    reg  [2:0]   o_test;

    wire         i_enable;
    wire         i_f_select_serial; 
    wire         i_load_config; 
    reg   [3:0]  i_f_select;
    wire         i_clk;   
    reg          o_phi_p;
    reg          o_phi_l1;
    reg          o_phi_l2;
    reg          o_phi_r;


    wire adc_start_conversion;

    // DIGITAL
    assign i_test = io_in[26];
    assign i_clk = io_in[25];
    assign i_enable = io_in[24];
    assign i_f_select_serial = io_in[23];
    assign i_load_config = io_in[22];
	
    // LOCALPARAM 
    localparam MIN_TIEMPO_REQ =   CICLOS_FORMAS_DE_ONDA * 2052+PHI_P_WIDTH;
    localparam CICLOS_FORMAS_DE_ONDA =   8;
    localparam CICLOS_PHI_L =   CICLOS_FORMAS_DE_ONDA/2;
    localparam CICLOS_PHI_R =   CICLOS_FORMAS_DE_ONDA/4;


    

    // REGISTROS INTERNOS
    reg [31:0]  contador;
    reg [13:0]  contador_waves;
    reg [3:0]   f_selected;
    reg [1:0]   estado; 
    reg [1:0]   sig_estado;
    reg [$clog2(CICLOS_FORMAS_DE_ONDA):0] ciclos;
    reg pulse_ended;

    reg [3:0]   f_sel_sr;  
    reg [2:0]   f_sel_bit_counter; 

    reg         i_enable_wb;
    reg         i_clk_wb;
    reg [3:0]   i_f_select_wb;

    wire        i_enable_mux;
    wire [3:0]  i_f_select_mux;
    wire        i_clk_mux;

    reg i_test_reg;

    assign  io_oeb = {(`MPRJ_IO_PADS-`ANALOG_PADS){1'b0}};// always enabled

    // ASIGNACION DE SERIE A PARALELO DEL SELECTOR DE FRECUENCIAS
    always @(posedge i_clk_mux ) begin
        if (~i_enable_mux || (i_test && ~i_test_reg)) begin
            f_sel_sr <= 4'b0;
            f_sel_bit_counter <= 4'b0;
        end
        else begin
            if (i_load_config == 1) begin
                f_sel_sr <= {f_sel_sr[2:0], i_f_select_serial}; // Desplazar un bit
                f_sel_bit_counter <= f_sel_bit_counter + 1;
            end
            
            if (f_sel_bit_counter == 3'b100) begin
                i_f_select <= f_sel_sr;
                f_sel_bit_counter <= 4'b0;
            end
        end
    end

    // DECODIFICACION DE LOS ESTADOS
    localparam  [1:0] INITIAL_SETUP   = 2'b00;
    localparam  [1:0] SHIFT_CHARGES   = 2'b01;
    localparam  [1:0] HOLD_CAPTURE    = 2'b10;
    localparam  [1:0] PULSE_HPND      = 2'b11;
    localparam  PHI_P_WIDTH	      = 4;	

    initial begin
        o_phi_r = 0;
        o_phi_l2 = 0;
        o_phi_l1 = 0;
        o_phi_p = 0;
        contador = 0;
        contador_waves = 0;
        f_selected = 0;
        estado = 0;
        sig_estado = 0;
        ciclos = 0;
        o_test = 3'b0;
    end

// Actualizar el valor de i_test_reg al final del ciclo de reloj
always @(posedge wb_clk_i) begin
    i_test_reg <= i_test;
end

//ACTUALIZAR EL VALOR DE F_SELECTED
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Flanco positivo de i_test detectado
        f_selected <= 0;
    else if (estado == PULSE_HPND  && sig_estado == SHIFT_CHARGES)
        f_selected <= i_f_select_mux;
end

//FLAG PARA CONTROLAR EL FINAL DEL PULSO
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear en flanco de i_test
        pulse_ended <= 0;
    else if ((estado == PULSE_HPND)  && (sig_estado == SHIFT_CHARGES))
        pulse_ended <= 1;
    else
        pulse_ended <= 0;    
end

//CONTADOR PRINCIPAL
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear contador
        contador <= 0;
    else if ((estado == PULSE_HPND)  && (sig_estado == SHIFT_CHARGES))
        contador <= 0;
    else
        contador <= contador + 1;
end

//CONTADOR DE CICLOS DE RELOJ PARA GENERAR LAS WF
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear contador de ciclos
        ciclos <= 0;
    else if ((ciclos < (CICLOS_FORMAS_DE_ONDA-1)) & (estado == SHIFT_CHARGES))
        ciclos <= ciclos + 1;
    else  
        ciclos <= 0;
end

//CONTADOR DE VECES QUE SE GENERARON LAS ONDAS PHI_L1, PHI_L2 Y PHI_R
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear contador de ondas
        contador_waves <= 0;
    else if (estado == PULSE_HPND)
        contador_waves <= 0;
    else if (ciclos == CICLOS_FORMAS_DE_ONDA-1)
        contador_waves <= contador_waves + 1;
end


//MAQUINA DE ESTADOS FINITOS 

// TRANSICIÓN SINCRÓNICA DE ESTADO
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear estado
        estado <= INITIAL_SETUP;
    else 
        estado <= sig_estado;
end

//DECODIFICACION DEL SIGUIENTE ESTADO
always @(*) begin
    case (estado)
    INITIAL_SETUP: begin
        if(( contador > PHI_P_WIDTH) && (contador_waves == 0))
    	    sig_estado = SHIFT_CHARGES;   
        else 
            sig_estado = INITIAL_SETUP; 
	
    end
    SHIFT_CHARGES: begin
        if ( contador_waves <= 2051 )
            sig_estado = SHIFT_CHARGES;
        else 
            sig_estado = HOLD_CAPTURE;   
    end
    HOLD_CAPTURE: begin
        if ( contador <= (MIN_TIEMPO_REQ + (f_selected * PASO_DEF )))
            sig_estado = HOLD_CAPTURE;
        else 
            sig_estado = PULSE_HPND;  
    end
    PULSE_HPND: begin
        if ( contador <= (MIN_TIEMPO_REQ + (f_selected * PASO_DEF ) + PHI_P_WIDTH)) // PHI_P_WIDTH  >  320ns
            sig_estado = PULSE_HPND;
        else 
            sig_estado = SHIFT_CHARGES;  
    end
    endcase
end

always @(*) begin
    if ((estado==SHIFT_CHARGES && ciclos>=CICLOS_PHI_L  && ciclos <CICLOS_PHI_L+CICLOS_PHI_R) || (estado==PULSE_HPND) ||(estado==INITIAL_SETUP))
        o_phi_r =1;
    else 
        o_phi_r =0;    
end

always @(*) begin
    if ((estado==SHIFT_CHARGES && (ciclos>=CICLOS_PHI_L)) | (estado==PULSE_HPND) ||(estado==INITIAL_SETUP))
        o_phi_l2 =1;
    else 
        o_phi_l2 =0;    
end

always @(*) begin
    if ((estado==SHIFT_CHARGES && (ciclos<CICLOS_PHI_L)) )
        o_phi_l1 =1;
    else 
        o_phi_l1 =0;    
end

always @(*) begin
    if ((estado==PULSE_HPND) ||(estado==INITIAL_SETUP) ) begin
        o_phi_p =1;
    end else begin
        o_phi_p =0;   
    end
end

//LOGICA WISHBONE
always @(posedge wb_clk_i) begin
    if(i_test) begin
        if(wb_rst_i) begin
            wbs_dat_o <= 32'b0;
        end else begin
            // Write
            if (wbs_stb_i && wbs_cyc_i && wbs_we_i) begin
                case(wbs_adr_i)
                    ENABLE_ADDRESS: i_enable_wb <= wbs_dat_i[0];
                    FREQUENCY_ADDRESS: i_f_select_wb <= wbs_dat_i[3:0];
                    CLOCK_ADDRESS: i_clk_wb <= wbs_dat_i[0];
                    RETURN_ADDRESS: o_test <= wbs_dat_i[2:0];
                    default: wbs_dat_o <= 32'b0;
                endcase
            end
            // Handle Read Operations
            if (wbs_stb_i && wbs_cyc_i && !wbs_we_i) begin
                case(wbs_adr_i)
                    PHI_P_ADDRESS: wbs_dat_o <= {31'b0, o_phi_p};
                    PHI_L1_ADDRESS: wbs_dat_o <= {31'b0, o_phi_l1};
                    PHI_L2_ADDRESS: wbs_dat_o <= {31'b0, o_phi_l2};
                    PHI_R_ADDRESS: wbs_dat_o <= {31'b0, o_phi_r};
                    default: wbs_dat_o <= 32'b0;
                endcase
            end
        end
    end
end

assign i_enable_mux = i_test ? i_enable_wb : i_enable ;

assign i_clk_mux = i_test ? i_clk_wb : i_clk ;

assign i_f_select_mux = i_test ? i_f_select_wb : i_f_select ;


    always @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            io_out[9:7] <= 0;
        end 
        else begin
            io_out[9:7] <= o_test;
        end
    end

    always @(posedge i_clk_mux) begin
        io_out[6:0] <= 0;
        io_out[10] <= o_phi_p; 
        io_out[11] <= o_phi_l1;
        io_out[12] <= o_phi_l2;
        io_out[13] <= o_phi_r;
        io_out[26:14] <= 0;
    end

    always @(posedge wb_clk_i) begin
        if(wb_rst_i)
            wbs_ack_o <= 0;
        else
            wbs_ack_o <= (wbs_stb_i && (wbs_adr_i == ENABLE_ADDRESS || wbs_adr_i == FREQUENCY_ADDRESS || wbs_adr_i == CLOCK_ADDRESS || wbs_adr_i == RETURN_ADDRESS || wbs_adr_i == PHI_P_ADDRESS || wbs_adr_i == PHI_L1_ADDRESS || wbs_adr_i == PHI_L2_ADDRESS || wbs_adr_i == PHI_R_ADDRESS));
        end


endmodule


module dtm #(
	parameter [31:0] DEFAULT_DIV = 1 // = clock/baudrate
) (
	output ser_tx,
	input  ser_rx,

        output reg        dmi_valid,
        output reg        dmi_wr,
        output reg [ 6:0] dmi_addr,
        output reg [31:0] dmi_wdata,
        input      [31:0] dmi_rdata,

	input resetn,
	input clk
);
        wire uart_tx_busy;
        reg  uart_tx_vld;
        wire uart_rx_rdy;
        reg  [31:0] uart_tx_data;
        wire [31:0] uart_rx_data;

        parameter MAGIC_NUMBER = 8'h5A;

        parameter STATE_IDLE       = 0;
        parameter STATE_MAGICNUM   = 1;
        parameter STATE_ADDR       = 2;
        parameter STATE_DATA_BYTE0 = 3;
        parameter STATE_DATA_BYTE1 = 4;
        parameter STATE_DATA_BYTE2 = 5;
        parameter STATE_DATA_BYTE3 = 6;
        parameter STATE_CHECKSUM   = 7;

        reg [3:0] rx_state;
        reg [7:0] rx_checksum;
        always @(posedge clk) begin
                if (!resetn) begin
                        dmi_wr    <= 0;
                        dmi_addr  <= 0;
                        dmi_wdata <= 0;
                        dmi_valid <= 0;
                        rx_state  <= STATE_IDLE;
                end else if (!uart_rx_rdy) begin
                        dmi_valid <= 0;
                end else begin
                        rx_checksum <= rx_checksum ^ uart_rx_data[7:0];
                        case(rx_state)
                                STATE_IDLE: begin
                                        rx_checksum <= 0;
                                        if(uart_rx_data[7:0] == MAGIC_NUMBER)
                                                rx_state <= STATE_ADDR;
                                end
                                STATE_ADDR: begin
                                        dmi_wr   <= uart_rx_data[7];
                                        dmi_addr <= uart_rx_data[6:0];
                                        rx_state <= STATE_DATA_BYTE0;
                                end
                                STATE_DATA_BYTE0: begin
                                        dmi_wdata[7:0] <= uart_rx_data[7:0];
                                        rx_state       <= STATE_DATA_BYTE1;
                                end
                                STATE_DATA_BYTE1: begin
                                        dmi_wdata[15:8] <= uart_rx_data[7:0];
                                        rx_state        <= STATE_DATA_BYTE2;
                                end
                                STATE_DATA_BYTE2: begin
                                        dmi_wdata[23:16] <= uart_rx_data[7:0];
                                        rx_state         <= STATE_DATA_BYTE3;
                                end
                                STATE_DATA_BYTE3: begin
                                        dmi_wdata[31:24] <= uart_rx_data[7:0];
                                        rx_state         <= STATE_CHECKSUM;
                                end
                                STATE_CHECKSUM: begin
                                        rx_state <= STATE_IDLE;
                                        if(rx_checksum == uart_rx_data[7:0])
                                                dmi_valid <= 1;
                                end
                        endcase
                end
        end

        reg [3:0] tx_state;
        reg [7:0] tx_checksum;
        always @(posedge clk) begin
                if (!resetn) begin
                        tx_state <= STATE_IDLE;
                        uart_tx_vld  <= 0;
                        uart_tx_data <= 0;
                        tx_checksum  <= 0;
                end else begin
                        uart_tx_vld  <= 0;
                        case(tx_state)
                                STATE_IDLE: begin
                                        if(dmi_valid && !dmi_wr) begin
                                                tx_state     <= STATE_MAGICNUM;
                                                uart_tx_vld  <= 1;
                                                uart_tx_data <= MAGIC_NUMBER;
                                                tx_checksum  <= 0;
                                        end
                                end
                                STATE_MAGICNUM: begin
                                        if(~uart_tx_vld && ~uart_tx_busy) begin
                                                tx_state     <= STATE_ADDR;
                                                uart_tx_vld  <= 1;
                                                uart_tx_data <= {dmi_wr, dmi_addr};
                                                tx_checksum  <= tx_checksum ^ {dmi_wr, dmi_addr};
                                        end
                                end
                                STATE_ADDR: begin
                                        if(~uart_tx_vld && ~uart_tx_busy) begin
                                                tx_state     <= STATE_DATA_BYTE0;
                                                uart_tx_vld  <= 1;
                                                uart_tx_data <= dmi_rdata[7:0];
                                                tx_checksum  <= tx_checksum ^ dmi_rdata[7:0];
                                        end
                                end
                                STATE_DATA_BYTE0: begin
                                        if(~uart_tx_vld && ~uart_tx_busy) begin
                                                tx_state     <= STATE_DATA_BYTE1;
                                                uart_tx_vld  <= 1;
                                                uart_tx_data <= dmi_rdata[15:8];
                                                tx_checksum  <= tx_checksum ^ dmi_rdata[15:8];
                                        end
                                end
                                STATE_DATA_BYTE1: begin
                                        if(~uart_tx_vld && ~uart_tx_busy) begin
                                                tx_state     <= STATE_DATA_BYTE2;
                                                uart_tx_vld  <= 1;
                                                uart_tx_data <= dmi_rdata[23:16];
                                                tx_checksum  <= tx_checksum ^ dmi_rdata[23:16];
                                        end
                                end
                                STATE_DATA_BYTE2: begin
                                        if(~uart_tx_vld && ~uart_tx_busy) begin
                                                tx_state     <= STATE_DATA_BYTE3;
                                                uart_tx_vld  <= 1;
                                                uart_tx_data <= dmi_rdata[31:24];
                                                tx_checksum  <= tx_checksum ^ dmi_rdata[31:24];
                                        end
                                end
                                STATE_DATA_BYTE3: begin
                                        if(~uart_tx_vld && ~uart_tx_busy) begin
                                                tx_state     <= STATE_CHECKSUM;
                                                uart_tx_vld  <= 1;
                                                uart_tx_data <= tx_checksum;
                                        end
                                end
                                STATE_CHECKSUM: begin
                                        if(~uart_tx_vld && ~uart_tx_busy) begin
                                                tx_state <= STATE_IDLE;
                                        end
                                end
                        endcase
                end
        end
                
	simpleuart #(
                .DEFAULT_DIV(DEFAULT_DIV)
        ) simpleuart (
		.clk         (clk),
		.resetn      (resetn),

		.ser_tx      (ser_tx),
		.ser_rx      (ser_rx),

		.reg_div_we  (4'h0),
		.reg_div_di  (32'h0),
		.reg_div_do  (),

		.reg_dat_we  (uart_tx_vld),
		.reg_dat_re  (uart_rx_rdy),
		.reg_dat_di  (uart_tx_data),
		.reg_dat_do  (uart_rx_data),
	        .reg_dat_valid(uart_rx_rdy),
	        .reg_dat_busy(uart_tx_busy),
		.reg_dat_wait()
	);

endmodule

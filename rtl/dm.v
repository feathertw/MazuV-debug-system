module dm #(
	parameter NULL = 1
) (
        input             dmi_valid,
        output reg        dmi_ready,
        input             dmi_write,
        input [ 6:0]      dmi_addr,
        input [31:0]      dmi_wdata,
        output reg [31:0] dmi_rdata,

	input             bus_valid,
	output reg        bus_ready,
	input             bus_write,
	input   [19:2]    bus_addr,
	input   [31:0]    bus_wdata,
	output reg [31:0] bus_rdata,

	input resetn,
	input clk
);
        reg [31:0] register [0:7];
        reg [31:0] ram [0:7];

        wire dmi_match = dmi_valid && dmi_ready;

        always @(posedge clk) begin
                if(dmi_match && dmi_write) begin
                        register[dmi_addr] <= dmi_wdata;
                end
        end

        always @(posedge clk) begin
                if(!resetn) begin
                        dmi_rdata <= 0;
                end else if (dmi_valid && ~dmi_write) begin
                        dmi_rdata <= register[dmi_addr];
                end
        end

        always @(posedge clk) begin
                if(!resetn) begin
                        dmi_ready <= 0;
                end else if (dmi_match) begin
                        dmi_ready <= 0;
                end else if (dmi_valid) begin
                        dmi_ready <= 1;
                end
        end

        wire bus_match = bus_valid && bus_ready;

        always @(posedge clk) begin
                if(!resetn) begin
                        ram[0] <= 32'h00000013;
                        ram[1] <= 32'h00000013;
                        ram[2] <= 32'h0400000b;
                        ram[3] <= 32'h0000006f;
                end else if(bus_match && bus_write) begin
                        ram[bus_addr] <= bus_wdata;
                end
        end

        always @(posedge clk) begin
                if(!resetn) begin
                        bus_rdata <= 0;
                end else if (bus_valid && !bus_write) begin
                        bus_rdata <= ram[bus_addr];
                end
        end

        always @(posedge clk) begin
                if(!resetn) begin
                        bus_ready <= 0;
                end else if (bus_match) begin
                        bus_ready <= 0;
                end else if (bus_valid) begin
                        bus_ready <= 1;
                end
        end
endmodule

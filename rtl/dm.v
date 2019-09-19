module dm #(
	parameter NULL = 1
) (
        input             dmi_valid,
        input             dmi_wr,
        input [ 6:0]      dmi_addr,
        input [31:0]      dmi_wdata,
        output reg [31:0] dmi_rdata,

	input resetn,
	input clk
);
        reg [31:0] register [0:7];

        always @(posedge clk) begin
                if(dmi_valid && dmi_wr) begin
                        register[dmi_addr] <= dmi_wdata;
                end
        end
        always @(posedge clk) begin
                if(!resetn) begin
                        dmi_rdata <= 'h0;
                end else if (dmi_valid && ~dmi_wr) begin
                        dmi_rdata <= register[dmi_addr];
                end
        end
endmodule

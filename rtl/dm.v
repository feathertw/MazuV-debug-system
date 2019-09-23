module dm #(
	parameter NULL = 1
) (
        output reg        interrupt,
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

        reg [7:0] rom_file [0:128*4-1];
        wire [31:0] rom [0:128-1+2];

        genvar i;
        generate
                for (i = 0; i < 128; i = i + 1) begin
                        assign rom[i] = {rom_file[i*4+3],rom_file[i*4+2],rom_file[i*4+1],rom_file[i*4+0]};
                end
        endgenerate
        assign rom[128] = dm_command;
        assign rom[129] = 0;
        initial begin
                $readmemh("debug/src/dm_rom.hex", rom_file);
        end

        wire dmi_match = dmi_valid && dmi_ready;

        always @(posedge clk) begin
                if(dmi_match && dmi_write) begin
                        register[dmi_addr] <= dmi_wdata;
                end
        end

        always @(posedge clk) begin
                if(!resetn) begin
                        interrupt <= 0;
                end else if(dmi_match && dmi_write) begin
                        interrupt <= 1;
                end else if (bus_match && bus_write && {bus_addr,2'h0}=='h204)begin
                        interrupt <= 0;
                end
        end
        reg [31:0] dm_command;
        always @(posedge clk) begin
                if(!resetn) begin
                        dm_command <= 0;
                end else if(dmi_match && !dmi_write) begin
                        dm_command <= 32'h8000_0000;
                end else if (bus_match && bus_write && {bus_addr,2'h0}=='h200)begin
                        dm_command <= 0;
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
                        bus_rdata <= rom[bus_addr];
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

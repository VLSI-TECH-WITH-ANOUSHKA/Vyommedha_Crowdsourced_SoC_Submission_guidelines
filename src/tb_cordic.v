`timescale 1ns / 1ps


module tb_coric;
    reg clk;
    reg rst;
    reg bus_write;
    reg bus_read;
    reg [5:0] addr;
    reg [31:0] wdata;
    wire [31:0] rdata;
    wire done;

    cordic_core uut (
        .clk(clk),
        .rst(rst),
        .bus_write(bus_write),
        .bus_read(bus_read),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata),
        .done(done));

    initial clk = 0;
    always #5 clk = ~clk;

    task apply_angle(input [31:0] angle_val);
    begin
        @(posedge clk);
        bus_write <= 1;
        addr <= 6'h04; // angle register
        wdata <= angle_val;
        @(posedge clk);
        bus_write <= 0;

        wait(done == 1);
        @(posedge clk);

        bus_read <= 1;
        addr <= 6'h08; // cos
        @(posedge clk);
        $display("Cosine: %d", rdata);
        addr <= 6'h0C; // sin
        @(posedge clk);
        $display("Sine: %d", rdata);
        bus_read <= 0;
    end
    endtask

    initial begin
        rst = 1;
        bus_write = 0;
        bus_read  = 0;
        addr = 0;
        wdata = 0;

        @(posedge clk);
        rst = 0;

        // eg: 0 deg = 0x00000000, 90 deg = 0x20000000 (approximately though), 45 deg = 0x10000000
        $display("Testing 0 degrees");
        apply_angle(32'h00000000);

        $display("Testing 45 degrees");
        apply_angle(32'h10000000);

        $display("Testing 90 degrees");
        apply_angle(32'h20000000);

        $display("Testing -45 degrees");
        apply_angle(32'hF0000000); // two's complement

        $display("Simulation complete.");
        $stop;
    end
endmodule

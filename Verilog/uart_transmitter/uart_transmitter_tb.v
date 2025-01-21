`include "uart_transmitter.v"
`include "baud_rate_generator.v"

`timescale 1ns/1ps

module uart_transmitter_tb (
    
);

parameter PERIOD = 10;
parameter NUM_DATA = 256; //the number of data
integer count, i, j, k, error;


//module input 
reg clk = 0;
reg rst;
//reg [7:0]data = 8'b00101011;
reg [7:0]data;
reg start = 0;
//module output
wire baud_rate_signal;
wire uart_rx;

// there you can read data from the solution file,and store in the register.
reg [9:0] solution [0:255];
initial begin
  $readmemb("solution.dat",solution);
end

//call module
baud_rate_generator ins1 (
    .clk(clk),
    .rst(rst),
    .baud_rate_signal(baud_rate_signal)
);
uart_transmitter ins2 (
    .data(data),
    .baud_rate_signal(baud_rate_signal),
    .start(start),
    .rst(rst),
    .clk(clk),
    .uart_tx(uart_tx)
);

//dump file
initial begin
    $dumpfile("uart_transmitter_tb.vcd");
    $dumpvars;
end

//clk generate
initial begin
    forever begin
        #(PERIOD/2);
        clk = ~clk;
    end
end

//system reset
initial begin
    rst = 0;
    #(2*PERIOD);
    rst = 1;
    #(PERIOD);
    rst = 0;
end

//start control
initial begin
    wait(rst == 1);
    wait(rst == 0);
    #(PERIOD);
    start = 1;
    //#(1000*PERIOD);
    
end

//input data 0000_0000~1111_1111
initial begin
    count = 0;
    data = 0;
    wait(start == 1);
    forever begin
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge baud_rate_signal);
            if (count == 9) begin
                count = 0;
                data = data + 1;  //transmit complete (10-bit)
            end else begin //count != 10
                count = count + 1;
                data = data;
            end
        end
    end
end

//auto check
initial begin
    error = 0;
    wait(baud_rate_signal == 1);
    for (j = 0; j < NUM_DATA ; j = j + 1) begin
        for (k = 0; k < 10; k = k + 1 ) begin
            @(posedge baud_rate_signal);
            if (uart_tx == solution[j][k]) begin
                error = error;
            end else begin
                error = error + 1;
                $display("pattern number No.%d, bit.%d is wrong at time:%t", j, k, $time);
                $display("your answer is %b, but the correct answer is %b", uart_tx, solution[j][k]);
            end
        end
    end
    if(error == 0) begin
        $display("Your answer is correct!");
    end else begin
        $display("Your answer is wrong!");
    end
    $finish;
end



endmodule //uart_transmitter_tb
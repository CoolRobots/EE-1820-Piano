//Code is partially ai generated
//Ai is allowed for project, goal wasn't to independantly write verilog but instead to learn the circuitry
module piano_final (

    input wire clk,

    input wire reset,

    input wire [1:0] wave_select,

    input wire keyC4, keyC4h, keyD4, keyD4h,

    input wire keyE4, keyF4, keyF4h,

    input wire keyG4, keyG4h,

    input wire keyA4, keyA4h, keyB4,

    input wire keyC5, keyC5h, keyD5, keyD5h,

    input wire keyE5, keyF5,

    output wire tone,

    output wire [8:0] U,

    output wire [8:0] V,

    output wire [7:0] dac_data

);

    wire [17:0] keys_raw;

    assign keys_raw = {

        keyC4, keyC4h, keyD4, keyD4h,

        keyE4, keyF4, keyF4h,

        keyG4, keyG4h,

        keyA4, keyA4h, keyB4,

        keyC5, keyC5h, keyD5, keyD5h,

        keyE5, keyF5

    };

    // Synchronize the input signals to the FPGA clock.

    reg [17:0] keys_meta;

    reg [17:0] keys_sync;

    reg [1:0] wave_meta;

    reg [1:0] wave_sync;

    always @(posedge clk) begin

        if (reset) begin

            keys_meta <= 0;

            keys_sync <= 0;

            wave_meta <= 0;

            wave_sync <= 0;

        end

        else begin

            keys_meta <= keys_raw;

            keys_sync <= keys_meta;

            wave_meta <= wave_select;

            wave_sync <= wave_meta;

        end

    end

    wire [21:0] threshold;

    wire [3:0] note;

    wire active;

    wire [4:0] sample_index;

    wire [7:0] sample_value;

    key_decode decoder (

        .keys(keys_sync),

        .threshold(threshold),

        .note(note),

        .active(active)

    );

    note_display displays (

        .note(note),

        .active(active),

        .U(U),

        .V(V)

    );

    piano_timing timing (

        .clk(clk),

        .reset(reset),

        .keys(keys_sync),

        .active(active),

        .threshold(threshold),

        .tone(tone),

        .sample_index(sample_index)

    );

    waveform_lut waveforms (

        .sample_index(sample_index),

        .wave_select(wave_sync),

        .sample_value(sample_value)

    );

    assign dac_data = active ? sample_value : 8'd128;

endmodule

// ============================================================

// KEY DECODER

// Original piano thresholds are retained.

//

// Note codes:

// C=0, C#=1, D=2, D#=3, E=4, F=5,

// F#=6, G=7, G#=8, A=9, A#=10, B=11

// ============================================================

module key_decode (

    input wire [17:0] keys,

    output reg [21:0] threshold,

    output reg [3:0] note,

    output reg active

);

    always @* begin

        threshold = 0;

        note = 0;

        active = 0;

        case (keys)

            18'b10_0000_0000_0000_0000: begin

                threshold = 22937;

                note = 0;

                active = 1;

            end

            18'b01_0000_0000_0000_0000: begin

                threshold = 21647;

                note = 1;

                active = 1;

            end

            18'b00_1000_0000_0000_0000: begin

                threshold = 20432;

                note = 2;

                active = 1;

            end

            18'b00_0100_0000_0000_0000: begin

                threshold = 19285;

                note = 3;

                active = 1;

            end

            18'b00_0010_0000_0000_0000: begin

                threshold = 18202;

                note = 4;

                active = 1;

            end

            18'b00_0001_0000_0000_0000: begin

                threshold = 17181;

                note = 5;

                active = 1;

            end

            18'b00_0000_1000_0000_0000: begin

                threshold = 16224;

                note = 6;

                active = 1;

            end

            18'b00_0000_0100_0000_0000: begin

                threshold = 15326;

                note = 7;

                active = 1;

            end

            18'b00_0000_0010_0000_0000: begin

                threshold = 14451;

                note = 8;

                active = 1;

            end

            18'b00_0000_0001_0000_0000: begin

                threshold = 13631;

                note = 9;

                active = 1;

            end

            18'b00_0000_0000_1000_0000: begin

                threshold = 12876;

                note = 10;

                active = 1;

            end

            18'b00_0000_0000_0100_0000: begin

                threshold = 12155;

                note = 11;

                active = 1;

            end

            18'b00_0000_0000_0010_0000: begin

                threshold = 11488;

                note = 0;

                active = 1;

            end

            18'b00_0000_0000_0001_0000: begin

                threshold = 10831;

                note = 1;

                active = 1;

            end

            18'b00_0000_0000_0000_1000: begin

                threshold = 10224;

                note = 2;

                active = 1;

            end

            18'b00_0000_0000_0000_0100: begin

                threshold = 9663;

                note = 3;

                active = 1;

            end

            18'b00_0000_0000_0000_0010: begin

                threshold = 9101;

                note = 4;

                active = 1;

            end

            18'b00_0000_0000_0000_0001: begin

                threshold = 8601;

                note = 5;

                active = 1;

            end

            default: begin

                threshold = 0;

                note = 0;

                active = 0;

            end

        endcase

    end

endmodule

// ============================================================

// SEVEN-SEGMENT DISPLAYS

//

// Bit order from your previous code:

// [8:0] = SEG, DP, g, f, e, d, c, b, a

//

// A = note letter

// V: blank or three horizontal lines for a sharp

// ============================================================

module note_display (

    input wire [3:0] note,

    input wire active,

    output reg [8:0] U,

    output reg [8:0] V

);

    always @* begin

        U = 9'h000;

        V = 9'h000;

        if (active) begin

            case (note)

                4'd0, 4'd1:

                    U = 9'h039;    // C

                4'd2, 4'd3:

                    U = 9'h05e;    // d

                4'd4:

                    U = 9'h079;    // E

                4'd5, 4'd6:

                    U = 9'h071;    // F

                4'd7, 4'd8:

                    U = 9'h03d;    // G approximation

                4'd9, 4'd10:

                    U = 9'h077;    // A

                4'd11:

                    U = 9'h07c;    // b

                default:

                    U = 9'h000;

            endcase

            case (note)

                4'd1, 4'd3, 4'd6, 4'd8, 4'd10:

                    V = 9'h049;    // Segments a, d, g

                default:

                    V = 9'h000;

            endcase

        end

    end

endmodule

// ============================================================

// TIMING

//

// tone: original-style square wave

// sample_index: steps through 32 waveform samples

// ============================================================

module piano_timing (

    input wire clk,

    input wire reset,

    input wire [17:0] keys,

    input wire active,

    input wire [21:0] threshold,

    output reg tone,

    output reg [4:0] sample_index

);

    reg [21:0] square_count;

    reg [21:0] sample_count;

    reg [17:0] previous_keys;

    wire [21:0] sample_ticks;

    // Original half-period is threshold + 1 clocks.

    // A full period contains 32 samples.

    // Round (threshold + 1) / 16 to the nearest integer.

    assign sample_ticks = (threshold + 22'd9) >> 4;

    always @(posedge clk) begin

        if (reset) begin

            square_count <= 0;

            sample_count <= 0;

            previous_keys <= 0;

            tone <= 0;

            sample_index <= 0;

        end

        else begin

            previous_keys <= keys;

            // Silence or restart when the selected key changes.

            if (!active || keys != previous_keys) begin

                square_count <= 0;

                sample_count <= 0;

                tone <= 0;

                sample_index <= 0;

            end

            else begin

                // Original square-wave timing.

                if (square_count >= threshold) begin

                    square_count <= 0;

                    tone <= ~tone;

                end

                else begin

                    square_count <= square_count + 1'b1;

                end

                // Waveform sample timing.

                if (sample_count >= sample_ticks - 1'b1) begin

                    sample_count <= 0;

                    sample_index <= sample_index + 1'b1;

                end

                else begin

                    sample_count <= sample_count + 1'b1;

                end

            end

        end

    end

endmodule

// ============================================================

// WAVEFORM LOOKUP TABLES

// 00 = sine

// 01 = triangle

// 10 = sawtooth

// 11 = square

// Each waveform contains 32 bits.

// Ts is really long

// ============================================================

module waveform_lut (

    input wire [4:0] sample_index,

    input wire [1:0] wave_select,

    output reg [7:0] sample_value

);

    always @* begin

        sample_value = 8'd128;

        case (wave_select)

            // SINE WAVE

            2'b00: begin

                case (sample_index)

                    5'd0:  sample_value = 8'd128;

                    5'd1:  sample_value = 8'd152;

                    5'd2:  sample_value = 8'd176;

                    5'd3:  sample_value = 8'd198;

                    5'd4:  sample_value = 8'd218;

                    5'd5:  sample_value = 8'd234;

                    5'd6:  sample_value = 8'd245;

                    5'd7:  sample_value = 8'd253;

                    5'd8:  sample_value = 8'd255;

                    5'd9:  sample_value = 8'd253;

                    5'd10: sample_value = 8'd245;

                    5'd11: sample_value = 8'd234;

                    5'd12: sample_value = 8'd218;

                    5'd13: sample_value = 8'd198;

                    5'd14: sample_value = 8'd176;

                    5'd15: sample_value = 8'd152;

                    5'd16: sample_value = 8'd128;

                    5'd17: sample_value = 8'd103;

                    5'd18: sample_value = 8'd79;

                    5'd19: sample_value = 8'd57;

                    5'd20: sample_value = 8'd37;

                    5'd21: sample_value = 8'd21;

                    5'd22: sample_value = 8'd10;

                    5'd23: sample_value = 8'd2;

                    5'd24: sample_value = 8'd0;

                    5'd25: sample_value = 8'd2;

                    5'd26: sample_value = 8'd10;

                    5'd27: sample_value = 8'd21;

                    5'd28: sample_value = 8'd37;

                    5'd29: sample_value = 8'd57;

                    5'd30: sample_value = 8'd79;

                    5'd31: sample_value = 8'd103;

                    default: sample_value = 8'd128;

                endcase

            end

            // TRIANGLE WAVE

            2'b01: begin

                case (sample_index)

                    5'd0:  sample_value = 8'd128;

                    5'd1:  sample_value = 8'd143;

                    5'd2:  sample_value = 8'd159;

                    5'd3:  sample_value = 8'd175;

                    5'd4:  sample_value = 8'd191;

                    5'd5:  sample_value = 8'd207;

                    5'd6:  sample_value = 8'd223;

                    5'd7:  sample_value = 8'd239;

                    5'd8:  sample_value = 8'd255;

                    5'd9:  sample_value = 8'd239;

                    5'd10: sample_value = 8'd223;

                    5'd11: sample_value = 8'd207;

                    5'd12: sample_value = 8'd191;

                    5'd13: sample_value = 8'd175;

                    5'd14: sample_value = 8'd159;

                    5'd15: sample_value = 8'd143;

                    5'd16: sample_value = 8'd128;

                    5'd17: sample_value = 8'd112;

                    5'd18: sample_value = 8'd96;

                    5'd19: sample_value = 8'd80;

                    5'd20: sample_value = 8'd64;

                    5'd21: sample_value = 8'd48;

                    5'd22: sample_value = 8'd32;

                    5'd23: sample_value = 8'd16;

                    5'd24: sample_value = 8'd0;

                    5'd25: sample_value = 8'd16;

                    5'd26: sample_value = 8'd32;

                    5'd27: sample_value = 8'd48;

                    5'd28: sample_value = 8'd64;

                    5'd29: sample_value = 8'd80;

                    5'd30: sample_value = 8'd96;

                    5'd31: sample_value = 8'd112;

                    default: sample_value = 8'd128;

                endcase

            end

            // SAWTOOTH WAVE

            2'b10: begin

                case (sample_index)

                    5'd0:  sample_value = 8'd0;

                    5'd1:  sample_value = 8'd8;

                    5'd2:  sample_value = 8'd16;

                    5'd3:  sample_value = 8'd24;

                    5'd4:  sample_value = 8'd32;

                    5'd5:  sample_value = 8'd40;

                    5'd6:  sample_value = 8'd48;

                    5'd7:  sample_value = 8'd56;

                    5'd8:  sample_value = 8'd64;

                    5'd9:  sample_value = 8'd72;

                    5'd10: sample_value = 8'd80;

                    5'd11: sample_value = 8'd88;

                    5'd12: sample_value = 8'd96;

                    5'd13: sample_value = 8'd104;

                    5'd14: sample_value = 8'd112;

                    5'd15: sample_value = 8'd120;

                    5'd16: sample_value = 8'd128;

                    5'd17: sample_value = 8'd136;

                    5'd18: sample_value = 8'd144;

                    5'd19: sample_value = 8'd152;

                    5'd20: sample_value = 8'd160;

                    5'd21: sample_value = 8'd168;

                    5'd22: sample_value = 8'd176;

                    5'd23: sample_value = 8'd184;

                    5'd24: sample_value = 8'd192;

                    5'd25: sample_value = 8'd200;

                    5'd26: sample_value = 8'd208;

                    5'd27: sample_value = 8'd216;

                    5'd28: sample_value = 8'd224;

                    5'd29: sample_value = 8'd232;

                    5'd30: sample_value = 8'd240;

                    5'd31: sample_value = 8'd248;

                    default: sample_value = 8'd128;

                endcase

            end

            // SQUARE WAVE

            2'b11: begin

                sample_value =

                    (sample_index < 5'd16) ? 8'd255 : 8'd0;

            end

            default: begin

                sample_value = 8'd128;

            end

        endcase

    end

endmodule
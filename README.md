# Basic Computer Design in VHDL (Basys3)

This project was developed as part of the **Computer Architecture** course at the Pontifical Catholic University of Chile. The goal was to design and implement a basic computer using the Basys3 development board. This project involved the creation of a CPU, ROM, and I/O functionality using VHDL, as well as an assembler to convert assembly language into machine code to program the ROM.

## Project Stages

The project was divided into three main stages:

### Stage 1: Basic CPU and ROM Design

- Developed the CPU using VHDL.
- Implemented key components such as the Control Unit, ALU (Arithmetic Logic Unit), and memory operations.
- Focused on executing a simple multiplication algorithm written in assembly.

### Stage 2: Advanced Features

- Introduced indirect addressing, subroutines, and stack management.
- Developed an assembler to translate assembly instructions into machine code.
- Programmed the ROM using the assembler output and demonstrated the computer's functionality on the Basys3 board.

### Stage 3: Input/Output and Game Development

In this stage, the focus was on adding I/O capabilities using memory-mapped devices. The architecture was extended to include input and output components such as switches, buttons, LEDs, displays, and an optional LCD screen. The assembler was enhanced to support text and characters for the LCD.

**Input/Output Devices**:
    - **Timer**: Provides seconds, milliseconds, and microseconds.
    - **16-bit Registers**: For controlling the state of LEDs and 7-segment displays.
    - **Multiplexor/Demultiplexor**: To map input/output devices to the data memory.

**Memory-mapped I/O Addresses**:
    - `0`: LEDs (Output)
    - `1`: Switches (Input)
    - `2`: Displays (Output)
    - `3`: Buttons (Input)
    - `4`: Seconds (Input)
    - `5`: Milliseconds (Input)
    - `6`: Microseconds (Input)
    - `7`: LCD (Output)

**LCD Implementation**:
    - The LCD was connected to the Basys3 board via the Pmod Header JB and JC ports. The LCD data bus is 11 bits wide, with the most significant bit used for load control and the other 10 bits for data.

**Game**:

  **Reaction Game**: A game to test players' reaction times. After a countdown on the display, the first player to press their button is shown as the winner on the 7-segment display, and their reaction time is displayed on the LEDs.

This game was written in assembly and loaded onto the ROM using the assembler. Input was handled through the Basys3 switches and buttons, while output was displayed on the LEDs and 7-segment displays.

## Requirements

To run this project, you will need:

- **Basys3 FPGA Development Board**.
- **Vivado Design Suite**: The project was developed using Vivado for synthesis, simulation, and implementation.
- **VHDL Source Files**: Available in this repository.
- **Assembler**: Included in this repository as an executable and source code. Just need to run `python Assembler.py/main.py` to compile the assembler.

### Software Installation

1. **Vivado**: Download and install [Vivado Design Suite](https://www.xilinx.com/support/download.html) from the Xilinx website.
2. **Assembler**: The assembler is provided as an executable. Alternatively, you can compile it from the provided source code using any standard C compiler.

## How to Run

1. **Open the Vivado Project**:
    - Clone this repository and open the Vivado project files in the Vivado Design Suite.
    - Synthesize, implement, and generate the bitstream.

2. **Upload to Basys3**:
    - Connect the Basys3 board to your PC.
    - Upload the generated bitstream (.bit file) to the Basys3 board.

3. **Programming the ROM**:
    - Use the assembler provided to convert your assembly code into machine code, it will automatically program the ROM with the machine code.

4. **Testing**:
    - The included demo programs consist of a reaction game for multiple players. You can modify or create new assembly programs and reprogram the ROM to test different functionalities.

## Project Outcomes

- A fully functional basic computer capable of executing simple programs.
- Demonstrated the ability to implement indirect addressing, subroutines, stack operations, and I/O functionalities.
- Developed a custom assembler to translate human-readable assembly instructions into machine code.
- Created an interactive game using the input/output devices on the Basys3 board.

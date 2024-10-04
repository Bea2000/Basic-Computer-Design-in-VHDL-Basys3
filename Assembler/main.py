# main
import sys
from ast import arg
from iic2343 import Basys3
# sys.argv = argumentos en input, base_prefix = ruta arhcivo, byteorder = endian, excecutable = ruta python
from input_file_processor import get_content
from data_controller import get_data_content
from code_controller import get_code_content, get_labels, get_instructions, get_ram_instructions
import instructions_opcodes

rom_programmer = Basys3()

input_file_path = sys.argv[1]
available_assembly_instructions = instructions_opcodes.load_assembly_instructions("CPU - instructions_opcodes.tsv")
file_content = get_content(input_file_path) #contenido limpiado del assembly
data = get_data_content(file_content)[1] # valores y direcciones
code = get_data_content(file_content)[0]
labels = get_labels(code, len(data)) #labels y sus direcciones
code = get_code_content(file_content) #solo instrucciones

basys_list = []
if __name__ == '__main__':
##############################################################################
    # generamos instrucciones que mueven variables de DATA a RAM 
    ram_instruction = get_ram_instructions(data, available_assembly_instructions)
    # convertimos a formato de librería
    for inst in ram_instruction:
        final_byte_array = int(inst, 2).to_bytes((len(inst) + 7) // 8, 'big')
        final_byte_array = bytearray(final_byte_array)
        basys_list.append(final_byte_array)
##############################################################################
    # generamos el resto de las intrucciones en CODE
    for elem in code:
        final_instruction2 = ''
        instructions = get_instructions(elem, labels, data)
        if instructions is not None:
            # Instrucciones que no cuentan con parámetros
            if instructions[0] == 'RET' or instructions[0] == 'NOP':
                command = instructions[0]
                params = ''
            # instrucciones con parámetros
            else:
                command, params = instructions[0].split(' ')
            opcode = available_assembly_instructions[command][params]
            # comandos con dos instrucciones
            if command == 'RET' or command == 'POP':
                final_instruction = opcode[0] + instructions[1]
                final_instruction2 = opcode[1] + instructions[1]
            # comandos con una instruccion
            else:
                final_instruction = opcode + instructions[1]
            # convertimos a formato de librería
            final_byte_array = bytearray([int(str(final_instruction[0:4]), base = 2),int(str(final_instruction[4:12]), base = 2),int(str(final_instruction[12:20]), base = 2),int(str(final_instruction[20:28]), base = 2),int(str(final_instruction[28:36]), base = 2)])
            basys_list.append(final_byte_array)
            # caso dos instrucciones
            if final_instruction2 != '':
                final_byte_array = bytearray([int(str(final_instruction2[0:4]), base = 2),int(str(final_instruction2[4:12]), base = 2),int(str(final_instruction2[12:20]), base = 2),int(str(final_instruction2[20:28]), base = 2),int(str(final_instruction2[28:36]), base = 2)])
                basys_list.append(final_byte_array)
################################################################################
    # Inicializamos Basys y entregamos instrucciones
    rom_programmer.begin(port_number = 10)
    for i in range(len(basys_list)):
        rom_programmer.write(i, basys_list[i])
    rom_programmer.end()

sys.exit()

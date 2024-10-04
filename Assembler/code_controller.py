from re import X
from number_converter import convert_str_to_bin
from assembly_instruction_recognizer import get_instruction_type


def get_code_content(content_list):
    ## Buscar donde parten instrucciones
    for i in range(len(content_list)):
        if content_list[i] == "CODE:":
            code_position = i
    ## obtener comandos de instrucciones
    commands = content_list[code_position + 1: len(content_list)]
    return commands


def get_labels(code_content, len_data):
    labels = {}
    i = 0
    dir = 2*len_data+1
    while i < len(code_content):
        instruction = code_content[i]
        #Revisar si es instruccion
        type_instruction = get_instruction_type(instruction) #Si es comentario o parte del data = None
        if type_instruction == None:
            valid = False 
        else:
            valid = True
        if valid:
            if type_instruction == "label":
                pos_points = instruction.rfind(":")
                #Revisar si tiene instruccion en la misma linea que label
                if instruction[-1] != ":":
                    label = instruction[0:pos_points]
                    dir += 1
                #Solo está el label en esa linea
                else:
                    label = instruction.replace(':', '')
                label = label.replace('//', '')
                label = label.strip(" ")
                direction = convert_str_to_bin(f"{dir}")
                labels[label] = direction
            elif "POP" in instruction or "RET" in instruction:
                dir += 2
            else:
                dir += 1
        i+=1
    return labels

def get_ram_instructions(data, opcodes):
    ## Variables deben siempre
        ## Guardarse en un registro
    opcode_1 = opcodes["MOV"]["B,Lit"]
        ## Mover valor de registro a la RAM
    opcode_2 = opcodes["MOV"]["(Dir),B"]
    list_instructions = []
    for x in data:
        literal = data[x][1]
        direction = convert_str_to_bin(str(x))
        instruction1 = opcode_1 + literal ## B = valor de var
        instruction2 = opcode_2 + direction ## (var) = B
        list_instructions.append(instruction1)
        list_instructions.append(instruction2)
    instruction3 = opcode_1 + "0000000000000000" ## Reseteamos B (B=0)
    list_instructions.append(instruction3)
    return list_instructions


def get_instructions(code_line, labels, data):
    instruction_type = get_instruction_type(code_line)
    ## revisamos que no sea un label
    if instruction_type != "label":
        # definimos el literal asociado a la instruccion
        literal = "0000000000000000" # (default = 0)
        if "Lit" in instruction_type: # Caso donde provenga de un literal
            pos_comma = code_line.rfind(",")+1
            if code_line[pos_comma:].isnumeric(): # Literal directo
                literal = convert_str_to_bin(code_line[pos_comma:])
            else: # Literal proviene de direccion de variable
                literal = code_line[pos_comma:]
                found = False
                for x in data:
                    if data[x][0] == literal:
                        literal = convert_str_to_bin(str(x))
                        found = True
                if not found:
                    if literal[-1] == "h" or literal[-1] == "d" or literal[-1] == "b":  #Caso donde sea utilizado otro formato de numero
                        literal = convert_str_to_bin(code_line[pos_comma:])
        elif "(Dir)" in instruction_type: # Caso donde provenga de dato en RAM
            pos_comma = code_line.rfind(",")+1
            if pos_comma == 0: #instrucciones con un parametro como INC (Dir)
                literal = code_line.split(" ")[1].strip("()")
            else:
                if "(" in code_line[pos_comma:]: # Mover a dirección Ej: MOV (dir),A
                        literal = code_line[pos_comma:].strip("()")
                else: # Usar direccion Ej: MOV A,(dir)
                    literal = code_line[:pos_comma-1].split(" ")[1].strip("()")
            # Convertir literal a binario
            if not literal.isnumeric(): 
                for x in data: # Si no es número busco el dato
                    if data[x][0] == literal:
                        literal = convert_str_to_bin(str(x))
            else:
                literal = convert_str_to_bin(literal)
        elif "Ins" in instruction_type: # Debo buscar dirección de salto
            search = code_line.split(" ")[1]
            print(search)
            literal = labels[search]
            print(instruction_type,literal)
        elif "INC A" in instruction_type or "DEC A" in instruction_type: # Se resta o suma 1
            literal = "0000000000000001"
        return [instruction_type,literal]
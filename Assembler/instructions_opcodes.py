def load_assembly_instructions(path):
    instructions_dict = {}
    specialCommands = ['RET', 'POP', '', 'NOP']

    with open(path) as file:
        lines = file.readlines()
        for i in range(len(lines)):
            this_line_list = lines[i].strip('\n').replace('\t', ' ').split(' ')

            command = this_line_list[0]
            parameters = this_line_list[1]
            if command not in specialCommands:
                opcode = this_line_list[2]

                if command not in instructions_dict.keys():
                    instructions_dict[command] = {}
                    instructions_dict[command][parameters] = opcode
                else:
                    instructions_dict[command][parameters] = opcode
            else:
                if command != '':
                    if i < len(lines) - 1:
                        next_line_list = lines[i + 1].strip('\n').replace('\t', ' ').split(' ')
                    if command == 'POP':
                        opcode_1 = this_line_list[2]
                        opcode_2 = next_line_list[1]
                        opcode = [opcode_1, opcode_2]
                        if command not in instructions_dict.keys():
                            instructions_dict[command] = {}
                            instructions_dict[command][parameters] = opcode
                        else:
                            instructions_dict[command][parameters] = opcode
                    elif command == 'NOP':
                        opcode = this_line_list[1]
                        parameters = ''
                        if command not in instructions_dict.keys():
                            instructions_dict[command] = {}
                            instructions_dict[command][parameters] = opcode
                        else:
                            instructions_dict[command][parameters] = opcode
                    else:
                        opcode_1 = this_line_list[1]
                        opcode_2 = next_line_list[1]
                        opcode = [opcode_1, opcode_2]
                        if command not in instructions_dict.keys():
                            instructions_dict[command] = {'': opcode}

    return instructions_dict

def get_instruction_type(full_instruction):
    # Recibe una línea de código de CODE sin comentarios 
    full_instruction_list = full_instruction.split(' ')

    # Todos los elementos de largo 2
    if len(full_instruction_list) == 1:
        full_instruction_list.insert(1, "")

    # ["MOV", "A,(variable2)"]
    instruction = full_instruction_list[0]
    parameters = full_instruction_list[1].split(",")
    # reconocimiento
    if instruction == "DATA:":
        return "DATA"
    elif instruction == "CODE:":
        return "CODE"
    elif ":" in instruction:
        return "label"
    else:
        # Manejo de parámetros
        final_parameters = " "
        for i in range(2):
            if  (i == 0 and parameters[0] != "") or (i == 1 and len(parameters) > 1):
                if "(" in parameters[i]:
                    if "B" in parameters[i]:
                        final_parameters += f"{parameters[i]},"
                    else:
                        final_parameters += "(Dir),"
                else:
                    if parameters[i] == "A" or parameters[i] == "B":
                        final_parameters += f"{parameters[i]},"
                    elif instruction[0] == "J" or instruction == "CALL":
                        final_parameters += "Ins"
                    else:
                        final_parameters += "Lit"
        final_parameters = final_parameters.strip(",")
    return instruction + final_parameters
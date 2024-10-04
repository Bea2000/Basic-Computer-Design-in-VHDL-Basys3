def convert_str_to_bin(value):
    # Evaluamos los values x dataType y los guardamos como binarios
    scale = 0
    # binario
    if 'b' in value:
        value = value.split('b')[0]
        value = value.zfill(16)
    # decimal
    elif 'd' in value:
        scale = 10
        value = value.split('d')[0]
        value = bin(int(value, scale)).zfill(16)
    # hexadecimal
    elif 'h' in value:
        scale = 16
        value = value.split('h')[0]
        value = bin(int(value, scale)).zfill(16)
    # default = decimal
    else:
        scale = 10
        value = bin(int(value)).zfill(16)
    # Arreglar error de formato (b puesta para expresar número binario)
    b_pos = value.rfind("b")
        # Caso b en el inicio
    if b_pos == 1:
        value = value[2:]
        while len(value) < 16:
            value = "0" + value
        # Cualquier otro caso
    else:
        value = value.replace("b","0")
    return value

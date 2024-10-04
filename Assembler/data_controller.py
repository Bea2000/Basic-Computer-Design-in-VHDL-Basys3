from number_converter import convert_str_to_bin


def get_data_content(file_content):
    data = {}

    memory = 0

    # Poblar DATA
    while file_content[0] != 'CODE:':
        if file_content[0] == 'DATA:':
            pass
        # Si el value no es un string
        elif "'" not in file_content[0] and '"' not in file_content[0]:
            if ' ' in file_content[0]:
                label, value = file_content[0].split(' ')
                value = convert_str_to_bin(value)
                data[memory] = [label, value]
                memory += 1
            else:
                label, value = data[memory - 1]
                value = convert_str_to_bin(file_content[0])
                data[memory] = [label, value]
                memory += 1

        # Si el value es un string
        else:
            label, value = file_content[0].split(' ', 1)
            value = value.replace("'", "")
            value = ''.join(format(ord(i), '08b') for i in value)
            data[memory] = [label, value]
            memory += 1
        file_content.pop(0)
    file_content = file_content[1:]
    return [file_content,data]

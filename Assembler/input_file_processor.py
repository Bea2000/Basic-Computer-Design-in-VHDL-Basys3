import re


def remove_first_end_spaces(string):
    return "".join(string.rstrip().lstrip())


def get_content(path):
    content = []
    # Poblar content
    with open(path) as f:
        while True:
            line = f.readline()
            # Remove tabs
            element = line.strip('\n').replace('\t', ' ')
            # Remove //
            element = element.split('//')[0]
            # Remove extra space between strings
            element = re.sub(' +', ' ', element)
            # Remove first and end spaces
            element = remove_first_end_spaces(element)
            if element != '':
                content.append(element)
            if not line:
                break
    return content

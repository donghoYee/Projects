import sys

string = sys.argv[1]
string = string.replace("%", "%0x")
string = string.replace(" ", "%20")
string_list = string.split("%")[1:]
string_to_int = [int(string,16) for string in string_list]
decoded_string = bytearray(string_to_int).decode('utf-8')
print(decoded_string, end="")
sys.stdout.flush()
import math 

def makemaps():
    max_int = 2**14
    values = []
    number = [0]*(max_int )
    for i in range(max_int):
        result = calculations(i)
        if result not in values:
            values.append(result)

        number[i] = values.index(result)

    # Specify the file path
    file_path = 'map_hex.mem'

    # Open the file in write mode
    with open(file_path, 'w') as file:
        # Write each element to a new line
        for element in number:
            binary_number = convert_to_10_bit_unsigned_binary(element)
            hex_result = '0x{:03X}'.format(int(binary_number, 2))[2:]
            file.write(str(hex_result) + '\n')

    # Specify the file path
    file_path = 'arctan_palette_hex.mem'

    # Open the file in write mode
    with open(file_path, 'w') as file:
        # Write each element to a new line
        for element in values:
            binary_number = convert_to_16_bit_signed_binary(element)
            hex_result = '0x{:04X}'.format(int(binary_number, 2))[2:]
            file.write(str(hex_result) + '\n')
      

def convert_to_10_bit_unsigned_binary(number):
    thirteen_bit_binary = 0
    if(number >=0):
        binary_representation = bin(number)
        binary_string = binary_representation[2:]
        thirteen_bit_binary = format(int(binary_string, 2), '010b')
 
  
    return thirteen_bit_binary
           

def convert_to_16_bit_signed_binary(number):
    thirteen_bit_binary = 0
    if(number >=0):
        binary_representation = bin(number)
        binary_string = binary_representation[2:]
        thirteen_bit_binary = format(int(binary_string, 2), '016b')
    else: 
        binary_representation = bin(abs(number)-1)
        binary_string = binary_representation[2:]
        thirteen_bit_binary = format(int(binary_string, 2), '016b')
        new_string = ""
        for (i, bit) in enumerate(thirteen_bit_binary):
            if bit == "0":
                new_string += "1"
            else:
                new_string += "0"
        #print(new_string)
        
        #print(thirteen_bit_binary)
        thirteen_bit_binary = new_string
   
  
    return thirteen_bit_binary

def calculations(distance):
    #    AngleCorrectForDistance = (int32_t)((atan(((21.8 * (155.3 - (node.distance))) /
    #    155.3) / (node.distance))) * 3666.93);
    if(distance == 0 ): 
        return round(math.atan(100000)*3666.93)
    out =  round((math.atan(((21.8 * (155.3 - (distance))) /155.3) / (distance))) * 3666.93)
    #print(out)
    return out 
makemaps()
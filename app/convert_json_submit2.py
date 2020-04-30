import os
import json
from collections import OrderedDict

# filename
FILE = "./result.txt"

reshape_result = {}
detect_class = ["Car", "Truck", "Pedestrian", "Bicycle", "Signal", "Signs"]
class_num = [0, -1, 1, -1, 2, -1, 3, -1, 4, 5]

with open(FILE) as fr:
    while True: 
        line_str = fr.readline()
        if(not line_str):
            break
        line_array = line_str.split()
        # line array must be {filename, category, x_min, y_min, x_max, y_max}
        filename       = line_array[0]
        category_index = class_num[int(line_array[1])]
        x_min          = int(line_array[2])
        y_min          = int(line_array[3])
        x_max          = int(line_array[4])
        y_max          = int(line_array[5])

        if category_index != -1:
            category = detect_class[category_index]
            if reshape_result.get(filename) is None:
                reshape_result[filename] = {}
            if not category in reshape_result[filename]:
                reshape_result[filename][category] = []
            reshape_result[filename][category].append([x_min,y_min,x_max,y_max])

lost_result = 0
for i in range(6355):
    fname = "test_{:04d}.jpg".format(i)
    if reshape_result.get(fname) is None:
        reshape_result[fname] = {}
        lost_result += 1

#print(reshape_result)
#print(lost_result)

with open("./pred_answer.json",mode="w") as fw:
    json.dump(reshape_result, fw)

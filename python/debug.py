import numpy as np
from PIL import Image

w, h = Image.open('ship.png').size

print(f"Img:{w * h}")
print()

with open("R_out.txt", 'r') as file:
    contents = file.read()
    print(f"R:{len(contents)}") 

with open("G_out.txt", 'r') as file:
    contents = file.read()
    print(f"G:{len(contents)}")  

with open("B_out.txt", 'r') as file:
    contents = file.read()
    print(f"B:{len(contents)}")
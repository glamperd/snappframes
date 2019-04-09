import cv2
from PIL import Image
import base64
from hashlib import sha256
import json
import io
try:
    to_unicode = unicode
except NameError:
    to_unicode = str

def get_num_pixels(filepath):
    width, height = Image.open(filepath).size
    return width, height

filepath = 'bokky.png'
width, height = get_num_pixels(filepath)

img = cv2.imread(filepath)
length =  int(height/4)
width =  int(width/2)

hashes = [ ]
for r in range(0,img.shape[0],length):
    for c in range(0,img.shape[1],width):
        
        #split image into chunks
        img_filename = f"img{r}_{c}.png"
        img_chunk = img[r:r+length, c:c+width,:]
        cv2.imwrite(img_filename, img_chunk)

        #encode image chunk into base64
        encoded_filename = f"img{r}_{c}.json"
        with open(img_filename, "rb") as image_file:
                encoded_string = base64.b64encode(image_file.read())

        ##hash encoding
        encoded_hash = sha256(encoded_string).hexdigest()
        hashes.append(encoded_hash)

        # Define data
        data = {'encoded_string': str(encoded_string),
                'encoded_hash': str(encoded_hash)}

        # Write JSON file
        with io.open(encoded_filename, 'w', encoding='utf8') as outfile:
                str_ = json.dumps(data,
                                indent=4, sort_keys=True,
                                separators=(',', ': '), ensure_ascii=False)
                outfile.write(to_unicode(str_))

with io.open('hashes.json', 'w', encoding='utf8') as outfile:
        str_ = json.dumps(hashes,
                        indent=4, sort_keys=True,
                        separators=(',', ': '), ensure_ascii=False)
        outfile.write(to_unicode(str_))

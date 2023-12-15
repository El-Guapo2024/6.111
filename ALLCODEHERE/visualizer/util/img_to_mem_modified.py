import sys
from PIL import Image, ImageOps

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: {0} <image to convert>".format(sys.argv[0]))

    else:
        input_fname = sys.argv[1]
        image_in = Image.open(input_fname)
        image_in = image_in.convert('L')
        threshold = 128
              
        scale_factor = 1  # You can adjust this factor as needed
        scaled_image = image_in.resize(
            (int(image_in.width * scale_factor), int(image_in.height * scale_factor))
        )
        inverted_image =  ImageOps.invert(scaled_image)
        inverted_image = inverted_image.point(lambda p: p > threshold and 255)
      
 
        
        image_out = inverted_image.copy()
        w, h = image_out.size
        # Save the image itself
        with open(f'image_invert_scaled.mem', 'w') as f:
            for y in range(h):
                for x in range(w):
                    if(image_out.getpixel((x,y)) == 0):
                        f.write(f'{0:01}\n')
                    else:
                        f.write(f'{1:01b}\n')
 

        print('Output image saved at image.mem')


def crop_and_save(input_image_path, output_image_path):
    image = Image.open(input_image_path)
    image = image.convert("RGBA")

    # Crop the image (assuming white background)
    cropped_image = image.crop(image.getbbox())

    # Save the result
    cropped_image.save(output_image_path)
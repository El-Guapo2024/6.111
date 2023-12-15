from PIL import Image, ImageOps

def crop_and_save(input_image_path, output_image_path):
     # Open the image in grayscale mode
    image = Image.open(input_image_path).convert("L")

    # Invert the colors (make letters white and background black)
    threshold = 128
    inverted_image = ImageOps.invert(image)
    inverted_image = inverted_image.point(lambda p: p > threshold and 255)
      
 
    # Get the bounding box of non-black pixels
     # Determine the size of the final cropped image
    

    spacing = inverted_image.height/4-
    # Create a new image with the final size
    final_cropped_image = Image.new("L", (final_width, final_height), color=255)


    # Crop the image using the bounding box
    for i in range(0,4):
        bbox = (0, i*letter_height,final_width,)
    

    # Invert the colors back to the original (letters are black, background is white)
    cropped_image = ImageOps.invert(cropped_image)

    # Save the result
    cropped_image.save(output_image_path)

letter_height = 20
input_image_path = "./compact_letter_sprites.png"
output_image_path = "./compact_letter_sprites.png"
crop_and_save(input_image_path, output_image_path)
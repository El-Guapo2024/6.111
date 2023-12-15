from PIL import Image, ImageOps

def crop_and_save(input_image_path, output_image_path):
     # Open the image in grayscale mode
    image = Image.open(input_image_path).convert("L")

    # Invert the colors (make letters white and background black)
    threshold = 128
    inverted_image = ImageOps.invert(image)
    inverted_image = inverted_image.point(lambda p: p > threshold and 255)
      
 
    # Get the bounding box of non-black pixels
    bbox = inverted_image.getbbox()

    # Crop the image using the bounding box
    cropped_image = inverted_image.crop(bbox)

    # Invert the colors back to the original (letters are black, background is white)
    cropped_image = ImageOps.invert(cropped_image)

    # Save the result
    cropped_image.save(output_image_path)


input_image_path = "./download.png"
output_image_path = "./compact_letter_sprites.png"
crop_and_save(input_image_path, output_image_path)
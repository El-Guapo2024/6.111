from PIL import Image, ImageOps

def remove_first_white_row(image):
    # Find the index of the first row that is entirely white
    white_row_index = next((row_index for row_index in range(image.height) if all(image.getpixel((x, row_index)) == 255 for x in range(image.width))), None)

    if white_row_index is not None:
        # Create a new image without the first entirely white row
        new_height = image.height - 1
        new_image = Image.new("L", (image.width, new_height), color=255)

        new_row_index = 0
        for row_index in range(image.height):
            # Skip the first entirely white row
            if row_index == white_row_index:
                continue

            # Copy non-white rows to the new image
            new_image.paste(image.crop((0, row_index, image.width, row_index + 1)), (0, new_row_index))
            new_row_index += 1

        return new_image
    else:
        # If no row is entirely white, return the original image
        return image

def remove_all_white_rows(input_image_path, output_image_path):
    # Open the image in grayscale mode
    image = Image.open(input_image_path).convert("L")

    # Invert the colors (make letters white and background black)
    inverted_image = ImageOps.invert(image)

    # Get the bounding box of non-black pixels
    bbox = inverted_image.getbbox()

    # Crop the image using the bounding box
    cropped_image = inverted_image.crop(bbox)

    # Invert the colors back to the original (letters are black, background is white)
    cropped_image = ImageOps.invert(cropped_image)

    # Remove all entirely white rows using a loop
    while True:
        modified_image = remove_first_white_row(cropped_image)

        # Break the loop if the modified image is the same as the original
        if modified_image.tobytes() == cropped_image.tobytes():
            break

        # Update the image for the next iteration
        cropped_image = modified_image

    # Save the result
    modified_image.save(output_image_path)

# Example usage
input_image_path = "./compact_letter_sprites.png"
output_image_path = "./nowhiterows.png"
remove_all_white_rows(input_image_path, output_image_path)

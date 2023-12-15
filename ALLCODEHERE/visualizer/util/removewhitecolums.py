from PIL import Image, ImageOps

def remove_first_white_column(image):
    # Find the index of the first column that is entirely white
    white_column_index = next((col_index for col_index in range(image.width) if all(image.getpixel((col_index, y)) == 255 for y in range(image.height))), None)

    if white_column_index is not None:
        # Create a new image without the first entirely white column
        new_width = image.width - 1
        new_image = Image.new("L", (new_width, image.height), color=255)

        new_col_index = 0
        for col_index in range(image.width):
            # Skip the first entirely white column
            if col_index == white_column_index:
                continue

            # Copy non-white columns to the new image
            new_image.paste(image.crop((col_index, 0, col_index + 1, image.height)), (new_col_index, 0))
            new_col_index += 1

        return new_image
    else:
        # If no column is entirely white, return the original image
        return image

def remove_all_white_columns(input_image_path, output_image_path):
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

    # Remove all entirely white columns using a loop
    while True:
        modified_image = remove_first_white_column(cropped_image)

        # Break the loop if the modified image is the same as the original
        if modified_image.tobytes() == cropped_image.tobytes():
            break

        # Update the image for the next iteration
        cropped_image = modified_image

    # Save the result
    modified_image.save(output_image_path)

# Example usage
input_image_path = "./nowhiterows.png"
output_image_path = "./nowhite.png"
remove_all_white_columns(input_image_path, output_image_path)

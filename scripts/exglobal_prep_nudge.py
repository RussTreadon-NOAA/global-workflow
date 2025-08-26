#!/usr/bin/env python3
# forecast_completer.py
import sys
import os

def main():
    """
    Takes a forecast hour as a command-line argument and writes a completion
    status to an ASCII text file.
    """
    # --- 1. Input Validation ---
    # Check if exactly one command-line argument (the forecast hour) is provided.
    # sys.argv is a list containing the script name at index 0, followed by arguments.
    if len(sys.argv) != 2:
        print("Usage: python forecast_completer.py <forecast_hour>")
        print("Example: python forecast_completer.py 12")
        sys.exit(1) # Exit the script with an error code

    forecast_hour_str = sys.argv[1]

    # Check if the provided argument is a valid integer.
    try:
        forecast_hour = int(forecast_hour_str)
    except ValueError:
        print(f"Error: Invalid forecast hour '{forecast_hour_str}'. Please provide an integer.")
        sys.exit(1)

    # --- 2. File Operations ---
    # Define the name of the output file.
    output_filename = f"forecast_hour_{forecast_hour:03d}_completed.txt"
    
    # Get the directory where the script is located to save the file there.
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_filepath = os.path.join(script_dir, output_filename)

    # Create the content to be written to the file.
    content = f"Forecast hour {forecast_hour} has been completed.\n"

    # --- 3. Write to File ---
    try:
        # 'with open(...) as f:' ensures the file is automatically closed
        # even if errors occur. 'w' mode means write (creates a new file or
        # overwrites an existing one).
        with open(output_filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"Successfully wrote completion status to: {output_filepath}")

    except IOError as e:
        print(f"Error: Could not write to file {output_filepath}.")
        print(f"Reason: {e}")
        sys.exit(1)

# --- Script Entry Point ---
# This ensures the main() function is called only when the script is executed directly.
if __name__ == "__main__":
    main()

import serial
import csv
from datetime import datetime

# Set up serial connection (adjust COM port and baud rate)
ser = serial.Serial('COM9', 115200)

# Output CSV file
csv_filename = f"serial_output_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"

with open(csv_filename, mode='w', newline='') as file:
    writer = csv.writer(file)

    print(f"Writing to {csv_filename}. Press Ctrl+C to stop.")
    try:
        writer.writerow(["Time_s_,I"])
        while True:
            line = ser.readline().decode('utf-8').strip()
            if line:
                row = line.split(',')  # Adjust delimiter if needed
                writer.writerow(row)
                print(row)
    except KeyboardInterrupt:
        print("Stopped by user.")
    finally:
        ser.close()

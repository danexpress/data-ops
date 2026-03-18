import os
import csv
import random
from datetime import datetime, timedelta


def generate_temperature_csv(filename, num_records=1000):
    if num_records < 0:
        raise ValueError("num_records must be a non-negative integer")

    cities = ["New York", "London", "Tokyo", "Paris", "Sydney"]
    header = ["City", "Temperature", "timestamp"]

    os.makedirs(os.path.dirname(filename), exist_ok=True)

    try:
        with open(filename, "w", newline="") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(header)

            for _ in range(num_records):
                city = random.choice(cities)
                temp = round(random.uniform(10, 35), 1)
                time = datetime.now() - timedelta(days=random.randint(0, 365))

                writer.writerow([city, temp, time.isoformat()])

    except (IOError, OSError) as e:
        raise IOError(f"Failed to generate temperature CSV file: {str(e)}")


if __name__ == "__main__":
    generate_temperature_csv("data/temperature_data.csv")

from pathlib import Path
import sys


def main():
    if len(sys.argv) != 3:
        print("Usage: python3 bin_to_mem.py <input.bin> <output.mem>")
        sys.exit(1)

    input_file = Path(sys.argv[1])
    output_file = Path(sys.argv[2])

    data = input_file.read_bytes()

    if len(data) % 4:
        data += bytes(4 - len(data) % 4)

    with output_file.open("w") as f:
        for i in range(0, len(data), 4):
            word = int.from_bytes(data[i:i + 4], "little")
            f.write(f"{word:08x}\n")

    print(
        f"Generated {output_file} "
        f"({len(data) // 4} instructions)"
    )


if __name__ == "__main__":
    main()
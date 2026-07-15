import os
import sys
import struct

def fix_samsung_recovery_image(img_path, dt_path, page_size):
    with open(img_path, 'rb') as f:
        img = bytearray(f.read())
    with open(dt_path, 'rb') as f:
        dt_data = f.read()
    if len(img) < page_size:
        print(f"Error: image too small ({len(img)} < {page_size})")
        return 1
    magic = img[0:8]
    kernel_size = struct.unpack_from('<I', img, 8)[0]
    ramdisk_size = struct.unpack_from('<I', img, 16)[0]
    page_size_hdr = struct.unpack_from('<I', img, 36)[0]
    dt_size = struct.unpack_from('<I', img, 40)[0]
    print(f"kernel_size: {kernel_size}, ramdisk_size: {ramdisk_size}, page_size: {page_size_hdr}")
    header_pages = 1
    kernel_pages = (kernel_size + page_size - 1) // page_size
    ramdisk_pages = (ramdisk_size + page_size - 1) // page_size
    dt_offset = (header_pages + kernel_pages + ramdisk_pages) * page_size
    if len(img) < dt_offset:
        img.extend([0] * (dt_offset - len(img)))
    img.extend(dt_data)
    dt_pages = (len(dt_data) + page_size - 1) // page_size
    padded_end = (header_pages + kernel_pages + ramdisk_pages + dt_pages) * page_size
    while len(img) < padded_end:
        img.append(0)
    struct.pack_into('<I', img, 40, len(dt_data))
    with open(img_path, 'wb') as f:
        f.write(img)
    print(f"Fixed: dt_size={len(dt_data)}, dt.img at offset {dt_offset}")
    return 0

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <recovery.img> <dt.img> <page_size>")
        sys.exit(1)
    sys.exit(fix_samsung_recovery_image(sys.argv[1], sys.argv[2], int(sys.argv[3])))

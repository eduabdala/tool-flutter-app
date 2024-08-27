import tkinter as tk
from tkinter import messagebox
import hashlib
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from binascii import unhexlify
import json
import argparse

def convert_and_hash(hex_serial_number):
    decimal_serial_number = str(int(hex_serial_number, 16))
    padded_serial_number = decimal_serial_number.zfill(20)
    ascii_value = ''.join(format(ord(char), '02x') for char in padded_serial_number)
    sha256_hash = hashlib.sha256(ascii_value.encode('ascii')).hexdigest()
    return sha256_hash

def derivate_key(key, data):
    iv = bytes([0] * 16)
    cipher = Cipher(algorithms.AES(unhexlify(key)), modes.CBC(iv), backend=default_backend())
    encryptor = cipher.encryptor()
    encrypted_data = encryptor.update(unhexlify(data)) + encryptor.finalize()
    return encrypted_data.hex()

def calculate_kcv(key):
    iv = bytes([0] * 16)
    zero_block = bytes([0] * 16)
    cipher = Cipher(algorithms.AES(unhexlify(key)), modes.CBC(iv), backend=default_backend())
    encryptor = cipher.encryptor()
    encrypted_kcv = encryptor.update(zero_block) + encryptor.finalize()
    return encrypted_kcv.hex()[:6]

def convert_to_hex(value):
    return hex(int(str(value), 0))[2:].upper().zfill(8)

def derive_key(hw_id, original_key):
    
    try:
        hex_hw_id = convert_to_hex(hw_id).zfill(8)
        hashed_serial = convert_and_hash(hex_hw_id)
        derivated_key = derivate_key(original_key, hashed_serial)
        kcv = calculate_kcv(derivated_key)
        
        return print(derivated_key,kcv)
    except Exception as e:
        messagebox.showerror("Error", str(e))




if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Chamar minha funcao com argumentos")
    parser.add_argument("arg1", type=str, help="Primeiro argumento")
    parser.add_argument("arg2", type=str, help="Segundo argumento")
    args = parser.parse_args()

    derive_key(args.arg1, args.arg2)

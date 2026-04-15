#!/usr/bin/env python3
import os
import sys

def find_verilog_files(root_dir):
    """Ищет файлы с расширениями .v или .sv"""
    verilog_files = []
    for file in os.listdir(root_dir):
        if file.endswith('.v') or file.endswith('.sv'):

            rel_path = os.path.abspath(os.path.join(root_dir, file))
            verilog_files.append(rel_path)
    return verilog_files

def create_file(path:str, file_name:str):    
    os.chdir(path)
    files = find_verilog_files('.')    
    with open(file_name, 'w') as f:
        for file_path in files:
            f.write(file_path + '\n')
    

def main():
    if len(sys.argv) != 3:
        print("Использование: script.py <rtl_dir> <tb_dir>")
        sys.exit(1)
    
    rtl_dir = os.path.abspath(sys.argv[1])
    tb_dir = os.path.abspath(sys.argv[2])
    
    if not os.path.exists(rtl_dir):
        print(f"Ошибка: Директория {rtl_dir} не существует")
        sys.exit(1)
    
    if not os.path.exists(tb_dir):
        print(f"Ошибка: Директория {tb_dir} не существует")
        sys.exit(1)

    create_file(rtl_dir, 'rtl.files')
    create_file(tb_dir, 'tb.files')      

if __name__ == "__main__":
    main()
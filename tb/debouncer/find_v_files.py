#!/usr/bin/env python3
import os
import sys

def find_verilog_files(root_dir):
    """Ищет файлы с расширениями .*v"""
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
    script_dir = os.path.dirname(os.path.abspath(__file__))
    prj_dir = os.path.abspath(os.path.join(script_dir, '../..'))
    
    rtl_dir = os.path.join(prj_dir, 'src')
    if not os.path.exists(rtl_dir):
        print(f"Ошибка: Директория {rtl_dir} не существует")
        sys.exit(1)
    
    tb_dir = os.path.join(prj_dir, 'tb', 'timer')
    if not os.path.exists(tb_dir):
        print(f"Ошибка: Директория {tb_dir} не существует")
        sys.exit(1)

    create_file(rtl_dir, 'rtl.files')
    create_file(tb_dir, 'tb.files')        

if __name__ == "__main__":
    main()
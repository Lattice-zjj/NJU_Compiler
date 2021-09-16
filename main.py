import os
from utils.logger import setup_logger
def main():
    logger = setup_logger("Compiler Test", "./Result")
    path = './test' #待读取文件的文件夹绝对地址
    files = os.listdir(path) #获得文件夹中所有文件的名称列表
    list0 = [] #存放path路径中的文件内容
    list1 = [] #存放path中子文件夹的文件内容
    for file in files:
        print(file, os.path.isdir(file))
        if not os.path.isdir(file): #判断是否是文件夹   
            f = open(path+"/"+file)
            s = [] #初始化列表
            print(s.append(f))
        else:
            path1 = path+"/"+file
            files1 = os.listdir(path1)
            for file1 in files1:
                f = open(path1+"/"+file1)
                s = [] #初始化列表
                for ii in f: #遍历文件，一行行读取，并添加到s中  
                    s.append(ii)  
                    list1.append(s)
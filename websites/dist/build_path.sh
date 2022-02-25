#!/bin/bash
#### 此脚本用于批量修改资源路径(局限性：仅能修改双引号标记的资源。如：`href="xxxx"`，而不能修改类似`href=''`等单引号引用的资源)
#### 2022-02-26


#### 预设参数
#
# 要修改的文件路径(HTML文件和JS文件修改方法不同)
html_fp="
index.html
"
js_fp="
js/app.edeb6736.js
js/app.edeb6736.js.map
"
# 要修改的root前缀(`/js/`就是`/`；`https://baidu.com/js/`就是`https://baidu.com/`)
wroot="/"
# 目标root前缀(假设chroot="https://baidu.com/",修改后`js/`就是`https://baidu.com/js/`；`1.png`就是`https://baidu.com/1.png`)
wchroot="http://rmshadows.gitee.io/html-template/websites/dist/"
# 需要重构路径的 完整的 文件名 或者 文件夹名（注意：文件夹请以“/”结尾，需要全称）
todo_list="
favicon.ico
css/
js/
img/
"
# 资源引用符号(默认双引号)
quotes="\""

#############################
#### 下列预设参数请勿修改谢谢
# 储存修改前的字符串
src_list=""
# 储存修改后的字符串
dst_list=""
# UID
ROOT_UID=0

#### 脚本内置函数调用
#
## 控制台颜色输出
# 红色：警告、重点
# 黄色：警告、一般打印
# 绿色：执行日志
# 蓝色、白色：常规信息
# 颜色colors
CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # warning color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"
# echo like ...  with  flag type  and display message  colors
# -s 绿
# -e 红
# -w 黄
# -i 蓝
prompt () {
    case ${1} in
        "-s"|"--success")
        echo -e "${b_CGSC}${@/-s/}${CDEF}";;
        "-x"|"--exec")
        echo -e "日志：${b_CGSC}${@/-x/}${CDEF}";;
        "-e"|"--error")
        echo -e "${b_CRER}${@/-e/}${CDEF}";;
        "-w"|"--warning")
        echo -e "${b_CWAR}${@/-w/}${CDEF}";;
        "-i"|"--info")
        echo -e "${b_CCIN}${@/-i/}${CDEF}";;
        "-m"|"--msg")
        echo -e "信息：${b_CCIN}${@/-m/}${CDEF}";;
        "-k"|"--kv")  # 三个参数
        echo -e "${b_CCIN} ${2} ${b_CWAR} ${3} ${CDEF}";;
        *)
            echo -e "$@"
        ;;
    esac
}
## 询问函数 Yes:1 No:2 ???:5
:<<!询问函数
函数调用请使用：
comfirm "\e[1;33m? [y/N]\e[0m"
choice=$?
if [ $choice == 1 ];then
  yes
elif [ $choice == 2 ];then
  prompt -i "——————————  下一项  ——————————"
else
  prompt -e "ERROR:未知返回值!"
  exit 5
fi
!询问函数
comfirm () {
  flag=true
  ask=$1
  while $flag
  do
    echo -e "$ask"
    read -r input
    if [ -z "${input}" ];then
      # 默认选择N
      input='n'
    fi
    case $input in [yY][eE][sS]|[yY])
      return 1
      flag=false
    ;;
    [nN][oO]|[nN])
      return 2
      flag=false
    ;;
    *)
      prompt -w "Invalid option..."
    ;;
    esac
  done
}


#### 修改文件的函数
html_edit(){
    prompt -w "下列HTML文件将被修改："
    num=1
    for ((i=0;i<$html_fp_len;i++));do
        item=${html_fp[$i]}
        prompt -s "$num) $item"
        num=$((num+1))
    done
    prompt -i "==============================================================================================="
    # 检查需要被替换的字符
    num=1
    for ((i=0;i<$src_list_len;i++));do
        item=${src_list[$i]}
        prompt -i "$num) $item"
        num=$((num+1))
    done
    num=1
    prompt -w "上列字符将被替换成下列："
    for ((i=0;i<$dst_list_len;i++));do
        item=${dst_list[$i]}
        prompt -s "$num) $item"
        num=$((num+1))
    done
    prompt -i "===============================================================================================\n\n\n\n"
    #### 这里是确认运行的模块
    comfirm "\n\n\n\n\e[1;31m 批量替换HTML文件资源引用[y/N]\e[0m"
    choice=$?
    if [ $choice == 1 ];then
        prompt -x "开始批量替换......"
        #### 开始批量替换
        #
        for ((i=0;i<$html_fp_len;i++));do
            filepath=${html_fp[$i]}
            prompt -x "正在修改文件：$filepath"
            for ((i=0;i<$src_list_len;i++));do
                src=${src_list[$i]}
                dst=${dst_list[$i]}
                # prompt -w "$src"
                # prompt -w "$dst"
                sed -i 's|'$src'|'$dst'|g' $filepath
            done
        done
        prompt -m "HTML文件修改完成。"
    elif [ $choice == 2 ];then
        prompt -w "Quit !"
    fi
}
# 修改JS的方法
js_edit(){
    prompt -w "下列Java Script文件将被修改："
    num=1
    for ((i=0;i<$js_fp_len;i++));do
        item=${js_fp[$i]}
        prompt -s "$num) $item"
        num=$((num+1))
    done
    #### 这里是确认运行的模块
    comfirm "\n\n\n\n\e[1;31m 批量替换Java Script文件资源引用(谨慎！)[y/N]\e[0m"
    choice=$?
    if [ $choice == 1 ];then
        prompt -x "开始批量替换......"
        #### 开始批量替换
        for ((i=0;i<$js_fp_len;i++));do
            filepath=${js_fp[$i]}
            prompt -x "正在修改文件：$filepath"
            # ^img/*.(jpg)$
            # sed 's#*.jpg#++++++++++++++++++++++++++++++++++++++++++++++++++++++#g' $filepath
            sed 's/*jpg*/++++++++++++++++++++++++++++++++++++++++++++++++++++++/g' $filepath
        done
        prompt -m "JS文件修改完成。"
    elif [ $choice == 2 ];then
        prompt -w "Quit !"
    fi
}


#### 正文
#
#### 检查是否有root权限，有则退出，提示用户使用普通用户权限。
prompt -i "\n检查权限  ——    Checking for root access...\n"
if [ "$UID" -eq "$ROOT_UID" ];then
    # Error message
    prompt -e "\n [ Error ] -> 请不要使用管理员权限运行 Please DO NOT run as root  \n"
    exit 1
else
    prompt -w "\n——————————  Unit Ready  ——————————\n"
fi
#### 预处理
#
# 转为列表
todo_list=($todo_list)
html_fp=($html_fp)
js_fp=($js_fp)
# 列表长度
todo_list_len=${#todo_list[@]}
html_fp_len=${#html_fp[@]}
js_fp_len=${#js_fp[@]}
# 生成被修改字符
for ((i=0;i<$todo_list_len;i++));do
    item=${todo_list[$i]}
    src_list[$i]="$quotes$wroot$item"
done
src_list_len=${#src_list[@]}
# 生成被修改字符
for ((i=0;i<$todo_list_len;i++));do
    item=${todo_list[$i]}
    dst_list[$i]="$quotes$wchroot$item"
done
dst_list_len=${#dst_list[@]}
# 修改文件
html_edit

# TODO: JS批量替换失败，正则表达式不通过
# js_edit

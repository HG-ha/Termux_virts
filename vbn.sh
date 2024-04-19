#######################################################################
# Script Name: vbn.sh                                                 #
# Description: It is used to manage VMS.                              #
# Author: Yi ming                                                     #
# Date: April 18, 2024                                                #
# Version: 1.0                                                        #
# Home: api.wer.plus                                                  #
# Github: github.com/HG-ha                                            #
# QQ Group: 376957298                                                 #
#######################################################################

# Exit immediately if an error occurs
# 有任何错误直接退出
set -e

# ADAPTS to termux and other linux
# 适配termux和其他Linux
if [ ! -n $TERMUX_VERSION ]; then
    package_manager="pkg"
else
    distro=$(cat /etc/os-release | grep '^ID=' | cut -d'=' -f2 | tr -d '"')
    case "$distro" in
        "ubuntu" | "debian")
            package_manager="apt install -y"
            ;;
        "centos" | "rhel")
            package_manager="yum install -y"
            ;;
        "alpine")
            package_manager="apk add"
            ;;
        *)
            echo "未知的 Linux 发行版。"
            exit 1
            ;;
    esac
fi

# github domestic proxy
github_proxy="https://hub.gitmirror.com/"

# Virtual machine list
# 存储虚拟机的信息
vmlist='{
    "centos7":{
        "iso": "CentOS-7-x86_64-Everything-2009.iso",
        "filename": "centos7-x86_64-2009.qcow2",
        "install": "Minimal Installation",
        "installed_by": "Yi ming",
        "allocation_size": "40G",
        "actual_size": "1.62G",
        "format": "qcow2",
        "username": "root",
        "password": "123456",
        "download": "wget -O ${HOME}/.vbn_vms/centos7-x86_64-2009.qcow2 --no-check-certificate https://onw.cc/1drv.ms.php?url=https://1drv.ms/u/s\\!AkrWd-0ZuuopwxxuVncSv2WOkvUk",
        "notes": "请使用vnc或ssh连接\n\n\t在字符模式下界面将无法正常显示\n\t默认vnc方式启动\n\n\t若要上网请修改dns文件: /etc/resolv.conf\n\n\t默认暴露22端口到宿主机18022端口\n\t外部ssh命令: ssh root@127.0.0.1 -p 18022",
        "hostfwd": "tcp::18022-:22",
        "default_command": "qemu-system-x86_64 -m 1G -netdev user,id=n1,hostfwd=tcp::18022-:22 -device virtio-net,netdev=n1 -hda ${HOME}/.vbn_vms/centos7-x86_64-2009.qcow2",
        "custom_command": "qemu-system-x86_64 -hda ${HOME}/.vbn_vms/centos7-x86_64-2009.qcow2 "
    },"alpine319":{
        "iso": "alpine-virt-3.19.1-x86_64.iso",
        "filename": "alpine-3.19.1-x86_64.qcow2",
        "install": "default",
        "installed_by": "Yi ming",
        "allocation_size": "40G",
        "actual_size": "378M",
        "format": "qcow2",
        "username": "root",
        "password": "123456",
        "download": "wget -O ${HOME}/.vbn_vms/alpine-3.19.1-x86_64.qcow2 --no-check-certificate https://onw.cc/1drv.ms.php?url=https://1drv.ms/u/s\\!AkrWd-0ZuuopwxmgM-RJhj4G3KH9",
        "notes": "在该版本中安装docker似乎有问题\n\t如有docker需求建议3.18版本\n\n\t若要上网请修改dns文件: /etc/resolv.conf\n\n\t默认暴露22端口到宿主机18022端口\n\t外部ssh命令: ssh root@127.0.0.1 -p 18022",
        "hostfwd": "tcp::18022-:22",
        "default_command": "qemu-system-x86_64 -m 1G -nographic -netdev user,id=n1,hostfwd=tcp::18022-:22 -device virtio-net,netdev=n1 -hda ${HOME}/.vbn_vms/alpine-3.19.1-x86_64.qcow2",
        "custom_command": "qemu-system-x86_64 -hda ${HOME}/.vbn_vms/alpine-3.19.1-x86_64.qcow2 "
    },"alpine318":{
        "iso": "alpine-virt-3.18.0-x86_64.iso",
        "filename": "alpine-3.18.0-x86_64.qcow2",
        "install": "default",
        "installed_by": "Yi ming",
        "allocation_size": "40G",
        "actual_size": "92M",
        "format": "qcow2",
        "username": "root",
        "password": "alpine",
        "download": "wget -O ${HOME}/.vbn_vms/alpine-3.18.0-x86_64.qcow2 --no-check-certificate https://onw.cc/1drv.ms.php?url=https://1drv.ms/u/s\\!AkrWd-0ZuuopwxpjDnxCLFc9rDx3",
        "notes": "若要上网请修改dns文件/etc/resolv.conf\n\n\t默认暴露22端口到宿主机18022端口\n\t外部ssh命令: ssh root@127.0.0.1 -p 18022",
        "hostfwd": "tcp::18022-:22",
        "default_command": "qemu-system-x86_64 -m 1G -nographic -netdev user,id=n1,hostfwd=tcp::18022-:22 -device virtio-net,netdev=n1 -hda ${HOME}/.vbn_vms/alpine-3.18.0-x86_64.qcow2",
        "custom_command": "qemu-system-x86_64 -hda ${HOME}/.vbn_vms/alpine-3.18.0-x86_64.qcow2 "
    },"bt_centos7":{
        "iso": "CentOS-7-x86_64-Everything-2009.iso",
        "filename": "bt_centos7-x86_64-2009.qcow2",
        "install": "Minimal Installation, bt_panel_v8.0.6",
        "installed_by": "Yi ming",
        "allocation_size": "40G",
        "actual_size": "2.7G",
        "format": "qcow2",
        "username": "root",
        "password": "123456",
        "download": "wget -O ${HOME}/.vbn_vms/bt_centos7-x86_64-2009.qcow2 --no-check-certificate https://onw.cc/1drv.ms.php?url=https://1drv.ms/u/s\\!AkrWd-0Zuuopwxf15mFt-3zcIO8q",
        "notes": "安装了宝塔8.0.6版本的centos7\n\n\t面板地址: http://127.0.0.1:25479/ed978faa\n\tbt_username: yiming\n\tbt_password: yiming\n\t运行宝塔: bt 3\n\n\t请使用vnc或ssh连接\n\t在字符模式下界面将无法正常显示\n\n\t默认vnc方式启动\n\n\t若要上网请修改dns文件/etc/resolv.conf\n\n\t默认暴露22端口到宿主机18022端口\n\t外部ssh命令: ssh root@127.0.0.1 -p 18022",
        "hostfwd": "tcp::18022-:22, tcp::25479-:25479",
        "default_command": "qemu-system-x86_64 -m 2G -smp 2 -netdev user,id=n1,hostfwd=tcp::18022-:22,hostfwd=tcp::25479-:25479 -device virtio-net,netdev=n1 -hda ${HOME}/.vbn_vms/bt_centos7-x86_64-2009.qcow2",
        "custom_command": "qemu-system-x86_64 -hda ${HOME}/.vbn_vms/bt_centos7-x86_64-2009.qcow2 "
    },"bt_alpine318":{
        "iso": "alpine-virt-3.18.0-x86_64.iso",
        "filename": "bt_alpine-3.18.0-x86_64.qcow2",
        "install": "default, bt_panel_v8.0.6",
        "installed_by": "Yi ming",
        "allocation_size": "40G",
        "actual_size": "1.3G",
        "format": "qcow2",
        "username": "root",
        "password": "alpine",
        "download": "wget -O ${HOME}/.vbn_vms/bt_alpine-3.18.0-x86_64.qcow2 --no-check-certificate https://onw.cc/1drv.ms.php?url=https://1drv.ms/u/s\\!AkrWd-0Zuuopwxj4dUIheBdSmlvz",
        "notes": "安装了宝塔8.0.6版本的alpine3.18\n\n\t面板地址: http://127.0.0.1:11306/eaeab87a\n\tbt_username: oqlsnrhi\n\tbt_password: 71e1f417\n\t运行宝塔: bt 3\n\n\t若要上网请修改dns文件/etc/resolv.conf\n\n\t默认暴露22端口到宿主机18022端口\n\t外部ssh命令: ssh root@127.0.0.1 -p 18022",
        "hostfwd": "tcp::18022-:22, tcp::11306-:11306",
        "default_command": "qemu-system-x86_64 -m 1G -nographic -netdev user,id=n1,hostfwd=tcp::18022-:22,hostfwd=tcp::11306-:11306 -device virtio-net,netdev=n1 -hda ${HOME}/.vbn_vms/bt_alpine-3.18.0-x86_64.qcow2",
        "custom_command": "qemu-system-x86_64 -hda ${HOME}/.vbn_vms/bt_alpine-3.18.0-x86_64.qcow2 "
    }
}'

# Check and install
# 检查并自动安装命令
check_command() {
    if ! command -v "${1}" &> /dev/null; then
        echo "install : ${1}"
        eval ${package_manager} ${1}
        echo -e "\n\n\n"
    fi
}

# Inspector directory
# 检查家目录
check_home_dir(){
    if [ ! -d ${HOME}/.vbn_vms ]; then
        mkdir ${HOME}/.vbn_vms
    fi
}

# The VM file exists
# 虚拟机文件是否存在
vm_file_exits() {
    if [ ! -f "${HOME}/.vbn_vms/${1}" ]; then
        echo -e "\033[33mNo VM is installed\033[0m"
        exit 1
    fi
}

# Obtain all supported VMS
# 获取所有支持的虚拟机
get_vms() {
    check_command "jq"
    vm_list=`echo ${vmlist} | jq -r "keys[]"`
    echo -e "\033[31mVM list:\033[0m"
    for vm_name in $vm_list
    do
        vm_iso=`echo ${vmlist} | jq -r ".${vm_name}.iso"`
        vm_size=`echo ${vmlist} | jq -r ".${vm_name}.actual_size"`
        vm_desc=`echo ${vmlist} | jq -r ".${vm_name}.notes"`
        echo -e "
    \033[32mname\033[0m: \033[31m${vm_name}\033[0m
    \033[32miso\033[0m : \033[31m${vm_iso}\033[0m
    \033[32msize\033[0m: \033[31m${vm_size}\033[0m
    \033[32mdesc\033[0m: \033[36m${vm_desc}\033[0m
"
    done
}

# Install a VM.
# 安装虚拟机
install_vm() {
    check_home_dir
    # check availability
    # 检查可用性
    if echo ${vmlist} | jq -e ".${1}" > /dev/null; then
        # Check whether the VM file exists
        # 检查是否存在虚拟机文件
        vm_file=`echo ${vmlist} | jq -r ".${1}.filename"`
        if [ -f "${HOME}/.vbn_vms/${vm_file}" ]; then
            read -p "The VM file is detected. Do you want to continue downloading? (y/n): " input
            if [ ${input} = "y" ]; then
                echo -e "\033[33mOverlay download\033[0m"
            else
                echo -e "\033[33mInvalid selection, exit\033[0m"
                exit 0
            fi
        fi

        # Download process
        download=`echo ${vmlist} | jq -r ".${1}.download"`
        echo -e "\n\033[32m##### Download ${1}\033[0m\n"
        eval ${download}
        if [ $? -eq 0 ]; then
            echo -e "\033[32m##### Download command executed successfully\033[0m"
            echo -e "\033[32m##### installation complete\033[0m"
            echo -e "\033[32m##### You can start running ${1}\033[0m"
            echo -e "\033[32m\n\ncommand: vbn start ${1}\033[0m"
        else
            echo -e "\033[33mDownload command failed\033[0m"
            exit 1
        fi
    else
        echo -e "
\033[33mThe VM is out of range
虚拟机不在支持范围内\033[0m"
    fi
}

# command prompt
# 指令选项
case ${1} in
    "list")
        # Lists all virtual machines
        # 列出所有虚拟机
        get_vms
        ;;
    "install")
        # Install the specified VM
        # 安装指定虚拟机
        if [ -n "$2" ]; then
            install_vm $2
        else
            echo -e "
Enter the virtual machine you want to install
请输入要安装的虚拟机
"
        fi
        ;;
    "info")
        # View all information about a specified VM
        # 查看指定虚拟机的全部信息
        if [ -n "$2" ] ;then
            if echo ${vmlist} | jq -e ".${2}" > /dev/null; then
                echo ${vmlist} | jq ".${2}"
            else
                echo -e "
\033[33mThe VM is out of range
虚拟机不在支持范围内\033[0m"
            fi
        else
            echo -e "
Specify the virtual machine you want to view
请指定要查看的虚拟机
"
        fi
        ;;
    "start")
        # Start the specified VM
        # 启动指定虚拟机
        if [ -n "$2" ]; then
            if echo ${vmlist} | jq -e ".${2}" > /dev/null; then
                # Check whether the VM file exists
                # 检查是否存在虚拟机文件
                vm_file=`echo ${vmlist} | jq -r ".${2}.filename"`
                vm_file_exits ${vm_file}
                start_vm=`echo ${vmlist} | jq -r ".${2}.default_command"`
                if [ $3 = "-D" ]; then
                    eval ${start_vm} &> /dev/null &
                else
                    eval ${start_vm}
                fi
            else
                echo -e "
\033[33mThe VM is out of range
虚拟机不在支持范围内\033[0m"
            fi
        else
            echo -e "
Specify the virtual machine you want to start
请指定要启动的虚拟机
"
        fi
        ;;
    "stop")
        # Kill the VM process directly. Some operations may not be saved
        # 直接杀死虚拟机进程，有些操作可能会无法保存
        # Shut down the virtual machine as normally as possible
        # 尽可能在虚拟机内正常关机
        if [ -n "$2" ] ;then
            if echo ${vmlist} | jq -e ".${2}" > /dev/null; then
                vm_file=`echo ${vmlist} | jq -r ".${2}.filename"`
                vm_file_exits ${vm_file}
                vm_pid=`ps -u | grep ${vm_file} | grep -v grep | awk '{print $2}'`
                if [ -z "${vm_pid}" ]; then
                    echo -e "\033[32mThe VM is not started\033[0m"
                else
                    kill ${vm_pid}
                    if [ $? -eq 0 ]; then
                        echo -e "\033[32mKill ${2} success\033[0m"
                    else
                        echo -e "\033[33mKill ${2} failed\033[0m"
                    fi
                fi
            else
                echo -e "
\033[33mThe VM is out of range
虚拟机不在支持范围内\033[0m"
            fi
        else
            echo -e "
Specify the virtual machine you want to stop
请指定要停止的虚拟机
"
        fi
        ;;
    "status")
        # Kill the VM process directly. Some operations may not be saved
        # 直接杀死虚拟机进程，有些操作可能会无法保存
        # Shut down the virtual machine as normally as possible
        # 尽可能在虚拟机内正常关机
        if [ -n "$2" ] ;then
            if echo ${vmlist} | jq -e ".${2}" > /dev/null; then
                vm_file=`echo ${vmlist} | jq -r ".${2}.filename"`
                vm_file_exits ${vm_file}
                vm_pid=`ps -u | grep ${vm_file} | grep -v grep | awk '{print $2}'`
                if [ -z "${vm_pid}" ]; then
                    echo -e "\033[32mThe VM is not running\033[0m"
                else
                    echo -e "\033[32mThe VM is running, PID: ${vm_pid}\033[0m"
                fi
            else
                echo -e "
\033[33mThe VM is out of range
虚拟机不在支持范围内\033[0m"
            fi
        else
            echo -e "
Specify the virtual machine you want to view
请指定要查看的虚拟机
"
        fi
        ;;
    "snapshot")
        # Vm snapshot management
        # 虚拟机快照管理
        case ${2} in
            "a")
                # Adding a snapshot
                # 添加快照
                if [ -n "$3" ] ;then
                    if echo ${vmlist} | jq -e ".${3}" > /dev/null; then
                        vm_file=`echo ${vmlist} | jq -r ".${3}.filename"`
                        vm_file_exits ${vm_file}
                        check_command "qemu-img"
                        if [ -n "$4" ] ;then
                            qemu-img snapshot -c "${4}" "${HOME}/.vbn_vms/${vm_file}"
                            if [ $? -eq 0 ]; then
                                echo -e "\033[32mSnapshot ${3} is successfully add for the VM ${2}\033[0m"
                            else
                                echo -e "\033[33mFailed to add a snapshot\033[0m"
                            fi
                        else
                            echo -e "\033[33mSpecify snapshot name\033[0m"
                            exit 1
                        fi
                    else
                        echo -e "
        \033[33mThe VM is out of range
        虚拟机不在支持范围内\033[0m"
                    fi
                else
                    echo -e "
        Specify the virtual machine that you want to operate
        请指定要操作的虚拟机
        "
                fi
                ;;
            "r")
                # Restore a VM to a snapshot
                # 恢复虚拟机到快照
                if [ -n "$3" ] ;then
                    if echo ${vmlist} | jq -e ".${3}" > /dev/null; then
                        vm_file=`echo ${vmlist} | jq -r ".${3}.filename"`
                        vm_file_exits ${vm_file}
                        check_command "qemu-img"
                        if [ -n "$4" ] ;then
                            qemu-img snapshot -a "${4}" "${HOME}/.vbn_vms/${vm_file}"
                            if [ $? -eq 0 ]; then
                                echo -e "\033[32mThe VM ${3} is successfully restored to snapshot ${4}\033[0m"
                            else
                                echo -e "\033[33mSnapshot recovery failure\033[0m"
                            fi
                        else
                            echo -e "\033[33mSpecify snapshot name\033[0m"
                            exit 1
                        fi
                    else
                        echo -e "
        \033[33mThe VM is out of range
        虚拟机不在支持范围内\033[0m"
                    fi
                else
                    echo -e "
        Specify the virtual machine that you want to operate
        请指定要操作的虚拟机
        "
                fi
                ;;
            "d")
                # Deleting a Snapshot
                # 删除快照
                if [ -n "$3" ] ;then
                    if echo ${vmlist} | jq -e ".${3}" > /dev/null; then
                        vm_file=`echo ${vmlist} | jq -r ".${3}.filename"`
                        vm_file_exits ${vm_file}
                        check_command "qemu-img"
                        if [ -n "$4" ] ;then
                            qemu-img snapshot -d "${4}" "${HOME}/.vbn_vms/${vm_file}"
                            if [ $? -eq 0 ]; then
                                echo -e "\033[32msuccessfully delete\033[0m"
                            else
                                echo -e "\033[33mfail to delete\033[0m"
                            fi
                        else
                            echo -e "\033[33mSpecify snapshot name\033[0m"
                            exit 1
                        fi
                    else
                        echo -e "
        \033[33mThe VM is out of range
        虚拟机不在支持范围内\033[0m"
                    fi
                else
                    echo -e "
        Specify the virtual machine that you want to operate
        请指定要操作的虚拟机
        "
                fi
                ;;
            "l")
                # View VM snapshots
                # 查看虚拟机的快照
                if [ -n "$3" ] ;then
                    if echo ${vmlist} | jq -e ".${3}" > /dev/null; then
                        vm_file=`echo ${vmlist} | jq -r ".${3}.filename"`
                        vm_file_exits ${vm_file}
                        check_command "qemu-img"
                        qemu-img snapshot -l "${HOME}/.vbn_vms/${vm_file}"
                        # if [ -n "${comm}" ]; then
                        #     echo -e "\033[32mNo snapshot is created for the current VM\033[0m"
                        # fi
                    else
                        echo -e "
        \033[33mThe VM is out of range
        虚拟机不在支持范围内\033[0m"
                    fi
                else
                    echo -e "
        Specify the virtual machine that you want to operate
        请指定要操作的虚拟机
        "
                fi
                ;;
            *)
                :
                ;;
        esac
        ;;
    update)

        ;;
    *)
        echo "It's something else."
        ;;
esac
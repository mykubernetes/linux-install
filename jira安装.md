```
wget https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-7.13.0-x64.bin



[root@YZSJHL82-204 ~]# chmod +x atlassian-jira-software-7.13.0-x64.bin
[root@YZSJHL82-204 ~]# ./atlassian-jira-software-7.13.0-x64.bin
Unpacking JRE ...
Starting Installer ...
十月 23, 2018 4:38:25 下午 java.util.prefs.FileSystemPreferences$1 run
信息: Created user preferences directory.
十月 23, 2018 4:38:25 下午 java.util.prefs.FileSystemPreferences$2 run
信息: Created system preferences directory in java.home.

This will install JIRA Software 7.4.1 on your computer.
OK [o, Enter], Cancel [c]
o               #按o安装
Choose the appropriate installation or upgrade option.
Please choose one of the following:
Express Install (use default settings) [1], Custom Install (recommended for advanced users) [2, Enter], Upgrade an existing JIRA installation [3]
2               #2为自定义安装

Where should JIRA Software be installed?
[/opt/atlassian/jira]
/usr/local/atlassina/jira       #自定义安装目录
Default location for JIRA Software data
[/var/atlassian/application-data/jira]
/usr/local/atlassina/jira_data          #自定义数据目录
Configure which ports JIRA Software will use.
JIRA requires two TCP ports that are not being used by any other
applications on this machine. The HTTP port is where you will access JIRA
through your browser. The Control port is used to startup and shutdown JIRA.
Use default ports (HTTP: 8080, Control: 8005) - Recommended [1, Enter], Set custom value for HTTP and Control ports [2]
2               #2为自定义端口
HTTP Port Number
[8080]          #8080为默认端口
8050            #http连接端口
Control Port Number
[8005]
8040            #控制端口
JIRA can be run in the background.
You may choose to run JIRA as a service, which means it will start
automatically whenever the computer restarts.
Install JIRA as Service?
Yes [y, Enter], No [n]
y               #是否开机自启
Details on where JIRA Software will be installed and the settings that will be used.
Installation Directory: /usr/local/atlassina/jira 
Home Directory: /usr/local/atlassina/jira_data 
HTTP Port: 8050 
RMI Port: 8040 
Install as service: Yes 
Install [i, Enter], Exit [e]
i               #确认已选配置

Extracting files ...


Please wait a few moments while JIRA Software is configured.
Installation of JIRA Software 7.4.1 is complete
Start JIRA Software 7.4.1 now?
Yes [y, Enter], No [n]
y               #启动

Please wait a few moments while JIRA Software starts up.
Launching JIRA Software ...
Installation of JIRA Software 7.4.1 is complete
Your installation of JIRA Software 7.4.1 is now ready and can be accessed
via your browser.
JIRA Software 7.4.1 can be accessed at http://localhost:8050
Finishing installation ...
```  

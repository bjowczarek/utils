
update-java-alternatives is actually pretty nice. So, to get it to work with my manual installation: copy jdk1.8.0_45 to /usr/lib/jvm
```
cp .java-1.7.0-openjdk-amd64.jinfo .java-1.8.0-u45-amd64.jinfo
ln -s jdk1.8.0_45 java-1.8.0-u45-amd64
```
Then I used vim for a search / replace:
```
vim .java-1.8.0-u45-amd64.jinfo
:%s/java-7-openjdk-amd64/java-1.8.0-u45-amd64
:wq
```
Also decrement the priority by 1

:sigh: update-java-alternatives doesn't do the installation. But at least we have a file to work with
```
VirtualBox:/usr/lib/jvm$ cat .java-1.8.0-u45-amd64.jinfo  | perl -e 'while (<>) { @line = split(/\s+/); $filename = $line[1]; $abspath = $line[2]; $abspath =~ /(.*jdk[^\/]+)/; $manpath = $1 . "/man/man1/"; $manfile = "$manpath$filename.1"; if (-f $manfile) { system("sudo gzip $manfile"); } system("sudo update-alternatives --install /usr/bin/$filename $filename $abspath 1070 --slave /usr/share/man/man1/$filename.1.gz $filename.1.gz $manfile.gz"); }'
```
Then I selected my new installation:

```
VirtualBox:/usr/lib/jvm$ sudo update-java-alternatives -l
java-1.7.0-openjdk-amd64 1071 /usr/lib/jvm/java-1.7.0-openjdk-amd64
java-1.8.0-u45-amd64 1070 /usr/lib/jvm/java-1.8.0-u45-amd64

VirtualBox:/usr/lib/jvm$ sudo update-java-alternatives -s java-1.8.0-u45-amd64
```
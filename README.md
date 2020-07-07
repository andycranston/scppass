# scppass

An expect script to run the `scp` command and if `scp` asks for a password then automatically supply one.

## WAIT! You should use public/private keys

Yes you should. Definitely. 100%. Always.

...but sometimes you may have to copy many files to/from many systems
using `scp` with passwords. For example during an initial deployment. The
`scppass` expect script is a tool to allow you to automate these file
copying processes.

## Technical demonstration video

This link:

[Technical Demonstration Video of the scppass expect script](https://youtu.be/j5G639stqnU)

shows the `scppass` expect script in action.

## Pre-requisites

The `expect` package must be installed and `/usr/local/bin/expect` must be the
`expect` executable (or a link to it).

## Installing the `scppass` expect script

Copy the `scppass.exp` file from the repository, rename it to `scppass`
and place it in a directory that is listed in your `PATH` environment
variable. Make sure it has execute permission/mode set on it.

A command sequence similar to:

```
cp scppass.exp $HOME/bin/scppass
cd $HOME/bin
chmod u=rwx,go=rx scppass
```

might be appropriate for your environment.

## Running the `scppass` expect script

First set the environment variable `SCPPASS` to contain the password
for the user on the remote system you want to copy files to/from.

For example if the user is `andyc` on remote system `nserv` has a
password of `notmypassword` (*) then this command sequence (**) on a
`bash` like shell:

```
SCPPASS=notmypassword
export SCPPASS
```

would work.

(*) NOTE: `notmypassword` is not a password I have ever used!!! It is
here purely for this documentation.

(**) NEVER do this on anything except for a demonstration
environment. Here are two reasons why. One, someone might be looking
over your shoulder and see the password. Two, most `bash` like shells
store each typed command in a history file which could be read by other
users with elevated priviledges (e.g. anyone who can `sudo` to get
`root` access).

A better way to set environment variables like `SCPPASS` to passwords is
to use my utility called `setpw` - see:

[Set Windows/UNIX/Linux environment variables with a password but keep the password hidden](https://github.com/andycranston/setpw)

Now that the `SCPPASS` environment variable has been set you can use the
`scppass` expect script to copy a file from a remote system like this:

```
scppass andyc@nserv:/home/andyc/myfile myfile
```

This will copy the file `/home/andyc/myfile` from the remote system
`nserv` using the user name `andyc` and password from environment variable
`SCPPASS` to a file called `myfile` in the current directory.

Here is an example run:

```
$ scppass andyc@nserv:/home/andyc/myfile myfile
Password variable: SCPPASS, timeout: 60 seconds, yes/no response: no.
spawn scp andyc@nserv:/home/andyc/myfile myfile
andyc@nserv's password:
myfile                                        100% 1494     1.5KB/s   00:00
$
```

Similarly a file on the local system can be copied to the remote system
like this:

```
scppass myfile andyc@nserv:/home/andyc/myfile
```

Here is another example run:

```
swstore $ scppass myfile andyc@nserv:/home/andyc/myfile
Password variable: SCPPASS, timeout: 60 seconds, yes/no response: no.
spawn scp myfile andyc@nserv:/home/andyc/myfile
andyc@nserv's password:
myfile                                        100% 1494     1.5KB/s   00:00
$
```

## Default fail safe

When using the `scp` command to copy files to or from a remote
system for the first time a message similar to:

```
The authenticity of host 'nserv (10.1.1.8)' can't be established.
ECDSA key fingerprint is SHA256:mA/Df1QvZd79YAFhihx49jVObthoIt3USodO5bMhorc.
Are you sure you want to continue connecting (yes/no)?
```

might be displayed and the `scp` command waits for the user to respond
with `yes` or `no`.

Because the `scppass` expect script runs the `scp` command it has to
handle this situation. By default it takes a "fail safe" approach and
will automatically default to answering `no`.  For example:

```
$ scppass myfile andyc@nserv:/home/andyc/myfile
Password variable: SCPPASS, timeout: 60 seconds, yes/no response: no.
spawn scp myfile andyc@nserv:/home/andyc/myfile
The authenticity of host 'nserv (10.1.1.8)' can't be established.
ECDSA key fingerprint is SHA256:mA/Df1QvZd79YAFhihx49jVObthoIt3USodO5bMhorc.
Are you sure you want to continue connecting (yes/no)?
*** Assuming it is NOT ok to continue connecting!!! ***
no
Host key verification failed.
lost connection
$
```

## Command line option `-e`

Normally the `scppass` expect script gets the password from the
environment variable `SCPPASS`.  If the password is stored in
a different environment variable you can use the `-e` command line option
to name it. For exampe if the password is stored in
an environment variable `ANDYPASS` you could use:

```
scppass -e ANDYPASS myfile andyc@nserv:/home/andyc/myfile
```

and the password would be taken from the `ANDYPASS` environment variable.

## Command line option `-t`

The `scppass` expect script will exit with an error it if determines
there has not been any activity for 60 seconds (one minute). Because
the transfer of large files over slow links can easily take longer than
this  the command line option `-t` (for timeout) can be specified
with a different timeout value. The timeout value is specified in seconds.
For example:

```
scppass -t 180 myfile andyc@nserv:/home/andyc/myfile
```

would use a timeout of 180 seconds (three minutes).

## Command line option `-y`

We have seen that the default fail safe approach of answering
the question:

```
Are you sure you want to continue connecting (yes/no)?
```

is `no`. There mayb be some limited circumstances when you would
want the `scppass` expect script to answer `yes`. To do this use the
`-y` command line option. For example:

```
scppass -y myfile andyc@nserv:/home/andyc/myfile
```

Here is an example run:

```
$ scppass -y myfile andyc@nserv:/home/andyc/myfile
Password variable: SCPPASS, timeout: 60 seconds, yes/no response: yes.
spawn scp myfile andyc@nserv:/home/andyc/myfile
The authenticity of host 'nserv (10.1.1.8)' can't be established.
ECDSA key fingerprint is SHA256:mA/Df1QvZd79YAFhihx49jVObthoIt3USodO5bMhorc.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'nserv,10.1.1.8' (ECDSA) to the list of known hosts.
andyc@nserv's password:
myfile                                        100% 1494     1.5KB/s   00:00
$
```

ATTENTION: USE THIS COMMAND LINE OPTION WITH EXTREME CAUTION!!!

I will repeat that:

ATTENTION: USE THIS COMMAND LINE OPTION WITH EXTREME CAUTION!!!

Remember that you are responsible for the security of the systems
you administer.

## Command line option order

The `scppass` expect script processes command line options in a rather
simple way. If specifying two or possibly all three command line
options the order they are specified matters otherwise they will not be
recognised.

The `-e` option, if specified, must be specified first. The
`-y` option, if specified, must be specified last. The `-t` option,
if specified with either of the `-e` or `-y` options must be specified
after `-e` and before `-y`.

## A final word on public/private keys

Normally you should use public/private keys to allow you to use the `scp`
command without entering passwords. While the `scppass` expect script
might be a handy workaround for an environment where public/private keys
cannot be used (or are yet to be set up) you should do everything you
can to implement public/private keys as soon as you can. It will involve
some work and possibly having to persuade others of the benefits but it
is the right thing to do.

---------------------------------------------------------------

End of README.md

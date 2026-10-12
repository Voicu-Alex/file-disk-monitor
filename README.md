# File & Disk Usage Monitor

A Bash tool that compares two snapshots of a Linux system recorded with the `script` command and produces a **human-readable report** of what changed: files and directories that were created or deleted, and disk-usage differences.

Project for the *Computer Science Tools and Techniques* course (ITBI), Faculty of Mathematics and Computer Science, University of Bucharest, 2025–2026.

## The problem

`script` logs (`typescript` files) contain everything printed in a terminal, including colour codes and control characters. Comparing the output of `ls -l` and `df` between two moments by hand is slow and error-prone.

## How it works

1. **Clean**: strips control characters and ANSI escape codes (`col -b`, `sed`)
2. **Extract**: keeps the `ls -l` entries and the `df` lines (`grep`, `awk`)
3. **Compare**: runs `diff` on the extracted snapshots
4. **Report**: turns the raw diff into plain sentences

Temporary files live in a private `mktemp` directory that is removed automatically on exit.

## Usage

```bash
chmod +x monitor.sh

# compare two recorded sessions
./monitor.sh session1.log session2.log

# compare a recorded session with the current state of the directory
./monitor.sh session1.log
```

Example output:

```
Raport monitorizare :
Fisiere/directoare sterse :
a.txt

Fisiere/directoare noi :
nou.txt

Modificari spatiu disc :
Inainte : /dev/sda1  41152736 10240000 28800000  27% /
Acum : /dev/sda1     41152736 10240032 28799968  27% /
```

Runs in under a second on MB-sized logs and needs only standard tools (Bash, grep, sed, awk, diff), so it works on any Linux distribution.

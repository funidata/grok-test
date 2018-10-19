Test [logstash grok](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html) patterns against input files.

# Examples

## Configuring Grok patterns
NOTE: this does *NOT* test logstash filter configurations, only grok patterns. You should move your `grok { match => ... }` regexes to grok pattern files, leaving a minimal `logstash.conf` filter:

```
filter {
  if [type] == "sshd" {
    grok {
      patterns_dir => [ "/logstash/patterns/" ]
      match => { "message" => '%{PAM_LOG}|%{SSHD_LOG}' }
    }
  }
}
```

The same `patterns_dir` and `match` pattern arguments can then be passed to `grok-test`:

```
$ grok-test --patterns roles/logstash/files/patterns/ --pattern '%{PAM_LOG}|%{SSHD_LOG}'
```

## Generating input logs for testing

If you are matching against the logstash `message` field, then you must feed the plain log messages as input, not entire syslog logfiles.

This is easy to do using `systemd-journald`:

```
$ journalctl -t sudo -o cat
   terom : TTY=pts/3 ; PWD=/home/terom ; USER=root ; COMMAND=/sbin/lvs
```

## Generated grok-test output

The generated output consists of:

* The original input line
* Grok captures, one per line, indented
* An empty line

```
$ journalctl -t sudo -o cat PRIORITY=5 -n 1 | grok-test --patterns roles/logstash/files/patterns/ --pattern '%{PAM_LOG}|%{SUDO_LOG}'  
   terom : TTY=pts/19 ; PWD=/home/terom ; USER=root ; COMMAND=/usr/bin/apt upgrade
	user: terom
	sudo.tty: pts/19
	sudo.pwd: /home/terom
	sudo.user: root
	sudo.command: /usr/bin/apt upgrade

```

## Comparing output changes when grok patterns change

Setup a directory with `*.log` files, and use the included `grok-test.sh` script to diff `*.log` -> `*.out` changes:

```
$ ~/grok-test/setup.sh
$ mkdir roles/logstash/grok-test
$ journalctl -t sudo -o cat > roles/logstash/grok-test/sudo.log
```

The first argument to `grok-test.sh` is the path prefix to the `*.log` file, and the script will generate/update a corresponding `*.out` file:

```
$ mkdir tests
$ GROK_TEST=.bin/grok-test .bin/grok-test.sh roles/logstash/grok-test/sudo --patterns roles/logstash/files/patterns --pattern '%{PAM_LOG}|%{SUDO_LOG}'
[DIFF] roles/logstash/grok-test/sudo
    --- roles/logstash/grok-test/sudo.out	2018-10-19 14:03:26.096453730 +0300
    +++ roles/logstash/grok-test/sudo.new	2018-10-19 14:03:27.412457705 +0300
    @@ -83,5 +83,5 @@
     	sudo.group: docker
     	sudo.env: TEST=foo
     	sudo.command: /bin/echo test
    -	sudo.error:
    +	sudo.error: command not allowed

```

The `*.log` and `*.out` files should be commited to version control as test-case input/expected-output files

# Requirements

* ruby

# Setup

Use the included `setup.sh` script to build and install the gem into your user gempath (`~/.gem`), installing the binstubs into `.bin` in your current working directory:

```
$ .../setup.sh
$ .bin/grok-test --help
$ GROK_TEST=.bin/grok-test .bin/grok-test.sh ...
```

# Usage

```
Usage: grok-test [options] --pattern=PATTERN [INPUT-FILES]...
        --debug
        --verbose
    -P, --patterns=PATH              Load patterns
        --all-captures               Use all captures, not only named
    -p, --pattern=PATTERN            Match pattern
```

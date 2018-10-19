Test [logstash grok](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html) patterns against input files.

# Examples

## Configuring Grok patterns
NOTE: this does *NOT* test logstash filter configurations, only grok patterns. You should move your `grok { match => ... }` regexes to grok pattern files, using a minimal `logstash.conf` filter:

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

The same pattern arguments can then be passed to `grok-test`:

```
$ grok-test --patterns roles/logstash/files/patterns/ --pattern '%{PAM_LOG}|%{SSHD_LOG}'
```

## Generating input logs for testing

If you are matching against the logstash `message` field, then you must feed the plain log messages as input, not entirely syslog logfiles.

This is easy to do using `systemd-journald`:

```
$ journalctl -t sudo -o cat
   terom : TTY=pts/3 ; PWD=/home/terom ; USER=root ; COMMAND=/sbin/lvs
```

## Generated grok-test output

The generated output consists of:

* The original input line
* Grok captures, one per line, indentend
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

# Setup

```
$ gem build grok-test.gemspec && gem install --user grok-test-*.gem
$ ln -sr ~/.gem/ruby/*/bin/grok-test ~/.local/bin
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

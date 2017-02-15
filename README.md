# man-tokenizer [![Build Status](https://travis-ci.org/LCTT-Lab/man-tokenizer.svg?branch=master)](https://travis-ci.org/LCTT-Lab/man-tokenizer)

Tokenizer designed for translating man pages.

## Rendering Test

```
$ make -ij5 test | tee /tmp/test.log
```

## TODO

### Identify MACROs

**Ignore Block: connot translate / cannot be merged into other lines.**

```
.\"
..
.ad
.BI
.Bl
.bp
.br
.Bd
.Bx
.Dd # TODO: Verify this.
.de
.ds
.DT
.Dt
.Ed
.El
.el
.fam
.fi
.Fn
.ft
.HP
.hy
.ie
.if
.In
.in
.It
.LP
.na
.ne
.nf
.nh
.nr
.ns
.Os
.P
.PD
.PP
.Pp
.RE
.RS
.so
.sp
.ta
.TH # FIXME: Special, params 4 and 5 can be translate, ignore for now.
.ti
.TP
.TS
.UC
```

**Content Block: can translate, cannot be merged into other lines.**

```
.IP
.SH
.Sh
.SS
.Ss
.TE
```

**Ignore Inline: cannot translate, can be merged into other lines.**

```
.B
.BR
.Dv
.Fa
.I
.IB
.IR
.Li
.Nm
.RB
.RI
.UE
.UR # TODO: Verify this.
```

**Content Inline: can translate, can be merged into other lines.**

```
.Nd
.q # what's this?
```

**TODO: ignore block and ignore inline need re-validate.**

### Identify ESCAPEs

Not started yet.

### Join Lines

Not started yet.

### Parse Phrases

Not started yet.

### Handles Special MACROs.

Not started yet.

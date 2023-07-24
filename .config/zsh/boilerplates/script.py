#!/usr/bin/env python3
# vim: filetype=zsh:tabstop=4:shiftwidth=4:expandtab:

#  _____           
# |  ___|__   ___  
# | |_ / _ \ / _ \ 
# |  _| (_) | (_) |
# |_|  \___/ \___/ 
#                  

import sys

def warn(*args, **kwargs):
    msg = ' '.join(str(a) for a in args)
    kwargs.setdefault('file', sys.stderr)
    print('WARN:', msg, **kwargs)


def err(*args, **kwargs):
    msg = ' '.join(str(a) for a in args)
    kwargs.setdefault('file', sys.stderr)
    print('ERROR:', msg, **kwargs)


def bail(*args, **kwargs):
    err(*args, **kwargs)
    sys.exit(1)


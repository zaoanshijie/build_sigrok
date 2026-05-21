#!/bin/bash
# Fix default (C) tag archive_cmds and CXX tag archive_cmds
python3 << 'PYEOF'
with open('libtool') as f:
    lines = f.readlines()
with open('libtool', 'w') as f:
    for l in lines:
        if 'archive_cmds=' in l and '-link -dll~linknames=' in l:
            f.write('archive_cmds="/bin/sh tools/gen_exports.sh \\$lib.def \\$libobjs && \\$CC -shared \\$predep_objects \\$libobjs \\$deplibs \\$postdep_objects \\$compiler_flags \\$lib.def -o \\$lib && cp \\$lib \\$(dirname \\$lib)/\\$soname"\n')
        elif 'archive_cmds="\\$CC -shared -nostdlib' in l:
            l = l.replace('-shared -nostdlib', '-shared')
            l = l.rstrip()
            if '&& cp' not in l:
                l = l[:-1] + ' && cp \\$lib \\$(dirname \\$lib)/\\$soname"\n'
            f.write(l)
        else:
            f.write(l)
PYEOF

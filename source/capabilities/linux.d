/*
 * Copyright (C) 2024 Mai-Lapyst
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Module to linux kernel "functionallity". Largely based on "/usr/include/linux/capability.h".
 * 
 * License:   $(HTTP https://www.gnu.org/licenses/agpl-3.0.html, AGPL 3.0).
 * Copyright: Copyright (C) 2024 Mai-Lapyst
 * Authors:   $(HTTP codearq.net/mai-lapyst, Mai-Lapyst)
 */
module capabilities.linux;

struct __user_cap_header_struct {
    uint ver;
    int pid;
}
alias cap_user_header_t = __user_cap_header_struct*;

struct __user_cap_data_struct {
    uint effective;
    uint permitted;
    uint inheritable;
}
alias cap_user_data_t = __user_cap_data_struct*;

enum Capability : int {
    INVALID = -1,
    CHOWN = 0,
    DAC_OVERRIDE = 1,
    DAC_READ_SEARCH = 2,
    FOWNER = 3,
    FSETID = 4,
    KILL = 5,
    SETGID = 6,
    SETUID = 7,
    SETPCAP = 8,
    LINUX_IMMUTABLE = 9,
    NET_BIND_SERVICE = 10,
    NET_BROADCAST = 11,
    NET_ADMIN = 12,
    NET_RAW = 13,
    IPC_LOCK = 14,
    IPC_OWNER = 15,
    SYS_MODULE = 16,
    SYS_RAWIO = 17,
    SYS_CHROOT = 18,
    SYS_PTRACE = 19,
    SYS_PACCT = 20,
    SYS_ADMIN = 21,
    SYS_BOOT = 22,
    SYS_NICE = 23,
    SYS_RESOURCE = 24,
    SYS_TIME = 25,
    SYS_TTY_CONFIG = 26,
    MKNOD = 27,
    LEASE = 28,
    AUDIT_WRITE = 29,
    AUDIT_CONTROL = 30,
    SETFCAP = 31,
    MAC_OVERRIDE = 32,
    MAC_ADMIN = 33,
    SYSLOG = 34,
    WAKE_ALARM = 35,
    BLOCK_SUSPEND = 36,
    AUDIT_READ = 37,
    PERFMON = 38,
    BPF = 39,
    CHECKPOINT_RESTORE = 40,
}

import std.traits;
static foreach (e; EnumMembers!Capability) {
    mixin("alias CAP_" ~ e.stringof ~ " = Capability." ~ e.stringof ~ ";");
}
alias CAP_LAST_CAP = EnumMembers!Capability[$-1];

enum cap_valid(x) = ((x) >= 0 && (x) <= CAP_LAST_CAP);

enum CAP_TO_INDEX(x) = ((x) >> 5);
enum CAP_TO_MASK(x) = (1U << ((x) & 31));

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
 * Module to libcap functionallity. Largely based on "/usr/include/sys/capability.h".
 * 
 * License:   $(HTTP https://www.gnu.org/licenses/agpl-3.0.html, AGPL 3.0).
 * Copyright: Copyright (C) 2024 Mai-Lapyst
 * Authors:   $(HTTP codearq.net/mai-lapyst, Mai-Lapyst)
 */
module capabilities.libcap;

import core.sys.posix.sys.types;
import capabilities.linux;

alias cap_t = void*;
alias cap_value_t = Capability;

extern(C) cap_value_t cap_max_bits();

extern(C) char* cap_proc_root(const char* root);

enum cap_flag_t {
    EFFECTIVE = 0,
    PERMITTED = 1,
    INHERITABLE = 2,
}
alias CAP_EFFECTIVE = cap_flag_t.EFFECTIVE;
alias CAP_PERMITTED = cap_flag_t.PERMITTED;
alias CAP_INHERITABLE = cap_flag_t.INHERITABLE;

enum cap_iab_vector_t {
    inh = 2,
    amb = 3,
    bound = 4,
}
alias CAP_IAB_INH = cap_iab_vector_t.inh;
alias CAP_IAB_AMB = cap_iab_vector_t.amb;
alias CAP_IAB_BOUND = cap_iab_vector_t.bound;

alias cap_iab_t = void*;

enum cap_flag_value_t {
    clear = 0,
    set = 1,
}
alias CAP_CLEAR = cap_flag_value_t.clear;
alias CAP_SET = cap_flag_value_t.set;

enum cap_mode_t {
    uncertain = 0,
    nopriv = 1,
    pure1e_init = 2,
    pure1e = 3,
    hybrid = 4,
}
alias CAP_MODE_UNCERTAIN = cap_mode_t.uncertain;
alias CAP_MODE_NOPRIV = cap_mode_t.nopriv;
alias CAP_MODE_PURE1E_INIT = cap_mode_t.pure1e_init;
alias CAP_MODE_PURE1E = cap_mode_t.pure1e;
alias CAP_MODE_HYBRID = cap_mode_t.hybrid;

extern(C) @nogc {
    cap_t cap_dup(cap_t);
    int cap_free(cap_t);
    cap_t cap_init();
    cap_iab_t cap_iab_dub(cap_iab_t);
    cap_iab_t cap_iab_init();

    int cap_get_flag(cap_t cap_p, cap_value_t cap, cap_flag_t flag, cap_flag_value_t* value_p);
    int cap_set_flag(cap_t cap_p, cap_flag_t flag, int ncap, const cap_value_t* caps, cap_flag_value_t value);
    int cap_clear(cap_t cap_p);
    int cap_clear_flag(cap_t cap_p, cap_flag_t flag);
    int cap_fill_flag(cap_t cap_p, cap_flag_t to, cap_t reference, cap_flag_t from);
    int cap_fill(cap_t cap_p, cap_flag_t to, cap_flag_t from);

    enum CAP_DIFFERS(result, flag) = (((result) & (1 << (flag))) != 0);
    int cap_compare(cap_t cap_a, cap_t cap_b);
    enum CAP_IAB_DIFFERS(result, vector) = (((result) & (1 << (vector))) != 0);
    int cap_iab_compare(cap_iab_t, cap_iab_t);

    cap_flag_value_t cap_iab_get_vector(cap_iab_t, cap_iab_vector_t, cap_value_t);
    int cap_iab_set_vector(cap_iab_t, cap_iab_vector_t, cap_value_t, cap_flag_value_t);
    int cap_iab_fill(cap_iab_t, cap_iab_vector_t, cap_t, cap_flag_t);

    cap_t cap_get_fd(int);
    cap_t cap_get_file(const char*);
    uid_t cap_get_nsowner(cap_t);
    int cap_set_fd(int, cap_t);
    int cap_set_file(const char*, cap_t);
    int cap_set_nsowner(cap_t, uid_t);

    cap_t cap_get_proc();
    cap_t cap_get_pid(pid_t);
    int cap_set_proc(cap_t);

    int cap_get_bound(cap_value_t);
    int cap_drop_bound(cap_value_t);
    enum CAP_IS_SUPPORTED(cap) = (cap_get_bound(cap) >= 0);

    int cap_get_ambient(cap_value_t);
    int cap_set_ambient(cap_value_t, cap_flag_value_t);
    int cap_reset_ambient();
    enum CAP_AMBIENT_SUPPORTED() = (cap_get_ambient(CAP_CHOWN) >= 0);

    ssize_t cap_size(cap_t cap_d);
    ssize_t cap_copy_ext(void* cap_ext, cap_t cap_d, ssize_t length);
    cap_t cap_copy_int(const void* cap_ext);
    cap_t cap_copy_int_check(const void* cap_ext, ssize_t length);

    cap_t cap_from_text(const char*);
    char* cap_to_text(cap_t, ssize_t*);
    int cap_from_name(const char*, cap_value_t*);
    char* cap_to_name(cap_value_t);

    char* cap_iab_to_text(cap_iab_t iab);
    cap_iab_t cap_iab_from_text(const char* text);

    void cap_set_syscall(
        long function(long, long, long, long) new_syscall,
        long function(long, long, long, long, long, long, long) new_syscall6,
    );

    int cap_set_mode(cap_mode_t flavor);
    cap_mode_t cap_get_mode();
    const(char)* cap_mode_name(cap_mode_t flavor);

    uint cap_get_secbits();
    int cap_set_secbits(uint bits);

    int cap_prctl(long pr_cmd, long arg1, long arg2, long arg3, long arg4, long arg5);
    int cap_prctlw(long pr_cmd, long arg1, long arg2, long arg3, long arg4, long arg5);
    int cap_setuid(uid_t uid);
    int cap_setgroups(gid_t gid, size_t ngroups, const gid_t[] groups);

    cap_iab_t cap_iab_get_proc();
    cap_iab_t cap_iab_get_pid(pid_t);
    int cap_iab_set_proc(cap_iab_t iab);

    alias cap_launch_t = void*;

    // cap_launch_t cap_new_launcher(const char* arg0, const char* const* argv, const char* const* envp);
    cap_launch_t cap_func_launcher(int function(void* detail) callback_fn);
    int cap_launcher_callback(cap_launch_t attr, int function(void* detail) callback_fn);
    int cap_launcher_setuid(cap_launch_t attr, uid_t uid);
    int cap_launcher_setgroups(cap_launch_t attr, gid_t gid, int ngroups, const gid_t* groups);
    int cap_launcher_set_mode(cap_launch_t attr, cap_mode_t flavor);
    cap_iab_t cap_launcher_set_iab(cap_launch_t attr, cap_iab_t iab);
    int cap_launcher_set_chroot(cap_launch_t attr, const char* chroot);
    pid_t cap_launch(cap_launch_t attr, void* detail);

    int capget(cap_user_header_t header, cap_user_data_t data);
    int capset(cap_user_header_t header, const cap_user_data_t data);

    int capgetp(pid_t pid, cap_t cap_d);

    int capsetp(pid_t pid, cap_t cap_d);
}

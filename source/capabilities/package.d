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
 * The main Module
 * 
 * License:   $(HTTP https://www.gnu.org/licenses/agpl-3.0.html, AGPL 3.0).
 * Copyright: Copyright (C) 2024 Mai-Lapyst
 * Authors:   $(HTTP codearq.net/mai-lapyst, Mai-Lapyst)
 */
module capabilities;

public import capabilities.lookup;
public import capabilities.libcap;
public import capabilities.linux;

import core.sys.posix.sys.types : pid_t;
import core.sys.linux.sys.prctl;

struct Capabilities {
    private cap_t raw = null;

    /**
     * Initializes this capabilities object by duplicating another
     * 
     * Params:
     *   other = The capabilities object to duplicate
     */
    this(ref Capabilities other) @nogc {
        other.ensureInit();
        this.raw = cap_dup(other.raw);
    }

    private this(cap_t raw) @nogc {
        this.raw = raw;
    }

    /** 
     * Ensures the low-level value is properly initialized.
     */
    void ensureInit() @nogc {
        if (this.raw is null)
            this.raw = cap_init();
    }

    ~this() @nogc {
        if (this.raw !is null)
            cap_free(this.raw);
    }

    /**
     * Gets the state of an capability in an flag.
     * 
     * Params:
     *   cap = The capability to test.
     *   flag = The flag to test.
     *   result = Reference to set the result to; "true" means set, "false" means clear.
     * 
     * Returns: "true" if successfull; "false" otherwise. Sets "errno" on error.
     */
    bool getFlag(Capability cap, cap_flag_t flag, ref bool result) @nogc {
        this.ensureInit();

        cap_flag_value_t r;
        if (cap_get_flag(this.raw, cap, flag, &r) < 0) {
            return false;
        }
        result = r == CAP_SET;
        return true;
    }

    /**
     * Sets the state of an capability in an flag.
     * 
     * Params:
     *   flag = The flag to set.
     *   cap = The capability to set.
     *   val = The value to set; can either be "CAP_SET" or "CAP_CLEAR".
     * 
     * Returns: "true" if successfull; "false" otherwise. Sets "errno" on error.
     */
    bool setFlag(cap_flag_t flag, Capability cap, cap_flag_value_t val = CAP_SET) @nogc {
        this.ensureInit();
        return cap_set_flag(this.raw, flag, 1, &cap, val) >= 0;
    }

    /**
     * Sets the state of capabilities in an flag.
     * 
     * Params:
     *   flag = The flag to set.
     *   caps = The capabilities to set.
     *   val = The value to set; can either be "CAP_SET" or "CAP_CLEAR".
     * 
     * Returns: "true" if successfull; "false" otherwise. Sets "errno" on error.
     */
    bool setFlag(cap_flag_t set, Capability[] caps, cap_flag_value_t val = CAP_SET) @nogc {
        this.ensureInit();
        return cap_set_flag(this.raw, set, cast(int) caps.length, caps.ptr, val) >= 0;
    }

    /**
     * Sets the state of capabilities in an flag.
     * 
     * Params:
     *   flag = The flag to set.
     *   caps = The capabilities (range) to set.
     *   val = The value to set; can either be "CAP_SET" or "CAP_CLEAR".
     * 
     * Returns: "true" if successfull; "false" otherwise. Sets "errno" on error.
     */
    bool setFlag(Range)(cap_flag_t set, Range caps, cap_flag_value_t val = CAP_SET) {
        this.ensureInit();
        foreach (ref cap; caps) {
            if (cap_set_flag(this.raw, set, 1, &cap, val) < 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * Clears all capabilities in all flags.
     * 
     * Returns: "true" if successfull; "false" otherwise. Sets "errno" on error.
     */
    bool clear() @nogc {
        this.ensureInit();
        return cap_clear(this.raw) >= 0;
    }

    /**
     * Clears all capabilities one flag.
     * 
     * Returns: "true" if successfull; "false" otherwise. Sets "errno" on error.
     */
    bool clearFlag(cap_flag_t flag) @nogc {
        this.ensureInit();
        return cap_clear_flag(this.raw, flag) >= 0;
    }

    /**
     * Fills the flag "to" with the capabilities from flag "from" in the capabilites object "other".
     * 
     * Params:
     *   to = The flag to set.
     *   other = The capabilities object to copy from.
     *   from = The flag to copy from.
     * 
     * Returns: "true" if successfull; "false" otherwise. Sets "errno" on error.
     */
    bool fillFlag(cap_flag_t to, ref Capabilities other, cap_flag_t from) {
        this.ensureInit();
        other.ensureInit();
        return cap_fill_flag(this.raw, to, other.raw, from) >= 0;
    }

    /**
     * Fills the flag "to" with the capabilities from flag "from".
     * 
     * Params:
     *   to = The flag to set.
     *   from = The flag to copy from.
     * 
     * Returns: "true" if successfull; "false" otherwise. Sets "errno" on error.
     */
    bool fill(cap_flag_t to, cap_flag_t from) @nogc {
        this.ensureInit();
        return cap_fill(this.raw, to, from) >= 0;
    }

    /**
     * Compares the current capabilities object with another one.
     * 
     * Params:
     *   other = The capabilities object to compare against.
     * 
     * Returns: "true" if theyre equal; "false" otherwise.
     */
    bool compare(ref Capabilities other) @nogc const {
        if (other.raw == this.raw) return true;
        if (other.raw is null || this.raw is null) return false;
        return cap_compare(cast(cap_t) this.raw, other.raw) == 0;
    }

    pragma(inline) auto opIndex(Capability cap, cap_flag_t set) {
        bool r;
        this.getFlag(cap, set, r);
        return r;
    }

    pragma(inline) auto opIndexAssign(Capability cap, cap_flag_t set, cap_flag_value_t val) @nogc {
        return this.setFlag(set, cap, val);
    }

    /**
     * Retrieves the capabilities object for the current process.
     */
    static auto getForCurrentProcess() @nogc {
        return Capabilities(cap_get_proc());
    }

    /**
     * Retrieves the capabilities object for a specific process.
     */
    static auto getForPid(pid_t pid) @nogc {
        return Capabilities(cap_get_pid(pid));
    }

    /**
     * Sets the current's process's capabilities object to the current one.
     * 
     * Returns: "true" if successfull; "false" otherwise.
     */
    bool setForCurrentProcess() @nogc {
        this.ensureInit();
        return cap_set_proc(this.raw) >= 0;
    }

    /**
     * Sets the current's threads's "keep capabilities" flag to "on".
     * Note: currently this is only supported on linux.
     * 
     * Returns: "true" if successfull; "false" otherwise.
     */
    static bool threadKeepCaps() @nogc {
        version (linux) {
            // TODO: also support the older SECBIT_KEEP_CAPS operation
            return prctl(PR_SET_KEEPCAPS, 1, 0, 0, 0) >= 0;
        } else {
            return false;
        }
    }
}

/**
 * Sets the specified capabilities for the current process as
 * effective, permitted and inheritable.
 * 
 * Params:
 *   caps = List of capabilitiy names
 */
void setCurrentCapabilities(string[] caps) {
    cap_value_t[] cap;
    cap.reserve(caps.length);
    foreach (ref e; caps) {
        try {
            import std.conv : to;
            auto n = e.to!int;
            cap ~= cast(Capability) n;
        } catch (Throwable th) {
            cap ~= e.toCapabilityId;
        }
    }
    setCurrentCapabilities(cap);
}

/**
 * Sets the specified capabilities for the current process as
 * effective, permitted and inheritable.
 * 
 * Params:
 *   cap = The capabilities as libcap values
 */
void setCurrentCapabilities(cap_value_t[] cap) {
    Capabilities caps;
    caps.clear();
    caps.setFlag(CAP_EFFECTIVE, cap);
    caps.setFlag(CAP_PERMITTED, cap);
    caps.setFlag(CAP_INHERITABLE, cap);
    if (!caps.setForCurrentProcess()) {
        import core.stdc.string;
        import core.stdc.errno;
        import std.conv;
        throw new Exception("Could not set capabilities: " ~ strerror(errno).to!string);
    }
}

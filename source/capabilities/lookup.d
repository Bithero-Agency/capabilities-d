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
 * Module to hold code to lookup human-readable names for all capability id's.
 * 
 * License:   $(HTTP https://www.gnu.org/licenses/agpl-3.0.html, AGPL 3.0).
 * Copyright: Copyright (C) 2024 Mai-Lapyst
 * Authors:   $(HTTP codearq.net/mai-lapyst, Mai-Lapyst)
 */
module capabilities.lookup;

import capabilities.linux;
import std.traits;

static import std.traits;
import std.algorithm.iteration;
import capabilities.libcap;

private {
    struct CapEntry {
        string name;
        Capability cap;
    }

    alias caps = EnumMembers!Capability;
    template buildCapEntries(int i = 0)
    {
        static if (i >= caps.length) {
            enum buildCapEntries = "";
        } else {
            alias cap = caps[i];
            static if (cap < 0) {
                enum buildCapEntries = buildCapEntries!(i+1);
            } else {
                enum buildCapEntries =
                    ("CapEntry(\"" ~ cap.stringof ~ "\", Capability." ~ cap.stringof ~ "),\n")
                    ~ buildCapEntries!(i+1)
                ;
            }
        }
    }

    static immutable CapEntry[] cap_list = mixin("[" ~ buildCapEntries!() ~ "]");
}

/**
 * Gets a capability by it's name.
 * 
 * Params:
 *   name = The name to lookup (case insensitive)
 * 
 * Returns: The capabilities value.
 */
Capability toCapabilityId(string name) pure @safe {
    import std.string : toUpper;
    name = name.toUpper;
    foreach (ref cap; cap_list) {
        if (cap.name == name) return cap.cap;
    }
    return Capability.INVALID;
}

unittest {
    assert("sys_boot".toCapabilityId == 22);
    assert("bpf".toCapabilityId == 39);
}

/**
 * Converts a capability to it's string representation / name.
 * 
 * Params:
 *   cap = The capability to convert.
 * 
 * Returns: The name or "<invalid>" if it's an invalid capability.
 */
string toString(Capability cap) pure @safe nothrow @nogc {
    if (cap < 0) {
        return "<invalid>";
    }
    return cap_list[cap].name;
}

unittest {
    assert(CAP_SYSLOG.toString() == "SYSLOG");
}

import std.range;
import std.traits : isSomeString;

auto toCapabilityIds(Range)(ref Range r)
if (isSomeString!(typeof(r.front)))
{
    struct Result {
        Range r;

        this(ref Range r) {
            this.r = r;
        }

        @property auto empty() => this.r.empty();

        @property Capability front() {
            import std.conv;

            auto elem = this.r.front();
            try {
                auto n = elem.to!int;
                return cast(Capability) n;
            } catch (ConvException ex) {
                return elem.toCapabilityId;
            }
        }

        void popFront() {
            this.r.popFront();
        }

        static if (hasLength!Range) {
            @property size_t length() => this.r.length;
        }
    }
    return Result(r);
}

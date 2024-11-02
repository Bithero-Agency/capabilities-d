# capabilities-d

A wrapper around the linux capabilitiy system and libcap in dlang.

## License

The code in this repository is licensed under AGPL-3.0-or-later; for more details see the LICENSE file in the repository.

## Usage

- `get_capid_byname(string)` to lookup human readable names to capability id's.
- `setCurrentCapabilities(string[])` to set the current capabilities from a list of human readable names.
- the `Capabilities` struct to control capabilities more fine-graded than `setCurrentCapabilities`.

# Structure of `code/speechbasicV2.8.asm`

`speechbasicV2.8.asm` is the ACME assembler source for C64 Speech BASIC
2.8. It builds a Commodore 64 BASIC extension PRG that installs itself at
`$0801`, moves the normal BASIC program start to `$1801`, and hooks into the
C64 BASIC interpreter so that new tokens, commands, function-key strings, disk
helpers, memory block definitions, and speech record/playback commands become
available from BASIC.

Speech BASIC is designed for the original external 2-bit audio digitizer
hardware. The main sound path samples joystick port 2 (`$DC00`) as a 2-bit
value, stores four samples per byte, and plays those samples back through the
SID volume register (`$D418`). The border color is also changed during sound
activity, using the same 2-bit sample value as an index into color and volume
tables.

## What the Program Does

At a high level, the program:

- Installs new BASIC interpreter vectors for tokenizing, listing, command
  dispatch, expression evaluation, keyboard scanning, NMI, and BRK handling.
- Adds new BASIC tokens for commands such as `HEAR`, `RECORD`, `PLAY`,
  `BLOCK`, `MAP`, `BLOAD`, `BSAVE`, `EXEC`, `MON`, `SCREEN`, `HEX`, and `DEZ`.
- Adds expression syntax for hexadecimal and binary numeric constants using
  `$...` and `%...`.
- Provides configurable function-key macros through `KEY`.
- Provides disk utility commands (`DISK`, `DIR`, `BLOAD`, `BSAVE`) with
  v2.8 fixes for device-existence checking and safer `BLOAD` address handling.
- Provides a block table: 32 named memory ranges that can be printed, edited,
  loaded, saved, played, recorded, or used from `EXEC`.
- Records 2-bit samples from the digitizer into RAM and plays them back through
  SID volume changes.
- Provides a simple monitor-like editor/display for the packed speech data.

## Build and Load Layout

Important source sections:

- The assembler output directive is near the top:
  `!to "build/speechbasicV2.8.prg",cbm`.
- The program starts at `$0801`, using a BASIC loader line that executes
  `SYS(2080) SPEECH BASIC 2.8`.
- After the loader, execution jumps to `OWN_INIT`.
- `OWN_INIT` sets the BASIC start pointer (`$2B/$2C`) to `$1801`, clears
  `$1800`, installs all vectors with `setvectors`, and prints the Speech BASIC
  power-on message.

The extension itself occupies the memory below the new BASIC start. User BASIC
programs therefore start at `$1801`, leaving room for the resident extension.

## Interpreter Integration

The most important mechanism is vector replacement. `setvectors` installs these
handlers:

- `$0304/$0305` -> `OWN_CRUNCH`: tokenizes input lines.
- `$0306/$0307` -> `OWN_PLOOP`: lists tokenized lines back as text.
- `$0308/$0309` -> `OWN_GONE`: dispatches executable BASIC commands.
- `$030A/$030B` -> `OWN_EVAL`: extends expression evaluation.
- `$028F/$0290` -> `OWN_KBDDEC`: expands function keys.
- `$0318/$0319` -> `OWN_NMI`: handles NMI and stop behavior.
- `$0316/$0317` -> `OWN_BRK`: resets/cleans up on BRK.

These hooks let Speech BASIC participate in the normal BASIC workflow instead
of parsing everything as a separate shell.

### Tokenizing: `OWN_CRUNCH`

`OWN_CRUNCH` is the input-line tokenizer. It scans the C64 input buffer,
recognizes keywords from `OWN_CMDS`, and converts them into token values. If a
word is not a Speech BASIC keyword, it falls through to the ROM command table
at `CBM_CMDTAB` so normal BASIC commands still work.

It also preserves normal BASIC behavior for quoted strings, `DATA`, `REM`,
spaces, `?` as `PRINT`, and ordinary numeric/operator characters.

### Listing: `OWN_PLOOP`

`OWN_PLOOP` is the inverse of tokenizing. During `LIST`, it detects Speech BASIC
tokens, looks them up in `OWN_CMDS`, and prints the keyword text. Older BASIC
tokens are passed back to the ROM listing code.

### Command Dispatch: `OWN_GONE`

`OWN_GONE` is the runtime dispatcher. It checks whether the current token is in
the Speech BASIC executable token range (`$CC` through `$E3`). If so, it uses
`CMDS_TAB` to jump to the corresponding command handler. Otherwise it returns
control to the original BASIC command execution routine.

`OWN_CMDS` and `CMDS_TAB` must stay in the same order. The Nth token in
`OWN_CMDS` maps to the Nth address in `CMDS_TAB`.

### Expression Evaluation: `OWN_EVAL`

`OWN_EVAL` adds two numeric literal formats:

- `$...` for hexadecimal numbers.
- `%...` for binary numbers.

The conversion routines build the value in BASIC's floating accumulator and
then return to the ROM evaluator.

## Command Table

The token table begins at `OWN_CMDS`. Main executable tokens are:

- `$CC` `RESET`
- `$CD` `BASIC`
- `$CE` `HELP`
- `$CF` `KEY`
- `$D0` `HIMEM`
- `$D1` `DISK`
- `$D2` `DIR`
- `$D3` `BLOAD`
- `$D4` `BSAVE`
- `$D5` `MAP`
- `$D6` `MEM`
- `$D7` `PAUSE`
- `$D8` `BLOCK`
- `$D9` `HEAR`
- `$DA` `RECORD`
- `$DB` `PLAY`
- `$DC` `VOLDEF`
- `$DD` `COLDEF`
- `$DE` `HEX`
- `$DF` `DEZ`
- `$E0` `SCREEN`
- `$E1` `EXEC`
- `$E2` `MON`
- `$E3` left-arrow monitor input command

The non-executable helper tokens follow:

- `$E4` `FROM`
- `$E5` `SPEED`
- `$E6` `OFF`

These are used as modifiers inside other commands, for example address ranges
and speed/screen settings.

## Utility and System Commands

Places to look:

- `CMD_RESET`: clears chips, reinstalls vectors, clears SID registers.
- `CMD_BASIC`: switches Speech BASIC off and returns to normal BASIC.
- `CMD_HELP`: prints either Speech BASIC commands or normal BASIC commands.
- `CMD_KEY`: displays or changes function-key macro strings in `keytab`.
- `OWN_KBDDEC`: keyboard scan hook that expands function keys into the keyboard
  buffer.
- `CMD_HIMEM`: changes BASIC's memory limit (`$37/$38`) after validating it.
- `CMD_MEM`: prints important memory ranges using `MEMTXTPTR`.
- `CMD_PAUSE`: waits either for a timer count or for a port-2 status change.
- `CMD_HEX` / `CMD_DEZ`: select hexadecimal or decimal address display.
- `CMD_SCREEN`: controls whether sound commands blank the screen during
  operation.

`CMD_PAUSE` temporarily replaces the IRQ vector with `OWN_IRQ`, which decrements
the two-byte `timer` value on each interrupt and then chains to the normal IRQ
routine.

## Disk Commands and Address Parsing

Places to look:

- `CMD_DISK`: reads the disk error channel or sends a disk command.
- `CMD_DIR`: opens and prints a directory listing.
- `CMD_BLOAD`: loads a file to its original or specified memory address.
- `CMD_BSAVE`: saves a memory range to disk.
- `chkparam`: common filename/device parser and v2.8 device-present check.
- `GETADDR`: evaluates and validates a 16-bit address.
- `set_def_val`: common range parser for `BLOCK`, `FROM`, `TO`, and comma
  forms.

`BLOAD` and `BSAVE` use C64 KERNAL file calls such as `SETNAM`, `SETLFS`,
`OPEN`, `CHKIN`, `CHKOUT`, `CHRIN`, `CHROUT`, `CLRCHN`, and `CLOSE`.

When reading or writing arbitrary RAM, the code temporarily changes processor
port `$01` to bank RAM in (`$34`) and then restores ROM-visible operation
(`$37` or `$35` depending on the surrounding routine). This is necessary because
speech data can live under ROM areas.

The v2.8 `BLOAD` fix is in `L0F45`: after resolving the destination address, it
checks that the load start is not below the Speech BASIC BASIC-start address
`$1801`, avoiding self-overwrite of the resident extension area.

## Block System

Speech BASIC maintains 32 block definitions. Each block has:

- A start address.
- An end address.
- An 8-character name stored in `stringtable`.

Places to look:

- `CMD_BLOCK`: defines or updates a block.
- `CMD_MAP`: prints block definitions in editable BASIC-like form.
- `CALC_BLKADR`: maps a block number to its 4-byte entry in the block table.
- `blocktabstart` / `blocktabend`: the address table data area.
- `stringtable`: the fixed-width block-name table.
- `set_def_val`: parses either `BLOCK n` or explicit address ranges.

The block table is the bridge between memory management and speech operation:
`BLOAD`, `BSAVE`, `RECORD`, `PLAY`, `MON`, and `EXEC` can use the same address
ranges by referring to blocks.

## Speech Recording and Playback

The sound path is centered on `HEAR`, `RECORD`, `PLAY`, and shared setup in
`L12B0` / `clear_sid`.

### Shared Setup: `L12B0` and `clear_sid`

`L12B0` handles an optional `SPEED` parameter. It self-modifies the delay bytes
used by:

- `delay_play`
- `delay_hear`
- `delay_rec`

It also saves screen, border, and sprite state, optionally blanks the screen,
clears SID registers, and installs `break_nmi` as the NMI vector.

`break_nmi` and `break` are the stop/cleanup path. On stop, the code patches
the active `STA $D418` instructions in the record/play loops into `JMP break`,
then later restores them. This is a compact 6502 technique for exiting tight
timing loops without adding extra checks to every inner iteration.

### `HEAR`

`CMD_HEAR` monitors the digitizer live:

- Reads joystick port 2 at `$DC00`.
- Masks the low two bits.
- Uses those bits as an index into `COLTABLE` and `VOLTABLE`.
- Writes border color to `$D020`.
- Writes SID volume to `$D418`.

It does not store samples; it is a live monitor.

### `RECORD`

`CMD_RECORD` records a memory range:

- Parses the destination range through `set_def_val`.
- Reads four 2-bit samples from `$DC00`.
- Packs them into one byte by shifting into `$A8`.
- Banks RAM in and stores the byte at the current address.
- Advances until the configured end address is reached.

The delay loop controls sampling speed.

### `PLAY`

`CMD_PLAY` plays a memory range:

- Parses the source range through `set_def_val`.
- Reads one byte from RAM.
- Unpacks it into four 2-bit samples.
- Uses each sample as an index into `COLTABLE` and `VOLTABLE`.
- Writes the corresponding volume to `$D418` and border color to `$D020`.
- Advances until the configured end address is reached.

Because samples are packed four per byte, the inner loop processes four sound
values before moving to the next memory address.

### Volume and Color Tables

`COLTABLE` and `VOLTABLE` contain four values each. The sample value `0..3`
indexes both tables. `CMD_VOLDEF` changes `VOLTABLE`; `CMD_COLDEF` temporarily
retargets the same store logic to change `COLTABLE`.

## `EXEC` Sequencer

`CMD_EXEC` interprets a string as a compact sound command sequence. It saves the
current BASIC text pointer, redirects parsing to the string contents, and
dispatches single-character sequence commands through `excmdtable` and
`execaddr`.

Recognized sequence characters are:

- `P`: play a block.
- `S`: set speed.
- `W`: pause.
- `V`: set volume table.
- `C`: set color table.
- `#`: jump to another command string.

This lets BASIC programs build small playback scripts from strings rather than
issuing full BASIC commands repeatedly.

## Monitor and Packed Data Editing

Places to look:

- `CMD_MON`: displays packed speech data as groups of four visible digits per
  byte, with colors based on the sample values.
- `out_4` / `out_1`: split a byte into four 2-bit values and print them.
- `CMD_LEFTARROW`: parses monitor-style input and writes edited packed sample
  values back to memory.
- `mon_table`: masks used to replace a selected 2-bit pair inside a byte.

The left-arrow command works with BASIC warm start behavior and is effectively
part of the custom monitor/editor interface.

## Data Areas

Important persistent data tables and variables:

- `OWN_CMDS`: token text table.
- `CMDS_TAB`: command handler jump table.
- `keytab` and `keynum`: function-key strings and C64 key ordering.
- `timer`: two-byte pause counter.
- `DATA_START` / `DATA_END`: current parsed address range.
- `COLTABLE` / `VOLTABLE`: 2-bit sample to color/volume mapping.
- `status`, `sprite_flag`, `scn_stat`, `col_buff`: screen/sound state saved
  around sound operations.
- `HEXDEC_FLAG`: address print mode.
- `blocktabstart`, `blocktabend`, and `stringtable`: block definitions and
  names.

## Good Entry Points for Reading

To understand the program efficiently, read in this order:

1. `OWN_INIT` and `setvectors`: how the extension installs itself.
2. `OWN_CMDS` and `CMDS_TAB`: the public command surface and dispatch order.
3. `OWN_CRUNCH`, `OWN_PLOOP`, `OWN_GONE`: how BASIC tokenization, listing, and
   execution are extended.
4. `set_def_val`, `GETADDR`, and `CALC_BLKADR`: how address ranges and blocks
   are parsed.
5. `CMD_RECORD`, `CMD_PLAY`, `CMD_HEAR`, `L12B0`, `break_nmi`, and `break`: the
   core speech mechanism.
6. `CMD_BLOAD` and `CMD_BSAVE`: disk I/O and RAM banking behavior.
7. `CMD_EXEC` and `CMD_MON`: higher-level sequencing and data editing.

## Maintenance Notes

- Keep `OWN_CMDS` and `CMDS_TAB` synchronized. Adding or reordering executable
  commands requires updating both.
- Keep token range checks in `OWN_GONE` consistent with the executable command
  range. Helper tokens such as `FROM`, `SPEED`, and `OFF` are tokenized but not
  directly dispatched as commands.
- Be careful around self-modifying code. Delay values, end-address comparisons,
  `CMD_COLDEF`, and NMI stop handling all patch instructions or operands at
  runtime.
- Be careful around `$01` memory banking. Several routines explicitly bank RAM
  in to read/write under ROM and then restore normal mapping.
- Timing-sensitive loops in `HEAR`, `RECORD`, and `PLAY` are deliberately tight.
  Adding instructions there changes sample rate and playback speed.
- The v2.8 fixes are part of the source's intent: device checking in
  `chkparam`, safer `BLOAD` destination validation in `L0F45`, and the corrected
  `PAUSE` timer comparison.

# Fixes

This section compares `code/speechbasicV2.7.asm` with
`code/speechbasicV2.8.asm`. Version 2.8 keeps the same overall structure and
command set, but adds three functional fixes and a few small cleanups.

## Version and Build Output

The version identifiers were updated from 2.7 to 2.8:

- The file header now says `Version 2.8`.
- The assembler output target changed from `build/speechbasicV2.7.prg` to
  `build/speechbasicV2.8.prg`.
- The BASIC loader text and power-on message now show `2.8`.
- The comment header now documents the v2.8 fixes.

These changes identify the new build but do not change runtime behavior by
themselves.

## `BLOAD` Self-Overwrite Protection

In v2.7, `BLOAD` could load data below the relocated BASIC start address and
overwrite the resident Speech BASIC program area. The v2.7 comments already
noted this as a known problem.

Version 2.8 fixes this in `L0F45`, after `set_def_val` has resolved the load
start address in `DATA_START`:

- It compares the high byte of the requested start address with `$18`.
- If the start address is below `$1801`, it closes the file and raises
  `ILLEGAL QUANTITY`.
- If the high byte is exactly `$18`, it also checks that the low byte is at
  least `$01`.
- Only addresses at or above `$1801` are copied into `$AE/$AF` as the active
  load/save pointer.

This protects the extension area below the new BASIC program start from being
overwritten by `BLOAD`.

One detail to watch: `L0F45` is shared by `BLOAD` and `BSAVE`. In v2.8 this
address validation therefore applies to both paths using that helper, although
the documented bug being fixed is the unsafe `BLOAD` destination.

## Device-Present Check in `chkparam`

In v2.7, `chkparam` accepted device numbers `8` and above, stored the value in
`CBM_CURDEV`, and returned. It did not check whether the device actually existed.
For commands that open disk files or channels, an absent device could leave the
machine waiting indefinitely.

Version 2.8 adds KERNAL IEEE calls and a device error code:

- `CBM_LISTN = $FFB1`
- `CBM_UNLSN = $FFAE`
- `DEVICE_NOT_PRESENT = $05`

After validating and storing the device number, `chkparam` now:

1. Clears `CBM_STATUS`.
2. Sends `LISTEN` to the selected device with `CBM_LISTN`.
3. Sends `UNLISTEN` with `CBM_UNLSN`.
4. Checks `CBM_STATUS`.
5. If bit 7 is set, closes the active file/channel path and raises
   `DEVICE NOT PRESENT`.

The old illegal-device-number path remains for values below 8. The new path
distinguishes between an invalid device number and a valid-looking device number
where no drive responds.

This affects the shared disk parameter parser used by `DISK`, `DIR`, `BLOAD`,
and `BSAVE`.

## `PAUSE` Timer Race Fix

`CMD_PAUSE` with a numeric argument installs `OWN_IRQ`, which decrements the
two-byte `timer` value on each IRQ while the foreground code waits for the value
to reach zero.

In v2.7, the wait loop checked the low byte first:

```asm
LDA timer
BNE -
LDA timer+1
BNE -
```

That created a race: the IRQ could decrement the high byte between the low-byte
check and high-byte check. If that happened near a low-byte wrap, the foreground
wait could skip a full low-byte count.

Version 2.8 checks the high byte first:

```asm
LDA timer+1
BNE -
LDA timer
BNE -
```

This avoids the observed case where `PAUSE` could skip 255 counts from the wait
value.

## `HELP` Cleanup and Spacing Optimization

The `CMD_HELP` path for showing normal BASIC commands was cleaned up.

In v2.7, it consumed only one extra character after `HELP`, with comments noting
that this only worked for one trailing character and that a loop would work
better. Version 2.8 implements that loop:

```asm
.loop1
    JSR CBM_CHRGET
    BNE .loop1
```

This clears all remaining trailing input before printing the normal BASIC
command overview.

The command-column spacing logic was also simplified. Instead of calling
`CBM_JPLOT` to read the cursor position, v2.8 reads `$D3` directly. This is a
small optimization for the same purpose: calculate how many spaces are needed to
align the command list.

## Disk Command Cleanup

`CMD_DISK` no longer calls `CBM_SETNAM` before `chkparam`. The source comment
explains why: setting the filename there is unnecessary because `chkparam`
already calls the ROM filename setup routine.

This is a cleanup, not a command behavior change.

## Shared Address Helper Cleanup

An apparently unused instruction at label `L0F2C`:

```asm
L0F2C JSR CBM_CHKCOM
```

was commented out in v2.8. The nearby comment already says `$0f2c is not used
anywhere ?`.

The illegal-quantity jump in `GETADDR` was also given the local label
`.error1`, which is reused by the new `BLOAD` address validation path.

## `BSAVE` Close-Path Cleanup

In `CMD_BSAVE`, v2.7 called `CBM_CLRCHN` immediately before jumping to `.close`
on output status error. Since `.close` also restores channels before closing the
file, v2.8 comments out the duplicate `CBM_CLRCHN`.

This removes repeated cleanup work on the error path.

## `out_4` Optimization

In v2.7, `out_4` called `out_1` three times and then jumped to `out_1` for the
fourth sample:

```asm
out_4
    JSR out_1
    JSR out_1
    JSR out_1
    JMP out_1
```

In v2.8, the final jump is commented out. Because `out_4` falls through directly
into `out_1`, the fourth call still happens without needing the explicit
`JMP`.

This is a small size/speed optimization that preserves behavior.

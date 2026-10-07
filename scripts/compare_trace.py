import re
from pathlib import Path


SPIKE_BASE = 0x80000000

RTL_LOG = Path("tests/rtl_trace.log")
SPIKE_LOG = Path("tests/spike.log")


# ============================================================
# RTL TRACE PARSER
# ============================================================

def parse_rtl():
    entries = []

    pattern = re.compile(
        r"PC=([0-9a-fA-F]+)\s+"
        r"INST=([0-9a-fA-F]+)"
        r"(?:\s+RD=(\d+)\s+VALUE=([0-9a-fA-F]+))?"
        r"(?:\s+MEM=([0-9a-fA-F]+)"
        r"(?:\s+VALUE=([0-9a-fA-F]+))?)?"
    )

    for line in RTL_LOG.read_text().splitlines():
        match = pattern.search(line)

        if not match:
            continue

        pc, inst, rd, rd_value, mem, mem_value = match.groups()

        entries.append(
            {
                "pc": int(pc, 16),
                "inst": int(inst, 16),
                "rd": int(rd) if rd is not None else None,
                "rd_value": (
                    int(rd_value, 16)
                    if rd_value is not None
                    else None
                ),
                "mem": (
                    int(mem, 16)
                    if mem is not None
                    else None
                ),
                "mem_value": (
                    int(mem_value, 16)
                    if mem_value is not None
                    else None
                ),
            }
        )

    return entries


# ============================================================
# SPIKE TRACE PARSER
# ============================================================

def parse_spike():
    entries = []

    pattern = re.compile(
        r"core\s+0:\s+3\s+"
        r"0x([0-9a-fA-F]+)\s+"
        r"\(0x([0-9a-fA-F]+)\)"
        r"(.*)"
    )

    for line in SPIKE_LOG.read_text().splitlines():
        match = pattern.search(line)

        if not match:
            continue

        pc_text, inst_text, rest = match.groups()

        spike_pc = int(pc_text, 16)

        entry = {
            "pc": (spike_pc - SPIKE_BASE) & 0xFFFFFFFF,
            "inst": int(inst_text, 16),
            "rd": None,
            "rd_value": None,
            "mem": None,
            "mem_value": None,
        }

        # ----------------------------------------------------
        # Register write
        # ----------------------------------------------------

        rd_match = re.search(
            r"(?:^|\s)x([0-9]|[12][0-9]|3[01])\s+"
            r"0x([0-9a-fA-F]+)",
            rest
        )

        if rd_match:
            entry["rd"] = int(rd_match.group(1))
            entry["rd_value"] = int(rd_match.group(2), 16)

        # ----------------------------------------------------
        # Memory access
        # ----------------------------------------------------

        mem_match = re.search(
            r"mem\s+0x([0-9a-fA-F]+)"
            r"(?:\s+0x([0-9a-fA-F]+))?",
            rest
        )

        if mem_match:
            spike_mem = int(mem_match.group(1), 16)

            entry["mem"] = (
                spike_mem - SPIKE_BASE
            ) & 0xFFFFFFFF

            if mem_match.group(2):
                entry["mem_value"] = int(
                    mem_match.group(2),
                    16
                )

        entries.append(entry)

    return entries


# ============================================================
# SPIKE VALUE NORMALIZATION
# ============================================================

def normalize_spike_rd_value(entry):
    value = entry["rd_value"]

    if value is None:
        return None

    opcode = entry["inst"] & 0x7F

    # --------------------------------------------------------
    # The RTL program starts at 0x00000000.
    #
    # The Spike program starts at 0x80000000.
    #
    # These instructions generate values that depend directly
    # on the current PC:
    #
    # AUIPC -> rd = PC + immediate
    # JAL   -> rd = PC + 4
    # JALR  -> rd = PC + 4
    #
    # Remove the Spike address base so both machines can be
    # compared in the same logical address space.
    # --------------------------------------------------------

    OPCODE_AUIPC = 0x17
    OPCODE_JALR = 0x67
    OPCODE_JAL = 0x6F

    if opcode in (
        OPCODE_AUIPC,
        OPCODE_JALR,
        OPCODE_JAL,
    ):
        return (value - SPIKE_BASE) & 0xFFFFFFFF

    return value


# ============================================================
# MAIN DIFFERENTIAL TEST
# ============================================================

def main():

    # --------------------------------------------------------
    # Check log files
    # --------------------------------------------------------

    if not RTL_LOG.exists():
        print(f"ERROR: {RTL_LOG} does not exist.")
        return

    if not SPIKE_LOG.exists():
        print(f"ERROR: {SPIKE_LOG} does not exist.")
        return

    # --------------------------------------------------------
    # Parse traces
    # --------------------------------------------------------

    rtl = parse_rtl()
    spike = parse_spike()

    print()
    print("==============================================")
    print("       SPIKE vs RTL DIFFERENTIAL TEST")
    print("==============================================")
    print()

    print(f"RTL instructions   : {len(rtl)}")
    print(f"Spike instructions : {len(spike)}")
    print()

    if len(rtl) != len(spike):
        print(
            f"WARNING: RTL has {len(rtl)} instructions, "
            f"Spike has {len(spike)} instructions."
        )
        print()

    total = min(len(rtl), len(spike))

    passed = 0


    # ========================================================
    # INSTRUCTION-BY-INSTRUCTION COMPARISON
    # ========================================================

    for index in range(total):

        r = rtl[index]
        s = spike[index]

        errors = []


        # ----------------------------------------------------
        # PC
        # ----------------------------------------------------

        if r["pc"] != s["pc"]:
            errors.append(
                f"PC RTL={r['pc']:08x} "
                f"SPIKE={s['pc']:08x}"
            )


        # ----------------------------------------------------
        # Instruction
        # ----------------------------------------------------

        if r["inst"] != s["inst"]:
            errors.append(
                f"INST RTL={r['inst']:08x} "
                f"SPIKE={s['inst']:08x}"
            )


        # ----------------------------------------------------
        # Destination register
        # ----------------------------------------------------

        if r["rd"] != s["rd"]:
            errors.append(
                f"RD RTL={r['rd']} "
                f"SPIKE={s['rd']}"
            )


        # ----------------------------------------------------
        # Destination register value
        # ----------------------------------------------------

        spike_rd_value = normalize_spike_rd_value(s)

        if r["rd_value"] != spike_rd_value:
            errors.append(
                f"RD_VALUE RTL="
                f"{format_optional_hex(r['rd_value'])} "
                f"SPIKE="
                f"{format_optional_hex(spike_rd_value)}"
            )


        # ----------------------------------------------------
        # Memory address
        # ----------------------------------------------------

        if r["mem"] != s["mem"]:
            errors.append(
                f"MEM RTL="
                f"{format_optional_hex(r['mem'])} "
                f"SPIKE="
                f"{format_optional_hex(s['mem'])}"
            )


        # ----------------------------------------------------
        # Memory write value
        # ----------------------------------------------------

        if r["mem_value"] != s["mem_value"]:
            errors.append(
                f"MEM_VALUE RTL="
                f"{format_optional_hex(r['mem_value'])} "
                f"SPIKE="
                f"{format_optional_hex(s['mem_value'])}"
            )


        # ----------------------------------------------------
        # PASS
        # ----------------------------------------------------

        if not errors:

            passed += 1

            event = ""

            if r["rd"] is not None:
                event = (
                    f"x{r['rd']}="
                    f"{r['rd_value']:08x}"
                )

            elif r["mem"] is not None:

                if r["mem_value"] is not None:
                    event = (
                        f"MEM[{r['mem']:08x}]="
                        f"{r['mem_value']:08x}"
                    )
                else:
                    event = (
                        f"MEM[{r['mem']:08x}]"
                    )

            print(
                f"[{index + 1:02d}] PASS  "
                f"PC={r['pc']:08x}  "
                f"INST={r['inst']:08x}  "
                f"{event}"
            )


        # ----------------------------------------------------
        # FAIL
        # ----------------------------------------------------

        else:

            print(
                f"[{index + 1:02d}] FAIL  "
                f"PC={r['pc']:08x}  "
                f"INST={r['inst']:08x}"
            )

            for error in errors:
                print(f"     {error}")


    # ========================================================
    # FINAL RESULT
    # ========================================================

    print()
    print("==============================================")
    print(
        f"Result: {passed}/{total} instructions match"
    )

    if (
        passed == total
        and len(rtl) == len(spike)
    ):
        print("ALL INSTRUCTIONS MATCH SPIKE")
    else:
        print("DIFFERENCES FOUND")

    print("==============================================")


# ============================================================
# HELPER
# ============================================================

def format_optional_hex(value):

    if value is None:
        return "None"

    return f"{value:08x}"


# ============================================================
# ENTRY POINT
# ============================================================

if __name__ == "__main__":
    main()
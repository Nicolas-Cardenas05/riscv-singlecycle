import re
from pathlib import Path

SPIKE_BASE = 0x80000000

RTL_LOG = Path("tests/rtl_trace.log")
SPIKE_LOG = Path("tests/spike.log")


def parse_rtl():
    entries = []

    pattern = re.compile(
        r"PC=([0-9a-fA-F]+)\s+"
        r"INST=([0-9a-fA-F]+)"
        r"(?:\s+RD=(\d+)\s+VALUE=([0-9a-fA-F]+))?"
        r"(?:\s+MEM=([0-9a-fA-F]+)(?:\s+VALUE=([0-9a-fA-F]+))?)?"
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
                "rd_value": int(rd_value, 16) if rd_value is not None else None,
                "mem": int(mem, 16) if mem is not None else None,
                "mem_value": int(mem_value, 16) if mem_value is not None else None,
            }
        )

    return entries


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

        entry = {
            "pc": int(pc_text, 16) - SPIKE_BASE,
            "inst": int(inst_text, 16),
            "rd": None,
            "rd_value": None,
            "mem": None,
            "mem_value": None,
        }

        rd_match = re.search(
            r"x(\d+)\s+0x([0-9a-fA-F]+)",
            rest
        )

        if rd_match:
            entry["rd"] = int(rd_match.group(1))
            entry["rd_value"] = int(rd_match.group(2), 16)

        mem_match = re.search(
            r"mem\s+0x([0-9a-fA-F]+)(?:\s+0x([0-9a-fA-F]+))?",
            rest
        )

        if mem_match:
            entry["mem"] = int(mem_match.group(1), 16) - SPIKE_BASE

            if mem_match.group(2):
                entry["mem_value"] = int(mem_match.group(2), 16)

        entries.append(entry)

    return entries


def normalize_spike_rd_value(entry):
    value = entry["rd_value"]

    if value is None:
        return None

    opcode = entry["inst"] & 0x7F

    # JAL writes PC + 4 into rd.
    if opcode == 0b1101111 and value >= SPIKE_BASE:
        return value - SPIKE_BASE

    return value


def main():
    rtl = parse_rtl()
    spike = parse_spike()

    print()
    print("==============================================")
    print("       SPIKE vs RTL DIFFERENTIAL TEST")
    print("==============================================")
    print()

    if len(rtl) != len(spike):
        print(
            f"WARNING: RTL has {len(rtl)} instructions, "
            f"Spike has {len(spike)} instructions."
        )
        print()

    total = min(len(rtl), len(spike))
    passed = 0

    for index in range(total):
        r = rtl[index]
        s = spike[index]

        errors = []

        if r["pc"] != s["pc"]:
            errors.append(
                f"PC RTL={r['pc']:08x} SPIKE={s['pc']:08x}"
            )

        if r["inst"] != s["inst"]:
            errors.append(
                f"INST RTL={r['inst']:08x} SPIKE={s['inst']:08x}"
            )

        if r["rd"] != s["rd"]:
            errors.append(
                f"RD RTL={r['rd']} SPIKE={s['rd']}"
            )

        spike_rd_value = normalize_spike_rd_value(s)

        if r["rd_value"] != spike_rd_value:
            errors.append(
                f"RD_VALUE RTL={r['rd_value']} "
                f"SPIKE={spike_rd_value}"
            )

        if r["mem"] != s["mem"]:
            errors.append(
                f"MEM RTL={r['mem']} SPIKE={s['mem']}"
            )

        if r["mem_value"] != s["mem_value"]:
            errors.append(
                f"MEM_VALUE RTL={r['mem_value']} "
                f"SPIKE={s['mem_value']}"
            )

        if not errors:
            passed += 1

            event = ""

            if r["rd"] is not None:
                event = (
                    f"x{r['rd']}={r['rd_value']:08x}"
                )

            elif r["mem"] is not None:
                event = (
                    f"MEM[{r['mem']:08x}]="
                    f"{r['mem_value']:08x}"
                )

            print(
                f"[{index + 1:02d}] PASS  "
                f"PC={r['pc']:08x}  "
                f"INST={r['inst']:08x}  "
                f"{event}"
            )

        else:
            print(
                f"[{index + 1:02d}] FAIL  "
                f"PC={r['pc']:08x}  "
                f"INST={r['inst']:08x}"
            )

            for error in errors:
                print(f"     {error}")

    print()
    print("==============================================")
    print(f"Result: {passed}/{total} instructions match")

    if passed == total and len(rtl) == len(spike):
        print("ALL INSTRUCTIONS MATCH SPIKE")
    else:
        print("DIFFERENCES FOUND")

    print("==============================================")


if __name__ == "__main__":
    main()
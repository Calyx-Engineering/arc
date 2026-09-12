# response-length-rank.py — rank two candidate wordings of a skill across MANY probe runs.
#
#   python tools/response-length-rank.py A=<dir> B=<dir> [--case <name>] [--eval-dir <dir>]
#   python tools/response-length-rank.py selftest
#
# WHY THIS EXISTS. tools/response-length.sh --probe scores ONE run. #158 compared two skills at
# n=1, #213 at n=3, and #213's own constraint says why neither could settle anything: the
# 20-word case scores 0.09 to 0.91 across runs that differ in nothing but the sampling. Three
# runs establish that a ceiling is reachable and not reliably held. They cannot rank two
# wordings, and reading a 0.45 against a 0.19 as "the candidate is better" is reading two draws
# from overlapping distributions. #262 raises the count, and a raised count needs something
# that aggregates — otherwise the comparison is a person eyeballing twelve terminal scrollbacks.
#
# THE RUN IS THE UNIT, NOT THE TURN. Eleven turns inside one run are not eleven independent
# observations: a run that decays fails every turn after it decays, and a run that holds passes
# every turn. Pooling turns across runs makes twelve runs look like 130 samples and shrinks the
# interval by a factor of three and a half over what the design earns. So the ranking test is
# over per-run rates, and the pooled turn figure is printed beside it as the suite number it is
# — the thing tools/response-length.sh reports — never as the thing being tested.
#
# THE SCORER IS tools/response-length.py's, IMPORTED. prose_words, thin_floor, verdicts and
# read_case all come from there. A second copy would be a second thin floor, a second fence
# rule and a second CUT rule, and the day they disagree the ranking and the suite score are
# measuring different things while both print "within budget".
#
# A RUN THE RATE LIMIT DESTROYED IS REFUSED, NOT AVERAGED IN. #213 lost two billed runs that
# came back with all eleven turns CUT, one at $0.000. The scorer already refuses to read a
# truncated reply as a held budget, turn by turn — but a run that is ALL truncation still
# arrives here as a case with a denominator of zero or one, and a single surviving turn scoring
# 1/1 would enter the ranking as a perfect run. So a run is VOID when it has no scoreable turn,
# or when more than half its turns were cut, and a void run is named and excluded rather than
# silently weighted. RLR_MIN_SCORED raises the bar if a case needs it.
#
# WHAT IT READS. One directory per arm, holding the RL_PROBE_OUT JSON of each run — one file
# per run, any name, `*.json`. tools/response-length.sh's own header already says ONE RUN PER
# PATH, because the runner writes a case's entry whole and --runs N leaves only the last. This
# tool is the reason to obey that: each file is one run, and the filename is what the report
# calls it.
import io
import importlib.util
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

_spec = importlib.util.spec_from_file_location("rl_score", os.path.join(HERE, "response-length.py"))
rl = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(rl)

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


# ---- the exact Mann-Whitney null ----------------------------------------------------
# Two arms of six runs each is small enough that the normal approximation is the wrong
# instrument and large enough that complete separation is decisive: with n=6 against n=6, every
# run of one arm above every run of the other gives U=0 and a two-sided p of 0.0022. That is the
# number #213's constraint was asking for, and it is reachable at a count a billed probe can
# actually pay for. The distribution is counted rather than approximated because at these n the
# approximation's tail is wrong by enough to change the answer.
def _u_counts(n, m, memo):
    """How many of the C(n+m, n) arrangements give each value of U. Index is U."""
    key = (n, m)
    if key in memo:
        return memo[key]
    if n == 0 or m == 0:
        memo[key] = [1]
        return memo[key]
    # c(n, m, u) = c(n-1, m, u-m) + c(n, m-1, u) — the standard recurrence, carried as whole
    # polynomials so each (n, m) is computed once.
    a = _u_counts(n - 1, m, memo)
    b = _u_counts(n, m - 1, memo)
    out = [0] * (n * m + 1)
    for u, c in enumerate(a):
        out[u + m] += c
    for u, c in enumerate(b):
        out[u] += c
    memo[key] = out
    return out


def mann_whitney(xs, ys):
    """(U, two-sided exact p, tied pairs). U counts pairs where an x beats a y.

    Ties score half a pair, which is the usual convention and keeps U symmetric — but the exact
    null below is the untied one, so the tie count travels with the answer rather than being
    absorbed into it. A caller that sees ties should say so.
    """
    n, m = len(xs), len(ys)
    if not n or not m:
        return 0.0, 1.0, 0
    u = 0.0
    tied = 0
    for x in xs:
        for y in ys:
            if x > y:
                u += 1
            elif x == y:
                u += 0.5
                tied += 1
    counts = _u_counts(n, m, {})
    total = float(sum(counts))
    # U and n*m - U are the two tails of the same statistic. Round outward so a half-integer U
    # from a tie cannot make the tail smaller than the data supports.
    lo = int(u)
    hi = int(u + 0.9999)
    p_low = sum(counts[: lo + 1]) / total
    p_high = sum(counts[hi:]) / total
    return u, min(1.0, 2.0 * min(p_low, p_high)), tied


# ---- one run ------------------------------------------------------------------------
def score_run(path, casedir_of, min_scored):
    """{case name: dict} for one RL_PROBE_OUT file.

    Each entry carries the scored turns, the rate, the first breach, whether chat-response
    fired on the turn the budget was stated, and — when the run is unusable — why.
    """
    data = json.load(io.open(path, encoding="utf-8"))
    out = {}
    for name, turns in sorted(data.items()):
        cp = casedir_of(name)
        if not cp:
            out[name] = {"void": "no case.yaml for %s under the eval directory" % name}
            continue
        case = rl.read_case(cp)
        budget, set_on = case["budget"], case["set_on"]
        if not budget:
            out[name] = {"void": "case sets no word budget"}
            continue
        floor = rl.thin_floor(budget, int(os.environ.get("RL_THIN_FLOOR", "15")))
        pairs, fired = [], {}
        for k, v in sorted(turns.items(), key=lambda kv: int(kv[0])):
            pairs.append((int(k), rl.prose_words(v.get("text", "")), v.get("cut", "")))
            fired[int(k)] = v.get("fired") or []
        scored, breach = rl.verdicts(pairs, budget, floor)
        under = sum(1 for _, _, v in scored if v == "UNDER")
        over = sum(1 for _, _, v in scored if v == "OVER")
        cut = sum(1 for _, _, v in scored if v == "CUT")
        denom = under + over
        row = {
            "budget": budget, "floor": floor, "turns": len(scored), "cut": cut,
            "under": under, "over": over, "denom": denom,
            "rate": (under / denom) if denom else 0.0,
            "breach": breach,
            "fired_on_set": "chat-response" in fired.get(set_on, []),
            "set_on": set_on,
            "void": "",
        }
        # Both halves of the rate-limit refusal, and CUT is asked FIRST because it names the
        # cause. A rate-limited run fails both tests — it is mostly cut, and what survives is
        # too little to score — and "only 1 scoreable turn" sends the reader looking at the
        # case while "5 of 6 turns cut short by the runner" sends them at the rate limit.
        if cut * 2 > len(scored):
            row["void"] = "%d of %d turns cut short by the runner" % (cut, len(scored))
        elif denom < min_scored:
            row["void"] = "only %d scoreable turn(s), minimum %d" % (denom, min_scored)
        out[name] = row
    return out


def arm_runs(d, casedir_of, min_scored):
    """[(run label, {case: row})] for every *.json in an arm's directory, sorted by name."""
    if not os.path.isdir(d):
        raise SystemExit("not a directory: %s" % d)
    files = sorted(f for f in os.listdir(d) if f.endswith(".json"))
    if not files:
        raise SystemExit("no *.json probe output under %s" % d)
    return [(os.path.splitext(f)[0], score_run(os.path.join(d, f), casedir_of, min_scored))
            for f in files]


def median(xs):
    s = sorted(xs)
    if not s:
        return 0.0
    h = len(s) // 2
    return s[h] if len(s) % 2 else (s[h - 1] + s[h]) / 2.0


def main(argv):
    evaldir = os.environ.get("RLR_EVAL_DIR", "evals/response-length")
    only = ""
    min_scored = int(os.environ.get("RLR_MIN_SCORED", "3"))
    threshold = float(os.environ.get("RL_THRESHOLD", "0.67"))
    arms = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == "--case":
            i += 1
            only = argv[i]
        elif a == "--eval-dir":
            i += 1
            evaldir = argv[i]
        elif "=" in a:
            label, d = a.split("=", 1)
            arms.append((label, d))
        else:
            raise SystemExit("unknown argument: %s" % a)
        i += 1
    if not arms:
        raise SystemExit("usage: response-length-rank.py <label>=<dir> [<label>=<dir>] [--case <name>]")

    index = {}
    for dirpath, _, files in os.walk(evaldir):
        if "case.yaml" in files:
            index[os.path.relpath(dirpath, evaldir).replace(os.sep, "/")] = os.path.join(dirpath, "case.yaml")

    def casedir_of(name):
        return index.get(name, "")

    print("response-length-rank — %d arm(s), eval dir %s" % (len(arms), evaldir))
    print("The run is the unit. A pooled turn figure is printed beside it, never tested on.")
    print()

    summary = {}
    for label, d in arms:
        runs = arm_runs(d, casedir_of, min_scored)
        print("arm %s — %s" % (label, d))
        rates, pooled_u, pooled_d, fired_rows, unfired_rows, void = [], 0, 0, [], [], []
        for run_label, cases in runs:
            # A run that contributes NO row is VOID, not absent — and the question can only be
            # asked here, after --case has been applied. A file the runner was killed before
            # writing holds no case at all; a file holding only the other case of the suite is
            # the likelier one, and both used to vanish in silence, missing from the n this tool
            # prints. n is the whole claim it exists to make.
            emitted = 0
            for name, row in sorted(cases.items()):
                if only and name != only:
                    continue
                emitted += 1
                if row.get("void"):
                    print("  VOID   %-22s %-28s %s" % (run_label, name, row["void"]))
                    void.append((run_label, name, row["void"]))
                    continue
                print("  %-22s %-28s %2d/%-2d  %.2f   first breach %-5s  fired on t%d: %s"
                      % (run_label, name, row["under"], row["denom"], row["rate"],
                         ("t%d" % row["breach"]) if row["breach"] is not None else "none",
                         row["set_on"], "yes" if row["fired_on_set"] else "no"))
                rates.append(row["rate"])
                pooled_u += row["under"]
                pooled_d += row["denom"]
                (fired_rows if row["fired_on_set"] else unfired_rows).append(row)
            if not emitted:
                why = ("holds no probe output at all" if not cases
                       else "holds no %s — only %s" % (only, ", ".join(sorted(cases))))
                print("  VOID   %-22s %-28s %s" % (run_label, only or "(any case)", why))
                void.append((run_label, only, why))
        if not rates:
            raise SystemExit("arm %s has no scoreable run" % label)
        print("  %-22s n=%d runs, %d void   median run rate %.2f   pooled %d/%d %.2f"
              % ("", len(rates), len(void), median(rates), pooled_u, pooled_d,
                 (pooled_u / pooled_d) if pooled_d else 0.0))
        print()
        summary[label] = {
            "rates": rates, "u": pooled_u, "d": pooled_d, "void": len(void),
            "fired": fired_rows, "unfired": unfired_rows,
        }

    # ---- the ranking -----------------------------------------------------------------
    labels = [l for l, _ in arms]
    if len(labels) == 2:
        a, b = labels
        xs, ys = summary[b]["rates"], summary[a]["rates"]
        u, p, tied = mann_whitney(xs, ys)
        sep = min(xs) > max(ys) or min(ys) > max(xs)
        print("ranking — %s against %s, Mann-Whitney over per-run rates" % (b, a))
        print("  n              %d vs %d" % (len(xs), len(ys)))
        print("  U              %.1f of %d" % (u, len(xs) * len(ys)))
        print("  exact p        %.4f%s" % (p, "" if not tied else "   (%d tied pair(s); the exact null is the untied one)" % tied))
        print("  separation     %s" % ("complete — every run of one arm beats every run of the other"
                                       if sep else "overlapping"))
        higher = b if median(xs) > median(ys) else a
        print("  RANKED         %s" % (
            ("%s, p=%.4f" % (higher, p)) if p < 0.05
            else "NO — p=%.4f at n=%d vs %d. Raise the run count or the arms do not differ." % (p, len(xs), len(ys))))
        print()

    # ---- the firing split, pooled across every arm -------------------------------------
    # #213 found a clean split with no overlap at n=4 either side, called it a finding to test
    # rather than a proven mechanism, and could not test it. #262 did, at n=29, and the ranges
    # overlap almost entirely. The split is reported across ALL arms because it is a question
    # about the mechanism, not about a wording — and it is an OBSERVED split, never an assigned
    # one. Nothing here randomises firing, so this ranks runs by something the run did, and a
    # difference is an association. Read which arms each side is made of before believing it:
    # when one arm fires on every run, "did not fire" is that arm's complement, not a condition.
    fired = [r for s in summary.values() for r in s["fired"]]
    unfired = [r for s in summary.values() for r in s["unfired"]]
    print("chat-response fired on the turn the budget was stated — pooled across arms")
    for name, rows in (("fired", fired), ("did not fire", unfired)):
        if not rows:
            print("  %-14s no runs" % name)
            continue
        pu = sum(r["under"] for r in rows)
        pd = sum(r["denom"] for r in rows)
        rr = [r["rate"] for r in rows]
        print("  %-14s %d run(s)   rate %.2f-%.2f   median %.2f   pooled %d/%d %.2f"
              % (name, len(rows), min(rr), max(rr), median(rr), pu, pd, pu / pd if pd else 0.0))
    if fired and unfired:
        u, p, tied = mann_whitney([r["rate"] for r in fired], [r["rate"] for r in unfired])
        print("  %-14s U=%.1f  exact p=%.4f%s" % ("", u, p, "  (%d tied)" % tied if tied else ""))
        print("  %-14s %s" % ("", "firing separates the runs" if p < 0.05
                              else "not separated at this count"))
    print()

    pooled_u = sum(s["u"] for s in summary.values())
    pooled_d = sum(s["d"] for s in summary.values())
    print("%-28s %.2f" % ("threshold", threshold))
    print("%-28s %s" % ("all arms pooled", "%d/%d  %.2f" % (pooled_u, pooled_d, pooled_u / pooled_d if pooled_d else 0.0)))
    print()
    print("A pooled figure over two arms is not a suite score — it mixes a control into it.")
    print("tools/response-length.sh --probe reports the suite, one run at a time.")


# ---- selftest ------------------------------------------------------------------------
# Synthetic probe JSON, no `claude`, no corpus, no bill. What it has to get right is what a
# billed run cannot be re-run to check: that a void run is excluded, that the ranking is over
# runs rather than turns, and that the exact p is the exact p.
def selftest():
    import shutil
    import subprocess
    import tempfile

    T = tempfile.mkdtemp()
    try:
        E = os.path.join(T, "evals")
        os.makedirs(os.path.join(E, "twenty", "turns"))
        io.open(os.path.join(E, "twenty", "case.yaml"), "w", encoding="utf-8").write(
            "budget: 20\nunit: words\nsource:\n  session: aaa11111\n  first_turn: 1\n"
            "  last_turn: 6\n  set_on: 1\n")

        def words(n):
            return " ".join("w" * n)

        def run(path, lengths, fired_first=True, cuts=()):
            turns = {}
            for i, n in enumerate(lengths, start=1):
                turns[str(i)] = {
                    "text": words(n),
                    "cut": "error_max_budget" if i in cuts else "",
                    "fired": ["chat-response"] if (i == 1 and fired_first) else [],
                }
            json.dump({"twenty": turns}, io.open(path, "w", encoding="utf-8"))

        A = os.path.join(T, "armA")
        B = os.path.join(T, "armB")
        os.makedirs(A)
        os.makedirs(B)
        # Arm A: six runs that mostly break the budget. Arm B: six that mostly hold it, and
        # every B run above every A run, so the ranking has one right answer.
        for i, over in enumerate([5, 5, 4, 5, 4, 5], start=1):
            run(os.path.join(A, "run-%d.json" % i),
                [18] * (6 - over) + [70] * over, fired_first=False)
        for i, over in enumerate([1, 0, 1, 2, 0, 1], start=1):
            run(os.path.join(B, "run-%d.json" % i),
                [18] * (6 - over) + [70] * over, fired_first=True)
        # A seventh B run the rate limit destroyed: every turn cut, and one surviving 18-word
        # reply that would otherwise enter the ranking as a perfect 1/1.
        run(os.path.join(B, "run-7-ratelimited.json"), [18] * 6, cuts=(1, 2, 3, 4, 5))
        # An eighth the runner never got to write, and a ninth holding only the OTHER case of a
        # suite. Under --case both used to be dropped in silence rather than counted as void,
        # and the filter is in every documented invocation, so the silence was the normal path.
        json.dump({}, io.open(os.path.join(B, "run-8-empty.json"), "w", encoding="utf-8"))
        json.dump({"sixty": {"1": {"text": words(18), "cut": "", "fired": []}}},
                  io.open(os.path.join(B, "run-9-other-case-only.json"), "w", encoding="utf-8"))

        env = dict(os.environ, RLR_EVAL_DIR=E)
        out = subprocess.run(
            [sys.executable, os.path.abspath(__file__), "A=" + A, "B=" + B,
             "--case", "twenty"],
            capture_output=True, text=True, encoding="utf-8", errors="replace", env=env)
        text = out.stdout + out.stderr

        P = F = 0

        def t(label, pattern):
            nonlocal P, F
            if re.search(pattern, text):
                print("  PASS  %s" % label)
                P += 1
            else:
                print("  FAIL  %s" % label)
                print("        wanted /%s/" % pattern)
                print("        got:")
                print("\n".join("          " + l for l in text.splitlines()))
                F += 1

        print("response-length-rank selftest")
        print()
        t("a run is scored from its probe JSON", r"run-1\s+twenty\s+1/6\s+0\.17")
        t("the arm's per-run rates are summarised", r"n=6 runs, 0 void")
        # The whole reason the tool exists: 12 runs are 12 observations, not 72.
        t("the ranking's n is runs, not turns", r"n\s+6 vs 6")
        t("a fully separated pair ranks at the exact p", r"exact p\s+0\.0022")
        t("complete separation is named as such", r"separation\s+complete")
        t("the higher arm is named", r"RANKED\s+B, p=0\.0022")
        # A run the rate limit destroyed must not be averaged in. Left in, its surviving turn
        # scores 1/1 and drags arm B's median up on evidence that does not exist.
        t("a mostly-cut run is void, not averaged in", r"VOID\s+run-7-ratelimited\s+twenty\s+5 of 6 turns cut")
        t("the void run is excluded from the arm's n", r"arm B[\s\S]*n=6 runs, 3 void")
        # Both under --case, which is what every documented invocation passes and what used to
        # filter the report of an empty run straight back out again.
        t("a run the runner never wrote is void, not absent",
          r"VOID\s+run-8-empty\s+twenty\s+holds no probe output at all")
        t("a run holding only the other case is void, not absent",
          r"VOID\s+run-9-other-case-only\s+twenty\s+holds no twenty — only sixty")
        t("the firing split is reported", r"chat-response fired on the turn the budget was stated")
        t("the split names how many runs each side", r"fired\s+6 run\(s\)")
        t("the pooled turn figure is printed beside the run figure",
          r"n=6 runs, 0 void\s+median run rate 0\.17\s+pooled 8/36 0\.22")
        # 12 runs of 6 turns is 72 turns, and arm B alone is 31/36 — well over the threshold.
        # Printing a pooled figure that mixes the control in as though it were a suite score is
        # the arithmetic this line exists to keep visible rather than quotable.
        t("the cross-arm pooled figure says it is not a suite score",
          r"A pooled figure over two arms is not a suite score")

        print()
        print("%d passed, %d failed" % (P, F))
        return 1 if F else 0
    finally:
        shutil.rmtree(T, ignore_errors=True)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "selftest":
        raise SystemExit(selftest())
    main(sys.argv[1:])

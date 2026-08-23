import pandas as pd
import matplotlib.pyplot as plt
import re

# Load TSV
df = pd.read_csv("/lustrehome/nitika/bash_script/fastq_file/subsampled_reads/stats.tsv", sep="\t")

# Extract sample name (e.g. R1_sub_0.1) from the file path
df["sample"] = df["file"].apply(lambda x: re.search(r"(R[12]_sub_[0-9.]+)", x).group(1))

# Split out read (R1/R2) and subsample fraction for sorting
df["read"] = df["sample"].str.extract(r"(R[12])")
df["frac"] = df["sample"].str.extract(r"sub_([0-9]+\.[0-9]+)").astype(float)
df = df.sort_values(["read", "frac"])

# ---------------- Plot ----------------
plt.rcParams["font.family"] = "sans-serif"

fig, ax = plt.subplots(figsize=(8, 6))
colors = {"R1": "steelblue", "R2": "orange"}
markers = {"R1": "o", "R2": "*"}
sizes = {"R1": 8, "R2": 16}
zorders = {"R1": 3, "R2": 2}

for read, sub in df.groupby("read"):
    sub = sub.sort_values("frac")
    x_pct = sub["frac"] * 100
    ax.plot(
        x_pct,
        sub["num_seqs"],
        marker=markers[read],
        markersize=sizes[read],
        markerfacecolor=colors[read],
        markeredgecolor="white",
        markeredgewidth=0.8,
        linestyle="None",
        alpha=0.9,
        zorder=zorders[read],
        label=read,
    )

# X-axis ticks as percentages (10%, 20%, ..., 90%)
xticks = sorted(df["frac"].unique() * 100)
ax.set_xticks(xticks)
ax.set_xticklabels([f"{int(x)}%" for x in xticks], fontsize=11)

# Labels and title
ax.set_xlabel("Subsampling level (%)", fontsize=13)
ax.set_ylabel("Number of reads", fontsize=13)
ax.set_title("Read counts across subsampling levels", fontsize=15, pad=12)

# Tick label font size (y-axis)
ax.tick_params(axis="y", labelsize=11)

# Clean white background
fig.patch.set_facecolor("white")
ax.set_facecolor("white")

# Remove top and right spines
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_linewidth(0.8)
ax.spines["bottom"].set_linewidth(0.8)

# Subtle horizontal gridlines only
ax.yaxis.grid(True, linestyle="--", linewidth=0.6, alpha=0.4)
ax.xaxis.grid(False)
ax.set_axisbelow(True)

# Legend
ax.legend(frameon=False, fontsize=11, loc="best")

plt.tight_layout()

# Save as PNG (300 dpi) and PDF (vector)
plt.savefig("reads_subsampling.png", dpi=300)
plt.savefig("reads_subsampling.pdf")

plt.show()

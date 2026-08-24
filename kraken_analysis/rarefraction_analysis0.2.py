import matplotlib.pyplot as plt

fig, ax1 = plt.subplots(figsize=(10,5))

ax1.plot(sample_cols, alpha_div["Observed_species"], marker="o", color="tab:blue", label="Observed species")
ax1.set_xlabel("Sequencing depth (subsample)")
ax1.set_ylabel("Observed species", color="tab:blue")
ax1.tick_params(axis="y", labelcolor="tab:blue")

# Shorten x-axis labels
short_labels = [c.replace("Sample #", "S") for c in sample_cols]
ax1.set_xticklabels(short_labels)

ax2 = ax1.twinx()
ax2.plot(sample_cols, alpha_div["Shannon"], marker="s", color="tab:red", label="Shannon index")
ax2.set_ylabel("Shannon diversity index", color="tab:red")
ax2.tick_params(axis="y", labelcolor="tab:red")

plt.title("Rarefaction analysis: species richness and diversity vs. sequencing depth")
fig.tight_layout()
plt.savefig("rarefaction_analysis.png", dpi=300, bbox_inches="tight")
plt.show()

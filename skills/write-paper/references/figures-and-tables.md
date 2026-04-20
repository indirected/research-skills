# Figures and Tables

Figures and tables are read more than the prose around them. A reviewer who skims your paper looks at the title, abstract, figures, and tables — often in that order, often before reading any prose. Each figure and table needs to **stand alone** and **earn its space**.

## What a figure / table must do

For each figure or table, ask:

1. **What single point does this make?** If you can't name one in a sentence, the figure does too much (or too little).
2. **Could a reviewer understand it from the figure + caption alone, without the body text?** If not, fix the caption or the figure.
3. **Is it the most efficient way to communicate this point?** A table of 2 numbers is wasteful; a figure with 50 lines is unreadable.

If the figure doesn't pass these tests, either redesign it or cut it.

## Universal principles

### 1. Direct labeling beats legends

Legends force the reader's eye to bounce between the plot and the legend box. Direct labels (text placed next to the line / point / region it describes) are read in a single pass. Use direct labels whenever possible.

If you must use a legend, place it inside the plot area near the data, not floating in a corner.

### 2. Real names, not "Method A" / "Method B"

In tables and figures, name baselines and your method with their actual names. Forcing the reader to refer back to a legend or table caption to decode "Method A" wastes their time.

### 3. Self-contained captions

Captions should describe **what the figure shows** and **what the reader should take away**, in 1–4 sentences:

> Figure 3: Accuracy vs. compute on MMLU. Our method (red) achieves the same accuracy as the strongest baseline (blue) at 1/3 the compute, and dominates the Pareto frontier across model scales 1B–70B.

Versus a thin caption:

> Figure 3: MMLU results.

The first lets a skimmer extract the point in 5 seconds; the second forces them to study the plot.

### 4. Vector graphics for figures

Use PDF or SVG (vector) for plots, not PNG/JPEG (raster), unless the figure is a literal photograph or screenshot. Vector scales cleanly when reviewers zoom in; raster gets blurry.

For LaTeX, prefer `\includegraphics` of `.pdf` figures saved from your plotting library (matplotlib's `savefig(..., format='pdf')`, Plotly export, etc.).

### 5. Readable when shrunk

Page-1 concept figures will display at smaller sizes than your screen. Test: shrink the figure to half-column width and check legibility. If labels become unreadable, your fonts are too small or the figure is too dense.

A common error: matplotlib defaults yield font sizes that look fine in a Jupyter notebook but illegible in a published two-column paper. Set font size explicitly (`rcParams['font.size'] = 12` or larger).

### 6. Color choices

- **Colorblind-safe palettes.** ~8% of male readers have some color vision deficiency. Tools like `colorbrewer` and matplotlib's `viridis`/`cividis` palettes are safer than default rainbow.
- **Distinguish on multiple dimensions.** Use color *and* line style (solid / dashed / dotted) so the figure is readable in grayscale.
- **Reserve red/green contrasts.** They're the most common confusion pair.

### 7. No spurious significant digits

In tables, report digits commensurate with sample size. "57.2%" on 100 examples is honest; "57.235%" implies precision you don't have. For variance, the convention is one significant digit on the variance and round the mean to match (e.g., 57.2 ± 1.3).

### 8. Booktabs style for tables

In LaTeX, use `\toprule`, `\midrule`, `\bottomrule` (from the `booktabs` package), not vertical rules. Vertical rules in tables are visually noisy; horizontal rules grouping related cells are enough.

```latex
\begin{tabular}{lccc}
\toprule
Method & Accuracy & F1 & Latency (ms) \\
\midrule
Baseline & 67.2 ± 1.1 & 64.5 ± 1.4 & 12 \\
\textbf{Ours} & \textbf{72.8 ± 0.9} & \textbf{70.3 ± 1.0} & 14 \\
\bottomrule
\end{tabular}
```

### 9. Bold the winner — but only honestly

Bold the best result in each column (or each row, depending on layout) — but only when it's statistically separated from the next-best. If two results tie within noise, bold both or neither. Bolding a result that ties a baseline as if it were a clean win is a small dishonesty that some reviewers will catch and many will resent.

### 10. One point per figure

A figure that tries to make 3 points usually makes 0. If you have 3 points, consider 3 figures (or 3 panels in a multi-panel figure with each panel scoped to one point).

Multi-panel figures are useful when the panels share an axis or are meaningfully comparable; sub-figure a, b, c each making a related point.

## Specific figure types

### System diagrams (architecture / pipeline figures)

Used for explaining a method's structure. Common in ML papers. Principles:

- **Arrows show data flow.** Make arrowheads visible; label the data on each arrow if non-obvious.
- **Boxes are components.** Label them with what they *do*, not generic names ("Encoder" not "Module 1").
- **Conventions stay consistent.** If purple = trainable, blue = frozen, in panel A, keep the same convention in panel B.
- **Don't over-decorate.** A clean black-and-white system diagram with thoughtful spacing reads better than a candy-colored one.

### Learning curves

Plotting metric (y) vs. training step or epoch (x). Principles:

- **Y-axis range chosen for the data.** Don't waste plot area on whitespace; don't compress the relevant range.
- **Multiple seeds shown.** Either as overlaid runs (faint individual lines + bold mean) or shaded confidence band (mean ± 1 stddev as a translucent fill).
- **Annotate key events.** "Loss spike at step 50k due to LR warmup ending" — annotate so the reader doesn't wonder.
- **Log scale for x-axis** when training spans orders of magnitude.

### Pareto frontier plots

Quality (y) vs. cost (x), with curves for each method. Critical for efficiency claims. Principles:

- **Include multiple operating points per method.** A frontier needs more than one point per curve.
- **Lower-cost is left.** This is convention — readers expect "to the upper-left is better".
- **Mark the operating points where each method is run** (small dots / markers on the curve).
- **Annotate any specific operating point you cite in text** ("our chosen config: K=8, marked with star").

### Scatter / agreement plots

Showing one quantity vs. another. Principles:

- **Include a reference line** (y=x for agreement; expected slope for trend).
- **Use transparency** when many points overlap.
- **Highlight outliers or interesting cases** with annotation.
- **Quote the correlation / R² in the caption** if relevant.

### Heatmaps (confusion matrices, attention patterns, etc.)

Principles:

- **Sequential colormap for unsigned data** (e.g., `viridis`).
- **Diverging colormap for signed data** (e.g., `RdBu` centered at 0).
- **Annotate cells with values** if the matrix is small enough (≤15×15).
- **Include the colorbar** with units labeled.
- **Sort rows / columns meaningfully** (e.g., confusion matrix rows in class-frequency order, or grouped by class hierarchy).

### Bar charts

Use sparingly — they often waste space relative to tables for the same information. When you do use them:

- **Order bars by value** (descending) unless there's a natural order (e.g., chronological).
- **Annotate exact values** above each bar — readers will want them.
- **Include error bars** when the underlying data has variance.
- **Avoid 3D effects.** They distort perception of magnitudes.

## Specific table types

### Main results table

The headline table of the experiments section. Should include:
- Methods (baselines + ours), one per row.
- Datasets / metrics / settings, one per column.
- Cells: mean ± stddev or mean ± CI.
- Best per column bolded (when statistically separated).
- Caption that names the takeaway.

Don't crowd it. If the table needs 12 columns, consider splitting into two tables (e.g., main benchmarks; transfer benchmarks).

### Ablation table

One row per configuration:
- "Full method" at the top or bottom.
- Each ablation as one row, with what was removed/changed.
- Last column: metric, with delta from full method.

The reader wants to see "removing C costs 3 points; removing D costs 0.2". Make the deltas easy to read.

### Sensitivity table

Showing variation across a hyperparameter:
- Rows: hyperparameter values.
- Columns: metric(s).
- Highlight the chosen value.

Often more efficiently shown as a small line plot (sensitivity curve) than a table — pick whichever is denser per square inch.

### Per-task / per-category breakdown

When reporting on a benchmark suite (e.g., MMLU's 57 subjects), the per-task breakdown often goes in the appendix as a long table. The main paper carries an aggregate; the appendix carries the breakdown.

## Concept figures (page-1 figures)

Many top-venue ML papers include a concept figure on page 1 that conveys the paper's idea or main result visually. These are high-leverage: reviewers see them immediately. Principles:

- **Communicates the contribution** (not just the problem). The reader should learn something about your method from the figure.
- **Self-explanatory in 5 seconds.** No mental gymnastics.
- **Direct labels, real names.** No placeholders.
- **Clean.** Not over-designed, not over-colored.

If you can't make a great concept figure, a great results figure (e.g., the Pareto frontier showing your method dominates) often serves the same purpose. A bad concept figure on page 1 hurts more than no figure — it confuses or misleads.

## Anti-patterns

- **The default-matplotlib-styling figure.** Tiny font, default colors, no direct labels. Fix these defaults; don't ship them.
- **The unreadable shrunken figure.** Looks fine in your editor; illegible at column-width. Always check at print size.
- **The legend that lives in a corner with 8 entries.** Direct-label.
- **The over-decorated table.** Vertical rules, alternating row colors, multiple font weights. Strip to booktabs.
- **The table with 4 numbers.** Should have been a sentence.
- **The figure with no caption point.** "Figure 4: Results." Tell the reader what to take away.
- **The cherry-picked example.** A qualitative figure showing your method's success — but the reader can't tell if it's representative. Pair with quantitative aggregates.
- **The chart-junk concept figure.** Three colors, four shapes, two text fonts, gradients, drop shadows. Less is more.

## Iteration discipline

Figures deserve real iteration. Workflow:

1. Draft the figure with whatever's at hand (matplotlib defaults, rough labels).
2. Identify the single point you want it to make.
3. Strip everything that doesn't serve that point.
4. Add what's missing for that point (annotation, reference line, labels).
5. Test at print size.
6. Have someone unfamiliar with the work look at it and tell you what they see.

Spending an hour on a figure that the reviewer reads for 30 seconds and immediately understands is a great trade.

## Code organization

Practical tip: keep figure-generating code under version control alongside the paper. When data updates, re-running one script regenerates all figures. Hand-tweaked figures in a vector editor become a liability when you need to update them for a rebuttal. Save vector exports + the source script.

## Cross-references

- For the headline result table, see `references/section-experiments.md` — the table is part of that section's structure.
- For the page-1 concept figure, see `references/section-intro.md` — the concept figure typically anchors the introduction.
- For figure-style choices in algorithms (pseudocode rather than figures), see `references/section-method.md`.

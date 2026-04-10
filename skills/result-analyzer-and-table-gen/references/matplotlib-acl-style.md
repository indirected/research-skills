# Matplotlib Style Settings for ACL Figures

This reference provides the exact matplotlib configuration needed to produce figures that meet
ACL formatting requirements and look professional in a two-column paper.

---

## Page Geometry

ACL uses A4 paper with these column widths:
- **Single column**: 7.7 cm = 3.031 in
- **Double column** (`figure*`): 16.0 cm = 6.299 in (both columns + gap)
- **Column gap**: 0.6 cm

For figures, use slightly less than the full column width to leave some padding:
- Single: `figsize=(3.0, 2.2)` — good default aspect ratio
- Double: `figsize=(6.2, 2.5)` — wide and short, good for comparisons

---

## Complete rcParams Configuration

Copy this block at the top of any figure-generation script:

```python
import matplotlib
import matplotlib.pyplot as plt
import numpy as np

# Use PDF backend for publication-quality output
matplotlib.use('pdf')

# ACL-compliant style settings
plt.rcParams.update({
    # Font — match ACL's Times Roman body text
    'font.family': 'serif',
    'font.serif': ['Times New Roman', 'Times', 'DejaVu Serif'],
    'font.size': 9,           # matches ACL footnote/caption size
    'axes.titlesize': 9,
    'axes.labelsize': 9,
    'xtick.labelsize': 8,
    'ytick.labelsize': 8,
    'legend.fontsize': 8,
    
    # Lines and markers
    'lines.linewidth': 1.5,
    'lines.markersize': 5,
    
    # Axes
    'axes.linewidth': 0.8,
    'axes.spines.top': False,    # remove top spine for cleaner look
    'axes.spines.right': False,  # remove right spine
    
    # Grid — subtle for readability
    'axes.grid': True,
    'grid.linewidth': 0.4,
    'grid.alpha': 0.5,
    'grid.linestyle': '--',
    
    # PDF embedding — REQUIRED for ACL submission
    # Ensures fonts are embedded in the PDF (not just referenced)
    'pdf.fonttype': 42,          # Type 42 = TrueType — fully embedded
    'ps.fonttype': 42,
    
    # Figure padding
    'figure.constrained_layout.use': True,
    'savefig.bbox': 'tight',
    'savefig.dpi': 300,          # for raster elements within vector PDF
    'savefig.pad_inches': 0.02,
})
```

---

## Color Palette: Wong (2011) Color-Blind Safe

This 8-color palette is distinguishable under all forms of color blindness and in grayscale.
ACL strongly encourages grayscale readability.

```python
WONG_PALETTE = {
    'black':        '#000000',
    'orange':       '#E69F00',
    'sky_blue':     '#56B4E9',
    'green':        '#009E73',
    'yellow':       '#F0E442',
    'blue':         '#0072B2',
    'vermillion':   '#D55E00',
    'pink':         '#CC79A7',
}

# Recommended order for sequential use:
WONG_COLORS = [
    '#0072B2',   # blue        — use for primary/first model
    '#D55E00',   # vermillion  — use for second model
    '#009E73',   # green       — use for third model
    '#E69F00',   # orange      — use for fourth model
    '#56B4E9',   # sky blue    — use for fifth
    '#CC79A7',   # pink        — use for sixth
    '#F0E442',   # yellow      — use last (low contrast on white)
    '#000000',   # black       — use for baseline/reference
]
```

---

## Hatching Patterns (for grayscale-safe figures)

When multiple bars/lines overlap in grayscale, add hatch patterns:

```python
HATCHES = ['', '//', '\\\\', 'xx', '..', '++', 'oo', '--']
# Use '' for the first series (solid fill), then alternate
```

Example with both color and hatch:
```python
for i, (model, color, hatch) in enumerate(zip(models, WONG_COLORS, HATCHES)):
    ax.bar(x + i * bar_width, values[model], 
           color=color, hatch=hatch, edgecolor='white', linewidth=0.5)
```

---

## Standard Figure Templates

### Bar Chart — Model Comparison

```python
def make_model_comparison_bar(stats_dict, output_path):
    """
    stats_dict: {model_name: {metric: value}} 
    e.g., {'GPT-4o': {'T1': 66.7, 'Correct': 46.7}, ...}
    """
    models = list(stats_dict.keys())
    metrics = ['QA Pass', 'Tier 1', 'Correct']
    metric_keys = ['qa_rate', 'tier1_rate', 'correct_rate']
    
    n_metrics = len(metrics)
    n_models = len(models)
    bar_width = 0.8 / n_models
    x = np.arange(n_metrics)
    
    fig, ax = plt.subplots(figsize=(3.0, 2.2))
    
    for i, (model, color, hatch) in enumerate(zip(models, WONG_COLORS, HATCHES)):
        values = [stats_dict[model].get(k, 0) for k in metric_keys]
        offset = (i - n_models/2 + 0.5) * bar_width
        bars = ax.bar(x + offset, values, bar_width * 0.9,
                      label=model, color=color, hatch=hatch, 
                      edgecolor='white', linewidth=0.5)
    
    ax.set_xticks(x)
    ax.set_xticklabels(metrics)
    ax.set_ylabel('Success Rate (%)')
    ax.set_ylim(0, 100)
    ax.legend(loc='upper right', framealpha=0.7)
    
    fig.savefig(output_path)
    plt.close(fig)
    print(f"Saved: {output_path}")
```

### Status Distribution Bar Chart

Shows where cases fail in the `PatchGenerationStatus` pipeline:

```python
STATUS_LABELS = {
    'PatchGenerationStatus.PATCH_PASSES_CHECKS': 'Correct',
    'PatchGenerationStatus.PATCH_FIXES_CRASH': 'Fixes Crash',
    'PatchGenerationStatus.PATCH_BUILD_SUCCESSFUL': 'Builds',
    'PatchGenerationStatus.PATCH_FORMAT_CORRECT': 'Format OK',
    'PatchGenerationStatus.FETCH_SOURCE_SUCCESSFUL': 'Source Fetched',
    'PatchGenerationStatus.FAILED': 'Failed',
    'PatchGenerationStatus.NOT_SUPPORTED': 'Not Supported',
    'PatchGenerationStatus.INIT_STATUS': 'Init',
}

def make_status_distribution(reports, output_path):
    from collections import Counter
    
    status_counts = Counter(r['max_patch_generation_status'] for r in reports)
    
    labels = [STATUS_LABELS.get(k, k) for k in status_counts.keys()]
    sizes = list(status_counts.values())
    colors = WONG_COLORS[:len(sizes)]
    
    fig, ax = plt.subplots(figsize=(3.0, 2.2))
    ax.barh(labels, sizes, color=colors)
    ax.set_xlabel('Number of Cases')
    ax.set_title('Failure Mode Distribution')
    
    fig.savefig(output_path)
    plt.close(fig)
```

### Iteration Distribution Histogram

```python
def make_iteration_histogram(reports, output_path):
    build_iters = [r['build_iters'] for r in reports if 'build_iters' in r]
    fix_iters = [r['fix_crash_iters'] for r in reports if 'fix_crash_iters' in r]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(6.2, 2.0))
    
    ax1.hist(build_iters, bins=range(max(build_iters)+2), 
             color=WONG_COLORS[0], edgecolor='white', linewidth=0.5)
    ax1.set_xlabel('Build Iterations')
    ax1.set_ylabel('Cases')
    
    ax2.hist(fix_iters, bins=range(max(fix_iters)+2),
             color=WONG_COLORS[1], edgecolor='white', linewidth=0.5)
    ax2.set_xlabel('Fix-Crash Iterations')
    
    fig.savefig(output_path)
    plt.close(fig)
```

---

## Saving Figures

Always save as PDF for vector output:

```python
fig.savefig('paper/figures/results_bar.pdf')
# savefig.bbox='tight' and savefig.pad_inches=0.02 handle the rest via rcParams
```

If you also need PNG for quick previews:
```python
fig.savefig('paper/figures/results_bar.png', dpi=150)
```

---

## Including Figures in LaTeX

Single-column figure:
```latex
\begin{figure}[t]
\centering
\includegraphics[width=\columnwidth]{figures/results_bar}
\caption{Model comparison on key metrics. 
Results are percentages of QA-passed cases (N=12--13 per model).}
\label{fig:results-bar}
\end{figure}
```

Double-column figure:
```latex
\begin{figure*}[t]
\centering
\includegraphics[width=\textwidth]{figures/results_comparison}
\caption{Detailed per-tier results across all models.}
\label{fig:results-comparison}
\end{figure*}
```

Note: LaTeX automatically resolves `figures/results_bar` to `figures/results_bar.pdf`
(no extension needed when using pdflatex/lualatex).

---

## Common Issues

| Problem | Fix |
|---|---|
| Fonts not embedded in PDF | Make sure `pdf.fonttype = 42` in rcParams |
| Figure too large / margins cut off | Use `savefig.bbox='tight'` + `pad_inches=0.02` |
| Bars too thin / axes labels overlap | Increase `figsize` slightly or reduce number of groups |
| Legend overlaps data | Use `bbox_to_anchor=(1, 1)` to place legend outside, then adjust `figsize` width |
| Grayscale looks bad | Add `hatch` patterns to bars, increase line contrast |

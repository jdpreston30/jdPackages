---
applyTo: "**/*.R"
---

# Figure Style Instructions

These instructions define the personal ggplot2 house style for this repository.
All visualization code should conform to these conventions.

---

## 1. Themes

### Primary themes (use one of these as the base)

**`theme_slam()`** — framed scientific style, no grid lines:
```r
theme_classic(base_size = 9) +
  theme(
    panel.border          = element_rect(colour = "black", fill = NA, linewidth = 1.27),
    panel.grid            = element_blank(),
    axis.title            = element_text(face = "bold"),
    strip.background      = element_blank(),
    strip.text            = element_text(face = "bold")
  )
```

**`theme_slam_open()`** — same but no panel border; only bottom + left axis lines.

**`theme_pub_*()`** family — ggprism-based, Arial font, `base_size = 12`:
- `theme_pub_dotbar()` — legend top horizontal; use for dot+bar plots and BCVI plots
- `theme_pub_barplot()` — for standard bar plots
- `theme_pub_pca()` — `aspect.ratio = 1`; major grid lines on both axes (`"gray80"`); border `linewidth = 1.6`; legend top horizontal
- `theme_pub_scatter()` — for scatter plots

**Fallback inline style** (minimal projects):
```r
theme_minimal(base_family = "Arial") +
  theme(
    panel.border     = element_blank(),
    axis.line        = element_line(colour = "black"),
    axis.title       = element_text(face = "bold"),
    strip.background = element_blank()
  )
```

---

## 2. Typography

- **Font family:** Arial (`base_family = "Arial"`)
- **Base size:** 9 pt for manuscript figures; 12 pt for standalone/presentation figures
- **Axis titles:** `face = "bold"` always
- **Strip text:** `face = "bold"`, `size = 7` for facet panels
- **Panel tags (A, B, C):** `face = "bold"`, `size = 9`, uppercase A/B/C
- **ggrepel labels:** `size = 2.5`

---

## 3. Color Palettes

### Sex × strain (slam_colours)
```r
c(
  "Male_WT"    = "#4B0082",   # deep purple
  "Female_WT"  = "#9B59B6",   # medium purple
  "Male_KO"    = "#D35400",   # deep orange
  "Female_KO"  = "#E59866"    # light orange
)
```

### Diverging (LMM effects, module–trait correlations, fold change)
```r
scale_fill_gradient2(
  low  = "#2166ac",   # blue
  mid  = "white",
  high = "#b2182b",   # red
  midpoint = 0,
  limits = c(-1, 1)
)
```

### Volcano / fold change directionality
```r
c(up = "#800017", down = "#113d6a", NS = "gray70")
# or: crimson = "#800017", navy = "#113d6a"
```

### PGD / paired comparisons
```r
c(pre = "#113d6a", post = "#800017")   # navy / crimson
```

### Continuous/age/time
- Use RdBu (ColorBrewer) or viridis depending on whether the scale is diverging or sequential.

### WGCNA modules
- Use the module hex colors directly from `WGCNA::labels2colors()` output.

---

## 4. Point and Line Geometry

### Scatter / individual data points
```r
geom_point(shape = 16, size = 2, alpha = 0.75)
```

### Jitter (overlaid on bar or violin)
```r
geom_jitter(width = 0.15, size = 0.6, alpha = 1, shape = 16)
```

### Distribution plots: violin + jitter + boxplot (in that order)
```r
geom_violin(trim = FALSE, alpha = 0.25) +
geom_jitter(width = 0.15, size = 0.6, alpha = 1, shape = 16) +
geom_boxplot(width = 0.15, outlier.shape = NA, alpha = 0.5)
```

### Smooth / trend lines
```r
geom_smooth(method = "loess", linewidth = 0.8, fill = colour, alpha = 0.15)
# Quadratic for archetype models:
geom_smooth(method = "lm", formula = y ~ poly(x, 2), ...)
```

### Spaghetti / per-subject lines
```r
geom_line(aes(group = subject_id), alpha = 0.25, linewidth = 0.3, colour = "grey50")
```

### Heatmap tiles
```r
geom_tile(colour = "white", linewidth = 0.08)
```

### Bar charts
```r
geom_col(width = 0.7, linewidth = 0.3)
# For targeted metabolites: light fill + dark outline via separate fill/colour scales
```

---

## 5. Axis Formatting

- Use `scale_x_continuous(expand = expansion(mult = c(0.05, 0.05)))` for most continuous axes.
- Use `expansion(mult = c(0, 0.08))` for bar chart y-axes (zero at origin, headroom above).
- Use `expansion(mult = c(0.08, 0.08))` for PCA/ordination axes.
- Heatmap x-axis: `angle = 45, hjust = 1, vjust = 1, size = 8`.
- Use `ggprism::guide_prism_offset()` for tick guides in ggprism themes.
- Avoid unnecessary axis expansion on categorical axes; set `expand = c(0, 0)` for bar charts.

---

## 6. Statistical Annotations

- **Do NOT use `ggpubr` for significance brackets.** Add significance manually.
- Reference lines:
  ```r
  geom_hline(yintercept = -log10(0.05), linetype = "dotted", colour = "grey50")
  geom_vline(xintercept = 0, linetype = "solid",  colour = "grey50")
  ```
- `ggrepel` for point labels: `geom_label_repel()` or `geom_text_repel()` with `size = 2.5`.
- Significance stars in heatmap cells via `annotate("text", label = "***")`.
- p-value formatting: use a `format_p_journal()` helper (e.g., `< 0.001`, `= 0.042`).

---

## 7. Faceting

```r
# Free y-axis for multi-module trajectory panels
facet_wrap(~ facet_label, scales = "free_y", ncol = n)

# Fixed scales for density / distribution comparisons
facet_grid(group ~ condition)
```
- `panel.spacing = unit(0.4, "cm")` in the theme.
- Strip background blank; strip text bold.

---

## 8. Legends

| Plot type                     | `legend.position`         | Notes                                           |
|-------------------------------|---------------------------|-------------------------------------------------|
| Volcano / KM survival         | `c(0.98, 0.98)` (inside)  | White background; top-right                     |
| Scatter / aging rate          | `"none"`                  | No legend                                       |
| Heatmap                       | `"bottom"` horizontal     | Colorbar `barwidth=1.5in, barheight=0.12in`      |
| Dot-bar / BCVI                | `"top"` horizontal        |                                                  |
| PCA / ordination              | `"top"` horizontal        | `guide_legend(override.aes = list(shape=15, size=4, linetype=0))` |

All legends horizontal when at top/bottom: `legend.direction = "horizontal"`.

---

## 9. Figure Assembly (patchwork + cowplot)

### patchwork
```r
library(patchwork)

fig <- (p1 | p2) / p3 +
  plot_layout(widths = c(1, 1), heights = c(2, 1)) +
  plot_annotation(
    tag_levels = "A",
    theme = theme(plot.tag = element_text(face = "bold", size = 9))
  )
fig & theme(plot.tag = element_text(face = "bold", size = 9))
```
- Tags: **uppercase A, B, C...**, size 9 pt, bold.
- Use `wrap_elements(full = p)` to treat a sub-patchwork as atomic for tagging.

### cowplot canvas (letter page)
```r
library(cowplot)

canvas <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11))
canvas +
  draw_plot(fig, x = 0, y = 0, width = 8.5, height = 11) +
  draw_label("Figure 1", x = 4.25, y = 10.7, size = 12,
             fontface = "bold", fontfamily = "Arial", hjust = 0.5)
```
- Float legends with `draw_grob(legend, x=..., y=..., width=..., height=..., hjust=0.5, vjust=0.5)`.
- Panel label coordinates: top-left `(0.08, 9.7)`, top-right `(4.3, 9.7)`.

### Square tight panels
```r
p + theme(
  aspect.ratio = 1,
  plot.margin  = margin(2, 2, 2, 2, "pt"),
  axis.title.y = element_text(margin = margin(r = 3)),
  axis.title.x = element_text(margin = margin(t = 3)),
  axis.text.y  = element_text(margin = margin(r = 1)),
  axis.text.x  = element_text(margin = margin(t = 1))
)
```

---

## 10. Saving Figures

```r
# Vector PDF (always prefer for manuscripts)
cairo_pdf(file.path(output_dir, "figure.pdf"), width = 8.5, height = 11, bg = "white")
print(fig)
dev.off()

# Raster PNG (supplemental / web)
ggsave(file.path(output_dir, "figure.png"), plot = fig,
       width = 8.5, height = 11, units = "in", dpi = 300, bg = "white")

# High-res TIFF (journal submission)
ggsave(file.path(output_dir, "figure.tiff"), plot = fig,
       width = 8.5, height = 11, units = "in", dpi = 600,
       device = "tiff", bg = "white")
```
- **Page size:** 8.5 × 11 in (US Letter) always.
- **Background:** always `bg = "white"` (never transparent).
- **DPI:** 300 draft · 600 PNG/TIFF submission · 800 TIFF high-res.
- Always use `cairo_pdf()` for PDF (supports transparency and custom fonts).

---

## 11. Special Plot Type Recipes

### Volcano plot
```r
ggplot(res, aes(log2FC, -log10(p_val), colour = direction)) +
  geom_point(shape = 16, size = 1.4, alpha = 0.65) +
  geom_hline(yintercept = -log10(0.05), linetype = "dotted", colour = "grey50") +
  geom_vline(xintercept = 0,            linetype = "solid",  colour = "grey50") +
  ggrepel::geom_text_repel(data = top_hits, aes(label = gene), size = 2.5) +
  scale_colour_manual(values = c(up = "#800017", down = "#113d6a", NS = "gray70")) +
  theme_slam_open() +
  theme(legend.position = c(0.98, 0.98),
        legend.justification = c(1, 1),
        legend.background = element_rect(fill = "white", colour = NA))
```

### PCA / ordination
```r
ggplot(scores, aes(PC1, PC2, colour = group)) +
  stat_ellipse(level = 0.95, linewidth = 0.5) +
  geom_point(shape = 16, size = 2, alpha = 0.75) +
  guides(colour = guide_legend(override.aes = list(shape = 15, size = 4, linetype = 0))) +
  theme_pub_pca()   # includes aspect.ratio = 1
```

### Heatmap
```r
ggplot(mat_long, aes(x = variable, y = feature, fill = value)) +
  geom_tile(colour = "white", linewidth = 0.08) +
  scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#b2182b",
                       midpoint = 0, limits = c(-1, 1)) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  guides(fill = guide_colorbar(barwidth = unit(1.5, "in"), barheight = unit(0.12, "in"),
                               title.position = "top", title.hjust = 0.5)) +
  theme_slam() +
  theme(axis.text.x  = element_text(angle = 45, hjust = 1, vjust = 1, size = 8),
        axis.text.y  = element_text(size = 5),
        legend.position = "bottom")
```

### Network (ggraph)
```r
library(ggraph)
ggraph(g, layout = "fr") +
  geom_edge_link(aes(width = weight, alpha = weight),
                 colour = "grey60",
                 show.legend = FALSE) +
  scale_edge_width_continuous(range = c(0.15, 0.75)) +
  scale_edge_alpha_continuous(range = c(0.20, 0.60)) +
  geom_node_point(aes(fill = module, size = hub_score),
                  shape = 21, colour = "white", stroke = 0.2) +
  scale_size_continuous(range = c(1, 4)) +
  geom_node_text(aes(label = name), size = 1.6, repel = TRUE) +
  theme_graph(base_family = "")
```

### KM survival curve
```r
ggplot(km_data, aes(time, surv, colour = group)) +
  geom_step(linewidth = 0.65, alpha = 0.90) +
  geom_text(data = label_df, aes(label = label), size = 2.5, colour = "grey30") +
  scale_colour_manual(values = colour_map) +
  theme_slam_open() +
  theme(legend.position = c(0.98, 0.98),
        legend.justification = c(1, 1),
        legend.background = element_rect(fill = "white", colour = NA))
```

### Dot-bar (targeted metabolites / bar + jitter)
```r
ggplot(df, aes(x = group, y = value, fill = group, colour = group)) +
  geom_col(alpha = 0.4, linewidth = 0.5) +
  geom_jitter(width = 0.15, size = 0.6, alpha = 1, shape = 16) +
  scale_fill_manual(values  = palette) +
  scale_colour_manual(values = palette) +
  theme_pub_dotbar() +
  theme(legend.position = "none")
```

### Diverging bar (fold change)
```r
ggplot(df, aes(x = abs_fc, y = reorder(term, abs_fc), fill = direction)) +
  geom_col(width = 0.7, linewidth = 0.3) +
  scale_fill_manual(values = c(positive = "#800017", negative = "#113d6a")) +
  theme_slam() +
  theme(
    legend.position  = "top",
    legend.direction = "horizontal",
    legend.key.size  = unit(0.35, "cm"),
    panel.border     = element_rect(linewidth = 0.545)
  )
```

---

## 12. Package Conventions

- Always load `library(ggplot2)` first; avoid `::` for geom_/scale_/theme_ calls inside plot chains.
- Use `::` for one-off calls: `patchwork::wrap_elements()`, `ggrepel::geom_text_repel()`.
- Import `ragg` or set `options(device = ragg::agg_png)` for raster rendering (better font support than the default PNG device).
- Do not use `ggpubr` for significance brackets — annotate manually.
- Do not use `theme_bw()` or `theme_gray()` as a base — use only `theme_classic()` or `theme_minimal()` then override.

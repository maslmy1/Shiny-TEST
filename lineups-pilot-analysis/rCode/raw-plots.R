# --------------------------------------------------------------------------
# Collect newest pilot data ------------------------------------------------
# --------------------------------------------------------------------------

source("lineups-pilot-analysis/rCode/data-management.R")
names(lineup_results_data)

# --------------------------------------------------------------------------
# Create Labeler -----------------------------------------------------------
# --------------------------------------------------------------------------

target_curvature.labs <- c("Target: Lots of Curvature", "Target: Medium Curvature", "Target: Little Curvature")
names(target_curvature.labs) <- c("E", "M", "H")

null_curvature.labs <- c("Null: Lots of Curvature", "Null: Medium Curvature", "Null: Little Curvature")
names(null_curvature.labs) <- c("E", "M", "H")

global_labeller <- labeller(
  target_curvature = target_curvature.labs,
  null_curvature = null_curvature.labs)

# --------------------------------------------------------------------------
# Plot Simulated Data ------------------------------------------------------
# --------------------------------------------------------------------------

# p_curvature <- lineup_results_data %>%
  
p_curvature <- lineup_results_data %>%
  ggplot(aes(x = test_param, y = correct, group = test_param, color = test_param)) +
  # geom_jitter(width = 0.15, height = 0.15, alpha = 0.9) +
  geom_point(position = position_jitterdodge(jitter.width = 0.3, jitter.height = 0.1, dodge.width = 1), alpha = 0.5) +
  theme_bw() +
  facet_grid(
    null_curvature~target_curvature,
    labeller = global_labeller
  ) +
  theme(aspect.ratio = 1) +
  scale_y_continuous("Target panel detected", breaks = c(0,1)) +
  scale_x_discrete("Target panel curvature embeded in null panel curvature") +
  scale_color_brewer(name = "Scale", labels = c("Linear", "Log"), palette = "Paired")
p_curvature


# BELOW HERE HAS BOTH VARIABILITIES
# # --------------------------------------------------------------------------
# # Create Labeler -----------------------------------------------------------
# # --------------------------------------------------------------------------
# 
# target_curvature.labs <- c("Target: Lots of Curvature", "Target: Medium Curvature", "Target: Little Curvature")
# names(target_curvature.labs) <- c("E", "M", "H")
# 
# null_curvature.labs <- c("Null: Lots of Curvature", "Null: Medium Curvature", "Null: Little Curvature")
# names(null_curvature.labs) <- c("E", "M", "H")
# 
# target_variability.labs <- c("Target: Low Variability", "Target: High Variability")
# names(target_variability.labs) <- c("Lv", "Hv")
# 
# null_variability.labs <- c("Null: Low Variability", "Null: High Variability")
# names(null_variability.labs) <- c("Lv", "Hv")
# 
# global_labeller <- labeller(
#                             target_curvature = target_curvature.labs,
#                             null_curvature = null_curvature.labs,
#                             target_variability = target_variability.labs,
#                             null_variability = null_variability.labs)
# 
# 
# # --------------------------------------------------------------------------
# # Across Curvature Raw Plots -----------------------------------------------
# # --------------------------------------------------------------------------
# 
# p_curvature <- lineup_results_data %>%
#   filter(null_variability == target_variability, rorschach == "0") %>%
#   ggplot(aes(x = test_param, y = correct, group = target_variability, color = target_variability)) +
#   # geom_jitter(width = 0.15, height = 0.15, alpha = 0.9) +
#   geom_point(position = position_jitterdodge(jitter.width = 0.3, jitter.height = 0.1, dodge.width = 1), alpha = 0.9) +
#   facet_grid(
#     null_curvature~ target_curvature,
#     labeller = global_labeller
#   ) +
#   theme_bw() +
#   theme(aspect.ratio = 1) +
#   scale_y_continuous("Target Panel Detected", breaks = c(0,1)) +
#   scale_x_discrete("Scale") +
#   scale_color_brewer(name = "Variability", labels = c("Low", "High"), palette = "Paired")
# p_curvature
# # ggsave(plot = p_curvature, filename = "p_curvature_raw.svg", path = "presentations/eskridge-PhD-seminars/oct_8_2020/images", device = "svg", width = 9, height = 9)
# 
# # --------------------------------------------------------------------------
# # Variability Effect Plots -------------------------------------------------
# # --------------------------------------------------------------------------
# 
# p_variability <- lineup_results_data %>%
#   filter(null_variability != target_variability, rorschach == "0") %>%
#   ggplot(aes(x = test_param, y = correct, color = target_curvature, group = target_curvature )) +
#   geom_point(position = position_jitterdodge(jitter.width = 0.3, jitter.height = 0.1, dodge.width = 1), alpha = 0.9) +
#   facet_grid(
#     null_variability~target_variability,
#     labeller = global_labeller
#   ) +
#   theme_bw() +
#   theme(aspect.ratio = 1) +
#   scale_y_continuous("Target Panel Detected", breaks = c(0,1)) +
#   scale_x_discrete("Scale") +
#   scale_color_brewer(name = "Curvature", labels = c("Little Curvature", "Medium Curvature", "Lots of Curvature"), palette = "Paired")
# p_variability
# # ggsave(plot = p_variability, filename = "p_variability_raw.svg", path = "presentations/eskridge-PhD-seminars/oct_8_2020/images", device = "svg", width = 9, height = 9)
# 
# # --------------------------------------------------------------------------
# # Rorschach raw results plots ----------------------------------------------
# # --------------------------------------------------------------------------
# 
# target_curvature.labs <- c("Lots of Curvature", "Medium Curvature", "Little Curvature")
# names(target_curvature.labs) <- c("E", "M", "H")
# 
# target_variability.labs <- c("Low Variability", "High Variability")
# names(target_variability.labs) <- c("Lv", "Hv")
# 
# rorschach_labeller <- labeller(
#   target_curvature = target_curvature.labs,
#   target_variability = target_variability.labs)
# 
# # --------------------------------------------------------------------------
# 
# p_rorschach <- lineup_results_data %>%
#   filter(rorschach == "1") %>%
#   ggplot(aes(x = test_param, y = correct, color = test_param)) +
#   geom_jitter(width = 0.15, height = 0.15, alpha = 0.9) +
#   facet_grid(
#     target_variability ~ target_curvature,
#     labeller = rorschach_labeller
#   )+
#   theme_bw() +
#   theme(aspect.ratio = 1) +
#   scale_y_continuous("Target Panel Detected", breaks = c(0,1)) +
#   scale_x_discrete("Scale") +
#   scale_color_brewer(name = "Scale", labels = c("Linear", "Log"), palette = "Paired")
# p_rorschach
# # ggsave(plot = p_rorschach, filename = "p_rorschach_raw.svg", path = "presentations/eskridge-PhD-seminars/oct_8_2020/images", device = "svg", width = 9, height = 6)
# 
# # --------------------------------------------------------------------------
# # --------------------------------------------------------------------------
# # --------------------------------------------------------------------------
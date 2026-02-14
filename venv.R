#!/usr/bin/env Rscript

# ── CLI Argument Parsing ──
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0 || !(args[1] %in% c("load", "dump"))) {
  stop("Usage: Rscript venv.R <load|dump> [--path PATH] [--req PATH] [--cran URL]")
}
mode <- args[1]

# ── Defaults ──
venv_path   <- ".venv"
req_path    <- "requirements.csv"
cran_mirror <- "https://cloud.r-project.org"

# ── Parse named arguments ──
named_args <- args[-1]
i <- 1
while (i <= length(named_args)) {
  key <- named_args[i]
  if (i + 1 > length(named_args)) stop(paste("Missing value for", key))
  val <- named_args[i + 1]
  switch(key,
    "--path"   = { venv_path   <- val },
    "--req"    = { req_path    <- val },
    "--cran" = { cran_mirror <- val },
    stop(paste("Unknown argument:", key))
  )
  i <- i + 2
}

# ── Dump mode: export installed packages ──
if (mode == "dump") {
  pkgs   <- installed.packages(lib.loc = venv_path)
  pkgs_1 <- pkgs[, c("Package", "Version", "Depends", "Imports", "Built")]
  write.csv(pkgs_1, req_path, row.names = FALSE)
  message("Dumped package list to ", req_path)
  q(status = 0)
}

# ── Load mode: install from requirements ──
pkgs      <- read.csv(req_path, stringsAsFactors = FALSE)
pkg_names <- pkgs$Package
pkg_names_new <- pkg_names[!(
  pkg_names %in% installed.packages(lib.loc = venv_path)[, "Package"]
)]

if (length(pkg_names_new) == 0) {
  message("All packages already installed.")
  q(status = 0)
}

if (!dir.exists(venv_path)) {
  dir.create(venv_path, recursive = TRUE)
}

# ── Find leaf packages (not a dependency of any other package) ──
all_deps <- character(0)
for (i in seq_len(nrow(pkgs))) {
  if (!(pkgs$Package[i] %in% pkg_names_new)) next
  raw  <- paste(na.omit(c(pkgs$Depends[i], pkgs$Imports[i])), collapse = ", ")
  deps <- trimws(unlist(strsplit(raw, ",")))
  deps <- sub("\\s*\\(.*\\)", "", deps)
  deps <- deps[deps != "" & deps != "R"]
  all_deps <- c(all_deps, deps)
}
all_deps <- unique(all_deps)
leaves   <- pkg_names_new[!(pkg_names_new %in% all_deps)]

message("Installing leaves (CRAN resolves the rest):\n", paste(leaves, collapse = ", "))

install.packages(
  leaves,
  lib          = venv_path,
  repos        = cran_mirror,
  dependencies = TRUE
)

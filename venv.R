#!/usr/bin/env Rscript

# ── CLI Argument Parsing ──
args <- commandArgs(trailingOnly = TRUE)

valid_cmds <- c("load", "dump", "install", "uninstall")

if (length(args) == 0 || !(args[1] %in% valid_cmds)) {
  stop("Usage: Rscript venv.R <load|dump|install|uninstall> [--path PATH] [--req PATH] [--cran URL] [packages...]")
}
mode <- args[1]

# ── Defaults ──
venv_path   <- ".venv"
req_path    <- "requirements.csv"
cran_mirror <- "https://cloud.r-project.org"

# ── Separate named options from positional package names ──
rest <- args[-1]
pkg_args   <- character(0)
named_args <- character(0)

i <- 1
while (i <= length(rest)) {
  if (grepl("^--", rest[i])) {
    # named arg: consume key + value
    if (i + 1 > length(rest)) stop(paste("Missing value for", rest[i]))
    named_args <- c(named_args, rest[i], rest[i + 1])
    i <- i + 2
  } else {
    # positional arg (package name)
    pkg_args <- c(pkg_args, rest[i])
    i <- i + 1
  }
}

# ── Parse named arguments ──
i <- 1
while (i <= length(named_args)) {
  key <- named_args[i]
  val <- named_args[i + 1]
  switch(key,
    "--path" = { venv_path   <- val },
    "--req"  = { req_path    <- val },
    "--cran" = { cran_mirror <- val },
    stop(paste("Unknown argument:", key))
  )
  i <- i + 2
}

# ── install mode ──
if (mode == "install") {
  if (length(pkg_args) == 0) stop("Provide one or more package names to install.")
  if (!dir.exists(venv_path)) dir.create(venv_path, recursive = TRUE)

  message("Installing: ", paste(pkg_args, collapse = ", "))
  install.packages(
    pkg_args,
    lib          = venv_path,
    repos        = cran_mirror,
    dependencies = TRUE
  )
  q(status = 0)
}

# ── uninstall mode ──
if (mode == "uninstall") {
  if (length(pkg_args) == 0) stop("Provide one or more package names to uninstall.")

  installed <- installed.packages(lib.loc = venv_path)[, "Package"]
  to_remove <- pkg_args[pkg_args %in% installed]
  not_found <- pkg_args[!(pkg_args %in% installed)]

  if (length(not_found) > 0) {
    message("Not installed (skipped): ", paste(not_found, collapse = ", "))
  }
  if (length(to_remove) > 0) {
    message("Removing: ", paste(to_remove, collapse = ", "))
    remove.packages(to_remove, lib = venv_path)
  } else {
    message("Nothing to remove.")
  }
  q(status = 0)
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

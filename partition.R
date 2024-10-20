if (!require("optparse")) {install.packages("optparse", repos = "http://cran.us.r-project.org")}
library(optparse)

option_list = list(
  make_option(c("-p", "--pathtofile"), type = "character", default = NULL, 
              help = "absolute path to the dataset in Nexus format", metavar = "character"),
  make_option(c("-o", "--orderedchars"), type = "character", default = NULL, 
              help = "indices of characters to be treated as ordered", metavar = "character")
)

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

# This function is more general than we need, since our Nexus files do not actually contain any
# polymorphisms (denoted by parentheses) or partial ambiguities (denoted by braces).

separate.char.strings <- function(string) {
  # Split by character *except* when in parentheses *or* braces:
  first_split <- strsplit(string, '\\([^)]*\\)(*SKIP)(*F)|{[^}]*}(*SKIP)(*F)|', perl = T)
  # The previous step failed to split adjacent matches such as "(0 1)(0 1)"; we need to fix this:
  second_split <- strsplit(first_split[[1]], "\\)\\(")
  # We want to keep both braces after splitting, so we use a slightly different solution. Credit:
  # Arun, https://stackoverflow.com/a/17623231
  third_split <- strsplit(unlist(second_split), '(?<=.)(?={)', perl = T)
  # Flatten the list to a vector and return:
  return(unlist(third_split))
}

hyphen.splicer <- function(vect) {
  no_hyphens <- vect[!grepl("-", vect)]
  contains_hyphens <- vect[grepl("-", vect)]
  splist <- Map(as.numeric, strsplit(contains_hyphens, "-"))
  unfold <- unlist(Map(function(x) x[1]:x[2], splist))
  out <- sort(as.numeric(c(no_hyphens, unfold)))
  return(out)
}

read.nexus.custom <- function(path, ord_ind_string) {
  linevec <- readLines(path)
  # The line from which we want to start reading the matrix is the one immediately below the
  # line that says 'MATRIX' -- unless it is empty, in which case it is the line after.
  tmp <- grep("MATRIX", linevec)
  to_skip <- ifelse(linevec[tmp + 1] != "", tmp, tmp + 1)
  # The number of lines to read in is determined by 'NTAX'
  ntax <- as.numeric(gsub(".*NTAX=(\\d+)[^\\d]+", "\\1", linevec[grep("NTAX", linevec)]))
  # Replace two or more successive spaces by a tab
  linevec[(to_skip + 1):(to_skip + ntax)] <- gsub("\\s\\s+", "\t",
                                                  linevec[(to_skip + 1):(to_skip + ntax)])
  # Delete leading tabs
  linevec <- gsub("^\\t", "", linevec)
  # Setting row.names to NULL forces the taxon names to become column 1 rather than row names:
  # this is better, since having a 1-column data set would otherwise cause problems later on
  dataset <- read.table(text = linevec, skip = to_skip, nrows = ntax, stringsAsFactors = F,
                        row.names = NULL, colClasses = "character", sep = "\t")
  # Now, extract the indices of ordered characters
  if (ord_ind_string == "") {
    ord_ind <- vector(mode = "numeric")
  } else {
    ord_ind <- eval(parse(text = paste0("c(", ord_ind_string, ")")))
  }
  # Break up column 2 (containing character strings of length n) into n columns so that each
  # column corresponds to one character
  charvects <- Map(separate.char.strings, dataset[, 2])
  # Check that the character strings are of the same length for all taxa
  lengths <- sapply(charvects, length)
  chars <- do.call(rbind, charvects)
  # Replace all partial uncertainties and polymorphisms by question marks. We can exploit the
  # fact that the first two of these categories always take up more than one character in the
  # parsed 'chars' matrix
  tmp <- apply(chars, 1,
               function(x) sapply(x, function(y) {if (nchar(y) > 1) y <- "?"; return(y)}))
  chars <- t(tmp)
  rownames(chars) <- dataset[, 1]
  if (all(lengths == lengths[1])) {
    return(list(dataset = chars, ordered_indices = ord_ind))
  } else {
    stop("The dataset contains character strings of unequal length.")
  }
}

# This function, too, is more general than we currently need, as it can deal with polymorphisms,
# partial ambiguities, and inapplicables.

obs.states <- function(charvect) {
  # "Unfold" partial uncertainties and polymorphisms
  expanded <- unlist(regmatches(charvect, gregexpr("[[:digit:]]+", charvect)))
  # Exclude missing data and inapplicables
  filtered <- expanded[which(!expanded %in% c("-", "?"))]
  return(table(filtered))
}

# Similar to the '.setNumStatesPartition()' method in RevBayes and most other phylogenetic
# software, we will determine the number of states for each character based on the maximum
# observed state rather than the total number of observed states. E.g., a character for which
# only states 0, 1, and 4 are observed will be assumed to have 5 rather than 3 states.

get.state.num <- function(matrix) {
  state_spaces <- apply(matrix, 2, obs.states, simplify = FALSE)
  states <- Map(function(x) as.numeric(names(x)), state_spaces)
  state_nums <- sapply(states, function(x) max(x) + 1)
  indices <- Map(function(x) which(state_nums == x), x = sort(unique(state_nums)))
  names(indices) <- sort(unique(state_nums))
  return(indices)
}

# Now apply the function above separately to ordered and unordered characters

get.ordered.unordered.state.nums <- function(path, ord_ind_string) {
  data <- read.nexus.custom(path, ord_ind_string)
  
  # Exclude constant characters
  const <- which(sapply(apply(data$dataset, 2, obs.states, simplify = FALSE), length) == 1)
  if (length(const) != 0) {
    warning(paste("The following characters are constant and will be excluded:",
                  paste(const, collapse = ", "), sep = "\n"))
  }
  
  if (length(c(const, data$ordered_indices)) == 0) {
    unordered_chars <- data$dataset
  } else {
    unordered_chars <- data$dataset[, -c(const, data$ordered_indices)]
  }
  
  ordered_chars <- data$dataset[, data$ordered_indices[which(!data$ordered_indices %in% const)]]
  
  if (ncol(unordered_chars) > 0) {
    unordered <- get.state.num(unordered_chars)
    names(unordered) <- paste0("MK", names(unordered)) # unordered chars are modeled using Mk
    unordered_matrices <- Map(function(x) unordered_chars[, x], x = unordered)
  }
  
  # If the above code block did not create an object called "unordered_matrices", create an
  # an empty list of that name:
  if (!exists("unordered_matrices")) {
    unordered_matrices <- list()
  }
  
  if (ncol(ordered_chars) > 0) {
    ordered <- get.state.num(ordered_chars)
    names(ordered) <- paste0("ORDERED", names(ordered))
    ordered_matrices <- Map(function(x) ordered_chars[, x], x = ordered)
  
    # Ordering only makes sense for characters with 3 or more states. Therefore, if we find that
    # some of our ordered characters are binary, we will reassign them to the corresponding
    # unordered partition.
    if ("ORDERED2" %in% names(ordered_matrices)) {
      # Print a warning
      warning(paste("Some of the characters that were specified as ordered are binary.",
                    "We add them to the end of the unordered binary partition instead.",
                    "This changes the ordering of characters compared to the original matrix.",
                    sep = "\n"))
      
      # Fortunately, the following works even if there is no list element called MK2 at first
      unordered_matrices$MK2 <- cbind(unordered_matrices$MK2, ordered_matrices$ORDERED2)
      ordered_matrices <- ordered_matrices[which(names(ordered_matrices) != "ORDERED2")]
    }
  }
  
  # If the above code block did not create an object called "ordered_matrices", create an
  # an empty list of that name:
  if (!exists("ordered_matrices")) {
    ordered_matrices <- list()
  }
  
  out <- c(unordered_matrices, ordered_matrices)
  # Exclude 1-state (constant) characters, should there be any
  out <- out[which(!names(out) %in% c("MK1", "ORDERED1"))]
  # If a partition contains a single character, it will be treated as a vector rather than
  # a matrix. Here, we correct this:
  one_char_mats <- which(sapply(out, is.matrix) == F)
  if (length(one_char_mats) > 0) {
    out[one_char_mats] <- Map(function(x) as.matrix(out[[x]], nrow = length(out[[x]]), ncol = 1),
                              x = one_char_mats)
  }
  return(out)
}

single.phy.printer <- function(frame, outpath) {
  head <- c(nrow(frame), ncol(frame))
  # Collapse separate character columns back into a single column containing character strings
  cllpsd <- cbind(rownames(frame), apply(frame, 1, function(x) paste(x, collapse = "")))
  phy <- file(outpath, "w")
  writeLines(capture.output(cat(head, sep = " ")), phy)
  write.table(cllpsd, file = phy, col.names = F, row.names = F, quote = F, sep = "\t", append = T)
  close(phy)
}

multi.phy.printer <- function(path, ord_ind_string) {
  # Extract that part of the file basename that goes before the file ending
  prefix <- strsplit(basename(path), "\\.")[[1]][1]
  char_frames <- get.ordered.unordered.state.nums(path, ord_ind_string)
  frame_paths <- paste0(dirname(path), "/", prefix, "_", names(char_frames), ".phy")
  Map(function(x, y) single.phy.printer(frame = x, outpath = y), x = char_frames, y = frame_paths)
}

# RUN

multi.phy.printer(opt$pathtofile, opt$orderedchars)
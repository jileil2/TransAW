# Fetch the two comparison implementations at fixed upstream revisions.
files <- c(
  "trans-lasso.R" = "https://raw.githubusercontent.com/saili0103/TransLasso/285009edf3e638567474108f823adcc1dc6c7c4a/TransLasso-functions.R",
  "riw.R" = "https://raw.githubusercontent.com/RIW-TL/Transfer-learning/cee9d7b4a5ca32abfbe466e2902806a232f86ba0/functions.R"
)
dir.create("method/reference", showWarnings = FALSE)
for (file in names(files)) download.file(files[[file]], file.path("method/reference", file), mode = "wb")

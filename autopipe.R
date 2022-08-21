# autopipe.R



# Dropbox download --------------------------------------------------------

library(rdrop2)
refreshable_token <- readRDS("refreshable_droptoken.rds")
info <- drop_acc(refreshable_token)
message("Dropbox account: ", info$name$display_name)

library(compasstools)
DROPBOX_DIR <- "TEMPEST_PNNL_Data/Current_data"
sf_raw <- compasstools::process_sapflow_dir(DROPBOX_DIR,
                                            tz = "EST",
                                            dropbox_token = refreshable_token)


# Process data ------------------------------------------------------------

test_n_obs <- nrow(sf_raw)
write.csv(head(sf_raw), "data_upload/sf_raw.csv")


# Google Drive upload -----------------------------------------------------

# TODO: this will need to be a refreshable token?

library(googledrive)
# x <- gargle::token_fetch()
# saveRDS(x, "googletoken.rds")
google_token <- readRDS("googletoken.rds")
drive_auth(token = google_token)
path <- drive_find("autopipe", n_max=100, type = "folder")
drive_upload("data_upload/sf_raw.csv", path = path)


# Post to Slack -----------------------------------------------------------

# This is very basic -- I created a webhook to post to my account (#ben)
# and saved the URL as 'slacktoken.rds'
# Using the `slackr` function would allow for much fancier stuff
library(slackr)
WEBHOOK_URL <- readRDS("slacktoken.rds")
msg <- paste("Processed", test_n_obs, "sapflow observations")
message("Posting to Slack: ", msg)
slackr_bot(msg, incoming_webhook_url = WEBHOOK_URL)

message("All done.")

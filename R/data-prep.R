sheffield_lsoas <- jogger::geo_get("lsoa", "Sheffield", "lad")

saveRDS(sheffield_lsoas, here::here("rds_data", "sheffield_lsoas.Rds"))


scc_oa_nbd_lookup <- readr::read_csv(here("data", "ref_OAs_2011_to_Sheff_100_nhoods_for_fb_db10022021.csv")) %>%
  janitor::clean_names() %>%
  dplyr::rename(oa11cd = oa_2011)

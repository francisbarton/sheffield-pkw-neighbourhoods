

# LSOA boundaries for the whole city --------------------------------------

if (FALSE) {
  sheffield_lsoas <- jogger::geo_get("lsoa", "Sheffield", "lad")
  saveRDS(sheffield_lsoas, here::here("rds_data", "sheffield_lsoas.Rds"))
}

sheffield_lsoas <- readRDS(here::here("rds_data", "sheffield_lsoas.Rds"))




# Census Output Area (OA) boundaries for the whole city -------------------

if (FALSE) {
  sheffield_coas <- jogger::geo_get("oa", "Sheffield", "lad", include_msoa = TRUE)
  saveRDS(sheffield_coas, here::here("rds_data", "sheffield_coas.Rds"))
}

sheffield_coas <- readRDS(here::here("rds_data", "sheffield_coas.Rds"))




# OA:Neighbourhood lookup from Sheffield City Council ---------------------


oa_scc_nbd_lookup <- readr::read_csv(here("data", "ref_OAs_2011_to_Sheff_100_nhoods_for_fb_db10022021.csv")) %>%
  janitor::clean_names() %>%
  dplyr::rename(oa11cd = oa_2011)



# Sheaf PKW area comprises 3 of Sheffield's 100 Neighbourhoods
sheaf_pkw_oas <- oa_scc_nbd_lookup %>%
  dplyr::filter(nhood_name %in% c("Heeley", "Highfield", "Meersbrook")) %>%
  dplyr::inner_join(sheffield_coas, .) %>%
  dplyr::select(!lad20cd:lad20nm)







# Boundaries for the 3 Neighbourhoods -------------------------------------


# sheaf_nhoods <- sheaf_pkw_oas %>%
#   split(.$nhood_name) %>%
#   purrr::map(sf::st_union)

# instead:
sheaf_nhoods <- sheaf_pkw_oas %>%
  dplyr::group_by(nhood_name) %>%
  dplyr::summarise() %>%
  dplyr::ungroup()





# Boundary for the whole Sheaf area ---------------------------------------


sheaf_boundary <- sf::st_union(sheaf_pkw_oas)



# Sheaf LSOA boundaries ---------------------------------------------------

sheaf_lsoas <- sheaf_pkw_oas %>%
  sf::st_drop_geometry() %>%
  dplyr::select(lsoa11cd) %>%
  dplyr::distinct()


sheaf_lsoas_bounds <- sheffield_lsoas %>%
  dplyr::inner_join(sheaf_lsoas)




# Explore LSOAs with some OAs inside Sheaf and some outside ---------------

# OAs within "Sheaf" LSOAs but that are themselves outside Sheaf nbd
oas_outside_sheaf <- sheffield_coas %>%
  sf::st_drop_geometry() %>%
  dplyr::select(1:3) %>%
  dplyr::inner_join(sheaf_lsoas) %>%
  dplyr::anti_join(sheaf_pkw_oas)

# OAs within those LSOAs that are inside Sheaf nbd
oas_inside_sheaf <- sheaf_pkw_oas %>%
  sf::st_drop_geometry() %>%
  dplyr::select(1:3) %>%
  dplyr::filter(lsoa11cd %in% oas_outside_sheaf$lsoa11cd)

# Create a table to show this
inside_outside_table <- oas_inside_sheaf %>%
  dplyr::count(lsoa11nm, name = "OAs inside Sheaf area") %>%
  dplyr::arrange(desc(`OAs inside Sheaf area`)) %>%
  dplyr::left_join(
    oas_outside_sheaf %>%
      dplyr::count(lsoa11nm, name = "OAs outside Sheaf area")
  )




# Ward boundaries for the whole city --------------------------------------

if (FALSE) {
  sheffield_wards <- jogger::geo_get("ward", "Sheffield", "lad", return_style = "minimal")
  saveRDS(sheffield_wards, here::here("rds_data", "sheffield_wards.Rds"))
}

sheffield_wards <- readRDS(here::here("rds_data", "sheffield_wards.Rds"))



sheffield_city_boundary <- sheffield_wards %>%
  sf::st_union()



# Obtain an OA:Ward lookup table ------------------------------------------

if (FALSE) {
  oa_wards_lookup <- jogger::geo_get(
    bounds_level = "oa",
    within = "Sheffield",
    within_level = "lad",
    include_msoa = FALSE,
    # returns ward data in "tidy" mode
    return_boundaries = FALSE
  )

  saveRDS(oa_wards_lookup,
          here::here("rds_data", "oa_wards_lookup.Rds"))
}

oa_wards_lookup <- readRDS(here::here("rds_data", "oa_wards_lookup.Rds"))

# Find all wards that contain 1 or more OAs within the Sheaf area
sheaf_wards <- oa_wards_lookup %>%
  dplyr::inner_join(sheaf_pkw_oas, by = "oa11cd") %>%
  dplyr::select(wd20cd) %>%
  dplyr::distinct() %>%
  dplyr::inner_join(sheffield_wards, .)


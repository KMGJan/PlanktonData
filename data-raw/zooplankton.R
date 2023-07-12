## code to prepare `zooplankton` dataset goes here

usethis::use_data(zooplankton, overwrite = TRUE)
# Monthly zooplankton biomass at three stations between 2007 and 2021

# library(shaRk)
# library(zoo)
# library(xts)
# library(reshape)

### 1. Import the files ----
Bodymass <- read_csv("./Biomass_Full.csv",
                     locale = locale(decimal_mark = "."),
                     show_col_types = F)  |>
  tidyr::pivot_longer(cols = 5:8, names_to = "Group", values_to = "Weight") |>

  dplyr::mutate(Location = ifelse(Station == "BY31",
                                  "Landsort",
                                  ifelse(Station == "B3",
                                         "NBS",
                                         "SBS"))) |>
  dplyr::select(-Station)

# Abundance data of zooplankton
zooplankton <- readRDS("./zooplankton.rds")

### 2. Filter and arrange the dataset zooplankton ----
zp <- zooplankton |>
  # Arrange the data taxonomy as the bodymass data
  dplyr::mutate(dev_stage_code = ifelse(dev_stage_code == "AD",
                                        "AD",
                                        ifelse(dev_stage_code == "C1",
                                               "C1",
                                               ifelse(dev_stage_code %in% c("C3",
                                                                            "C4"),
                                                      "C4",
                                                      as.character(dev_stage_code))))) |>
  # Filter years between 2007 and 2021
  dplyr::filter(Year > 2006,
                Year < 2022,
                # at depth of 30 and 60 m
                Depth %in% c(30, 60),
                # corresponding to abundance data
                unit == "ind/m3",
                # Excluding Nauplii
                dev_stage_code != "NP",
                # from these classes
                Class %in% c("Maxillopoda", # <----- Copepoda
                             "Branchiopoda",# <----- Cladocera
                             "Eurotatoria"), # <----- Rotifera
                # And from these 3 stations
                Station %in% c("BY5 BORNHOLMSDJ",
                               "BY15 GOTLANDSDJ",
                               "BY31 LANDSORTSDJ"))  |>
  # Select only columns of interest
  dplyr::select(Class,
                Order,
                Family,
                Genus,
                Species,
                SDATE,
                Yr_mon,
                Month,
                Year,
                Station,
                Day,
                Parameter,
                Value,
                Depth,
                dev_stage_code,
                sex_code) |>
  # Arrange a new column that matches bodymass.csv
  mutate(Group = case_when(
    Month %in% c(1, 2, 3) ~ "Jan-Mar",
    Month %in% c(4, 5, 6) ~ "Apr-Jun",
    Month %in% c(7, 8, 9) ~ "Jul-Sep",
    Month %in% c(10, 11, 12) ~ "Oct-Dec"))

# Merge bodymass and zooplankton data
zoo_table <- zp |>
  mutate(STAGE = dev_stage_code,
         SEXCO = sex_code,
         Station = ifelse(Station == "BY31 LANDSORTSDJ",
                          "BY31",
                          ifelse(Station == "BY5 BORNHOLMSDJ",
                                 "BY5",
                                 ifelse(Station == "NB1 / B3" | Station == "B3",
                                        "B3",
                                        "BY15"))),
         Location = ifelse(Station == "BY31",
                           "Landsort",
                           ifelse(Station %in% c("BY15", "BY5"),
                                  "SBS",
                                  "NBS")))  |>
  # if the Genus is not know, assign the Taxa as the class,
  # else assign the taxa as the genus
  transform(Genus = ifelse(Genus == "",
                           as.character(Class),
                           as.character(Genus)),
            Taxa = as.character(Genus)) |>
  mutate(Taxa = ifelse(Species %in% c("Acartia bifilosa",
                                      "Acartia longiremis",
                                      "Acartia tonsa",
                                      "Podon intermedius"),
                       as.character(Species),
                       as.character(Taxa)),
         Value = Value / 1000, # <---- from ind/m3 to ind/L
         SEXCO = ifelse(SEXCO == "M",
                        "M",
                        ifelse(SEXCO == "F",
                               "F",
                               "NS")),
         STAGE = ifelse(STAGE %in% c("AD",
                                     "C1",
                                     "C4",
                                     "JV"),
                        as.character(STAGE),
                        "NS")) |>

  # Now that everything matches the bodymass dataframe, we can merge
  right_join(Bodymass,
             by = c("Taxa",
                    "Location",
                    "STAGE",
                    "SEXCO",
                    "Group")) |>
  # Biomass = Abundance * Weigth
  dplyr::mutate(Biomass.ugL = Value * Weight) |>

  dplyr::select(Taxa,
                Station,
                Genus,
                SDATE,
                Yr_mon,
                Month,
                Year,
                Day,
                Biomass.ugL,
                Depth) |>

  dplyr::mutate(Taxa = ifelse(Genus == "Acartia",
                              "Acartia",
                              ifelse(Genus == "Podon",
                                     "Podon",
                                     as.character(Taxa)))) |>
  dplyr::filter(!is.na(Station))

names(zoo_table) <- c("Taxa",
                      "Station",
                      "Genus",
                      "SDATE",
                      "Yr_mon",
                      "Month",
                      "Year",
                      "Day",
                      "Value",
                      "Depth")

D30 <- subset(zoo_table, Depth != 60 & Taxa !='Pseudocalanus')
D60 <- subset(zoo_table, Depth == 60 & Taxa =='Pseudocalanus')
ztable1 <- rbind(D30, D60)
rm(D30, D60, zoo_table)

ztable2 <- ztable1 |>
  # We can assign the group copepoda, cladocera, and rotatoria to the genus
  mutate(Group = ifelse(Genus %in% c("Acartia",
                                     "Centropages",
                                     "Eurytemora",
                                     "Pseudocalanus",
                                     "Temora", "Limnocalanus"),
                        "Copepoda",
                        ifelse(Genus %in%c("Bosmina",
                                           "Evadne",
                                           "Podon"),
                               "Cladocera",
                               "Rotatoria")))
# Group by date and depth
d1 <- ztable2 |>
  group_by(Year,
           Yr_mon,
           Month,
           SDATE,
           Depth,
           Group,
           Genus,
           Station,
           Taxa) |>
  # Sum of each sampling event
  summarise(Value = sum(Value)) |>
  ungroup() |>
  # Monthly average
  group_by(Year,
           Yr_mon,
           Month,
           Genus,
           Group,
           Station,
           Taxa) |>
  summarise(Value = mean(Value, na.rm = T))

dGenus <- d1 |>
  group_by(Month,
           Year,
           Group,
           Genus,
           Station,
           Taxa) |>
  summarise(Value = mean(Value,
                         na.rm = T)) |>
  ungroup()

month = tibble(Month = 1:12,
               Month_abb = month.abb)
monthly_zoo <- dGenus |>
  dplyr::mutate(Coordinates = ifelse(Station == "BY15", "20.05000/57.33333",
                                     ifelse(Station == "BY31", "18.23333/58.58812",
                                            "15.98333/55.25000")),
                Biomass = Value) |>
  dplyr::right_join(month) |>
  dplyr::select(Month_abb, Year,  Station, Coordinates, Group, Taxa, Biomass)



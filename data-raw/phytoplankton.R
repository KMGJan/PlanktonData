## code to prepare `phytoplankton` dataset goes here

# Phytoplankton ----
## 1. Data processing ----
phytoplankton <- readRDS("./phytoplankton.rds")

## 2. Filter the data ----
phyto_table <- phytoplankton |>
  dplyr::filter(Station %in% c("BY31 LANDSORTSDJ","BY5 BORNHOLMSDJ", "BY15 GOTLANDSDJ"),
                Year > 2006,
                Year < 2022,
                unit == "ugC/l",
                trophic_type_code %in% c("AU", "MX")) |>
  dplyr::filter(Phylum !="<NA>") |>
  dplyr::mutate(Taxa = ifelse(Phylum == "Bacillariophyta",
                              "Diatoms",
                              ifelse(Phylum == "Miozoa",
                                     "Dinoflagellates",
                                     ifelse(Genus == "Mesodinium",
                                            "Mesodinium",
                                            ifelse(Phylum == "Cyanobacteria",
                                                   "Cyanobacteria",
                                                   "Other"))))) |>
  dplyr::mutate(Station = ifelse(Station == "BY31 LANDSORTSDJ", "BY31",ifelse(Station == "BY15 GOTLANDSDJ", "BY15", ifelse(Station %in% c("NB1 / B3", "NB 1", "B3"), "B3", "BY5"))))

phyto_table |>
  ggplot(aes(x=SDATE, y = log(Value), col=Depth))+
  geom_point()+
  facet_grid(Taxa~Station)

D10 <- subset(phyto_table, Depth == 20 & Station =='BY31' & Month != 11)
D20 <- subset(phyto_table, Depth == 10 & Station != 'BY31')
D20.2 <- subset(phyto_table, Depth == 10 & Station == "BY31" & Month%in% c(1,2,11,12))
ptable1 <- rbind(D10,D20, D20.2)

rm(D10, D20)

## 3. Arrange the data to have taxa carbon content per day ----
d1 <- ptable1 |>
  group_by(Year,
           Month,
           SDATE,
           Taxa,
           Station,
           Depth) |>
  summarise(Value = sum(Value)) |>

  group_by(Year,
           Month,
           Taxa,
           Station) |>
  summarise(Value = mean(Value,
                         na.rm = T))
month = tibble(Month = 1:12,
               Month_abb = month.abb)

phytoplankton <- d1 |> ungroup() |>
  dplyr::mutate(Coordinates = ifelse(Station == "BY15", "20.05000/57.33333",
                                     ifelse(Station == "BY31", "18.23333/58.58812",
                                            "15.98333/55.25000")),
                Biomass = Value) |>
  dplyr::right_join(month) |>
  dplyr::select(Month_abb, Year,  Station, Coordinates, Taxa, Biomass)

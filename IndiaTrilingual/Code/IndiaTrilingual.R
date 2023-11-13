

packages <- list("here","tidyverse","terra","sf",
                 "RColorBrewer","readxl","viridis",
                 "gridExtra")

lapply(packages, require,character.only = T) 


options(scipen = 9999)

############## 
### import the state shape file ###

States <- sf::st_read(here("Datasets","States",
                           "Admin2.shp")) %>% 
          dplyr::rename(STATE = ST_NM) %>%
          dplyr::mutate(STATE = toupper(STATE)) 


#### Merge the states of Telengana and Andhra Pradesh into one ####

Telengana_AndhraPradesh <- States %>%
                              dplyr::filter(STATE %in% c("TELANGANA","ANDHRA PRADESH")) %>%
                              sf::st_union() %>%
                              sf::st_as_sf() %>%
                              dplyr::mutate(STATE = "ANDHRA PRADESH") %>%
                              dplyr::rename(geometry = x)



# Remove original "TELANGANA" and "ANDHRA PRADESH" entries from States
States <- States %>%
  dplyr::filter(!STATE %in% c("TELANGANA", "ANDHRA PRADESH")) 


#### Add the Telengana_AndhraPradesh into the main States sf object ##

States <- States %>% 
              rbind(Telengana_AndhraPradesh)


############# 
#### load in the population data ###
############ 

Population <- read_xlsx(here("Datasets","CSVs",
                            "Population.xlsx"),
                        skip = 1) %>%
                    ## deleting the next two rows after making the first row column names
                        dplyr::slice(-1:-2) %>% 
        #### selecting the columns we need ########
             dplyr::select(`India/ State/ Union Territory/ District/ Sub-district`,
              Name,`Total/\r\nRural/\r\nUrban`,Population) %>%
        ### Filter by the State label#### 
        dplyr::filter(`India/ State/ Union Territory/ District/ Sub-district` == "STATE",
                      `Total/\r\nRural/\r\nUrban` == "Total") %>%
        dplyr::mutate(Name = dplyr::case_when(Name == "JAMMU & KASHMIR @&" ~ "JAMMU & KASHMIR",
                                              Name == "NCT OF DELHI" ~ "DELHI",
                                              Name == "ANDAMAN & NICOBAR ISLANDS" ~ "ANDAMAN & NICOBAR",
                                              TRUE ~ Name)) %>%
        dplyr::select(-c("India/ State/ Union Territory/ District/ Sub-district",
                         "Total/\r\nRural/\r\nUrban")) %>% 
        dplyr::mutate(Population = as.numeric(as.character(Population)))



############## 
### now combine the populations of DADRA and DAMAN 

# Create a new row for combined states
combined_row <- Population %>%
  dplyr::filter(Name %in% c("DAMAN & DIU", "DADRA & NAGAR HAVELI")) %>%
  dplyr::summarise(Name = "DADRA AND NAGAR HAVELI AND DAMAN AND DIU", 
            Population = sum(Population, na.rm = TRUE))


###### Now adding this to the Population data ##

# Bind the new row and remove the original rows
Population <- Population %>%
  dplyr::filter(!Name %in% c("DAMAN & DIU", "DADRA & NAGAR HAVELI")) %>%
  dplyr::bind_rows(combined_row) %>%
  dplyr::arrange(Name)



############
#### load the trilingual data 
#############

Bilingual_Trilingual <- read_xlsx(here("Datasets", "CSVs", "Trilingual.xlsx"), skip = 1) %>%
                             dplyr::slice(-1:-28) %>%
                             dplyr::select(`Area Name`,
                                           'Total/',
                                           `Educational level`,
                                           `Number speaking second language`,
                                           `Number speaking third language`) %>%
                             dplyr::filter(`Total/` == "Total",
                                           `Educational level` == "Total") %>%
                             dplyr::mutate(`Number speaking second language` = as.numeric(as.character(`Number speaking second language`)),
                                           `Number speaking third language` = as.numeric(as.character(`Number speaking third language`))) %>%
                             dplyr::mutate(Name = dplyr::case_when(`Area Name` == "NCT OF DELHI" ~ "DELHI",
                                                                   `Area Name` == "ANDAMAN & NICOBAR ISLANDS" ~ "ANDAMAN & NICOBAR",
                                                                   TRUE ~ `Area Name`))

############## same as the population ####
### now combine the populations of DADRA and DAMAN 

# Create a new row for combined states
combined_row_lingo <- Bilingual_Trilingual %>%
  dplyr::filter(`Area Name` %in% c("DAMAN & DIU", "DADRA & NAGAR HAVELI")) %>%
  dplyr::summarise(Name = "DADRA AND NAGAR HAVELI AND DAMAN AND DIU", 
            `Number speaking second language` = sum(`Number speaking second language`, na.rm = TRUE),
            `Number speaking third language` = sum(`Number speaking third language`, na.rm = TRUE)) 


###### Now adding this to the Population data ##

# Bind the new row and remove the original rows
Bilingual_Trilingual <- Bilingual_Trilingual %>%
  dplyr::filter(!Name %in% c("DAMAN & DIU", "DADRA & NAGAR HAVELI")) %>%
  dplyr::bind_rows(combined_row_lingo) %>%
  dplyr::arrange(Name) %>%
  dplyr::select(`Number speaking second language`,
                `Number speaking third language`,
                Name)



############### 
### Trilingual proportion 
######## 

Bilingual_Trilingual_proportion <- data.frame(STATE = Population$Name,
                                    POPULATION = Population$Population,
                                    BILINGUAL = Bilingual_Trilingual$`Number speaking second language`,
                                    TRILINGUAL = Bilingual_Trilingual$`Number speaking third language`,
                                    PROPORTION_SECOND = Bilingual_Trilingual$`Number speaking second language`/Population$Population,
                                    PROPORTION_THIRD = Bilingual_Trilingual$`Number speaking third language`/Population$Population)

######
## Add the proportion data to the state information 
####

States <- States %>% 
               dplyr::full_join(Bilingual_Trilingual_proportion) %>%
               dplyr::mutate(STATE_ABBREV = dplyr::case_when(STATE == "JAMMU & KASHMIR" ~ "JK",
                                                             STATE == "ARUNACHAL PRADESH" ~ "AP",
                                                             STATE == "ANDAMAN & NICOBAR" ~ "AN",
                                                             STATE == "ASSAM" ~ "AS",
                                                             STATE == "CHANDIGARH" ~ "CH",
                                                             STATE == "KARNATAKA" ~ "KA",
                                                             STATE == "MANIPUR" ~ "MN",
                                                             STATE == "MEGHALAYA" ~ "ML",
                                                             STATE == "MIZORAM" ~ "MZ",
                                                             STATE == "NAGALAND" ~ "NL",
                                                             STATE == "PUNJAB" ~ "PB",
                                                             STATE == "RAJASTHAN" ~ "RJ",
                                                             STATE == "SIKKIM" ~ "SK",
                                                             STATE == "TRIPURA" ~ "TR",
                                                             STATE == "UTTARAKHAND" ~ "UK",
                                                             STATE == "BIHAR" ~ "BR",
                                                             STATE == "KERALA" ~ "KL",
                                                             STATE == "MADHYA PRADESH" ~ "MP",
                                                             STATE == "GUJARAT" ~ "GJ",
                                                             STATE == "LAKSHADWEEP" ~ "LD",
                                                             STATE == "ODISHA" ~ "OR",
                                                             STATE == "CHHATTISGARH" ~ "CG",
                                                             STATE == "DELHI" ~ "DL",
                                                             STATE == "GOA" ~ "GA",
                                                             STATE == "HARAYANA" ~ "HR",
                                                             STATE == "HIMACHAL PRADESH" ~ "HP",
                                                             STATE == "JHARKHAND" ~ "JH",
                                                             STATE == "TAMIL NADU" ~ "TN",
                                                             STATE == "UTTAR PRADESH" ~ "UP",
                                                             STATE == "WEST BENGAL" ~ "WB",
                                                             STATE == "ANDHRA PRADESH" ~ "AP",
                                                             STATE == "PUDUCHERRY" ~ "PY",
                                                             STATE == "MAHARASHTRA" ~ "MH",
                                                             STATE == "TELENGANA" ~ "TG",
                                                             STATE == "DADRA AND NAGAR HAVELI AND DAMAN AND DIU" ~ "DH & DD",
                                                             STATE == "HARYANA" ~ "HR")) %>%
                        dplyr::filter(STATE != "LADAKH")




##Create bins for PROPORTION_SECOND

States <- States %>%
  dplyr::mutate(bin_second_language = cut(PROPORTION_SECOND, 
                                  breaks = c(-Inf, 0.3, 0.4, 0.5, 0.6, Inf), 
                                  labels = c("<30%", "30%-40%", "40%-50%", "50%-60%", ">60%"))) %>%
  dplyr::mutate(bin_third_language = cut(PROPORTION_THIRD, 
                                         breaks = c(-Inf, 0.05, 0.10, 0.15, 0.20, Inf), 
                                         labels = c("<5%", "5%-10%", "10%-15%", "15%-20%", ">20%")))


##########################
################## PLOTTING BILINGUAL #############
######


# Define the color palette
my_colors <- c("<30%" = "#000004", "30%-40%" = "#3B0F70", 
               "40%-50%" = "#8C2981", "50%-60%" = "#DE4968", 
               ">60%" = "#FDC326")

# Prepare the data
mainland <- States %>% filter(!STATE %in% c("LAKSHADWEEP", "ANDAMAN & NICOBAR"))
andaman_nicobar <- States %>% filter(STATE == "ANDAMAN & NICOBAR")
lakshadweep <- States %>% filter(STATE == "LAKSHADWEEP")

# Create the main map
main_map <- ggplot(data = mainland) +
  geom_sf(aes(fill = bin_second_language), color = "white") +
  scale_fill_manual(values = my_colors) +
  theme_void() +
  labs(title = "Percentage of Bilingual Population in India as per 2011 (except Lakshadweep)",
       fill = "Percent Bilingual") +
  theme(plot.title = element_text(hjust = 0.5, vjust = 1, size = 30,
                                  color = "black"))

# Zoomed-in inset for Andaman and Nicobar
andaman_map <- ggplot(data = andaman_nicobar) +
  geom_sf(aes(fill = bin_second_language), color = "white") +
  scale_fill_manual(values = my_colors) +
  theme_void() +
  theme(legend.position = "none") +
  coord_sf(xlim = c(92, 94), ylim = c(6, 14)) # Adjust these limits to zoom in

# Zoomed-in inset for Lakshadweep
lakshadweep_map <- ggplot(data = lakshadweep) +
  geom_sf(aes(fill = bin_second_language), color = "white") +
  scale_fill_manual(values = my_colors) +
  theme_void() +
  theme(legend.position = "none") +
  coord_sf(xlim = c(216, 228), ylim = c(30, 39)) # Adjust these limits to zoom in

# Convert insets to grobs
andaman_grob <- ggplotGrob(andaman_map)
lakshadweep_grob <- ggplotGrob(lakshadweep_map)

# Positioning the insets on the main map
map <- main_map + 
  annotation_custom(grob = andaman_grob, xmin = 90, xmax = 100, ymin = 10, ymax = 20) + # Adjust for Andaman
  annotation_custom(grob = lakshadweep_grob, xmin = 65, xmax = 78, ymin = 5, ymax = 13) # Adjust for Lakshadweep



ggsave(map,filename = "India_bilingual.png",width = 20, height = 7.75, dpi = 600,
       bg = "white", device = "png")


############
## PLOTTING PERCENT TRILINGUAL ##
########### 


# Define the color palette
my_colors <- c("<5%" = "#000004", "5%-10%" = "#3B0F70", 
               "10%-15%" = "#8C2981", "15%-20%" = "#DE4968", 
               ">20%" = "#FDC326")

# Prepare the data
mainland <- States %>% filter(!STATE %in% c("LAKSHADWEEP", "ANDAMAN & NICOBAR"))
andaman_nicobar <- States %>% filter(STATE == "ANDAMAN & NICOBAR")
lakshadweep <- States %>% filter(STATE == "LAKSHADWEEP")

# Create the main map
main_map <- ggplot(data = mainland) +
  geom_sf(aes(fill = bin_third_language), color = "white") +
  scale_fill_manual(values = my_colors) +
  theme_void() +
  labs(title = "Percentage of Trilingual Population in India as per 2011 (except Lakshadweep)",
       fill = "Percent Trilingual") +
  theme(plot.title = element_text(hjust = 0.5, vjust = 1, size = 30,
                                  color = "black"))

# Zoomed-in inset for Andaman and Nicobar
andaman_map <- ggplot(data = andaman_nicobar) +
  geom_sf(aes(fill = bin_third_language), color = "white") +
  scale_fill_manual(values = my_colors) +
  theme_void() +
  theme(legend.position = "none") +
  coord_sf(xlim = c(92, 94), ylim = c(6, 14)) # Adjust these limits to zoom in

# Zoomed-in inset for Lakshadweep
lakshadweep_map <- ggplot(data = lakshadweep) +
  geom_sf(aes(fill = bin_third_language), color = "white") +
  scale_fill_manual(values = my_colors) +
  theme_void() +
  theme(legend.position = "none") +
  coord_sf(xlim = c(216, 228), ylim = c(30, 39)) # Adjust these limits to zoom in

# Convert insets to grobs
andaman_grob <- ggplotGrob(andaman_map)
lakshadweep_grob <- ggplotGrob(lakshadweep_map)

# Positioning the insets on the main map
map <- main_map + 
  annotation_custom(grob = andaman_grob, xmin = 90, xmax = 100, ymin = 10, ymax = 20) + # Adjust for Andaman
  annotation_custom(grob = lakshadweep_grob, xmin = 65, xmax = 78, ymin = 5, ymax = 13) # Adjust for Lakshadweep



ggsave(map,filename = "India_trilingual.png",width = 20, height = 7.75, dpi = 600,
       bg = "white", device = "png")






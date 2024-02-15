# PCS_recodages_base <-
#   read_excel("01-Scripts et workspaces/Nomenclature PCS recodages.xlsx",
#              sheet = "Recodages")
#
# data <- emploi_data_list[["ee2013_18"]] %>% #ee2013_18 %>%
#   dplyr::filter(ANNEE >= 2014) %>%
#   dplyr::mutate(EMP_ADM_ENT = as.factor(dplyr::case_when(
#     stringr::str_detect(PUB3FP, "^1|^2|^3") ~ "1-Administrations publiques",
#     stringr::str_detect(PUB3FP, "^4")       ~ "2-Entreprises"
#   )))
# profession = rlang::expr(P)
# admin_ent = rlang::expr(EMP_ADM_ENT)
# nomenclaturePCS = "2003"
# varprefix = "PR"
# mélanger_independants_et_salaries = FALSE
# only_numbers = TRUE





# #Fonction pour créer une version modifiée de la nomenclature des CSP
# # à partir des professions détaillées :
# recodage_PCS <-
#   function(data, PCS_recodages_base = read_excel("Nomenclature PCS recodages.xlsx"),
#            profession, admin_ent, varprefix = "PR",
#            nomenclaturePCS = c("2003", "1982", "2020"),
#            mélanger_independants_et_salaries = FALSE, only_numbers = FALSE) {
#     data <- data
#     PROF <- rlang::enquo(profession)
#     EMP <- rlang::enquo(admin_ent)
#     data_ok <- data %>% dplyr::select(!!PROF, !!EMP)
# 
#     if(only_numbers == FALSE) {
#       result4 <- stringr::str_c(varprefix,"4")
#       result4_ord <- stringr::str_c(varprefix,"4_ord")
#       result3 <- stringr::str_c(varprefix,"3")
#       result3_long <- stringr::str_c(varprefix,"3_long")
#       result2 <- stringr::str_c(varprefix,"2")
#       result2_long <- stringr::str_c(varprefix,"2_long")
#       result1 <- stringr::str_c(varprefix,"1")
#       result1_long <- stringr::str_c(varprefix,"1_long")
#       result0 <- stringr::str_c(varprefix,"0")
#       result0_long <- stringr::str_c(varprefix,"0_long")
#     } else {
#       result4 <- stringr::str_c(varprefix, "4_chiffre")
#       result3 <- stringr::str_c(varprefix, "3_chiffre")
#       result2 <- stringr::str_c(varprefix, "2_chiffre")
#       result1 <- stringr::str_c(varprefix, "1_chiffre")
#       result0 <- stringr::str_c(varprefix, "0_chiffre")
#     }
# 
#     # PCS_recodages_base <-
#     #   read_excel("01-Scripts et workspaces/Nomenclature PCS recodages.xlsx",
#     #              sheet = "Recodages")
# 
#     if (mélanger_independants_et_salaries == FALSE){
#       all_PRx <- c("PR4_chiffre", "PR4_nom",       #"PR4_nom_M", "PR4_nom_F", "PR4_nom_MF",
#                    "PR3_chiffre", "PR3_nom",       #"PR3_nom_M", "PR3_nom_F", "PR3_nom_MF",
#                    "PR3_nom_abrev", #"PR3_nom_abrev_M", "PR3_nom_abrev_F", "PR3_nom_abrev_MF",
#                    "PR2_chiffre", "PR2_nom",       #"PR2_nom_M", "PR2_nom_F", "PR2_nom_MF",
#                    "PR2_nom_abrev", #"PR2_nom_abrev_M", "PR2_nom_abrev_F", "PR2_nom_abrev_MF",
#                    "PR1_chiffre", "PR1_nom",       #"PR1_nom_M", "PR1_nom_F", "PR1_nom_MF",
#                    "PR1_nom_abrev", #"PR1_nom_abrev_M", "PR1_nom_abrev_F", "PR1_nom_abrev_MF",
#                    "PR0_chiffre", "PR0_nom",       #"PR0_nom_M", "PR0_nom_F", "PR0_nom_MF",
#                    "PR0_nom_abrev"#, "PR0_nom_abrev_M", "PR0_nom_abrev_F", "PR0_nom_abrev_MF"
#       )
#     } else {
#       all_PRx <- c("PR4_chiffre", "PR4_nom", #"PR4_nom_M", "PR4_nom_F", "PR4_nom_MF",
#                    PR3_chiffre = "PRI3_chiffre",
#                    "PR3_nom", #"PR3_nom_M", "PR3_nom_F", "PR3_nom_MF",
#                    "PR3_nom_abrev", #"PR3_nom_abrev_M", "PR3_nom_abrev_F", "PR3_nom_abrev_MF",
#                    PR2_chiffre = "PRI2_chiffre",
#                    "PR2_nom",                         #"PR2_nom_M", "PR2_nom_F", "PR2_nom_MF",
#                    "PR2_nom_abrev",                   #"PR2_nom_abrev_M", "PR2_nom_abrev_F", "PR2_nom_abrev_MF",
#                    PR1_chiffre = "PRI1_chiffre",
#                    PR1_nom = "PRI1_nom",              #"PR1_nom_M", "PR1_nom_F", "PR1_nom_MF",
#                    PR1_nom_abrev = "PRI1_nom_abrev",  #"PR1_nom_abrev_M", "PR1_nom_abrev_F", "PR1_nom_abrev_MF",
#                    PR0_chiffre = "PRI0_chiffre",
#                    PR0_nom = "PRI0_nom",              #"PR0_nom_M", "PR0_nom_F", "PR0_nom_MF",
#                    PR0_nom_abrev = "PRI0_nom_abrev"#,  "PR0_nom_abrev_M", "PR0_nom_abrev_F", "PR0_nom_abrev_MF"
#       )
#     }
# 
#     if (nomenclaturePCS == "2003") {
#       PCS_recodages <- PCS_recodages_base %>%
#         dplyr::select(PCS2003_c, PCS2003_nom, PUB, tidyselect::all_of(all_PRx)) %>%
#         dplyr::filter(PCS2003_c != "")
#       PCS_c <- rlang::expr(PCS2003_c)
#       PCS_format <-  "^\\d{3}[[:lower:]]$"
#     } else if (nomenclaturePCS == "1982") {
#       PCS_recodages <- PCS_recodages_base %>%
#         dplyr::select(PCS1982_c, PCS1982_nom, PUB, tidyselect::all_of(all_PRx)) %>%
#         dplyr::filter(PCS1982_c != "")
#       PCS_c <- rlang::expr(PCS1982_c)
#       PCS_format <-   "^\\d{4}$"
#     } else {
#       stop('Version de la nomenclature des PCS (1982, 2003) non précisée')
#     }
# 
# 
#     data_ok <- data_ok %>% dplyr::mutate(Pc = fct_replace(!!PROF, "^(.{4}).+", "\\1") )
# 
#     wrong_format <- data_ok %>% dplyr::pull(Pc) %>% levels() %>%
#       stringr::str_detect(PCS_format, negate = TRUE)
#     which_wrong_format <- levels(dplyr::pull(data_ok, Pc))[wrong_format]
# 
#     data_ok <- data_ok %>%
#       dplyr::mutate(Pc = fct_detect_replace(Pc, PCS_format, "NULL", negate = TRUE) ) %>%
#       dplyr::mutate(Pc = forcats::fct_relevel(Pc, sort))
# 
#     if( any(wrong_format) ) {
#       warning(stringr::str_c(c("Wrong numbers formats were turned to NA :\n",
#                                rep(", ", length(which_wrong_format) -1)),
#                              "\"", which_wrong_format, "\""))
#     }
# 
#     PCS_list <- PCS_recodages %>% dplyr::filter(!!PCS_c %in% levels(dplyr::pull(data_ok, Pc)) ) %>%
#       dplyr::arrange(!!PCS_c)
# 
#     # Vérifier que les vecteurs sont égaux :
#     levels_not_found <- !levels(dplyr::pull(data_ok, Pc)) %in% dplyr::pull(PCS_list, !!PCS_c)
#     if ( any(levels_not_found) ) {
#       which_levels_not_found <-
#         levels(dplyr::pull(data_ok, Pc))[which(levels_not_found)]
#       stop(stringr::str_c(c("Some levels were not found in the Excel file :\n",
#                             rep(", ", length(which_levels_not_found) -1)), "\"",
#                           which_levels_not_found, "\"") )
#     }
# 
#     PCS_list %<>%
#       dplyr::mutate(PUB = as.factor(PUB) %>%
#                       forcats::fct_recode(":1" = "1", ":2" = "2") %>%
#                       forcats::fct_explicit_na("") ) %>%
#       dplyr::mutate(code = stringr::str_c(!!PCS_c, PUB))
# 
#     no_emp_code <- dplyr::pull(PCS_list, !!PCS_c)[which( !stringr::str_detect(PCS_list$PUB, ":") )]
# 
#     #PCS_list$code %>% as.factor %>% levels
# 
#     data_ok <- data_ok %>%
#       dplyr::mutate(!!EMP := fct_replace(!!EMP, "^(.).+", "\\1") %>% forcats::fct_explicit_na("2") ) %>%
#       dplyr::mutate(Pc = forcats::fct_cross(Pc, !!EMP, keep_empty = TRUE) %>% forcats::fct_relevel(sort) )
# 
#     Pc_EMP_crosslevels <- data_ok %>% dplyr::pull(Pc) %>% levels()
# 
#     PCS_list_crosslevels <- PCS_list$code %>%
#       purrr::map_if(!stringr::str_detect(., ":"), ~ rep(., 2)) %>% purrr::flatten_chr() %>% sort()
# 
#     crosslevel_not_found <-
#       ! stringr::str_sub(Pc_EMP_crosslevels, 1, 4) == stringr::str_sub(PCS_list_crosslevels, 1, 4)
# 
#     if ( any(crosslevel_not_found) ) {
#       which_crosslevel_not_found <- Pc_EMP_crosslevels[crosslevel_not_found]
#       stop(stringr::str_c(c("Problem while coding public/private :\n
#                    crosslevel not found in Excel file :\n",
#                             rep(", ", length(which_crosslevel_not_found) -1)), "\"",
#                           which_crosslevel_not_found, "\"") )
#     }
# 
#     if ( length(Pc_EMP_crosslevels) != length(PCS_list_crosslevels) ) {
#       stop("Problem while coding public/private : \n
#            crosslevels are not the same length in database and Excel file")
#     }
# 
#     Pc_EMP_PCS_list_mixed_crosslevels <-
#       stringr::str_c(stringr::str_sub(Pc_EMP_crosslevels, 1, 4),
#                      stringr::str_remove(PCS_list_crosslevels, "^.{4}"))
# 
#     mixed_crosslevel_not_found <-
#       Pc_EMP_PCS_list_mixed_crosslevels != PCS_list_crosslevels
#     if ( any(mixed_crosslevel_not_found) ) {
#       which_mixed_crosslevel_not_found <- Pc_EMP_crosslevels[mixed_crosslevel_not_found]
#       stop(stringr::str_c(c("Problem while coding public/private :\n
#                    crosslevel not corresponding in database and Excel file :\n",
#                             rep(", ", length(which_mixed_crosslevel_not_found) -1)), "\"",
#                           which_mixed_crosslevel_not_found, "\"") )
#     }
# 
#     data_ok <- data_ok %>% dplyr::mutate(Pc = `levels<-`(Pc, Pc_EMP_PCS_list_mixed_crosslevels))
# 
#     if (only_numbers == FALSE) {
#       data_ok <- data_ok %>%
#         dplyr::mutate(!!result4      := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR4      = stringr::str_c(PR4_chiffre, "-", PR4_nom                  )), PR4     ) ),
#                       !!result4_ord  := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR4_ord  = stringr::str_c(PR3_chiffre, "_", PR4_chiffre, "-", PR4_nom)), PR4_ord ) ),
#                       !!result3_long := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR3_long = stringr::str_c(PR3_chiffre, "-", PR3_nom                  )), PR3_long) ),
#                       !!result2_long := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR2_long = stringr::str_c(PR2_chiffre, "-", PR2_nom                  )), PR2_long) ),
#                       !!result1_long := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR1_long = stringr::str_c(PR1_chiffre, "-", PR1_nom                  )), PR1_long) ),
#                       !!result0_long := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR0_long = stringr::str_c(PR0_chiffre, "-", PR0_nom                  )), PR0_long) ),
#                       !!result3      := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR3      = stringr::str_c(PR3_chiffre, "-", PR3_nom_abrev            )), PR3     ) ),
#                       !!result2      := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR2      = stringr::str_c(PR2_chiffre, "-", PR2_nom_abrev            )), PR2     ) ),
#                       !!result1      := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR1      = stringr::str_c(PR1_chiffre, "-", PR1_nom_abrev            )), PR1     ) ),
#                       !!result0      := `levels<-`(Pc, dplyr::pull(dplyr::mutate(PCS_list, PR0      = stringr::str_c(PR0_chiffre, "-", PR0_nom_abrev            )), PR0     ) )
#         ) %>%
#         dplyr::mutate_if(is.factor, ~ forcats::fct_relevel(., sort))
# 
#       data_ok <- data_ok %>%
#         dplyr::select(!!result4,  !!result4_ord,  !!result3,  !!result3_long,  !!result2,
#                       !!result2_long, !!result1,  !!result1_long,  !!result0,  !!result0_long)
# 
#       data %<>%
#         dplyr::select(-tidyselect::any_of(c(result4,  result4_ord,  result3,  result3_long,  result2,
#                                             result2_long, result1,  result1_long,  result0,  result0_long))) %>%
#         dplyr::bind_cols(data_ok)
# 
#     } else {
#       data_ok <- data_ok %>%
#         dplyr::mutate(!!result4 := `levels<-`(Pc, dplyr::pull(PCS_list, PR4_chiffre) ),
#                       !!result3 := `levels<-`(Pc, dplyr::pull(PCS_list, PR3_chiffre) ),
#                       !!result2 := `levels<-`(Pc, dplyr::pull(PCS_list, PR2_chiffre) ),
#                       !!result1 := `levels<-`(Pc, dplyr::pull(PCS_list, PR1_chiffre) ),
#                       !!result0 := `levels<-`(Pc, dplyr::pull(PCS_list, PR0_chiffre) )
#         ) %>%
#         dplyr::mutate_if(is.factor, ~ forcats::fct_relevel(., sort))
# 
#       data_ok <- data_ok %>%
#         dplyr::select(!!result4,  !!result3,  !!result2, !!result1, !!result0)
# 
#       data %<>%
#         dplyr::select(-tidyselect::any_of(c(!!result4,  !!result3,  !!result2, !!result1, !!result0))) %>%
#         dplyr::bind_cols(data_ok)
#     }
# 
#     return(data)
# 
#     #data %>% tabw(!!PROF, PR4) %>% tabxl()
#   }









# data <- emploi_data_list[["ee2013_18"]] %>% dplyr::select(PRI0, EMP)
# EMP = rlang::expr(EMP)
# nb_min = 1000
# var <- rlang::expr(PRI0)
# feminiser = TRUE
# PCS_employeurs_fem_sheet <- PCS_employeurs_fem[[4]]

# data <- ct2013s %<>% select(-any_of(ends_with("_EMP")), -any_of(ends_with("_EMP_ord")))
# var <- rlang::expr(PRI3)
# EMP <- rlang::expr(EMP)
# nb_min <- 30
# feminiser <- TRUE
# PCS_employeurs_fem_sheet = PCS_employeurs_fem[[1]]


# Fontion pour décomposer les CSP par employeur :
# Collectivités locales (CL ou C), État (État ou E), Hôpitaux publics (HP ou H),
# Entreprises publiques (EP ou N),
# PME privées (PME ou P), Grandes entreprises privées (GE ou R)
# Particuliers (Part ou X), Indépendants (Ind ou Y)
#   Une fois renommées il s'agit des variables PE3, PE2, PE1 et PE0
recodage_PCS_EMP <- function(data, var, EMP = EMP, nb_min = 30,
                                  feminiser = FALSE, PCS_employeurs_fem_sheet) {
  data <- data
  var <- rlang::enquo(var)
  EMP <- rlang::enquo(EMP)

  # PCS_employeurs_fem <-
  #   list(read_xlsx("01-Scripts et workspaces\\Nomenclature PCS-employeurs FEM (EE14_18).xlsx", sheet = 1),
  #        read_xlsx("01-Scripts et workspaces\\Nomenclature PCS-employeurs FEM (EE14_18).xlsx", sheet = 2),
  #        read_xlsx("01-Scripts et workspaces\\Nomenclature PCS-employeurs FEM (EE14_18).xlsx", sheet = 3),
  #        read_xlsx("01-Scripts et workspaces\\Nomenclature PCS-employeurs FEM (EE14_18).xlsx", sheet = 4) ) %>%
  #   purrr::map(~dplyr::select(., 1:2))

  data_ok <- data %>% dplyr::select(!!var, !!EMP)

  result1 <- stringr::str_c(rlang::as_label(var),"_EMP")
  result2 <- stringr::str_c(rlang::as_label(var),"_EMP_ord")

  data_ok <- data_ok %>%
    dplyr::mutate(nb_char_for_dash = dplyr::pull(tibble::as_tibble(
      stringr::str_locate(!!var, "-")), .data$start)) %>%
    dplyr::mutate(var_c = stringr::str_sub(!!var, 1, nb_char_for_dash - 1),
                  var_n = stringr::str_sub(!!var, nb_char_for_dash + 1, -1)) %>%
    # dplyr::mutate(var_c = dplyr::case_when(stringr::str_length(var_c) < 3 ~ stringr::str_c(var_c, "_"),
    #                          stringr::str_length(var_c) >= 3 ~ var_c    )) %>%
    dplyr::mutate(EMPabr = dplyr::case_when(
      !!EMP == "1-Collectivités locales"          ~ "CL",
      !!EMP == "2-État"                           ~ "État",
      !!EMP == "3-Hôpitaux publics"               ~ "HP",
      !!EMP == "4-Entreprises publiques"          ~ "EP",
      stringr::str_detect(!!EMP, "^5-.*PME")               ~ "PME",
      stringr::str_detect(!!EMP, "^6-Grandes entreprises") ~ "GE",
      stringr::str_detect(!!EMP, "^7-Ent")                 ~ "EntI", #Ent taille inconnue
      !!EMP == "8-Particuliers"                   ~ "Part",
      !!EMP == "I-Pas d'employeur"                ~ "Ind"  ) ) %>%
    dplyr::mutate(EMPcode =  dplyr::case_when(
      !!EMP == "1-Collectivités locales"          ~ "C",
      !!EMP == "2-État"                           ~ "E",
      !!EMP == "3-Hôpitaux publics"               ~ "H",
      !!EMP == "4-Entreprises publiques"          ~ "N",
      stringr::str_detect(!!EMP, "^5-.*PME")               ~ "P",
      stringr::str_detect(!!EMP, "^6-Grandes entreprises") ~ "R",
      stringr::str_detect(!!EMP, "^7-Ent")                 ~ "T",   #Ent taille inconnue
      !!EMP == "8-Particuliers"                   ~ "X",
      !!EMP == "I-Pas d'employeur"                ~ "Y"  ) )


  data_ok <- data_ok %>%
    dplyr::group_by(!!var, EMPabr) %>%
    dplyr::mutate(effectifs_Etat = ifelse(EMPabr == "État", n(), NA),
                  effectifs_CL   = ifelse(EMPabr == "CL"  , n(), NA),
                  effectifs_HP   = ifelse(EMPabr == "HP"  , n(), NA),
                  effectifs_EP   = ifelse(EMPabr == "EP"  , n(), NA),
                  effectifs_PME  = ifelse(EMPabr == "PME" , n(), NA),
                  effectifs_GE   = ifelse(EMPabr == "GE"  , n(), NA),
                  effectifs_EntI = ifelse(EMPabr == "EntI", n(), NA),
                  effectifs_Part = ifelse(EMPabr == "Part", n(), NA),
                  effectifs_Ind  = ifelse(EMPabr == "Ind" , n(), NA)
    ) %>%
    dplyr::mutate(enough_Etat = ifelse((effectifs_Etat < nb_min)|is.na(effectifs_Etat), FALSE, TRUE),
                  enough_CL   = ifelse((effectifs_CL   < nb_min)|is.na(effectifs_CL)  , FALSE, TRUE),
                  enough_HP   = ifelse((effectifs_HP   < nb_min)|is.na(effectifs_HP)  , FALSE, TRUE),
                  enough_EP   = ifelse((effectifs_EP   < nb_min)|is.na(effectifs_EP)  , FALSE, TRUE),
                  enough_PME  = ifelse((effectifs_PME  < nb_min)|is.na(effectifs_PME) , FALSE, TRUE),
                  enough_GE   = ifelse((effectifs_GE   < nb_min)|is.na(effectifs_GE)  , FALSE, TRUE),
                  enough_EntI = ifelse((effectifs_EntI < nb_min)|is.na(effectifs_EntI), FALSE, TRUE),
                  enough_Part = ifelse((effectifs_Part < nb_min)|is.na(effectifs_Part), FALSE, TRUE),
                  enough_Ind  = ifelse((effectifs_Ind  < nb_min)|is.na(effectifs_Ind) , FALSE, TRUE),
    ) %>% dplyr::ungroup() %>%
    dplyr::group_by(!!var) %>%
    dplyr::mutate(enough_Etat = any(enough_Etat),
                  enough_CL = any(enough_CL),
                  enough_HP = any(enough_HP),
                  enough_EP = any(enough_EP),
                  enough_PME = any(enough_PME),
                  enough_GE = any(enough_GE),
                  enough_EntI = any(enough_EntI),
                  enough_Part = any(enough_Part),
                  enough_Ind  = any(enough_Ind)
    ) %>% dplyr::ungroup() %>%
    dplyr::mutate(only_one = dplyr::case_when(
      enough_Etat == T & enough_CL == F & enough_HP == F & enough_EP == F & enough_PME == F & enough_GE == F & enough_EntI == F & enough_Part == F & enough_Ind == F ~ "E",
      enough_Etat == F & enough_CL == T & enough_HP == F & enough_EP == F & enough_PME == F & enough_GE == F & enough_EntI == F & enough_Part == F & enough_Ind == F ~ "C",
      enough_Etat == F & enough_CL == F & enough_HP == T & enough_EP == F & enough_PME == F & enough_GE == F & enough_EntI == F & enough_Part == F & enough_Ind == F ~ "H",
      enough_Etat == F & enough_CL == F & enough_HP == F & enough_EP == T & enough_PME == F & enough_GE == F & enough_EntI == F & enough_Part == F & enough_Ind == F ~ "N",
      enough_Etat == F & enough_CL == F & enough_HP == F & enough_EP == F & enough_PME == T & enough_GE == F & enough_EntI == F & enough_Part == F & enough_Ind == F ~ "P",
      enough_Etat == F & enough_CL == F & enough_HP == F & enough_EP == F & enough_PME == F & enough_GE == T & enough_EntI == F & enough_Part == F & enough_Ind == F ~ "R",
      enough_Etat == F & enough_CL == F & enough_HP == F & enough_EP == F & enough_PME == F & enough_GE == F & enough_EntI == T & enough_Part == F & enough_Ind == F ~ "T",
      enough_Etat == F & enough_CL == F & enough_HP == F & enough_EP == F & enough_PME == F & enough_GE == F & enough_EntI == F & enough_Part == T & enough_Ind == F ~ "X",
      enough_Etat == F & enough_CL == F & enough_HP == F & enough_EP == F & enough_PME == F & enough_GE == F & enough_EntI == F & enough_Part == F & enough_Ind == T ~ "Y"
    )
    )


  data_ok <- data_ok %>%
    dplyr::mutate(
      result_c1 = as.factor(dplyr::case_when( #C'est le chiffre des variables _EMP / PEx
        (EMPabr == "État" & enough_Etat == T) |
          (EMPabr == "CL" & enough_CL == T) |
          (EMPabr == "HP" & enough_HP == T) |
          (EMPabr == "EP" & enough_EP == T) |
          (EMPabr == "PME" & enough_PME == T)|
          (EMPabr == "GE" & enough_GE == T)|
          (EMPabr == "EntI" & enough_EntI == T)|
          (EMPabr == "Part" & enough_Part == T)|
          (EMPabr == "Ind" & enough_Ind == T)    ~ stringr::str_c(var_c, EMPcode)
      )),
      result_c2 = dplyr::case_when( #C'est le chiffre des variables _EMP_ord / PEx_ord
        # !is.na(only_one) & EMPcode == only_one    ~ stringr::str_replace(
        #   PR3abr_c, "^(..).", stringr::str_c("\\1", only_one)),
        (EMPabr == "État" & enough_Etat == T) |
          (EMPabr == "CL" & enough_CL == T) |
          (EMPabr == "HP" & enough_HP == T) |
          (EMPabr == "EP" & enough_EP == T) |
          (EMPabr == "PME" & enough_PME == T)|
          (EMPabr == "GE" & enough_GE == T)|
          (EMPabr == "EntI" & enough_EntI == T)|
          (EMPabr == "Part" & enough_Part == T)|
          (EMPabr == "Ind" & enough_Ind == T)    ~ stringr::str_c(EMPcode, var_c)
      )
    )

  if (feminiser == FALSE) {
    data_ok <- data_ok %>% dplyr::mutate(      result_n = dplyr::case_when(
      # !is.na(only_one) & EMPcode == only_one     ~ PR3abr_n,
      (EMPabr == "État" & enough_Etat == T) |
        (EMPabr == "CL" & enough_CL == T) |
        (EMPabr == "HP" & enough_HP == T) |
        (EMPabr == "EP" & enough_EP == T) |
        (EMPabr == "PME" & enough_PME == T)|
        (EMPabr == "GE" & enough_GE == T)|
        (EMPabr == "EntI" & enough_EntI == T)|
        (EMPabr == "Part" & enough_Part == T)|
        (EMPabr == "Ind" & enough_Ind == T)    ~ stringr::str_c(var_n, " ", EMPabr)
    ))

    data_ok <- data_ok %>%
      dplyr::mutate(result_n = stringr::str_remove_all(result_n, " FP")) %>%
      #dplyr::mutate(result_n = stringr::str_remove_all(result_n, "\\(f[+-~]\\)")) %>%
      dplyr::mutate(result_n = stringr::str_replace_all(result_n, " +", " ")) %>%
      dplyr::mutate(!!result1 := stringr::str_c(result_c1, "-", result_n),
                    !!result2 := stringr::str_c(result_c2, "-", result_n)
      )


  } else { # If feminiser = TRUE
    PCS_employeurs_fem_sheet %<>%
      dplyr::filter_at(1, ~ . %in% levels(dplyr::pull(data_ok, result_c1)) )

    unfound_levels <-
      levels(dplyr::pull(data_ok, result_c1)) %>% .[! . %in% dplyr::pull(PCS_employeurs_fem_sheet, 1)]

    if(!rlang::is_empty(unfound_levels)) {
      warning(stringr::str_c("Level not found in Excel file turned to NA : ", unfound_levels) )
      data_ok <- data_ok %>% dplyr::mutate(result_c1 = fct_to_na(result_c1, unfound_levels) )
    }

    noms_fem_sheet <- PCS_employeurs_fem_sheet %>% names()
    PCS_employeurs_fem_sheet %<>%
      dplyr::mutate(!!rlang::sym(noms_fem_sheet[1]) := stringr::str_c(!!rlang::sym(noms_fem_sheet[1]), "-",
                                                                      !!rlang::sym(noms_fem_sheet[2])))

    data_ok <- data_ok %>%
      dplyr::mutate(result_c1 = `levels<-`(result_c1, dplyr::pull(PCS_employeurs_fem_sheet, 1))) %>%
      dplyr::mutate(result_c2 = stringr::str_c(result_c2, stringr::str_remove(result_c1, "^[^-]+")))

    data_ok <- data_ok %>%
      dplyr::mutate(!!result1 := result_c1,
                    !!result2 := result_c2)


  }

  data_ok <- data_ok %>%
    dplyr::mutate_at(dplyr::vars(!!result1, !!result2), ~ as.factor(dplyr::case_when(
      !is.na(.) ~ as.character(.),
      is.na(.) & !is.na(!!var) ~ "Z-Autres"
    ))) %>%
    dplyr::select(!!result1, !!result2)

  data %>% dplyr::bind_cols(data_ok)
}





# DGAFP La nomenclature FaPFP de familles de métiers de la fonction publique
#Annexe 3 : Programme SAS de création de la nomenclature FaPFP à partir des codes PCS
recodages_FaPFP <- 
  function(data, profession, admin_ent, 
           nomenclaturePCS = c("2003", "1982", "2020") ) {
    profession <- rlang::ensym(profession)
    admin_ent <- rlang::ensym(admin_ent)
    data_ok <- data %>% dplyr::select(!!profession, !!admin_ent)
    
        if (nomenclaturePCS[1] == "2003") {
      PCS_format <-  "^\\d{3}[[:upper:]]$"
    } else if (nomenclaturePCS[1] == "1982") {
      PCS_format <-   "^\\d{4}$"
    } else {
      stop('Version de la nomenclature des PCS (1982, 2003) non précisée')
    }
    
    
    data_ok <- data_ok %>% 
      dplyr::mutate(PE = tabxplor:::fct_replace(!!profession, "^(.{4}).+", "\\1") )
    
    levels <- data_ok %>% 
      dplyr::pull(PE) %>% levels() %>% purrr::set_names(stringr::str_to_upper(.))
    
    data_ok <- data_ok %>% 
      dplyr::mutate_at("PE", ~ forcats::fct_recode(., !!!levels))
    
    wrong_format <- data_ok %>% dplyr::pull(PE) %>% levels() %>%
      stringr::str_detect(PCS_format, negate = TRUE)
    which_wrong_format <- levels(dplyr::pull(data_ok, PE))[wrong_format]
    
    data_ok <- data_ok %>%
      dplyr::mutate(PE = tabxplor:::fct_detect_replace(PE, PCS_format, "NULL", negate = TRUE) ) %>%
      dplyr::mutate(PE = forcats::fct_relevel(PE, sort))
    
    if( any(wrong_format) ) {
      warning(stringr::str_c(c("Wrong numbers formats were turned to NA :\n",
                               rep(", ", length(which_wrong_format) -1)),
                             "\"", which_wrong_format, "\""))
    }
    
    
    if (nomenclaturePCS[1]  == "2003") {
      data_ok <- data_ok %>% 
        dplyr::mutate(FaPFP = as.factor(dplyr::case_when(
          
          ! stringr::str_detect(!!admin_ent, "^1") |
            #/*France télécom, la Poste exclus*/
            PE %in% c("333C", "333D", "451A", "451B", "521A", "521B") 
          ~ NA_character_,
          
          #/*ADMINISTRATION*/
          PE %in% c("331A", "333E", "333F", "372F", "375B", "376G", "451E", "451F", "461A",
                    "461F", "464B", "523A", "524A", "542A", "542B", "372C", "372D", "461E", "372B", "387B",
                    "461D", "477A", "543A", "541A", "541D", "335A", "441A", "441B", "312C", "312D", "313A",
                    "333C", "333D", "371A", "373A", "373B", "373C", "373D", "451A", "451B", "521A", "521B",
                    "543A", "543D", "374A", "374B", "375A", "462A", "462B", "462C", "462D", "462E",
                    "463A", "463B", "463C", "463D", "463E", "464A","487A", "546B", "551A", "552A", "553A",
                    "554A", "554B", "554C", "554H", "554D", "554E", "554F", "554G", "554J","555A", "556A",
                    "653A","374C", "374D") 
          ~ "01-Administration",
          #/*FINANCES PUBLIQUES*/
          PE %in% c("333B", "451C", "522A", "372A", "376B", "376C", "376D", "376E",
                    "376F", "467A", "467B", "467C", "467D", "545A", "545B", "545C", "545D", "376A") 
          ~"02-Finances publiques",
          #/*JUSTICE*/
          PE %in% c("312A", "312B", "333A", "372E")
          ~"03-Justice",
          #/*TECHNIQUE, INFORMATIQUE, TRANSPORTS*/
          PE %in% c("544A", "388A", "388B", "388C", "388D", "388E", "478A", "478B",
                    "478C", "478D", "383A", "383B", "383C", "473A", "473B", "473C", "482A", "622A", "622B",
                    "622G", "672A", "384A", "384B", "384C", "474A", "474B", "474C", "483A", "623A", "623B",
                    "623C", "623F", "623G", "624D", "624E", "624A", "624F", "624G", "628C", "634B", "673A",
                    "673B", "673C", "682A", "385A", "385B", "385C", "475A", "475B", "476A", "484A", "484B",
                    "625A", "625B", "625C", "625D", "625E", "625H", "626A", "626B", "628D", "628F", "637A",
                    "674A", "674B", "674C", "674E", "386A", "386E", "476B", "485B", "626C", "627A", "627B",
                    "627C", "627D", "627E", "627F", "635A", "674D", "675A", "675B", "675C", "652A", "652B",
                    "676A", "676B", "676C", "487B", "386D", "387F", "477D", "485A", "621G", "332A", "332B",
                    "311E", "387A", "387C", "387D", "479B", "628G", "637D", "676E", "685A", "312E", "312F",
                    "312G", "380A", "389A", "389B", "389C", "451D", "466A", "466B", "466C", "526E", "546A",
                    "546C", "546D", "546E", "641A", "641B", "642A", "642B", "643A", "644A", "651A", "651B",
                    "654A", "655A", "656A", "676D")
          ~"04-Technique",
          #/*SECURITE, DEFENSE*/
          PE %in% c("334A", "452A", "452B", "531A", "531B", "531C", "532A", "532B",
                    "532C", "533A", "533C", "534A", "534B", "5300")
          ~"05-Securite",
          #/*EDUCATION, FORMATION, RECHERCHE*/
          PE %in% c("341A", "342A", "421A", "421B", "422A", "422B", "422C", "341B",
                    "343A", "422D", "422E", "342E", "479A", "423A", "423B", "4200")
          ~"06-Éducation_recherche",
          #/*SPORTS ET LOISIRS, ANIMATION, CULTURE*/
          PE %in% c("351A", "425A", "352A", "353A", "353B", "353C", "465B", "637C",
                    "352B", "354A", "354B", "354C", "354D", "465A", "637B", "465C", "435A", "435B","424A",
                    "354G")
          ~"07-Sport, animation, culture",
          #/*BATIMENT, TRAVAUX PUBLICS*/
          PE %in% c("382A", "382B", "382C", "382D", "472A", "472B", "472C", "472D",
                    "481A", "481B", "621A", "621B", "621C", "621D", "621E", "621F", "632A", "632B", "632C",
                    "632D", "632E", "632F", "632G", "632H", "632J","633A", "671A", "671B", "681A", "681B")
          ~"08-BTP",
          #/*ENTRETIEN, MAINTENANCE*/
          PE %in% c("387E", "477B", "477C", "486A", "486D", "486E", "525A", "525B",
                    "525C", "525D", "525D", "628A", "628B", "628E", "632K","633B", "633C", "633D", "634A",
                    "634C", "634D", "684A", "684B")
          ~"09-Entretien, maintenance",
          #/*SOINS*/
          PE %in% c("311C", "311D", "344A", "344B", "344C", "344D", "431A", "431B",
                    "431D", "431E", "431F", "432B", "432D", "433A", "433B", "433C", "433D", "526A", "526B",
                    "526D", "311B") 
          ~"10-Soins",
          #/*SERVICES A LA PERSONNE, RESTAURATION*/
          PE %in% c("377A", "468A", "468B", "488A", "488B", "561A", "561D", "561E",
                    "561F", "636A", "636B", "636C", "636D", "683A", "431C", "526C", "562A", "562B", "563A",
                    "563B", "563C", "564A", "564B") 
          ~"11-Services_personne",
          PE %in% c("434A", "434B", "434C", "434D", "434E", "434F", "434G")
          
          ~"12-Action_sociale",
          #/*ESPACES VERTS ET PAYSAGES*/
          PE %in% c("381A", "471A", "471B", "480A", "480B", "533B", "631A", "691A",
                    "691B", "691C", "691D", "691E", "691F", "692A")
          ~"13-Espaces_verts_paysages",
        )))
      
    } else {
      stop("Pas implémenté pour les nomenclatures différentes de PCS 2003")
    }
    
    data_ok <- data_ok %>% dplyr::select(FaPFP)
    
    data <- data %>% dplyr::select(-tidyselect::any_of("FaPFP")) %>% 
      dplyr::bind_cols(data_ok)
    return(data)
    
  }


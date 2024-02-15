
# source("01-Scripts et workspaces\\Demarrage.R")
# load("01-Scripts et workspaces\\Recodages CSP\\Emploi82_18_fem.RData")

# data <- emploi82_18_fem %>% filter(ANNEE %in% 2009:2018) %>% select(-any_of(c("PPP1", "PPP2", "PPP3", "PPP4", "FAPPP")))
# profession <- expr(P)
# admin_ent <- expr(EMP_ADM_ENT)
# sexe = expr(SEXE)
# sexe_wt = expr(EXTRI)
# nomenclaturePCS <- "2003"
# sexeEE = 2015:2018

# rec1 <- pcspp(data, P, EMP_ADM_ENT, sexeEE = 2009:2018)
# rec2 <- pcspp(data, P, EMP_ADM_ENT, sexe = SEXE)
# rec3 <- pcspp(data, P, EMP_ADM_ENT, sexe = SEXE, sexe_wt = EXTRI)
# rec4 <- pcspp(data, P, EMP_ADM_ENT, masculiniser = TRUE)
# rec5 <- pcspp(data, P, EMP_ADM_ENT, gender_sign = FALSE)
# 
# rec1$PPP1 %>% levels()
# rec2$PPP1 %>% levels()
# rec3$PPP1 %>% levels()
# rec4$PPP1 %>% levels()
# rec5$PPP1 %>% levels()


# À éventuellement changer : 
#Rien à faire dans "2E2-INGÉNIEURS" :
#"372A-Cadres chargés d'études économiques, financières, commerciales"

# TOTAL 4I1-ENSEIGNANT·ES
# "422E-Surveillants et aides-éducateurs des établissements d'enseignement"

# "2D28-Cadres d’entreprise autres" = documentation + classés FP

# "5G21-Sous-officiers des Armées (et de la Gendarmerie)" Passer en 3 ?

# "3B1-CBS COMMERCE"
# 4 "467A-Chargés de clientèle bancaire" du public !

# TOTAL 3E1-MAÎTRISE
# 4 "468A-Maîtrise de restauration : salle et service" du public



# data <- ct2016
# profession <- expr(PE)
# admin_ent <- expr(EMP_ADM_ENT)
# sexe = expr(SEXE)
# sexe_wt = expr(pondcal)
# nomenclaturePCS <- "2003"
# sexeEE = 2015:2018
# threshold = c(33.3, 66.6)
# gender_sign = TRUE
# masculiniser = FALSE




#' PCS recodées pour comparatisme public-privé
#' @description Ces PCS recodées visent à faciliter la comparaison entre public et privé. 
#' Il s'agit de construire des familles de métier comparables entre fonction publique 
#' et entreprises : les professions classées « Administration publique » par la 
#' nomenclature FAP sont ventilées dans les familles professionnelles du secteur marchand,
#' en s'inspirant des familles de métiers de la fonction publique. Nous distinguons ainsi 
#' différentes filières, commerciale, financière, administrative, technique, santé, etc., 
#' au sein desquelles une hiérarchie de métiers peut être comparée entre administrations 
#' et entreprises. Les professionnels reconnus comme les médecins, les infirmières ou 
#' les enseignantes sont distingués des cols blancs (de niveau cadre ou de 
#' niveau subalerne), car leur proportion s'avère très différence dans les entreprises
#' et dans les administrations. Certaines recommandations du Conseil national de 
#' l'information statistique sont prises en compte (Amossé, Chardon et Eidelman, 2019) :
#' des "professions intermédiaires" de la fonction publique, classées A et apparentées 
#' aux cadres du point du vue du diplôme et/ou du salaire, passent notamment au niveau
#' de qualification supérieur (cadres de santé, cadres du social, cadres de l’armée).
#' La règle de féminisation des noms de professions suivante est adoptée par défaut :
#' masculin s’il y a plus de deux tiers d’hommes dans une profession ; féminin s’il y a 
#' plus de deux tiers de femmes ; forme inclusive s’il y a entre 33% et 66% de femmes. 
#' La féminisation n'est donc pas utilisées à des fins politiques d'inclusion symbolique, 
#' mais pour transmettre de l’information sociologique en rendant visible la place des 
#' femmes dans la structure sociale. 
#' @param data La base de données à partir de laquelle recoder les PCS. 
#' @param profession Le nom de la variable professions détaillées. Souvent `P` ou `PE` 
#' dans les bases fournies par l'INSEE. 
#' @param admin_ent Le nom d'une variable binaire avec deux modalités permettant de
#'  différencier secteur marchand et secteur public administratifs : la première modalité
#'  doit correspondre aux administrations publiques, et la seconde au secteur de droit 
#'  privé. Attention à ne pas inclure les entreprises publiques parmi les administrations.
#' @param nomenclaturePCS Quelle version de la nomemclature PCS la variable professions 
#' utilise-t-elle ? 2003 par default, 1982 possible, 2020 non encore disponible. 
#' @param sexeEE Par default, si aucune variable `sexe` n'est précisée, le calcul du taux
#' de féminisation est réalisé à partir de tableaux issus des enquêtes Emploi empilées 
#' sur 1982-2018. Il est alors possible de sélectionner une année parmi celles disponsibles, 
#' ou de faire la moyenne sur plusieurs années, en renseignant une suite de nombre entiers 
#' (integer vector). Par défault `2015:2018` (2015 à 2018). 
#' @param sexe Une seconde possibilité est de fournir le nom d'une variable sexe présente 
#' dans la base de données pour calculer le taux de féminisation. Pour être détectées les
#' modalités de variables doivent contenir les chaînes de caractères "hemme"/"homme", 
#' "masculin"/"féminin" ou "man"/"woman". 
#' @param sexe_wt Si une variable `sexe` est fournie, il est possible de fournir le nom 
#' de la variable de pondération à utiliser. 
#' @param masculiniser Mettre sur `TRUE` pour ne choisir que des noms de professions 
#' masculins.
#' @param threshold Les seuils à utiliser pour calculer le taux de féminisation, sous 
#' la forme d'une vecteur numérique de taille 1 ou 2. Le premier élément est le seuil 
#' en-dessous duquel les noms de professions sont conjugués au masculin (par default 33.3%). 
#' Le second élément est le seuil en-dessus duquel ils sont conjugués au féminin 
#' (par default 66.6%). Entre les deux seuils, l'écriture inclusive avec point médian est 
#' utilisée. Pour empêcher ce comportement, il est possible de ne préciser qu'un seul seuil.
#' @param gender_sign Par default, ajoute les symboles male et femelle lorsque le nom 
#' d'une profession ou d'une CSP est épicène. Mettre sur `FALSE` pour éviter ce 
#' comportement.
#' @param ESE Par defaut, pour la PCS 2003, les catégories spécifiques aux PCS-ESE 
#' sont repérées. Mettre sur `FALSE` pour les supprimer.
#'
#' @return La base de donnée de départ sous forme de `tibble`, avec cinq nouvelles 
#' variables correspondant aux différents niveaux des PCS publiques-privées :
#' * `PPP1` : le niveau agrégé (en 7 modalités) distingue "Chefs d’entreprise", "Cadres",
#' "Cols blancs subalternes", "Professionnel·les reconnu·es", "Employées", "Ouvriers"
#' et "Agriculteurs et ouvriers agricoles". Les consultants libéraux, professions libérales,
#' artisans des services, petits commerçants, artisans ouvriers, ont été classés dans 
#' les catégories desquelles ils sont les plus proches du point de vue du revenu moyen, 
#' du niveau de diplôme et du contenu de l'activité. Pour les enlever de l'analyse il est 
#' nécessaire de filter les non-salariés.
#' * `FAPPP` : les 11 filières professionnelles utilisées pour comparer public et privé.
#' * `PPP2` : le niveau le plus détaillé (45 modalités) auquel il est possible de 
#' constituer des catégories à la fois suffisamment homogène et regroupant salariés du 
#' public et  salariés du privé. Il suffit alors de croiser la variable `PPP2` avec une 
#' variable employeur dans un tableau pour effectuer une comparaison. Croisée avec les 
#' filières professionnelles `FAPPP`, elle fait apparaître leurs hiérarchies internes. 
#' * `PPP3` : ce niveau situé entre les CSP et les professions (171 modalités) fait 
#' apparaitre des professions appartenant aux administrations publiques et d'autres
#' appartenant au secteur marchand. 
#' * `PPP4` : les professions détaillées recodées au niveau le plus fin (459 modalités), 
#' séparées entre administrations publiques et secteur marchand (pas encore de 
#' féminisation personnalisable à ce niveau : celle adoptée est basée sur les chiffres de 
#' l'enquête Emploi 2014-2018).
#' 
#' @export
#'
# @examples
pcspp <-
  function(data, profession, admin_ent, 
           nomenclaturePCS = c("2003", "1982", "2020"),
           sexeEE = 2015:2018, sexe, sexe_wt, threshold = c(33.3, 66.6), gender_sign = TRUE, #varprefix = "PR",
           masculiniser = FALSE, ESE = FALSE
           #mélanger_independants_et_salaries = FALSE, only_numbers = FALSE
  ) {
    
    stopifnot(is.integer(sexeEE) & all(sexeEE %in% 1982:2018))
    sexeEE <- as.character(sexeEE)
    threshold <- sort(vctrs::vec_recycle(vctrs::vec_cast(threshold, double()), 2))
    
    # Create a new professions variable PPP4 from professions and enterprises/admin -------
    #First, we create a new variable with professions separated between merchant sector 
    # and public administrations: levels must be the same for 1982 and 2003 version of PCS.
    # It gives us a 3 digits and two letters profession code PPP4. 
    to_PPP4_both <- 
      switch(nomenclaturePCS[1],
             "2003" = c(
               '311a' = '4F41a', '311b' = '4F41b', '311c' = '4F41c', '311e' = '4F41d', '344b' = '4F41e', 
               '344a' = '4F10a', '344c' = '4F10b', '431e' = '4F43a', '311f' = '4F44a', '344d' = '4F44b', 
               '311d' = '4F45a', '343a' = '4F45b', '342a' = '4I11a', '342e' = '4I12a', '421a' = '4I14a', 
               '421b' = '4I14a', '341a' = '4I13a', '422a' = '4I13b', '422b' = '4I13c', '422c' = '4I13d', 
               '422d' = '4I13e', '352b' = '4J11a', '354a' = '4J11b', '354b' = '4J11c', '354c' = '4J11d', 
               '354d' = '4J11d', '353c' = '4J12a', '354g' = '4J13a', '312a' = '4J21a', '312b' = '4J21b', 
               '312f' = '4J21c', '352a' = '4J22a', '333a' = '4J23a', '335a' = '4J24a', '312g' = '4J25a', 
               '313a' = '4J25b', '451d' = '2E23a', '452a' = '2G00b', '351a' = '2J01a', '376f' = '2D26a', 
               '333c' = '2D27a', '333d' = '2D27a', '431b' = '4F20a', '431c' = '4F20b', '431d' = '4F20c', 
               '431f' = '4F20d', '431g' = '4F20d', '432a' = '4F42a', '432b' = '4F42a', '432c' = '4F42a', 
               '432d' = '4F42a', '433a' = '3F30a', '433b' = '3F30a', '433c' = '3F30a', '433d' = '3F30b', 
               '434b' = '4I22a', '434c' = '4I23a', '434d' = '4I21a', '434e' = '4I21b', '434f' = '4I21c', 
               '434g' = '4I21d', '422e' = '4I13e', '423a' = '4I33a', '423b' = '4I33b', '424a' = '4I34a', 
               '435a' = '2I25a', '435b' = '4I32a', '441a' = '4I35a', '441b' = '4I35a', '451a' = '3D08a', 
               '451b' = '3D08a', '531a' = '5G10a', '531b' = '5G10a', '532a' = '5G22a', '532b' = '5G23a', 
               '532c' = '5G23b', '533a' = '5G24a', '531c' = '5G32a', '533b' = '5G32b', '523a' = '5D01a', 
               '524a' = '5D01a', '522a' = '5C01a', '545d' = '5D03a', '521a' = '5D04a', '521b' = '5D04a', 
               '554b' = '5B11a', '554c' = '5B11b', '554d' = '5B11c', '554e' = '5B11d', '554f' = '5B11e', 
               '554g' = '5B11f', '556a' = '5B11g', '526a' = '5F00a', '526b' = '5F00b', '526c' = '5F00c', 
               '526d' = '5F00d', '526e' = '5F00e', '562a' = '5H12d', '562b' = '5H12e', '533c' = '5G31a', 
               '534a' = '5G31a', '534b' = '5G31a', '541d' = '5D02a', '542b' = '5D02b', '551a' = '5B13a', 
               '552a' = '5B13b', '553a' = '5B12a', '554a' = '5B12b', '554h' = '5B12c', '554j' = '5B12d', 
               '555a' = '5B12e', '621g' = '6E10a', '621a' = '6E11a', '621b' = '6E11b', '621c' = '6E11c', 
               '621d' = '6E11d', '621e' = '6E11e', '621f' = '6E11f', '622a' = '6E12a', '622b' = '6E12b', 
               '622g' = '6E12c', '623a' = '6E13a', '623b' = '6E13b', '623c' = '6E13c', '623f' = '6E13d', 
               '623g' = '6E13e', '624a' = '6E13f', '624d' = '6E13g', '624e' = '6E13h', '624f' = '6E13i', 
               '624g' = '6E13j', '627e' = '6E14a', '627f' = '6E14b', '625a' = '6E15a', '625b' = '6E15b', 
               '625c' = '6E15b', '625d' = '6E15c', '625e' = '6E15d', '626a' = '6E15e', '626b' = '6E15e', 
               '626c' = '6E15f', '627a' = '6E16a', '627b' = '6E16b', '627c' = '6E16c', '627d' = '6E17a', 
               '628a' = '6E18a', '628b' = '6E18b', '628c' = '6E18c', '628d' = '6E18d', '625h' = '6E19a', 
               '628e' = '6E19b', '628f' = '6E19c', '628g' = '6E19d', '631a' = '6E21a', '632c' = '6E22a', 
               '632d' = '6E22b', '632a' = '6E23a', '632b' = '6E23b', '632e' = '6E23c', '632f' = '6E23d', 
               '632g' = '6E23e', '632h' = '6E23e', '632j' = '6E23f', '632k' = '6E23g', '633a' = '6E24a', 
               '633b' = '6E24b', '633c' = '6E24c', '633d' = '6E24d', '634a' = '6E25a', '634b' = '6E25b', 
               '634c' = '6E25c', '634d' = '6E25d', '635a' = '6E26a', '636a' = '6E27a', '636b' = '6E27b', 
               '636c' = '6E27c', '636d' = '6E27d', '637a' = '6E28a', '637b' = '6E28b', '637c' = '6E28c', 
               '637d' = '6E28d', '641a' = '6E31a', '641b' = '6E32a', '642a' = '6E33a', '642b' = '6E33b', 
               '644a' = '6E34a', '651a' = '6E34b', '651b' = '6E34b', '654a' = '6E34c', '652b' = '6E35a', 
               '656a' = '6E35b', '655a' = '6E36a', '671a' = '6E41a', '671b' = '6E41b', '672a' = '6E42a', 
               '673a' = '6E43a', '673b' = '6E43b', '673c' = '6E43c', '674a' = '6E44a', '674b' = '6E44b', 
               '674c' = '6E44c', '674d' = '6E44d', '674e' = '6E44e', '675a' = '6E45a', '675b' = '6E46a', 
               '675c' = '6E46b', '676d' = '6E46c', '676e' = '6E46d', '652a' = '6E51a', '653a' = '6E51a', 
               '676a' = '6E51a', '643a' = '6E52a', '676b' = '6E53a', '676c' = '6E53b', '681a' = '6E61a', 
               '681b' = '6E61b', '682a' = '6E62a', '683a' = '6E63a', '684a' = '6E64a', '684b' = '6E64b', 
               '685a' = '6E65a', '691a' = '7K20a', '691b' = '7K20b', '691c' = '7K20c', '691d' = '7K20d', 
               '691e' = '7K20e', '691f' = '7K20f', '692a' = '7K20g', '111a' = '7K13a', '111b' = '7K13b', 
               '111c' = '7K13c', '111d' = '7K13d', '111e' = '7K13e', '111f' = '7K13f', '211a' = '6E71a', 
               '211b' = '6E71b', '211c' = '6E71c', '211d' = '6E71c', '211e' = '6E71d', '211f' = '6E71e', 
               '211g' = '6E71f', '211h' = '6E71g', '211j' = '6E71g', '217c' = '5H21a', '217d' = '5H21b', 
               '217e' = '5H21c', '219a' = '5H21d', '224d' = '3B21d', '225a' = '3B21e', '231a' = '1A01a', 
               '121a' = '7K12a', '121b' = '7K12b', '121c' = '7K12c', '121d' = '7K12d', '121e' = '7K12e', 
               '121f' = '7K12f', '122a' = '7K12g', '122b' = '7K12h', '122c' = '7K12i', '212a' = '6E72a', 
               '212b' = '6E72b', '212c' = '6E72c', '212d' = '6E72c', '221a' = '3B21a', '221b' = '3B21b', 
               '222a' = '3B21c', '222b' = '5B22a', '223a' = '5B22b', '223b' = '5B22c', '223c' = '5B22d', 
               '223d' = '5B22e', '223e' = '5B22f', '223f' = '5B22g', '223g' = '5B22h', '223h' = '5B22i', 
               '226a' = '3B22a', '226b' = '3B22b', '226c' = '3B22c', '227a' = '3B22d', '227b' = '3B22e', 
               '227c' = '3B22f', '227d' = '3B22g', '232a' = '1A02a', '213a' = '6E73a', '224a' = '5H22a', 
               '224b' = '5H22b', '224c' = '5H22c', '233a' = '1A03a', '233b' = '1A03b', '233c' = '1A03c', 
               '233d' = '1A03d', '214a' = '6E74a', '214b' = '6E74b', '215a' = '6E75a', '215b' = '6E75b', 
               '215c' = '6E75c', '215d' = '6E75d', '216a' = '6E76a', '216b' = '6E76b', '216c' = '6E76c', 
               '217a' = '6E77a', '217b' = '6E77b', '218a' = '6E77c', '214c' = '6E78a', '214d' = '6E78b', 
               '214e' = '6E78c', '214f' = '6E78d', '131a' = '7K11a', '131b' = '7K11b', '131c' = '7K11c', 
               '131d' = '7K11d', '131e' = '7K11e', '131f' = '7K11f', '312c' = '2D23a', '312d' = '2D23b', 
               '312e' = '2E22a'), 
             
             "1982" = c(
               '3111' = '4F41a', '3112' = '4F41b', '3113' = '4F41c', '3115' = '4F41d', '3432' = '4F41e', 
               '3431' = '4F10a', '3434' = '4F10b', '4321' = '4F43a', '3116' = '4F44a', '3435' = '4F44b', 
               '3114' = '4F45a', '3433' = '4F45b', '3415' = '4I11a', '3421' = '4I12a', '4211' = '4I14a', 
               '4215' = '4I14a', '4214' = '4I14a', '3411' = '4I13a', '4221' = '4I13b', '4224' = '4I13c', 
               '3512' = '4J11a', '3531' = '4J11b', '3532' = '4J11c', '3535' = '4J11c', '3533' = '4J11d', 
               '3523' = '4J12a', '3522' = '4J12a', '3534' = '4J13a', '3121' = '4J21a', '3122' = '4J21b', 
               '3127' = '4J21c', '3511' = '4J22a', '3313' = '4J23a', '3318' = '4J24a', '3128' = '4J25a', 
               '3130' = '4J25b', '4521' = '2G00b', '3513' = '2J01a', '3315' = '2D27a', '4312' = '4F20a', 
               '4313' = '4F20b', '4314' = '4F20c', '4315' = '4F20d', '4316' = '4F20d', '4322' = '4F42a', 
               '4323' = '4F42a', '4324' = '3F30a', '4325' = '3F30a', '4326' = '3F30a', '4327' = '3F30b', 
               '4331' = '4I22a', '4334' = '4I23a', '4332' = '4I21a', '4227' = '4I13e', '4232' = '4I33b', 
               '4233' = '4I34a', '4333' = '4I32a', '4411' = '4I35a', '4412' = '4I35a', '4511' = '3D08a', 
               '5311' = '5G10a', '5312' = '5G22a', '5313' = '5G23a', '5314' = '5G23b', '5315' = '5G24a', 
               '5316' = '5G32b', '5214' = '5D01a', '5215' = '5D01a', '5213' = '5C01a', '5211' = '5D04a', 
               '5212' = '5D04a', '5513' = '5B11a', '5515' = '5B11b', '5514' = '5B11d', '5516' = '5B11e', 
               '5517' = '5B11f', '5511' = '5B11g', '5221' = '5F00a', '5223' = '5F00e', '5621' = '5H12d', 
               '5622' = '5H12e', '5317' = '5G31a', '5417' = '5D02a', '5412' = '5D02b', '5415' = '5D02b', 
               '5518' = '5B13a', '5519' = '5B13b', '5512' = '5B12b', '5521' = '5B12d', '6245' = '6E10a', 
               '6246' = '6E10a', '6241' = '6E11a', '6242' = '6E11b', '6243' = '6E11c', '6244' = '6E11e', 
               '6214' = '6E12b', '6211' = '6E12b', '6218' = '6E12c', '6221' = '6E13a', '6235' = '6E13a', 
               '6220' = '6E13a', '6222' = '6E13b', '6223' = '6E13c', '6226' = '6E13d', '6227' = '6E13e', 
               '6231' = '6E13f', '6234' = '6E13g', '6236' = '6E13h', '6237' = '6E13i', '6238' = '6E13j', 
               '6281' = '6E14a', '6284' = '6E14b', '6283' = '6E14b', '6282' = '6E14b', '6251' = '6E15a', 
               '6254' = '6E15b', '6255' = '6E15d', '6261' = '6E15e', '6264' = '6E15f', '6265' = '6E15f', 
               '6271' = '6E16a', '6272' = '6E16b', '6273' = '6E16b', '6274' = '6E16c', '6291' = '6E17a', 
               '6292' = '6E17a', '6201' = '6E18a', '6202' = '6E18b', '6203' = '6E18c', '6204' = '6E18d', 
               '6293' = '6E19a', '6294' = '6E19c', '6299' = '6E19d', '6301' = '6E21a', '6331' = '6E22a', 
               '6332' = '6E22b', '6341' = '6E23a', '6342' = '6E23b', '6343' = '6E23c', '6344' = '6E23d', 
               '6345' = '6E23e', '6346' = '6E23f', '6347' = '6E23g', '6311' = '6E24a', '6312' = '6E24b', 
               '6313' = '6E24c', '6321' = '6E25a', '6322' = '6E25b', '6323' = '6E25c', '6324' = '6E25d', 
               '6371' = '6E26a', '6372' = '6E26a', '6373' = '6E26a', '6351' = '6E27a', '6352' = '6E27b', 
               '6353' = '6E27c', '6354' = '6E27d', '6391' = '6E28a', '6394' = '6E28a', '6392' = '6E28b', 
               '6393' = '6E28c', '6399' = '6E28d', '6411' = '6E31a', '6412' = '6E32a', '6413' = '6E33a', 
               '6414' = '6E33b', '6511' = '6E34b', '6512' = '6E34b', '6522' = '6E34c', '6513' = '6E35a', 
               '6531' = '6E35b', '6532' = '6E35b', '6521' = '6E36a', '6741' = '6E41b', '6742' = '6E41b', 
               '6711' = '6E42a', '6721' = '6E43a', '6722' = '6E43b', '6723' = '6E43c', '6751' = '6E44a', 
               '6754' = '6E44c', '6761' = '6E44d', '6764' = '6E44e', '6773' = '6E45a', '6771' = '6E45a', 
               '6772' = '6E45a', '6791' = '6E46a', '6799' = '6E46d', '6514' = '6E51a', '6515' = '6E51a', 
               '6792' = '6E51a', '6415' = '6E52a', '6793' = '6E53b', '6841' = '6E61a', '6842' = '6E61b', 
               '6821' = '6E62a', '6851' = '6E63a', '6891' = '6E64a', '6899' = '6E65a', '6911' = '7K20a', 
               '6912' = '7K20b', '6913' = '7K20c', '6914' = '7K20d', '6915' = '7K20e', '6916' = '7K20f', 
               '6921' = '7K20g', '1101' = '7K13a', '1102' = '7K13b', '1103' = '7K13c', '1104' = '7K13d', 
               '1105' = '7K13e', '1106' = '7K13f', '2151' = '6E71a', '2156' = '6E71b', '2155' = '6E71c', 
               '2153' = '6E71d', '2154' = '6E71e', '2157' = '6E71f', '2152' = '6E71g', '2172' = '5H21a', 
               '2173' = '5H21b', '2174' = '5H21c', '2190' = '5H21d', '2231' = '3B21a', '2232' = '3B21b', 
               '2233' = '3B21c', '2236' = '3B21d', '2235' = '3B21e', '2310' = '1A01a', '1201' = '7K12a', 
               '1202' = '7K12b', '1203' = '7K12c', '1204' = '7K12d', '1205' = '7K12e', '1206' = '7K12f', 
               '1211' = '7K12g', '1212' = '7K12h', '1213' = '7K12i', '2111' = '6E72a', '2113' = '6E72c', 
               '2210' = '3B21a', '2211' = '3B21b', '2212' = '3B21c', '2213' = '5B22a', '2214' = '5B22b', 
               '2216' = '5B22c', '2215' = '5B22e', '2217' = '5B22f', '2218' = '5B22g', '2219' = '5B22i', 
               '2242' = '3B22a', '2243' = '3B22b', '2241' = '3B22c', '2244' = '3B22d', '2246' = '3B22e', 
               '2245' = '3B22f', '2247' = '3B22g', '2320' = '1A02a', '2121' = '6E73a', '2122' = '6E73a', 
               '2221' = '5H22a', '2222' = '5H22b', '2224' = '5H22c', '2223' = '5H22c', '2331' = '1A03a', 
               '2332' = '1A03b', '2333' = '1A03c', '2334' = '1A03d', '2131' = '6E74a', '2132' = '6E74b', 
               '2101' = '6E75a', '2102' = '6E75a', '2103' = '6E75b', '2104' = '6E75b', '2105' = '6E75c', 
               '2106' = '6E75c', '2107' = '6E75d', '2161' = '6E76a', '2162' = '6E76b', '2163' = '6E76c', 
               '2164' = '6E76c', '2171' = '6E77a', '2181' = '6E77c', '2182' = '6E77c', '2141' = '6E78a', 
               '2142' = '6E78c', '2143' = '6E78d', '2112' = '6E78d', '1301' = '7K11a', '1302' = '7K11b', 
               '1303' = '7K11c', '1304' = '7K11d', '1305' = '7K11e', '1306' = '7K11f', '3124' = '2D23a', 
               '3125' = '2D23b', '3123' = '2D23b', '3126' = '2E22a')
             #, 
             #"2020" = 
      )

    to_PPP4_administrations <- 
      switch(nomenclaturePCS[1],
             "2003" = c(
               '331a' = '2D21a', '332a' = '2E23a', '332b' = '2E23a', '380a' = '2E23b', '381a' = '2E23b', 
               '382a' = '2E23b', '382b' = '2E23b', '382c' = '2E23b', '382d' = '2E23b', '383a' = '2E23b', 
               '383b' = '2E23b', '383c' = '2E23b', '384a' = '2E23b', '384b' = '2E23b', '384c' = '2E23b', 
               '385a' = '2E23b', '385b' = '2E23b', '385c' = '2E23b', '386a' = '2E23b', '386d' = '2E23b', 
               '386e' = '2E23b', '387a' = '2E23b', '387b' = '2E23b', '387c' = '2E23b', '387d' = '2E23b', 
               '387e' = '2E23b', '387f' = '2E23b', '388a' = '2E23b', '388b' = '2E23b', '388c' = '2E23b', 
               '388d' = '2E23b', '388e' = '2E23b', '389a' = '2E23b', '389b' = '2E23b', '389c' = '2E23b', 
               '333b' = '2C01a', '333e' = '2D24a', '333f' = '2D24b', '371a' = '2D24c', '372a' = '2D24c', 
               '372b' = '2D24c', '372c' = '2D24c', '372d' = '2D24c', '372e' = '2D24c', '372f' = '2D24c', 
               '373a' = '2D24c', '373b' = '2D24c', '373c' = '2D24c', '373d' = '2D24c', '374a' = '2D24c', 
               '374b' = '2D24c', '374c' = '2D24c', '374d' = '2D24c', '375a' = '2D24c', '375b' = '2D24c', 
               '376a' = '2D24c', '376b' = '2D24c', '376c' = '2D24c', '376d' = '2D24c', '376e' = '2D24c', 
               '376g' = '2D24c', '377a' = '2D24c', '334a' = '2G00a', '341b' = '2I11a', '431a' = '2F01a', 
               '434a' = '2I23a', '353a' = '2J02a', '353b' = '2J02a', '451e' = '3D01a', '451f' = '3D01a', 
               '461a' = '3D01b', '461d' = '3D01b', '461e' = '3D01b', '461f' = '3D01b', '464a' = '3D01b', 
               '467b' = '3D01b', '467c' = '3D01b', '425a' = '3D01b', '464b' = '3D01b', '465a' = '3D01b', 
               '465b' = '3D01b', '465c' = '3D01b', '466a' = '3D01b', '466b' = '3D01b', '451c' = '3C01a', 
               '452b' = '5G21a', '463a' = '3B13d', '463b' = '3B13d', '463c' = '3B13d', '463d' = '3B13d', 
               '463e' = '3B13d', '467a' = '3B13d', '462c' = '3B13d', '462d' = '3B13d', '462e' = '3B13d', 
               '471b' = '3E21a', '473b' = '3E21a', '473c' = '3E21a', '474b' = '3E21a', '474c' = '3E21a', 
               '475b' = '3E21a', '477a' = '3E21a', '477b' = '3E21a', '477c' = '3E21a', '471a' = '3E21a', 
               '472a' = '3E21a', '473a' = '3E21a', '474a' = '3E21a', '475a' = '3E21a', '479a' = '3E21a', 
               '478a' = '3E21a', '478b' = '3E21a', '478c' = '3E21a', '478d' = '3E21a', '472b' = '3E21a', 
               '472c' = '3E21a', '472d' = '3E21a', '476a' = '3E21a', '476b' = '3E21a', '477d' = '3E21a', 
               '479b' = '3E21a', '481a' = '3E11a', '481b' = '3E11a', '482a' = '3E11a', '483a' = '3E11a', 
               '484a' = '3E11a', '484b' = '3E11a', '485a' = '3E11a', '485b' = '3E11a', '486a' = '3E11a', 
               '486d' = '3E11a', '486e' = '3E11a', '466c' = '3E11a', '487a' = '3E11a', '487b' = '3E11a', 
               '462a' = '3E11a', '462b' = '3E11a', '468a' = '3E11a', '468b' = '3E11a', '488a' = '3E11a', 
               '488b' = '3E11a', '480a' = '3E11a', '480b' = '3E11a', '467d' = '3D04a', '541a' = '5D01b', 
               '545b' = '5D01b', '546a' = '5D01b', '546b' = '5D01b', '546d' = '5D01b', '546e' = '5D01b', 
               '542a' = '5D01b', '543a' = '5D01b', '543d' = '5D01b', '544a' = '5D01b', '545a' = '5D01b', 
               '545c' = '5D01b', '546c' = '5D01b', '525a' = '5H11a', '525b' = '5H11a', '525c' = '5H11b', 
               '525d' = '5H11c', '561a' = '5H11d', '561d' = '5H11d', '561e' = '5H11d', '561f' = '5H11d', 
               '563a' = '5H11d', '563b' = '5H11d', '563c' = '5H11d', '564a' = '5H11d', '564b' = '5H11d'), 
             
             "1982" = c(
               '3311' = '2D21a', '3312' = '2E23a', '3810' = '2E23b', '3820' = '2E23b', '3823' = '2E23b', 
               '3824' = '2E23b', '3833' = '2E23b', '3853' = '2E23b', '3821' = '2E23b', '3831' = '2E23b', 
               '3851' = '2E23b', '3822' = '2E23b', '3836' = '2E23b', '3832' = '2E23b', '3852' = '2E23b', 
               '3825' = '2E23b', '3826' = '2E23b', '3827' = '2E23b', '3835' = '2E23b', '3837' = '2E23b', 
               '3854' = '2E23b', '3829' = '2E23b', '3839' = '2E23b', '3838' = '2E23b', '3842' = '2E23b', 
               '3843' = '2E23b', '3841' = '2E23b', '3828' = '2E23b', '3855' = '2E23b', '3861' = '2E23b', 
               '3862' = '2E23b', '3863' = '2E23b', '3314' = '2C01a', '3317' = '2D24a', '3316' = '2D24b', 
               '3710' = '2D24c', '3721' = '2D24c', '3723' = '2D24c', '3725' = '2D24c', '3722' = '2D24c', 
               '3728' = '2D24c', '3724' = '2D24c', '3726' = '2D24c', '3727' = '2D24c', '3731' = '2D24c', 
               '3732' = '2D24c', '3733' = '2D24c', '3734' = '2D24c', '3735' = '2D24c', '3741' = '2D24c', 
               '3744' = '2D24c', '3751' = '2D24c', '3321' = '2G00a', '3414' = '2I11a', '4311' = '2F01a', 
               '3521' = '2J02a', '4514' = '3D01a', '4513' = '3D01a', '4615' = '3D01b', '4611' = '3D01b', 
               '4612' = '3D01b', '4631' = '3D01b', '4654' = '3D01b', '4231' = '3D01b', '4632' = '3D01b', 
               '4634' = '3D01b', '4635' = '3D01b', '4633' = '3D01b', '4636' = '3D01b', '4637' = '3D01b', 
               '4641' = '3D01b', '4512' = '3C01a', '4522' = '5G21a', '4624' = '3B13d', '4625' = '3B13d', 
               '4626' = '3B13d', '4627' = '3B13d', '4651' = '3B13d', '4628' = '3B13d', '4623' = '3B13d', 
               '4629' = '3B13d', '4702' = '3E21a', '4713' = '3E21a', '4722' = '3E21a', '4761' = '3E21a', 
               '4723' = '3E21a', '4751' = '3E21a', '4782' = '3E21a', '4717' = '3E21a', '4701' = '3E21a', 
               '4731' = '3E21a', '4732' = '3E21a', '4712' = '3E21a', '4711' = '3E21a', '4721' = '3E21a', 
               '4781' = '3E21a', '4793' = '3E21a', '4792' = '3E21a', '4791' = '3E21a', '4718' = '3E21a', 
               '4733' = '3E21a', '4735' = '3E21a', '4734' = '3E21a', '4771' = '3E21a', '4772' = '3E21a', 
               '4795' = '3E21a', '4794' = '3E21a', '4831' = '3E11a', '4832' = '3E11a', '4811' = '3E11a', 
               '4812' = '3E11a', '4821' = '3E11a', '4822' = '3E11a', '4851' = '3E11a', '4852' = '3E11a', 
               '4861' = '3E11a', '4862' = '3E11a', '4871' = '3E11a', '4873' = '3E11a', '4874' = '3E11a', 
               '4882' = '3E11a', '4881' = '3E11a', '4883' = '3E11a', '4884' = '3E11a', '4642' = '3E11a', 
               '4891' = '3E11a', '4892' = '3E11a', '4621' = '3E11a', '4622' = '3E11a', '4661' = '3E11a', 
               '4662' = '3E11a', '4893' = '3E11a', '4801' = '3E11a', '4802' = '3E11a', '5444' = '5D01b', 
               '5441' = '5D01b', '5442' = '5D01b', '5445' = '5D01b', '5411' = '5D01b', '5421' = '5D01b', 
               '5424' = '5D01b', '5416' = '5D01b', '5431' = '5D01b', '5434' = '5D01b', '5443' = '5D01b', 
               '5216' = '5H11a', '5217' = '5H11b', '5222' = '5H11c', '5611' = '5H11d', '5614' = '5H11d', 
               '5631' = '5H11d', '5632' = '5H11d', '5633' = '5H11d', '5634' = '5H11d')
             #, 
             #"2020" = 
      )
    stopifnot(length(which(names(to_PPP4_administrations) %in% names(to_PPP4_both))) == 0)
    to_PPP4_administrations <- c(to_PPP4_administrations, to_PPP4_both)
    
    to_PPP4_enterprises <- 
      switch(nomenclaturePCS[1],
             "2003" = c(
               '371a' = '2D22a', '380a' = '2E21a', '377a' = '2H00a', '382c' = '2E25b', '383b' = '2E25c', 
               '384b' = '2E25d', '385b' = '2E25e', '386d' = '2E25f', '386e' = '2E25g', '389a' = '2E25h', 
               '372a' = '2E23c', '372b' = '2D25a', '372c' = '2D25b', '372d' = '2D25b', '372e' = '2D25c', 
               '373a' = '2D25d', '373b' = '2D25e', '373c' = '2D25f', '373d' = '2D25g', '374b' = '2D25h', 
               '375a' = '2D25i', '375b' = '2D25i', '387a' = '2E23d', '387b' = '2E23e', '387c' = '2E23f', 
               '387d' = '2E23g', '376a' = '2C04a', '376b' = '2C03a', '376c' = '2C02a', '376d' = '2C04b', 
               '376e' = '2C03b', '374a' = '2B02a', '374c' = '2B01a', '374d' = '2B01b', '376g' = '2B03a', 
               '382d' = '2B04a', '383c' = '2B04b', '384c' = '2B04c', '385c' = '2B04d', '388d' = '2B04e', 
               '381a' = '2E26a', '382a' = '2E26b', '382b' = '2E26c', '383a' = '2E26d', '384a' = '2E26e', 
               '385a' = '2E26f', '386a' = '2E26g', '387e' = '2E26h', '387f' = '2E26i', '388e' = '2E26j', 
               '388a' = '2E27a', '388b' = '2E27b', '388c' = '2E27c', '341b' = '2I12a', '353a' = '2J03a', 
               '353b' = '2J03a', '372f' = '2D28a', '389b' = '2E28a', '389c' = '2E28b', '331a' = '2D28b', 
               '332a' = '2D28b', '332b' = '2D28b', '333b' = '2D28b', '333e' = '2D28b', '333f' = '2D28b', 
               '334a' = '2D28b', '431a' = '2F02a', '434a' = '2I24a', '461a' = '3D02a', '461d' = '3D03a', 
               '461e' = '3D03b', '461f' = '3D03b', '464a' = '3D03c', '467b' = '3C03a', '467c' = '3C03b', 
               '425a' = '3D06a', '464b' = '3D06b', '465a' = '3D06c', '465b' = '3D06d', '465c' = '3D06e', 
               '466a' = '3D07a', '466b' = '3D07a', '451e' = '3D07b', '451f' = '3D07b', '451c' = '3D07b', 
               '467d' = '3D07b', '452b' = '3D07b', '471b' = '3E22a', '473b' = '3E22b', '473c' = '3E22c', 
               '474b' = '3E22d', '474c' = '3E22e', '475b' = '3E22f', '477a' = '3E22g', '477b' = '3E23a', 
               '477c' = '3E23b', '471a' = '3E24a', '472a' = '3E24b', '473a' = '3E24c', '474a' = '3E24d', 
               '475a' = '3E24e', '479a' = '3E24f', '478a' = '3E25a', '478b' = '3E25b', '478c' = '3E25c', 
               '478d' = '3E25d', '472b' = '3E26a', '472c' = '3E26b', '472d' = '3E26c', '476a' = '3E26d', 
               '476b' = '3E26e', '477d' = '3E26f', '479b' = '3E26g', '481a' = '3E12a', '481b' = '3E12b', 
               '482a' = '3E13a', '483a' = '3E13b', '484a' = '3E13c', '484b' = '3E13d', '485a' = '3E13e', 
               '485b' = '3E13f', '486a' = '3E13g', '486d' = '3E13h', '486e' = '3E13i', '466c' = '3D05a', 
               '487a' = '3E14a', '487b' = '3E14b', '462a' = '3B12a', '462b' = '3B12b', '468a' = '3H00a', 
               '468b' = '3H00b', '488a' = '3H00c', '488b' = '3H00c', '480a' = '3E15a', '480b' = '3E15b', 
               '463a' = '3B11a', '463b' = '3B11a', '463c' = '3B11a', '463d' = '3B11a', '463e' = '3B11b', 
               '467a' = '3C02a', '462c' = '3B13a', '462d' = '3B13b', '462e' = '3B13c', '541a' = '5D05a', 
               '545b' = '5C02a', '546a' = '5D05b', '546b' = '5D05c', '546d' = '5D05d', '546e' = '5D05d', 
               '542a' = '5D06a', '543a' = '5D07a', '543d' = '5D08a', '544a' = '5D08b', '545a' = '5C03a', 
               '545c' = '5C03b', '546c' = '5D08c', '561a' = '5H12a', '561d' = '5H12b', '561e' = '5H12c', 
               '561f' = '5H12c', '563a' = '5H13a', '563b' = '5H13b', '563c' = '5H13c', '564a' = '5H13d', 
               '525a' = '5H14a', '525b' = '5H14a', '525c' = '5H14a', '525d' = '5H14a', '564b' = '5H14a'), 
             
             "1982" = c(
               '3710' = '2D22a', '3810' = '2E21a', '3751' = '2H00a', '3833' = '2E25b', '3831' = '2E25c', 
               '3836' = '2E25d', '3832' = '2E25d', '3835' = '2E25e', '3837' = '2E25e', '3839' = '2E25f', 
               '3838' = '2E25g', '3861' = '2E25h', '3721' = '2E23c', '3723' = '2D25a', '3725' = '2D25b', 
               '3722' = '2D25b', '3724' = '2D25d', '3726' = '2D25e', '3727' = '2D25f', '3732' = '2D25h', 
               '3735' = '2D25i', '3842' = '2E23d', '3843' = '2E23e', '3741' = '2C03a', '3744' = '2C03b', 
               '3731' = '2B02a', '3733' = '2B01a', '3734' = '2B01b', '3853' = '2B04a', '3851' = '2B04b', 
               '3852' = '2B04c', '3854' = '2B04d', '3855' = '2B04e', '3820' = '2E26a', '3823' = '2E26b', 
               '3824' = '2E26c', '3821' = '2E26d', '3822' = '2E26e', '3825' = '2E26f', '3826' = '2E26f', 
               '3827' = '2E26f', '3829' = '2E26g', '3841' = '2E26h', '3828' = '2E27a', '3414' = '2I12a', 
               '3521' = '2J03a', '3728' = '2D28a', '3862' = '2E28a', '3863' = '2E28b', '3311' = '2D28b', 
               '3312' = '2D28b', '3314' = '2D28b', '3317' = '2D28b', '3316' = '2D28b', '3321' = '2D28b', 
               '4311' = '2F02a', '4615' = '3D02a', '4611' = '3D03a', '4612' = '3D03b', '4631' = '3D03c', 
               '4654' = '3C03b', '4231' = '3D06a', '4632' = '3D06b', '4634' = '3D06c', '4635' = '3D06c', 
               '4633' = '3D06d', '4636' = '3D06e', '4637' = '3D06e', '4641' = '3D07a', '4514' = '3D07b', 
               '4513' = '3D07b', '4512' = '3D07b', '4522' = '3D07b', '4702' = '3E22a', '4713' = '3E22b', 
               '4722' = '3E22d', '4761' = '3E22e', '4723' = '3E22e', '4751' = '3E22f', '4782' = '3E22g', 
               '4717' = '3E23a', '4701' = '3E24a', '4731' = '3E24b', '4732' = '3E24b', '4712' = '3E24c', 
               '4711' = '3E24c', '4721' = '3E24d', '4781' = '3E24e', '4793' = '3E24f', '4792' = '3E25a', 
               '4791' = '3E25b', '4718' = '3E25d', '4733' = '3E26a', '4735' = '3E26b', '4734' = '3E26c', 
               '4771' = '3E26d', '4772' = '3E26e', '4795' = '3E26g', '4794' = '3E26g', '4831' = '3E12a', 
               '4832' = '3E12b', '4811' = '3E13a', '4812' = '3E13a', '4821' = '3E13b', '4822' = '3E13b', 
               '4851' = '3E13c', '4852' = '3E13c', '4861' = '3E13d', '4862' = '3E13d', '4871' = '3E13e', 
               '4873' = '3E13f', '4874' = '3E13f', '4882' = '3E13g', '4881' = '3E13h', '4883' = '3E13h', 
               '4884' = '3E13i', '4642' = '3D05a', '4891' = '3E14a', '4892' = '3E14b', '4621' = '3B12a', 
               '4622' = '3B12b', '4661' = '3H00a', '4662' = '3H00b', '4893' = '3H00c', '4801' = '3E15a', 
               '4802' = '3E15b', '4624' = '3B11a', '4625' = '3B11a', '4626' = '3B11a', '4627' = '3B11b', 
               '4651' = '3C02a', '4628' = '3B13a', '4623' = '3B13b', '4629' = '3B13c', '5444' = '5D05a', 
               '5441' = '5D05b', '5442' = '5D05c', '5445' = '5D05d', '5411' = '5D06a', '5421' = '5D07a', 
               '5424' = '5D08a', '5416' = '5D08b', '5431' = '5C03a', '5434' = '5C03b', '5443' = '5D08c', 
               '5611' = '5H12a', '5614' = '5H12c', '5631' = '5H13a', '5632' = '5H13c', '5633' = '5H13d', 
               '5216' = '5H14a', '5217' = '5H14a', '5222' = '5H14a', '5634' = '5H14a')
             #, 
             #"2020" = 
      )
    stopifnot(length(which(names(to_PPP4_enterprises) %in% names(to_PPP4_both))) == 0)
    to_PPP4_enterprises <- c(to_PPP4_enterprises, to_PPP4_both)
    
    
    
    
    if (ESE & nomenclaturePCS[1] == "2003") {
      to_PPP4_both <- c(to_PPP4_both, 
                        #"100x" = ""   , #Agriculteurs et éleveurs, salariés de leur exploitation 
                        #"210x" = ""   , #Artisans salariés de leur entreprise 
                        #"220x" = ""   , #Commerçants et assimilés, salariés de leur entreprise 
                        
                        "342b" = "4I11a", #Professeurs et maîtres de conférences 
                        "342c" = "4I11a", #Professeurs agrégés et certifiés en fonction dans l'enseignement supérieur 
                        "342d" = "4I11a", #Personnel enseignant temporaire de l'enseignement supérieur 
                        "342f" = "4I12a", #Directeurs et chargés de recherche de la recherche publique 
                        "342g" = "4I12a", #Ingénieurs d'étude et de recherche de la recherche publique 
                        "342h" = "4I12a", #Allocataires de la recherche publique 
                        
                        "354e" = "4J11d", #Artistes de la danse 
                        "354f" = "4J11d", #Artistes du cirque et des spectacles divers 
                        
                        "622c" = "6E12b", #Monteurs câbleurs qualifiés en électricité 
                        "622d" = "6E12b", #Câbleurs qualifiés en électronique (prototype, unité, petite série) 
                        "622e" = "6E12b", #Autres monteurs câbleurs en électronique 
                        "622f" = "6E12b", #Bobiniers qualifiés 
                        "623d" = "6E13c", #Opérateurs qualifiés sur machine de soudage 
                        "623e" = "6E13c", #Soudeurs manuels 
                        "624b" = "6E13f", #Monteurs, metteurs au point très qualifiés d'ensembles mécaniques travaillant à l'unité ou en petite série 
                        "624c" = "6E13f", #Monteurs qualifiés d'ensembles mécaniques travaillant en moyenne ou en grande série 
                        "625f" = "6E15d", #Autres opérateurs travaillant sur installations ou machines : industrie agroalimentaire (hors transformation des viandes) 
                        "625g" = "6E15d", #Autres ouvriers de production qualifiés ne travaillant pas sur machine : industrie agroalimentaire (hors transformation des viandes) 
                        "654b" = "6E34c", #Conducteurs qualifiés d'engins de transport guidés (sauf remontées mécaniques) 
                        "654c" = "6E34c", #Conducteurs qualifiés de systèmes de remontées mécaniques 
                        "656b" = "6E35b", #Matelots de la marine marchande 
                        "656c" = "6E35b", #Capitaines et matelots timoniers de la navigation fluviale 
                        "671c" = "6E41b", #Ouvriers non qualifiés des travaux publics et du travail du béton 
                        "671d" = "6E41b"#,#Aides-mineurs, ouvriers non qualifiés de l'extraction
      )
      
      to_PPP4_administrations <- c(to_PPP4_administrations,
                                   "381b" = "2E23b", #Ingénieurs et cadres d'étude et développement de l'agriculture, la pêche, les eaux et forêts 
                                   "381c" = "2E23b", #Ingénieurs et cadres de production et d'exploitation de l'agriculture, la pêche, les eaux et forêts 
                                   "386b" = "2E23b", #Ingénieurs et cadres d'étude, recherche et développement de la distribution d'énergie, eau 
                                   "386c" = "2E23b", #Ingénieurs et cadres d'étude, recherche et développement des autres industries (imprimerie, matériaux souples, ameublement et bois) 
                                   
                                   "451g" = "3D01a", #Professions intermédiaires administratives des collectivités locales 
                                   "451h" = "3D01a", #Professions intermédiaires administratives des hôpitaux 
                                   
                                   "461b" = "3D01b", #Secrétaires de direction, assistants de direction (non cadres) 
                                   "461c" = "3D01b", #Secrétaires de niveau supérieur (non cadres, hors secrétaires de direction) 
                                   "486b" = "3E11a", #Agents de maîtrise en maintenance, installation en électricité et électronique 
                                   "486c" = "3E11a", #Agents de maîtrise en maintenance, installation en électromécanique 
                                   
                                   "523b" = "5D01a", #Adjoints administratifs de l'Etat et assimilés (sauf Poste, France Télécom) 
                                   "523c" = "5D01a", #Adjoints administratifs des collectivités locales 
                                   "523d" = "5D01a", #Adjoints administratifs des hôpitaux publics 
                                   "524b" = "5D01a", #Agents administratifs de l'Etat et assimilés (sauf Poste, France Télécom) 
                                   "524c" = "5D01a", #Agents administratifs des collectivités locales 
                                   "524d" = "5D01a", #Agents administratifs des hôpitaux publics 
                                   
                                   "541b" = "5D01b", #Agents d'accueil qualifiés, hôtesses d'accueil et d'information 
                                   "541c" = "5D01b", #Agents d'accueil non qualifiés 
                                   "543b" = "5D01b", #Employés qualifiés des services comptables ou financiers 
                                   "543c" = "5D01b", #Employés non qualifiés des services comptables ou financiers 
                                   "543e" = "5D01b", #Employés qualifiés des services du personnel et des services juridiques 
                                   "543f" = "5D01b", #Employés qualifiés des services commerciaux des entreprises (hors vente) 
                                   "543g" = "5D01b", #Employés administratifs qualifiés des autres services des entreprises 
                                   "543h" = "5D01b", #Employés administratifs non qualifiés 
                                   
                                   #"553b" = ""   , #Vendeurs polyvalents des grands magasins 
                                   #"553c" = ""   , #Autres vendeurs non spécialisés 
                                   
                                   "561b" = "5H11d", #Serveurs, commis de restaurant, garçons qualifiés 
                                   "561c" = "5H11d" #Serveurs, commis de restaurant, garçons non qualifiés 
      )
      
      to_PPP4_enterprises <- c(to_PPP4_enterprises,
                               "381b" = "2E26a", #Ingénieurs et cadres d'étude et développement de l'agriculture, la pêche, les eaux et forêts 
                               "381c" = "2E26a", #Ingénieurs et cadres de production et d'exploitation de l'agriculture, la pêche, les eaux et forêts 
                               "386b" = "2E26g", #Ingénieurs et cadres d'étude, recherche et développement de la distribution d'énergie, eau 
                               "386c" = "2E26g", #Ingénieurs et cadres d'étude, recherche et développement des autres industries (imprimerie, matériaux souples, ameublement et bois) 
                               
                               "451g" = "3D07b", #Professions intermédiaires administratives des collectivités locales 
                               "451h" = "3D07b", #Professions intermédiaires administratives des hôpitaux 
                               "461b" = "3D02a", #Secrétaires de direction, assistants de direction (non cadres) 
                               "461c" = "3D02a", #Secrétaires de niveau supérieur (non cadres, hors secrétaires de direction) 
                               "486b" = "3E13g", #Agents de maîtrise en maintenance, installation en électricité et électronique 
                               "486c" = "3E13g", #Agents de maîtrise en maintenance, installation en électromécanique 
                               
                               #"523b" = ""   , #Adjoints administratifs de l'Etat et assimilés (sauf Poste, France Télécom) 
                               #"523c" = ""   , #Adjoints administratifs des collectivités locales 
                               #"523d" = ""   , #Adjoints administratifs des hôpitaux publics 
                               #"524b" = ""   , #Agents administratifs de l'Etat et assimilés (sauf Poste, France Télécom) 
                               #"524c" = ""   , #Agents administratifs des collectivités locales 
                               #"524d" = ""   , #Agents administratifs des hôpitaux publics 
                               
                               "541b" = "5D05a", #Agents d'accueil qualifiés, hôtesses d'accueil et d'information 
                               "541c" = "5D05a", #Agents d'accueil non qualifiés 
                               "543b" = "5D07a", #Employés qualifiés des services comptables ou financiers 
                               "543c" = "5D07a", #Employés non qualifiés des services comptables ou financiers 
                               "543e" = "5D08a", #Employés qualifiés des services du personnel et des services juridiques 
                               "543f" = "5D08a", #Employés qualifiés des services commerciaux des entreprises (hors vente) 
                               "543g" = "5D08a", #Employés administratifs qualifiés des autres services des entreprises 
                               "543h" = "5D08a", #Employés administratifs non qualifiés 
                               
                               "553b" = "5B12a", #Vendeurs polyvalents des grands magasins 
                               "553c" = "5B12a", #Autres vendeurs non spécialisés 
                               
                               "561b" = "5H12a", #Serveurs, commis de restaurant, garçons qualifiés 
                               "561c" = "5H12a" #Serveurs, commis de restaurant, garçons non qualifiés 
      )
    }
    
    
    if (missing(sexe)) {
      data_new <- data %>% dplyr::select(PROF = !!rlang::enquo(profession), 
                                         EMP  = !!rlang::enquo(admin_ent))
    } else {
      if (missing(sexe_wt)) {
        
        data_new <- data %>% dplyr::select(PROF    = !!rlang::enquo(profession), 
                                           EMP     = !!rlang::enquo(admin_ent), 
                                           SEXE    = !!rlang::enquo(sexe))
      } else {
        data_new <- data %>% dplyr::select(PROF    = !!rlang::enquo(profession), 
                                           EMP     = !!rlang::enquo(admin_ent), 
                                           SEXE    = !!rlang::enquo(sexe), 
                                           SEXE_WT = !!rlang::enquo(sexe_wt))
      }
    }
    
    data_ok <- data_new[!is.na(data_new$PROF),] %>% 
      dplyr::mutate(Pc = forcats::fct_relabel(.data$PROF, ~ stringr::str_sub(., 1, 4) %>% 
                                                stringr::str_to_lower())) #str_replace(., "^(.{4}).+", "\\1") 
    
    data_levels  <- levels(dplyr::pull(data_ok, Pc) %>% forcats::fct_drop())
    ok_levels    <- unique(c(names(to_PPP4_both),
                             names(to_PPP4_administrations), 
                             names(to_PPP4_enterprises)))
    new_levels   <- unique(c(to_PPP4_both, to_PPP4_administrations, to_PPP4_enterprises))
    wrong_levels <- data_levels[which(!data_levels %in% ok_levels)]
    
    data_ok <- data_ok %>% dplyr::mutate(PPP4 = factor(NA, new_levels))
    
    if (length(wrong_levels) != 0) message(paste0(
      c("Wrong PCS numbers were turned to `NA` : ",
        paste0(wrong_levels, collapse = ", ")           )
    ))
    
    test_admin <- data_ok$EMP == levels(data_ok$EMP)[1] & !is.na(data_ok$EMP)
    test_ent   <- data_ok$EMP == levels(data_ok$EMP)[2] | is.na(data_ok$EMP)
    #test_other <- !test_admin & !test_ent #separate entreprises and independants ?
    
    data_ok$PPP4[test_admin] <- data_ok$Pc[test_admin] %>% 
      forcats::fct_relabel(~ tidyr::replace_na(to_PPP4_administrations[.], "NULL")) %>% 
      forcats::fct_expand(new_levels) %>% forcats::fct_recode("NULL" = "NULL")
    
    ent <- data_ok$Pc[test_ent] %>% 
      forcats::fct_relabel(~ tidyr::replace_na(to_PPP4_enterprises[.], "NULL")) %>% 
      forcats::fct_expand(new_levels) %>% forcats::fct_recode("NULL" = "NULL")
    
    data_ok$PPP4[test_ent] <- ent
    
    # "4J22a" %in% levels(ent)
    # "4J22a" %in% new_levels
    # "4J22a" %in% levels(data_ok$PPP4)
    
    # data_ok$PPP4[test_ent]   <- data_ok$Pc[test_ent] %>% 
    #   forcats::fct_relabel(~ tidyr::replace_na(to_PPP4_enterprises[.], "NULL")) %>% 
    #   forcats::fct_expand(new_levels) %>% forcats::fct_recode("NULL" = "NULL")
    
    #data_ok <- data_ok %>% dplyr::select(-EMP, -Pc)
    
    data_new <- data_new %>% dplyr::mutate(PPP4 = factor(NA, new_levels))
    
    data_new$PPP4[!is.na(data_new$PROF)] <- data_ok$PPP4
    
    
    
    
    
    # Correspondence tables for male, female and inclusive names (not yet for PPP4) -------
    m <- stringi::stri_unescape_unicode("\\u2642")
    f <- stringi::stri_unescape_unicode("\\u2640")
    b <- paste0(m, f)
    # stringi::stri_escape_unicode("·")   # \\u00b7
    # stringi::stri_escape_unicode("é")   # \\u00e9
    
    PPP4_to_name <- c('1A01a' = '1A01a-Chefs de grande entreprise de 500 salariés et plus', 
                      '1A02a' = '1A02a-Chefs de moyenne entreprise, de 50 à 499 salariés', 
                      '1A03a' = '1A03a-Chefs d’entreprise du BTP, de 10 à 49 salariés', 
                      '1A03b' = '1A03b-Chefs d’entreprise de l’industrie ou des transports, de 10 à 49 salariés', 
                      '1A03c' = '1A03c-Chefs d’entreprise commerciale, de 10 à 49 salariés', 
                      '1A03d' = '1A03d-Chefs d’entreprise de services, de 10 à 49 salariés', 
                      '2B01a' = '2B01a-Cadres commerciaux des grandes entreprises (hors commerce de détail)', 
                      '2B01b' = '2B01b-Cadres commerciaux des PME (hors commerce de détail)', 
                      '2B02a' = paste0('2B02a-Cadres de l’exploitation des magasins de vente du commerce de détail ', m), 
                      '2B03a' = paste0('2B03a-Cadres de l’immobilier ', b), 
                      '2B04a' = '2B04a-Ingénieurs et cadres technico-commerciaux en BTP', 
                      '2B04b' = '2B04b-Ingénieurs et cadres technico-commerciaux en matériel électrique ou électronique professionnel', 
                      '2B04c' = '2B04c-Ingénieurs et cadres technico-commerciaux en matériel mécanique professionnel', 
                      '2B04d' = '2B04d-Ingénieurs et cadres technico-commerciaux des industries de transformations (biens intermédiaires)', 
                      '2B04e' = '2B04e-Ingénieurs et cadres technico-commerciaux en informatique et télécommunications', 
                      '2C01a' = '2C01a-Inspect\\u00b7rices des Finances publiques et des Douanes', 
                      '2C02a' = '2C02a-Cadres commercia\\u00b7les de la banque', 
                      '2C03a' = paste0('2C03a-Cadres des opérations bancaires  ', b), 
                      '2C03b' = paste0('2C03b-Cadres des services techniques des assurances ', b), 
                      '2C04a' = paste0('2C04a-Cadres des marchés financiers ', b), 
                      '2C04b' = '2C04b-Chef\\u00b7fes d’établissements et responsables de l’exploitation bancaire', 
                      '2D21a' = '2D21a-Personnel\\u00b7les de direction de la fonction publique', 
                      '2D22a' = paste0('2D22a-Cadres d’état-major administratifs, financiers, commerciaux des grandes entreprises ', m), 
                      '2D23a' = '2D23a-Experts comptables, comptables agréés, libéraux', 
                      '2D23b' = '2D23b-Consultant\\u00b7es libéra\\u00b7les en études économiques, organisation et recrutement, gestion et fiscalité', 
                      '2D24a' = '2D24a-Autres cadres publi\\u00b7ques administrati\\u00b7ves de l’état', 
                      '2D24b' = '2D24b-Cadres publi\\u00b7ques administrati\\u00b7ves des collectivités locales et hôpitaux publics (hors Enseignement, Patrimoine)', 
                      '2D24c' = '2D24c-Cadres publi\\u00b7ques administrati\\u00b7ves classés entreprise', 
                      '2D25a' = paste0('2D25a-Cadres de l’organisation ou du contrôle des services administratifs et financiers ', b), 
                      '2D25b' = paste0('2D25b-Cadres des ressources humaines (dont recrutement et formation) ', b), 
                      '2D25c' = paste0('2D25c-Juristes ', f), 
                      '2D25d' = paste0('2D25d-Cadres des services financiers ou comptables des grandes entreprises ', b), 
                      '2D25e' = paste0('2D25e-Cadres des autres services administratifs des grandes entreprises ', b), 
                      '2D25f' = paste0('2D25f-Cadres des services financiers ou comptables des PME ', b), 
                      '2D25g' = paste0('2D25g-Cadres des autres services administratifs des PME ', b), 
                      '2D25h' = '2D25h-Chef\\u00b7fes de produits, achet\\u00b7rices du commerce et autres cadres de la mercatique', 
                      '2D25i' = paste0('2D25i-Cadres de la communication (publicité, relations publiques) ', f), 
                      '2D26a' = paste0('2D26a-Cadres de la Sécurité sociale ', f), 
                      '2D27a' = paste0('2D27a-Cadres de la Poste/FT ', b), 
                      '2D28a' = paste0('2D28a-Cadres de la documentation, de l’archivage ', f), 
                      '2D28b' = '2D28b-Autres cadres d’entreprises classé\\u00b7es fonction publique', 
                      '2E21a' = '2E21a-Directeurs techniques des grandes entreprises', 
                      '2E22a' = '2E22a-Ingénieurs conseils libéraux en études techniques', 
                      '2E23a' = '2E23a-Ingénieur\\u00b7es publi\\u00b7ques', 
                      '2E23b' = '2E23b-Ingénieur\\u00b7es publi\\u00b7ques classé\\u00b7es entreprise', 
                      '2E23c' = '2E23c-Cadres chargé\\u00b7es d’études économiques, financières, commerciales', 
                      '2E23d' = '2E23d-Ingénieurs et cadres des achats et approvisionnements industriels', 
                      '2E23e' = '2E23e-Ingénieurs et cadres de la logistique, du planning et de l’ordonnancement', 
                      '2E23f' = '2E23f-Ingénieurs et cadres des méthodes de production', 
                      '2E23g' = '2E23g-Ingénieur\\u00b7es et cadres du contrôle-qualité', 
                      '2E25b' = '2E25b-Ingénieurs, cadres de chantier et conducteurs de travaux (cadres) du BTP', 
                      '2E25c' = '2E25c-Ingénieurs et cadres de fabrication en matériel électrique, électronique', 
                      '2E25d' = '2E25d-Ingénieurs et cadres de fabrication en mécanique et travail des métaux', 
                      '2E25e' = '2E25e-Ingénieurs et cadres de fabrication des industries de transformation (agroalimentaire, chimie, métallurgie, matériaux lourds)', 
                      '2E25f' = '2E25f-Ingénieurs et cadres de la production et de la distribution d’énergie, eau', 
                      '2E25g' = '2E25g-Ingénieur\\u00b7es et cadres de fabrication des autres industries (imprimerie, matériaux souples, ameublement et bois)', 
                      '2E25h' = '2E25h-Ingénieurs et cadres techniques de l’exploitation des transports', 
                      '2E26a' = '2E26a-Ingénieurs et cadres d’étude et d’exploitation de l’agriculture, la pêche, les eaux et forêts', 
                      '2E26b' = '2E26b-Ingénieurs et cadres d’étude du BTP', 
                      '2E26c' = '2E26c-Architectes salarié\\u00b7es', 
                      '2E26d' = '2E26d-Ingénieurs et cadres d’étude, recherche et développement en électricité, électronique', 
                      '2E26e' = '2E26e-Ingénieurs et cadres d’étude, recherche et développement en mécanique et travail des métaux', 
                      '2E26f' = '2E26f-Ingénieurs et cadres d’étude, recherche et développement des industries de transformation (agroalimentaire, chimie, métallurgie, matériaux lourds)', 
                      '2E26g' = '2E26g-Ingénieur\\u00b7es et cadres d’étude, recherche et développement des autres industries (imprimerie, matériaux souples, ameublement et bois, énergie, eau)', 
                      '2E26h' = '2E26h-Ingénieurs et cadres de la maintenance, de l’entretien et des travaux neufs', 
                      '2E26i' = '2E26i-Ingénieur\\u00b7es et cadres techniques de l’environnement', 
                      '2E26j' = '2E26j-Ingénieurs et cadres spécialistes des télécommunications', 
                      '2E27a' = '2E27a-Ingénieurs et cadres d’étude, recherche et développement en informatique', 
                      '2E27b' = '2E27b-Ingénieurs et cadres d’administration, maintenance, support et services aux utilisateurs en informatique', 
                      '2E27c' = '2E27c-Chefs de projets informatiques, responsables informatiques', 
                      '2E28a' = '2E28a-Officiers et cadres navigants techniques et commerciaux de l’aviation civile', 
                      '2E28b' = '2E28b-Officiers et cadres navigants techniques de la marine marchande', 
                      '2F01a' = '2F01a-Cadres publiques de santé', 
                      '2F02a' = '2F02a-Cadres privées de santé', 
                      '2H00a' = paste0('2H00a-Cadres de l’hôtellerie et de la restauration ', b), 
                      '2G00a' = '2G00a-Officiers des Armées et de la Gendarmerie (sauf officiers généraux)', 
                      '2G00b' = '2G00b-Inspecteurs et officiers de police', 
                      '2I11a' = '2I11a-Proviseur\\u00b7es et inspect\\u00b7rices de l’EN', 
                      '2I12a' = '2I12a-Chef\\u00b7fes d’établissement scolaire privé', 
                      '2I23a' = '2I23a-Cadres publi\\u00b7ques de l’intervention sociale', 
                      '2I24a' = '2I24a-Cadres associati\\u00b7ves (ou privé\\u00b7es lucrati\\u00b7ves) de l’intervention sociale', 
                      '2I25a' = '2I25a-Direct\\u00b7rices de centres socioculturels et de loisirs', 
                      '2J01a' = '2J01a-Bibliothécaires, archivistes, conservatrices et autres cadres du patrimoine', 
                      '2J02a' = '2J02a-Cadres publi\\u00b7ques de la presse et de l’audiovisuel', 
                      '2J03a' = paste0('2J03a-Cadres de la presse, de l’édition, de l’audiovisuel et des spectacles ', b), 
                      '3B11a' = '3B11a-Technicien\\u00b7nes commercia\\u00b7les (auprès d’entreprises ou de professionnels)', 
                      '3B11b' = '3B11b-Technicien\\u00b7nes commercia\\u00b7les auprès de particuliers', 
                      '3B12a' = '3B12a-Chef\\u00b7fes de petites surfaces de vente', 
                      '3B12b' = paste0('3B12b-Maîtrise de l’exploitation des magasins de vente ', b), 
                      '3B13a' = '3B13a-Achet\\u00b7rices non classé\\u00b7es cadres, aides-achet\\u00b7rices', 
                      '3B13b' = '3B13b-Animat\\u00b7rices commercia\\u00b7les des magasins de vente, marchandiseu\\u00b7ses (non cadres)', 
                      '3B13c' = '3B13c-Autres cols blancs subalternes du commerce (sauf technicien\\u00b7nes des forces de vente)', 
                      '3B13d' = paste0('3B13d-Cols blancs subalternes du commerce Employé\\u00b7es du public ', b), 
                      '3B21a' = '3B21a-Petits et moyens grossistes en alimentation', 
                      '3B21b' = '3B21b-Petits et moyens grossistes en produits non alimentaires', 
                      '3B21c' = '3B21c-Petit\\u00b7es et moyen\\u00b7nes détaillant\\u00b7es en alimentation spécialisée', 
                      '3B21d' = '3B21d-Exploitants de café, restaurant, hôtel, de 3 à 9 salariés', 
                      '3B21e' = '3B21e-Intermédiaires indépendants du commerce', 
                      '3B22a' = '3B22a-Agents généraux et courtiers d’assurance indépendants', 
                      '3B22b' = '3B22b-Agent\\u00b7es de voyage et auxiliaires de transports indépendant\\u00b7es', 
                      '3B22c' = '3B22c-Agent\\u00b7es immobilier\\u00b7es indépendant\\u00b7es', 
                      '3B22d' = '3B22d-Indépendant\\u00b7es gestionnaires de spectacle ou de service récréatif', 
                      '3B22e' = '3B22e-Indépendant\\u00b7es gestionnaires d’établissements privés (enseignement, santé, social)', 
                      '3B22f' = '3B22f-Astrologues, professionnelles de la parapsychologie, guérisseuses', 
                      '3B22g' = '3B22g-Autres indépendants divers prestataires de services', 
                      '3C01a' = '3C01a-Contrôleu\\u00b7ses des Finances publiques (et des Douanes)', 
                      '3C02a' = '3C02a-Chargé\\u00b7es de clientèle bancaire', 
                      '3C03a' = '3C03a-Technicien\\u00b7nes des opérations bancaires', 
                      '3C03b' = paste0('3C03b-Cols blancs (techniques et commerciales) des assurances ', f), 
                      '3D01a' = '3D01a-Cols blancs administratives de catégorie B', 
                      '3D01b' = '3D01b-Cols blancs administrati\\u00b7ves du public classées entreprise', 
                      '3D02a' = paste0('3D02a-Secrétaires de direction (non cadres) ', f), 
                      '3D03a' = '3D03a-Techniciennes (et maîtrise) des services financiers ou comptables', 
                      '3D03b' = '3D03b-Techniciennes administratives (et maîtrise) (autres que financiers et comptables)', 
                      '3D03c' = '3D03c-Assistantes de la publicité, des relations publiques (indépendantes ou salariées)', 
                      '3D04a' = '3D04a-Cols blancs administratives de la Sécurité sociale', 
                      '3D05a' = paste0('3D05a-Responsables d’exploitation des transports de voyageurs et de marchandises (non cadres) ', m), 
                      '3D06a' = paste0('3D06a-Sous-bibliothécaires, cadres intermédiaires du patrimoine ', b), 
                      '3D06b' = '3D06b-Interprètes et traductrices (indépendantes ou salariées)', 
                      '3D06c' = '3D06c-Concept\\u00b7rices et assistant\\u00b7es techniques des arts graphiques, de la mode et de la décoration (indépendant\\u00b7es et salarié\\u00b7es)', 
                      '3D06d' = '3D06d-Assistants techniques de la réalisation des spectacles vivants et audiovisuels (indépendants ou salariés)', 
                      '3D06e' = paste0('3D06e-Photographes ', b), 
                      '3D07a' = '3D07a-Responsables administrati\\u00b7ves ou commercia\\u00b7les des transports et du tourisme (non cadres)', 
                      '3D07b' = '3D07b-Cols blancs subalternes d’entreprise classé\\u00b7es fonction publique', 
                      '3D08a' = '3D08a-Cols blancs administrati\\u00b7ves de la Poste et France Télécom (statut public)', 
                      '3E11a' = '3E11a-Agents de maîtrise employés du public', 
                      '3E12a' = '3E12a-Conducteurs de travaux (non cadres)', 
                      '3E12b' = '3E12b-Chefs de chantier (non cadres)', 
                      '3E13a' = '3E13a-Agents de maîtrise en fabrication de matériel électrique, électronique', 
                      '3E13b' = '3E13b-Agents de maîtrise en construction mécanique, travail des métaux', 
                      '3E13c' = '3E13c-Agents de maîtrise en fabrication : agroalimentaire, chimie, plasturgie, pharmacie', 
                      '3E13d' = '3E13d-Agents de maîtrise en fabrication : métallurgie, matériaux lourds et autres industries de transformation', 
                      '3E13e' = '3E13e-Agents de maîtrise et techniciens en production et distribution d’énergie, eau, chauffage', 
                      '3E13f' = '3E13f-Agents de maîtrise en fabrication des autres industries (imprimerie, matériaux souples, ameublement et bois)', 
                      '3E13g' = '3E13g-Agents de maîtrise en maintenance, installation en électricité, électromécanique et électronique', 
                      '3E13h' = '3E13h-Agents de maîtrise en maintenance, installation en mécanique', 
                      '3E13i' = '3E13i-Agents de maîtrise en entretien général, installation, travaux neufs (hors mécanique, électromécanique, électronique)', 
                      '3E14a' = paste0('3E14a-Responsables d’entrepôt, de magasinage ', m), 
                      '3E14b' = paste0('3E14b-Responsables du tri, de l’emballage, de l’expédition et autres responsables de la manutention ', m), 
                      '3E15a' = '3E15a-Agents d’encadrement (non cadres) de l’agriculture', 
                      '3E15b' = '3E15b-Maîtres d’équipage de la marine marchande et de la pêche', 
                      '3E21a' = '3E21a-Techniciens employés du public (TP, labos…)', 
                      '3E22a' = '3E22a-Techniciens d’exploitation et de contrôle de la production en agriculture, eaux et forêt', 
                      '3E22b' = '3E22b-Techniciens de recherche-développement et des méthodes de fabrication en électricité, électromécanique et électronique', 
                      '3E22c' = '3E22c-Techniciens de fabrication et de contrôle-qualité en électricité, électromécanique et électronique', 
                      '3E22d' = '3E22d-Techniciens de recherche-développement et des méthodes de fabrication en construction mécanique et travail des métaux', 
                      '3E22e' = '3E22e-Techniciens de fabrication et de contrôle-qualité en construction mécanique et travail des métaux', 
                      '3E22f' = '3E22f-Techniciens de production et de contrôle-qualité des industries de transformation', 
                      '3E22g' = '3E22g-Techniciens de la logistique, du planning et de l’ordonnancement', 
                      '3E23a' = '3E23a-Techniciens d’installation et de maintenance des équipements industriels (électriques, électromécaniques, mécaniques, hors informatique)', 
                      '3E23b' = '3E23b-Techniciens d’installation et de maintenance des équipements non industriels (hors informatique et télécommunications)', 
                      '3E24a' = '3E24a-Techniciens d’étude et de conseil en agriculture, eaux et forêt', 
                      '3E24b' = '3E24b-Dessinateurs du BTP', 
                      '3E24c' = '3E24c-Dessinateurs en électricité, électromécanique et électronique', 
                      '3E24d' = '3E24d-Dessinateurs en construction mécanique et travail des métaux', 
                      '3E24e' = '3E24e-Technicien\\u00b7nes de recherche-développement et des méthodes de production des industries de transformation', 
                      '3E24f' = '3E24f-Technicien\\u00b7nes des laboratoires (hors public)', 
                      '3E25a' = '3E25a-Techniciens d’étude et de développement en informatique', 
                      '3E25b' = '3E25b-Techniciens de production, d’exploitation en informatique', 
                      '3E25c' = '3E25c-Techniciens d’installation, de maintenance, support et services aux utilisateurs en informatique', 
                      '3E25d' = '3E25d-Techniciens des télécommunications et de l’informatique des réseaux', 
                      '3E26a' = paste0('3E26a-Géomètres, topographes ', m), 
                      '3E26b' = '3E26b-Métreurs et techniciens divers du BTP', 
                      '3E26c' = '3E26c-Technicien\\u00b7nes des travaux public (hors état/CL)', 
                      '3E26d' = '3E26d-Assistants techniques, techniciens de l’imprimerie et de l’édition', 
                      '3E26e' = '3E26e-Technicien\\u00b7nes de l’industrie des matériaux souples, de l’ameublement et du bois', 
                      '3E26f' = '3E26f-Techniciens de l’environnement et du traitement des pollutions', 
                      '3E26g' = '3E26g-Experts salariés ou indépendants de niveau technicien, techniciens divers', 
                      '3F30a' = '3F30a-Technicien\\u00b7nes médica\\u00b7les', 
                      '3F30b' = '3F30b-Préparatrices en pharmacie', 
                      '3H00a' = paste0('3H00a-Maîtrise de restauration : salle et service ', b), 
                      '3H00b' = paste0('3H00b-Maîtrise de l’hébergement : hall et étages ', b), 
                      '3H00c' = paste0('3H00c-Maîtrise de restauration et de cuisine ', m), 
                      '4F10a' = '4F10a-Médecins hospitalier\\u00b7es sans activité libérale', 
                      '4F10b' = paste0('4F10b-Internes en médecine, odontologie et pharmacie ', b), 
                      '4F20a' = '4F20a-Infirmières psychiatriques', 
                      '4F20b' = '4F20b-Puéricultrices', 
                      '4F20c' = '4F20c-Infirmières spécialisées (autres)', 
                      '4F20d' = '4F20d-Infirmières (en soins généraux)', 
                      '4F41a' = '4F41a-Médecins libéra\\u00b7les spécialistes', 
                      '4F41b' = '4F41b-Médecins libéra\\u00b7les généralistes', 
                      '4F41c' = '4F41c-Chirurgien\\u00b7nes dentistes (libéra\\u00b7les ou salarié\\u00b7es)', 
                      '4F41d' = '4F41d-Vétérinaires (libéra\\u00b7les ou salarié\\u00b7es)', 
                      '4F41e' = '4F41e-Médecins salarié\\u00b7es non hospitalier\\u00b7es', 
                      '4F42a' = paste0('4F42a-Spécialistes de la réÉducation ', f), 
                      '4F43a' = paste0('4F43a-Sages-femmes ', f), 
                      '4F44a' = '4F44a-Pharmacien\\u00b7nes libéra\\u00b7les', 
                      '4F44b' = '4F44b-Pharmaciennes salariées', 
                      '4F45a' = paste0('4F45a-Psychologues, psychanalystes, psychothérapeutes ', f), 
                      '4F45b' = paste0('4F45b-Psychologues spécialistes de l’orientation scolaire et professionnelle ', f), 
                      '4I11a' = '4I11a-Enseignant\\u00b7es de l’enseignement supérieur', 
                      '4I12a' = '4I12a-Chercheu\\u00b7ses de la recherche publique', 
                      '4I13a' = '4I13a-Professeur\\u00b7es agrégé\\u00b7es et certifié\\u00b7es de l’enseignement secondaire', 
                      '4I13b' = '4I13b-Professeur\\u00b7es d’enseignement général des collèges', 
                      '4I13c' = '4I13c-Professeur\\u00b7es de lycée professionnel', 
                      '4I13d' = '4I13d-Professeur\\u00b7es contractuel\\u00b7les de l’enseignement secondaire (et maître\\u00b7sses auxiliaires)', 
                      '4I13e' = '4I13e-Conseillères principales d’Éducation', 
                      '4I14a' = '4I14a-Professeures des écoles', 
                      '4I21a' = '4I21a-Éducatrices spécialisées', 
                      '4I21b' = '4I21b-Monit\\u00b7rices Éducat\\u00b7rices', 
                      '4I21c' = '4I21c-Éducat\\u00b7rices techniques spécialisé\\u00b7es, monit\\u00b7rices d’atelier', 
                      '4I21d' = '4I21d-Éducatrices de jeunes enfants', 
                      '4I22a' = '4I22a-Assistantes sociales', 
                      '4I23a' = '4I23a-Conseillères en économie sociale familiale', 
                      '4I32a' = '4I32a-Animatrices socioculturels et de loisirs', 
                      '4I33a' = '4I33a-Monit\\u00b7rices d’école de conduite', 
                      '4I33b' = '4I33b-Format\\u00b7rices et animat\\u00b7rices de formation continue', 
                      '4I34a' = '4I34a-Éducat\\u00b7rices sporti\\u00b7ves (et sporti\\u00b7ves professionnel\\u00b7les)', 
                      '4I35a' = paste0('4I35a-Clergé ', m), 
                      '4J11a' = '4J11a-Aut\\u00b7rices littéraires, scénaristes, dialoguistes', 
                      '4J11b' = '4J11b-Artistes plasticien\\u00b7nes', 
                      '4J11c' = paste0('4J11c-Artistes de la musique et du chant ', m), 
                      '4J11d' = '4J11d-Artistes dramatiques, danseu\\u00b7ses', 
                      '4J12a' = paste0('4J12a-Cadres artistiques et technico-artistiques de la réalisation de l’audiovisuel et des spectacles ', m), 
                      '4J13a' = '4J13a-Professeur\\u00b7es d’art (hors établissements scolaires)', 
                      '4J21a' = '4J21a-Avocat\\u00b7es', 
                      '4J21b' = paste0('4J21b-Notaires ', b), 
                      '4J21c' = '4J21c-Architectes libéraux', 
                      '4J22a' = paste0('4J22a-Journalistes ', b, ' (y. c. rédact\\u00b7rices en chef)'), 
                      '4J23a' = '4J23a-Magistrat\\u00b7es', 
                      '4J24a' = paste0('4J24a-Professionnels de la politique et permanents syndicaux ', m), 
                      '4J25a' = '4J25a-Géomètres-experts, huissier\\u00b7es de justice, officiers ministériel\\u00b7les, professions libérales diverses', 
                      '4J25b' = '4J25b-Aides familiales non salariées de professions libérales effectuant un travail administratif', 
                      '5B11a' = '5B11a-Vendeu\\u00b7ses en ameublement, décor, équipement du foyer', 
                      '5B11b' = '5B11b-Vendeurs en droguerie, bazar, quincaillerie, bricolage', 
                      '5B11c' = '5B11c-Vendeuses du commerce de fleurs', 
                      '5B11d' = '5B11d-Vendeuses en habillement et articles de sport', 
                      '5B11e' = '5B11e-Vendeuses en produits de beauté, de luxe (hors biens culturels) et optique', 
                      '5B11f' = '5B11f-Vendeuses de biens culturels (livres, disques, multimédia, objets d’art)', 
                      '5B11g' = '5B11g-Vendeuses en gros de biens d’équipement, biens intermédiaires', 
                      '5B12a' = '5B12a-Vendeuses non spécialisées', 
                      '5B12b' = '5B12b-Vendeuses en alimentation', 
                      '5B12c' = '5B12c-Vendeu\\u00b7ses de tabac, presse et articles divers', 
                      '5B12d' = '5B12d-Pompistes et gérant\\u00b7es de station-service (salarié\\u00b7es ou mandataires)', 
                      '5B12e' = '5B12e-Vendeuses par correspondance', 
                      '5B13a' = '5B13a-Employé\\u00b7es de libre service du commerce et magasinier\\u00b7es', 
                      '5B13b' = '5B13b-Caissières', 
                      '5B22a' = '5B22a-Petit\\u00b7es et moyen\\u00b7nes détaillant\\u00b7es en alimentation générale', 
                      '5B22b' = '5B22b-Détaillant\\u00b7e\\u00b7s en ameublement, décor, équipement du foyer', 
                      '5B22c' = '5B22c-Détaillants en droguerie, bazar, quincaillerie, bricolage', 
                      '5B22d' = paste0('5B22d-Fleuristes ', f), 
                      '5B22e' = '5B22e-Détaillant\\u00b7es en habillement et articles de sport', 
                      '5B22f' = '5B22f-Détaillant\\u00b7es en produits de beauté, de luxe (hors biens culturels)', 
                      '5B22g' = '5B22g-Détaillant\\u00b7es en biens culturels (livres, disques, multimédia, objets d’art)', 
                      '5B22h' = '5B22h-Détaillants\\u00b7e en tabac, presse et articles divers', 
                      '5B22i' = '5B22i-Exploitant\\u00b7es et gérant\\u00b7es libres de station-service', 
                      '5C01a' = '5C01a-Agentes des Finances publiques (et des Douanes)', 
                      '5C02a' = '5C02a-Employées des services commerciaux de la banque', 
                      '5C03a' = '5C03a-Employées des services techniques de la banque', 
                      '5C03b' = '5C03b-Employées d’assurance', 
                      '5D01a' = '5D01a-Employées de bureau de la fonction publique', 
                      '5D01b' = '5D01b-Employées de bureau du public classées entreprise', 
                      '5D02a' = paste0('5D02a-Standardistes et téléphonistes ', f), 
                      '5D02b' = paste0('5D02b-Dactylos ', b, ' (sans secrétariat)'), 
                      '5D03a' = '5D03a-Employées de la Sécurité sociale', 
                      '5D04a' = '5D04a-Employé\\u00b7es de la Poste et de France Télécom', 
                      '5D05a' = '5D05a-Hôtesses d’accueil', 
                      '5D05b' = '5D05b-Contrôleu\\u00b7ses des transports', 
                      '5D05c' = '5D05c-Agent\\u00b7es des services commerciaux des transports de voyageurs et du tourisme', 
                      '5D05d' = '5D05d-Agent\\u00b7es d’accompagnement (transports, tourisme)', 
                      '5D06a' = paste0('5D06a-Secrétaires ', f), 
                      '5D07a' = '5D07a-Employées des services comptables ou financiers', 
                      '5D08a' = '5D08a-Employées administratives diverses d’entreprise', 
                      '5D08b' = '5D08b-Employé\\u00b7es et opérat\\u00b7rices d’exploitation en informatique', 
                      '5D08c' = '5D08c-Employé\\u00b7es administrati\\u00b7ves d’exploitation des transports de marchandises', 
                      '5F00a' = '5F00a-Aides-soignantes', 
                      '5F00b' = '5F00b-Assistantes dentaires, médicales et vétérinaires, aides de techniciennes médicales', 
                      '5F00c' = paste0('5F00c-Auxiliaires de puériculture ', f), 
                      '5F00d' = paste0('5F00d-Aides médico-psychologiques ', f), 
                      '5F00e' = '5F00e-Ambulanciers', 
                      '5G10a' = '5G10a-Agents de police', 
                      '5G21a' = '5G21a-Adjudants-chefs, adjudants et sous-officiers de rang supérieur de l’Armée et de la Gendarmerie', 
                      '5G22a' = paste0('5G22a-Gendarmes (grade < adjudant) ', m), 
                      '5G23a' = '5G23a-Sergents (et autres sous-officiers)', 
                      '5G23b' = paste0('5G23b-Militaires ', m), 
                      '5G24a' = '5G24a-Pompiers (dont militaires)', 
                      '5G31a' = '5G31a-Agents de sécurité', 
                      '5G32a' = '5G32a-Surveillants pénitentiaires', 
                      '5G32b' = '5G32b-Agents techniques forestiers, gardes des espaces naturels', 
                      '5H11a' = '5H11a-Agentes de service des établissements scolaires', 
                      '5H11b' = '5H11b-Autres agent\\u00b7es de service de la fonction publique', 
                      '5H11c' = '5H11c-Agentes de service hospitalieres', 
                      '5H11d' = paste0('5H11d-PSP de la FP classées privé (assmat, aides à domicile) ', f), 
                      '5H12a' = '5H12a-Serveu\\u00b7ses', 
                      '5H12b' = '5H12b-Aides-cuisinier\\u00b7es', 
                      '5H12c' = '5H12c-Employées de l’hôtellerie', 
                      '5H12d' = '5H12d-Esthéticiennes (salariées)', 
                      '5H12e' = '5H12e-Coiffeuses (salariées)', 
                      '5H13a' = '5H13a-Assistantes maternelles', 
                      '5H13b' = paste0('5H13b-Aides à domicile ', f), 
                      '5H13c' = paste0('5H13c-Employées de maison ', f), 
                      '5H13d' = paste0('5H13d-Concierges ', b), 
                      '5H14a' = '5H14a-Employées des services divers', 
                      '5H21a' = '5H21a-Artisanes coiffeuses, manucures, esthéticiennes', 
                      '5H21b' = '5H21b-Artisanes teinturieres, blanchisseuses', 
                      '5H21c' = '5H21c-Artisan\\u00b7es des services divers', 
                      '5H21d' = '5H21d-Aides familiales non salariées ou associées d’artisanes, effectuant un travail administratif ou commercial', 
                      '5H22a' = '5H22a-Exploitant\\u00b7es de petit restaurant, café-restaurant, de 0 à 2 salariés', 
                      '5H22b' = '5H22b-Exploitant\\u00b7es de petit café, débit de boisson, associé ou non à une autre activité hors restauration, de 0 à 2 salariés', 
                      '5H22c' = '5H22c-Exploitant\\u00b7es de petit hôtel, hôtel-restaurant, de 0 à 2 salariés', 
                      '6E10a' = '6E10a-Mineurs de fond qualifiés', 
                      '6E11a' = '6E11a-Chefs d’équipe du BTP', 
                      '6E11b' = '6E11b-Ouvriers qualifiés du travail du béton', 
                      '6E11c' = '6E11c-Conducteurs qualifiés d’engins de chantiers du BTP', 
                      '6E11d' = '6E11d-Ouvriers des travaux publics en installations électriques et de télécommunications', 
                      '6E11e' = '6E11e-Autres ouvriers qualifiés des travaux publics', 
                      '6E11f' = '6E11f-Ouvriers qualifiés des travaux publics (état/CL)', 
                      '6E12a' = '6E12a-Opérat\\u00b7rices qualifié\\u00b7es sur machines automatiques en production électrique ou électronique', 
                      '6E12b' = '6E12b-Câbleurs et bobiniers', 
                      '6E12c' = '6E12c-Plateformistes, contrôleu\\u00b7ses qualifié\\u00b7es de matériel électrique ou électronique', 
                      '6E13a' = '6E13a-Chaudronniers, forgerons, traceurs', 
                      '6E13b' = '6E13b-Tuyauteurs industriels qualifiés', 
                      '6E13c' = '6E13c-Soudeurs qualifiés sur métaux', 
                      '6E13d' = '6E13d-Opérateurs qualifiés d’usinage des métaux travaillant à l’unité ou en petite série, moulistes qualifiés', 
                      '6E13e' = '6E13e-Opérateurs qualifiés d’usinage des métaux sur autres machines (sauf moulistes)', 
                      '6E13f' = '6E13f-Monteurs qualifiés d’ensembles mécaniques', 
                      '6E13g' = '6E13g-Monteurs qualifiés en structures métalliques', 
                      '6E13h' = '6E13h-Ouvrier\\u00b7es qualifié\\u00b7es de contrôle et d’essais en mécanique', 
                      '6E13i' = '6E13i-Ouvriers qualifiés des traitements thermiques et de surface sur métaux', 
                      '6E13j' = '6E13j-Autres mécaniciens ou ajusteurs qualifiés (ou spécialité non reconnue)', 
                      '6E14a' = '6E14a-Ouvrier\\u00b7es de la photogravure et des laboratoires photographiques et cinématographiques', 
                      '6E14b' = '6E14b-Ouvriers de l’impression', 
                      '6E15a' = paste0('6E15a-Pilotes d’installation lourde des industries de transformation : agroalimentaire, chimie, plasturgie, énergie ', b), 
                      '6E15b' = '6E15b-Ouvriers de laboratoire (agroalimentaire, chimie, biologie, pharmacie)', 
                      '6E15c' = '6E15c-Ouvrier\\u00b7es des abattoirs', 
                      '6E15d' = '6E15d-Autres ouvriers (qualifiés) de l’industrie agro-alimentaire', 
                      '6E15e' = '6E15e-Ouvriers des industries de transformation (métallurgie, production verrière, matériaux de construction)', 
                      '6E15f' = '6E15f-Opérateurs et ouvriers qualifiés des industries lourdes du bois et de la fabrication du papier-carton', 
                      '6E16a' = '6E16a-Opérat\\u00b7rices qualifié\\u00b7es du textile et de la mégisserie', 
                      '6E16b' = '6E16b-Ouvrier\\u00b7es qualifié\\u00b7es de la coupe des vêtements et de l’habillement, autres opérat\\u00b7rices de confection qualifié\\u00b7es', 
                      '6E16c' = '6E16c-Ouvrier\\u00b7es qualifié\\u00b7es du travail industriel du cuir', 
                      '6E17a' = '6E17a-Ouvriers qualifiés de scierie, de la menuiserie industrielle et de l’ameublement', 
                      '6E18a' = '6E18a-Mécaniciens qualifiés de maintenance, entretien : équipements industriels', 
                      '6E18b' = '6E18b-Electromécaniciens, électriciens qualifiés d’entretien : équipements industriels', 
                      '6E18c' = '6E18c-Régleurs qualifiés d’équipements de fabrication (travail des métaux, mécanique)', 
                      '6E18d' = '6E18d-Régleurs qualifiés d’équipements de fabrication (hors travail des métaux et mécanique)', 
                      '6E19a' = '6E19a-Ouvriers qualifiés des autres industries (eau, gaz, énergie, chauffage)', 
                      '6E19b' = '6E19b-Ouvriers qualifiés de l’assainissement et du traitement des déchets', 
                      '6E19c' = '6E19c-Agent\\u00b7es qualifié\\u00b7es de laboratoire (sauf chimie, santé)', 
                      '6E19d' = '6E19d-Ouvriers qualifiés divers de type industriel', 
                      '6E21a' = '6E21a-Jardiniers', 
                      '6E22a' = '6E22a-Charpentiers en bois qualifiés', 
                      '6E22b' = '6E22b-Menuisiers qualifiés du bâtiment', 
                      '6E23a' = '6E23a-Maçons qualifiés', 
                      '6E23b' = '6E23b-Ouvriers qualifiés du travail de la pierre', 
                      '6E23c' = '6E23c-Couvreurs qualifiés', 
                      '6E23d' = '6E23d-Plombiers et chauffagistes qualifiés', 
                      '6E23e' = '6E23e-Ouvriers qualifiés des finitions du BTP', 
                      '6E23f' = '6E23f-Monteurs qualifiés en agencement, isolation', 
                      '6E23g' = '6E23g-Ouvriers qualifiés d’entretien général des bâtiments', 
                      '6E24a' = '6E24a-Électriciens qualifiés de type artisanal (y.c. bâtiment)', 
                      '6E24b' = '6E24b-Dépanneurs qualifiés en radiotélévision, électroménager, matériel électronique (salariés)', 
                      '6E24c' = '6E24c-Électriciens, électroniciens qualifiés d’entretien d’équipements non industriels', 
                      '6E24d' = '6E24d-Électriciens, électroniciens qualifiés d’entretien d’équipements non industriels', 
                      '6E25a' = '6E25a-Carrossiers d’automobiles qualifiés', 
                      '6E25b' = '6E25b-Métalliers, serruriers qualifiés', 
                      '6E25c' = '6E25c-Mécaniciens qualifiés en maintenance, entretien, réparation : automobile', 
                      '6E25d' = '6E25d-Mécaniciens qualifiés en maintenance, entretien, réparation : automobile', 
                      '6E26a' = '6E26a-Tailleuses et couturières qualifiées (ouvrières qualifiées du travail des étoffes sauf fabrication de vêtements, ouvrieres qualifiées de type artisanal du travail du cuir)', 
                      '6E27a' = '6E27a-Bouchers (sauf industrie de la viande)', 
                      '6E27b' = '6E27b-Charcutiers (sauf industrie de la viande)', 
                      '6E27c' = '6E27c-Boulangers, pâtissiers (sauf activité industrielle)', 
                      '6E27d' = '6E27d-Cuisiniers et commis de cuisine', 
                      '6E28a' = '6E28a-Modeleuses et mouleuses', 
                      '6E28b' = '6E28b-Ouvrier\\u00b7es d’art', 
                      '6E28c' = '6E28c-Ouvriers et techniciens des spectacles vivants et audiovisuels', 
                      '6E28d' = '6E28d-Ouvrier\\u00b7es qualifié\\u00b7es divers\\u00b7es de type artisanal', 
                      '6E31a' = '6E31a-Conducteurs routiers et grands routiers (salariés)', 
                      '6E32a' = '6E32a-Conducteurs routiers de transport en commun (salariés)', 
                      '6E33a' = '6E33a-Conducteurs de taxi (salariés)', 
                      '6E33b' = '6E33b-Conducteurs de voiture particulière (salariés)', 
                      '6E34a' = '6E34a-Conducteurs de véhicule de ramassage des ordures ménagères', 
                      '6E34b' = '6E34b-Conducteurs d’engin lourd', 
                      '6E34c' = '6E34c-Conducteurs de trains', 
                      '6E35a' = paste0('6E35a-Dockers ', m), 
                      '6E35b' = paste0('6E35b-Matelots de la marine marchande et de la navigation fluviale ', m), 
                      '6E36a' = '6E36a-Autres agents et ouvriers qualifiés (sédentaires) des services d’exploitation des transports', 
                      '6E41a' = '6E41a-Ouvriers non qualifiés des travaux publics (état/CL)', 
                      '6E41b' = '6E41b-Ouvriers non qualifiés des travaux publics, du travail du béton et de l’extraction (privé)', 
                      '6E42a' = '6E42a-Ouvrier\\u00b7es non qualifié\\u00b7es de l’électricité et de l’électronique', 
                      '6E43a' = '6E43a-Ouvriers de production non qualifiés travaillant par enlèvement de métal', 
                      '6E43b' = '6E43b-Ouvriers de production non qualifiés travaillant par formage de métal', 
                      '6E43c' = '6E43c-Ouvriers non qualifiés de montage, contrôle en mécanique et travail des métaux', 
                      '6E44a' = '6E44a-Ouvrier\\u00b7es de production non qualifié\\u00b7es : chimie, pharmacie, plasturgie', 
                      '6E44b' = paste0('6E44b-ONQ des abattoirs ', b), 
                      '6E44c' = paste0('6E44c-Autres ONQ des industries agro-alimentaires ', b), 
                      '6E44d' = '6E44d-Ouvriers de production non qualifiés : métallurgie, production verrière, céramique, matériaux de construction', 
                      '6E44e' = '6E44e-Ouvriers de production non qualifiés : industrie lourde du bois, fabrication des papiers et cartons', 
                      '6E45a' = '6E45a-Ouvrier\\u00b7es non qualifié\\u00b7es du textile', 
                      '6E46a' = '6E46a-Ouvriers de production non qualifiés du travail du bois et de l’ameublement', 
                      '6E46b' = '6E46b-Ouvrier\\u00b7es non qualifié\\u00b7es de l’imprimerie, presse, édition', 
                      '6E46c' = '6E46c-Agents non qualifiés des services d’exploitation des transports', 
                      '6E46d' = '6E46d-Ouvrier\\u00b7es non qualifié\\u00b7es divers\\u00b7es de type industriel', 
                      '6E51a' = '6E51a-Manutentionnaires, magasiniers, caristes', 
                      '6E52a' = '6E52a-Coursiers et livreurs', 
                      '6E53a' = '6E53a-Déménageurs non qualifiés', 
                      '6E53b' = paste0('6E53b-ONQ du tri, de l’emballage, de l’expédition ', b), 
                      '6E61a' = '6E61a-Ouvriers non qualifiés du gros oeuvre du bâtiment', 
                      '6E61b' = '6E61b-Ouvriers non qualifiés du second oeuvre du bâtiment', 
                      '6E62a' = '6E62a-Métalliers, serruriers, réparateurs en mécanique non qualifiés', 
                      '6E63a' = '6E63a-Apprentis boulangers, bouchers, charcutiers', 
                      '6E64a' = '6E64a-Nettoyeuses', 
                      '6E64b' = '6E64b-Ouvriers non qualifiés de l’assainissement et du traitement des déchets', 
                      '6E65a' = '6E65a-Ouvrier\\u00b7es non qualifié\\u00b7es divers\\u00b7es de type artisanal', 
                      '6E71a' = '6E71a-Artisans maçons', 
                      '6E71b' = '6E71b-Artisans menuisiers du bâtiment, charpentiers en bois', 
                      '6E71c' = '6E71c-Artisans plombiers,  couvreurs,  chauffagistes', 
                      '6E71d' = '6E71d-Artisans électriciens du bâtiment', 
                      '6E71e' = '6E71e-Artisans de la peinture et des finitions du bâtiment', 
                      '6E71f' = '6E71f-Artisans serruriers, métalliers', 
                      '6E71g' = '6E71g-Artisans  en terrassement,  travaux publics,  parcs et jardins', 
                      '6E72a' = '6E72a-Artisans mécaniciens en machines agricoles', 
                      '6E72b' = '6E72b-Artisans chaudronniers', 
                      '6E72c' = '6E72c-Artisans en mécanique générale, fabrication et travail des métaux (hors horlogerie et matériel de précision)', 
                      '6E73a' = '6E73a-Artisanes de l’habillement, du textile et du cuir', 
                      '6E74a' = '6E74a-Artisans de l’ameublement', 
                      '6E74b' = '6E74b-Artisans du travail mécanique du bois', 
                      '6E75a' = '6E75a-Artisan\\u00b7es boulanger\\u00b7es, pâtissier\\u00b7es', 
                      '6E75b' = '6E75b-Artisans bouchers', 
                      '6E75c' = '6E75c-Artisans charcutiers', 
                      '6E75d' = '6E75d-Autres artisans de l’alimentation', 
                      '6E76a' = '6E76a-Artisans mécaniciens réparateurs d’automobiles', 
                      '6E76b' = '6E76b-Artisans tôliers carrossiers d’automobiles', 
                      '6E76c' = '6E76c-Artisans réparateurs divers', 
                      '6E77a' = '6E77a-Conducteurs de taxis, ambulanciers et autres artisans du transport', 
                      '6E77b' = '6E77b-Artisans déménageurs', 
                      '6E77c' = '6E77c-Transporteurs indépendants routiers et fluviaux', 
                      '6E78a' = '6E78a-Artisans du papier, de l’imprimerie et de la reproduction', 
                      '6E78b' = '6E78b-Artisans de fabrication en matériaux de construction (hors artisanat d’art)', 
                      '6E78c' = '6E78c-Artisan\\u00b7es d’art', 
                      '6E78d' = '6E78d-Autres artisan\\u00b7es de fabrication (y.c. horloger.es, matériel de précision)', 
                      '7K11a' = '7K11a-Agriculteurs sur grande exploitation de céréales grandes cultures', 
                      '7K11b' = '7K11b-Maraîchers, horticulteurs, sur grande exploitation', 
                      '7K11c' = '7K11c-Viticulteurs, arboriculteurs fruitiers, sur grande exploitation', 
                      '7K11d' = '7K11d-Éleveurs d’herbivores, sur grande exploitation', 
                      '7K11e' = '7K11e-Éleveurs de granivores et éleveurs mixtes, sur grande exploitation', 
                      '7K11f' = '7K11f-Agriculteurs sur grande exploitation sans orientation dominante', 
                      '7K12a' = '7K12a-Agriculteurs sur moyenne exploitation de céréales grandes cultures', 
                      '7K12b' = '7K12b-Maraîcher\\u00b7es, horticult\\u00b7rices sur moyenne exploitation', 
                      '7K12c' = '7K12c-Viticulteurs, arboriculteurs fruitiers, sur moyenne exploitation', 
                      '7K12d' = '7K12d-Éleveurs d’herbivores sur moyenne exploitation', 
                      '7K12e' = '7K12e-Éleveu\\u00b7ses de granivores et éleveurs mixtes, sur moyenne exploitation', 
                      '7K12f' = '7K12f-Agriculteurs sur moyenne exploitation sans orientation dominante', 
                      '7K12g' = '7K12g-Entrepreneurs de travaux agricoles à façon', 
                      '7K12h' = '7K12h-Exploitants forestiers indépendants', 
                      '7K12i' = '7K12i-Patrons pêcheurs et aquaculteurs', 
                      '7K13a' = '7K13a-Agriculteurs sur petite exploitation de céréales-grandes cultures', 
                      '7K13b' = '7K13b-Maraîcher\\u00b7es, horticult\\u00b7rices sur petite exploitation', 
                      '7K13c' = '7K13c-Viticult\\u00b7rices, arboricult\\u00b7rices fruitier\\u00b7es, sur petite exploitation', 
                      '7K13d' = '7K13d-Éleveu\\u00b7ses d’herbivores, sur petite exploitation', 
                      '7K13e' = '7K13e-Éleveu\\u00b7ses de granivores et éleveu\\u00b7ses mixtes, sur petite exploitation', 
                      '7K13f' = '7K13f-Agriculteurs sur petite exploitation sans orientation dominante', 
                      '7K20a' = '7K20a-Conducteurs d’engin agricole ou forestier', 
                      '7K20b' = '7K20b-Ouvrier\\u00b7es de l’élevage', 
                      '7K20c' = '7K20c-Ouvrier\\u00b7es du maraîchage ou de l’horticulture', 
                      '7K20d' = '7K20d-Ouvriers de la viticulture ou de l’arboriculture fruitière', 
                      '7K20e' = '7K20e-Ouvriers agricoles sans spécialisation particulière', 
                      '7K20f' = '7K20f-Ouvriers de l’exploitation forestière ou de la sylviculture', 
                      '7K20g' = '7K20g-Marins pêcheurs et ouvriers de l’aquaculture'
    )
    PPP4_to_name <- PPP4_to_name %>% 
      stringi::stri_unescape_unicode() %>% 
      purrr::set_names(names(PPP4_to_name))
    
    
    PPP1_to_name <- tibble::tribble(
      ~chiffre,   ~fem                                                    , ~masc                                                          , ~both     ,
      '1', 'Cheffes d’entreprise'                                         , 'Chefs d’entreprise'                                           , 'Chef\\u00b7fes d’entreprise'                                           ,
      '2', paste('Cadres (et consultantes libérales)', f)                 , paste0('Cadres (et consultants libéraux) ', m)                 , paste0('Cadres (et consultant\\u00b7es libéra\\u00b7les) ', b)                    ,
      '3', paste0('Cols blancs subalternes ', f)                          , paste0('Cols blancs subalternes ', m)                          , paste0('Cols blancs subalternes ', b)                              ,
      '4', 'Professionnelles reconnues'                                   , 'Professionnels reconnus'                                      , 'Professionnel\\u00b7les reconnu\\u00b7es'                                             ,
      '5', 'Employées (dont artisanes des services, petites commerçantes)', 'Employés (dont artisans des services, petits commerçants)'    , 'Employé\\u00b7es (dont artisa\\u00b7nes des services, petit\\u00b7es commerçant\\u00b7es)',
      '6', 'Ouvrières (dont artisanes)'                                   , 'Ouvriers (dont artisans)'                                     , 'Ouvrier\\u00b7es (dont artisan\\u00b7es)'                                     ,
      '7', 'Agricultrices et ouvrières agricoles'                         , 'Agriculteurs et ouvriers agricoles'                           , 'Agricult\\u00b7rices et ouvrier\\u00b7es agricoles'                           ,
    ) %>% 
      dplyr::mutate(dplyr::across(tidyselect::all_of(c("fem", "masc", "both")), 
                                  stringi::stri_unescape_unicode))
    
    
    FAPPP_to_name <- c('A' = 'A-Filière patronale',
                       'B' = 'B-Filière commerciale',
                       'C' = 'C-Filière financière',
                       'D' = 'D-Filière administrative',
                       'E' = 'E-Filière technique',
                       'F' = 'F-Filière santé',
                       'G' = 'G-Filière sécurité',
                       'H' = 'H-Filière services pers',
                       'I' = 'I-Filière éduc-social',
                       'J' = 'J-Filière prof intel div',
                       'K' = 'K-Filière agricole'       ) 
    FAPPP_to_name <- FAPPP_to_name %>% 
      stringi::stri_unescape_unicode() %>% 
      purrr::set_names(names(FAPPP_to_name))
    
    PPP2_to_name <- tibble::tribble(
      ~chiffre, ~fem                                            , ~masc                                              , ~both     ,
      '1A0', 'Cheffes d’entreprise'                             , 'Chefs d’entreprise'                               , 'Chef\\u00b7fes d’entreprise'                               ,
      '2B0', 'Cadres commerciales'                              , 'Cadres commerciaux'                               , 'Cadres commercia\\u00b7les'                               ,
      '2C0', 'Inspectrices FiP / Cadres banque'                 , 'Inspecteurs FiP / Cadres banque'                  , 'Inspecteurs/trices FiP, Cadres banque'           ,
      '2D2', 'Cadres administratives'                           , 'Cadres administratifs'                            , 'Cadres administratifs/tives'                          ,
      '2E2', 'Ingénieures'                                      , 'Ingénieurs'                                       , 'Ingénieur\\u00b7es'                                       ,
      '2F0', paste0('Cadres de santé ', f)                      , paste0('Cadres de santé ', m)                      , paste0('Cadres de santé ', b)                               ,
      '2G0', 'Officières de la police et de l’armée'            , 'Officiers de la police et de l’armée'             , 'Officier\\u00b7es de la police et de l’armée'             ,
      '2H0', paste0('Cadres hôtellerie restauration ', f)       , paste0('Cadres hôtellerie restauration ', m)       ,paste0('Cadres hôtellerie restauration ', b)                    ,
      '2I1', 'Proviseures et inspectrices EN'                   , 'Proviseurs et inspecteurs EN'                     , 'Proviseur\\u00b7es et  inspecteurs/trices EN'                  ,
      '2I2', paste0('Cadres du social ', f)                     , paste0('Cadres du social ', m)                     , paste0('Cadres du social ', b)                                 ,
      '2J0', paste0('Cadres de la culture', f)                  , paste0('Cadres de la culture', m)                  , paste0('Cadres de la culture', b)                              ,
      '3B1', paste0('CBS commerce ', f)                         , paste0('CBS commerce ', m)                         , paste0('CBS commerce ', b)                                ,
      '3B2', 'Moyennes commerçantes (et ass.)'                  , 'Moyens commerçants (et ass.)'                     , 'Moyen\\u00b7nes commerçant\\u00b7es (et ass.)'         ,
      '3C0', 'Contrôleuses FiP / CBS banque '                   , 'Contrôleurs FiP / CBS banque '                    , 'Contrôleurs/leuses FiP / CBS banque '                 ,
      '3D0', paste0('CBS de bureau ', f)                        , paste0('CBS de bureau ', m)                        , paste0('CBS de bureau ', b)                                 ,
      '3E1', paste0('Maîtrise ', f)                             , paste0('Maîtrise ', m)                             , paste0('Maîtrise ', b)                                      ,
      '3E2', 'Techniciennes'                                    , 'Techniciens'                                      , 'Technicien\\u00b7nes'                                      ,
      '3F3', 'Techniciennes médicales (et ass.)'                , 'Techniciens médicaux (et ass.)'                   , 'Technicien\\u00b7nes médica\\u00b7les (et ass.)'                                    ,
      '3H0', paste0('Maitrise hotel-rest ', f)                  , paste0('Maitrise hotel-rest ', m)                  , paste0('Maitrise hotel-rest ', b)                         ,
      '4F1', 'Médecins hospitalières'                           , 'Médecins hospitaliers'                            , 'Médecins hospitalier\\u00b7es'                          ,
      '4F2', 'Infirmières'                                      , 'Infirmiers'                                       , 'Infirmie\\u00b7res'                                      ,
      '4F4', paste0('Santé autres ', f)                         , paste0('Santé autres ', m)                         , paste0('Santé autres ', b)                                  ,
      '4I1', 'Enseignantes'                                     , 'Enseignants'                                      , 'Enseignant\\u00b7es'                                    ,
      '4I2', 'Travailleuses sociales'                           , 'Travailleurs sociaux'                             , 'Travailleu\\u00b7ses socia\\u00b7les'                           ,
      '4I3', paste0('Educ social autres ', f)                   , paste0('Educ social autres ', m)                   , paste0('Educ social autres ', b)                          ,
      '4J1', paste0('Professions artistiques ', f)              , paste0('Professions artistiques ', m)              , paste0('Professions artistiques ', b)                                    ,
      '4J2', paste0('Prof intel divers ', f)                    , paste0('Prof intel divers ', m)                    , paste0('Prof intel divers ', b)                           ,
      '5B1', 'Employées commerce'                               , 'Employés commerce'                                , 'Employé\\u00b7es commerce'                               ,
      '5B2', 'Petites commerçantes'                             , 'Petits commerçants'                               , 'Petit\\u00b7es commerçant\\u00b7es'                           ,
      '5C0', 'Agentes adm. FiP / Employées banque'              , 'Agents adm. FiP / Employés banque'                , 'Agent\\u00b7es adm. FiP / Employé\\u00b7es banque'             ,
      '5D0', 'Employées de bureau'                              , 'Employés de bureau'                               , 'Employé\\u00b7es de bureau'                                 ,
      '5F0', 'Aides-soignantes'                                 , 'Aides-soignants'                                  , 'Aides-soignant\\u00b7es'                                 ,
      '5G1', 'Policières et gendarmes'                          , 'Policiers et gendarmes'                           , 'Policier\\u00b7es et gendarmes'                                        ,
      '5G2', 'Militaires et pompières'                          , 'Militaires et pompiers'                           , 'Militaires et pompier\\u00b7es'                              ,
      '5G3', 'Agentes de surveillance'                          , 'Agents de surveillance'                           , 'Agent\\u00b7es de surveillance'                                     ,
      '5H1', 'Employées services à la personne'                 , 'Employés services à la personne'                  , 'Employé\\u00b7es services à la personne'                 ,
      '5H2', 'Artisanes des services'                           , 'Artisans des services'                            , 'Artisan\\u00b7es des services'                          ,
      '6E1', 'Ouvrières Q indus'                                , 'Ouvriers Q indus'                                 , 'Ouvrier\\u00b7es Q indus'                                 ,
      '6E2', 'Ouvrières Q arti'                                 , 'Ouvriers Q arti'                                  , 'Ouvrier\\u00b7es Q arti'                                  ,
      '6E3', 'Ouvrières Q logi'                                 , 'Ouvriers Q logi'                                  , 'Ouvrier\\u00b7es Q logi'                                  ,
      '6E4', 'Ouvrières NQ indus'                               , 'Ouvriers NQ indus'                                , 'Ouvrier\\u00b7es NQ indus'                                ,
      '6E5', 'Ouvrières NQ logi'                                , 'Ouvriers NQ logi'                                 , 'Ouvrier\\u00b7es NQ logi'                                 ,
      '6E6', 'Ouvrières NQ arti'                                , 'Ouvriers NQ arti'                                 , 'Ouvrier\\u00b7es NQ arti'                                 ,
      '6E7', 'Artisanes ouvrières'                              , 'Artisans ouvriers'                                , 'Artisan\\u00b7es ouvrier\\u00b7es'                                ,
      '7K1', 'Agricultrices'                                    , 'Agriculteurs'                                     , 'Agricult\\u00b7rices'                                     ,
      '7K2', 'Ouvrières agricoles'                              , 'Ouvriers agricoles'                               , 'Ouvrier\\u00b7es agricoles'                               ,
    ) %>% 
      dplyr::mutate(dplyr::across(tidyselect::all_of(c("fem", "masc", "both")), 
                                  stringi::stri_unescape_unicode))
    
    PPP3_to_name <- tibble::tribble(
      ~chiffre, ~fem                                                          , ~masc                                                          , ~both     ,
      '1A01', 'Cheffes de grande entreprise'                                  , 'Chefs de grande entreprise'                                   , 'Chef\\u00b7fes de grande entreprise'                                        ,
      '1A02', 'Cheffes de moyenne entreprise'                                 , 'Chefs de moyenne entreprise'                                  , 'Chef\\u00b7fes de moyenne entreprise'                                       ,
      '1A03', 'Cheffes de petite entreprise'                                  , 'Chefs de petite entreprise'                                   , 'Chef\\u00b7fes de petite entreprise'                                        ,
      '2B01', 'Cadres commerciales'                                           , 'Cadres commerciaux'                                           , 'Cadres commercia\\u00b7les'                                                 ,
      '2B02', paste0('Cadres d’exploitation du commerce de détail', f)        , paste0('Cadres d’exploitation du commerce de détail', m)       , paste0('Cadres d’exploitation du commerce de détail', b)               ,
      '2B03', paste0('Cadres de l’immobilier ', f)                            , paste0('Cadres de l’immobilier ', m)                           , paste0('Cadres de l’immobilier ', b)                                   ,
      '2B04', 'Ingénieures technico-commerciales'                             , 'Ingénieurs technico-commerciaux'                              , 'Ingénieur\\u00b7es technico-commerciaux'                                    ,
      '2C01', 'Inspectrices des Finances publiques (et Douanes)'              , 'Inspecteurs des Finances publiques (et Douanes)'              , 'Inspecteurs/trices des Finances publiques (et Douanes)'                    ,
      '2C02', 'Cadres commerciales de la banque'                              , 'Cadres commerciaux de la banque'                              , 'Cadres commercia\\u00b7les de la banque'                                    ,
      '2C03', paste0('Cadres des services techniques (bancassurance)', f)     , paste0('Cadres des services techniques (bancassurance)', m)    , paste0('Cadres des services techniques (bancassurance)', b)            ,
      '2C04', paste0('Cadres de la banque autres', f)                         , paste0('Cadres de la banque autres', m)                        , paste0('Cadres de la banque autres', b)                                ,
      '2D21', 'Cadres dirigeantes de la fonction publique'                    , 'Cadres dirigeants de la fonction publique'                    , 'Cadres dirigeant\\u00b7es de la fonction publique'                          ,
      '2D22', 'Cadres dirigeantes des entreprises'                            , 'Cadres dirigeants des entreprises'                            , 'Cadres dirigeant\\u00b7es des entreprises'                                  ,
      '2D23', 'Consultantes libérales'                                        , 'Consultants libéraux'                                         , 'Consultant\\u00b7es libéra\\u00b7les'                                             ,
      '2D24', 'Cadres publiques administratives'                              , 'Cadres publics administratifs'                                , 'Cadres publi\\u00b7ques administratifs/tives'                                   ,
      '2D25', paste0('Cadres gestionnaires ', f)                              , paste0('Cadres gestionnaires ', m)                             , paste0('Cadres gestionnaires ', b)                                     ,
      '2D26', paste0('Cadres de la Sécurité sociale ', f)                     , paste0('Cadres de la Sécurité sociale ', m)                    , paste0('Cadres de la Sécurité sociale ', b)                            ,
      '2D27', paste0('Cadres de la Poste ', f, ' (et France Telecom)')        , paste0('Cadres de la Poste ', m, ' (et France Telecom)')       , paste0('Cadres de la Poste ', b, ' (et France Telecom)')               ,
      '2D28', paste0('Cadres d’entreprise autres ', f)                        , paste0('Cadres d’entreprise autres ', m)                       , paste0('Cadres d’entreprise autres ', b)                               ,
      '2E21', 'Directrices techniques'                                        , 'Directeurs techniques'                                        , 'Direct\\u00b7rices techniques'                                              ,
      '2E22', 'Ingénieures libérales'                                         , 'Ingénieurs libéraux'                                          , 'Ingénieur\\u00b7es libéra\\u00b7les'                                              ,
      '2E23', 'Ingénieures publiques'                                         , 'Ingénieurs publics'                                           , 'Ingénieur\\u00b7es publi\\u00b7ques'                                              ,
      '2E25', paste0('Cadres de production ', f)                              , paste0('Cadres de production ', m)                             , paste0('Cadres de production ', b)                                     ,
      '2E26', paste0('Cadres techniques ', f)                                 , paste0('Cadres techniques ', m)                                , paste0('Cadres techniques ', b)                                        ,
      '2E27', 'Ingénieures en informatique'                                   , 'Ingénieurs en informatique'                                   , 'Ingénieur\\u00b7es en informatique'                                         ,
      '2E28', paste0('Cadres aviation et marine marchande ', f)               , paste0('Cadres aviation et marine marchande ', m)              , paste0('Cadres aviation et marine marchande ', b)                      ,
      '2F01', 'Cadres publiques de santé '                                    , 'Cadres publics de santé '                                     , 'Cadres publi\\u00b7ques de santé '                                          ,
      '2F02', 'Cadres privées de santé '                                      , 'Cadres privés de santé '                                      , 'Cadres privé\\u00b7es de santé '                                            ,
      '2G00', 'Officières de la police et de l’armée'                         , 'Officiers de la police et de l’armée'                         , 'Officie\\u00b7res de la police et de l’armée'                               ,
      '2H00', paste0('Cadres hôtellerie restauration ', f)                    , paste0('Cadres hôtellerie restauration ', m)                   ,paste0('Cadres hôtellerie restauration ', b)                                  ,
      '2I11', 'Proviseures et inspectrices EN'                                , 'Proviseurs et inspecteurs EN'                                 , 'Proviseur\\u00b7es et inspecteurs/trices EN'                          ,
      '2I12', 'Cheffes d’établissement scolaire privé'                        , 'Chefs d’établissement scolaire privé'                         , 'Chef\\u00b7fes d’établissement scolaire privé'                              ,
      '2I21', 'Cadres publiques du social'                                    , 'Cadres publics du social'                                     , 'Cadres publi\\u00b7ques du social'                                          ,
      '2I22', 'Cadres privées du social'                                      , 'Cadres privés du social'                                      , 'Cadres privé\\u00b7es du social'                                            ,
      '2I23', 'Directrices de centres socioculturels'                         , 'Directeurs de centres socioculturels'                         , 'Directeurs/trices de centres socioculturels'                               ,
      '2J01', 'Cadres publiques du patrimoine '                               , 'Cadres publics du patrimoine '                                , 'Cadres publi\\u00b7ques du patrimoine '                                     ,
      '2J02', 'Cadres publiques presse et l’audiovisuel '                     , 'Cadres publics presse et audiovisuel '                        , 'Cadres publi\\u00b7ques presse et audiovisuel '                             ,
      '2J03', 'Cadres privées presse et audiovisuel '                         , 'Cadres privés presse et audiovisuel '                         , 'Cadres privé\\u00b7es presse et audiovisuel '                               ,
      '3B11', 'Techniciennes commerciales'                                    , 'Techniciens commerciaux'                                      , 'Technicien\\u00b7nes commercia\\u00b7les'                                         ,
      '3B12', paste0('Maitrise du commerce ', f)                              , paste0('Maitrise du commerce ', m)                             , paste0('Maitrise du commerce ', b)                                     ,
      '3B13', paste0('CBS commerce autres ', f)                               , paste0('CBS commerce autres ', m)                              , paste0('CBS commerce autres ', b)                                      ,
      '3B21', 'Moyennes commerçantes (3 à 9 salariés)'                        , 'Moyens commerçants (3 à 9 salariés)'                          , 'Moyen\\u00b7nes commerçant\\u00b7es (3 à 9 salariés)'                             ,
      '3B22', paste0('Prestataires de services ', f)                          , paste0('Prestataires de services ', m)                         , paste0('Prestataires de services ', b)                                 ,
      '3C01', 'Contrôleuses des Finances publiques (et Douanes)'              , 'Contrôleurs des Finances publiques (et Douanes)'              , 'Contrôleurs/leuses des Finances publiques (et Douanes)'                      ,
      '3C02', 'Chargées de clientèle bancaire'                                , 'Chargés de clientèle bancaire'                                , 'Chargé\\u00b7es de clientèle bancaire'                                        ,
      '3C03', paste0('Cols blancs subalternes de bureau de la banque ', f)    , paste0('Cols blancs subalternes de bureau de la banque ', m)   , paste0('Cols blancs subalternes de bureau de la banque ', f)        ,
      '3D01', paste0('Cols blancs subalternes de bureau du public ', f)       , paste0('Cols blancs subalternes de bureau du public ', m)      , paste0('Cols blancs subalternes de bureau du public ', b)           ,
      '3D02', paste0('Cols blancs subalternes du secrétariat ', f)            , paste0('Cols blancs subalternes du secrétariat ', m)           , paste0('Cols blancs subalternes du secrétariat ', b)                ,
      '3D03', paste0('CBS des services gestionnaires ', f)                    , paste0('CBS des services gestionnaires ', m)                   , paste0('CBS des services gestionnaires ', b)                           ,
      '3D04', 'Cols blancs administratives de la Sécurité sociale'            , 'Cols blancs administratifs de la Sécurité sociale'            , 'Cols blancs administratifs/tives de la Sécurité sociale'                  ,
      '3D05', paste0('Maitrise de la logistique ', f)                         , paste0('Maitrise de la logistique ', m)                        , paste0('Maitrise de la logistique ', b)                                ,
      '3D06', paste0('Cols blancs subalternes de l’infocom ', f)              , paste0('Cols blancs subalternes de l’infocom ', m)             , paste0('Cols blancs subalternes de l’infocom ', b),
      '3D07', paste0('Autres CBS de bureau ', f)                              , paste0('Autres CBS de bureau ', m)                             , paste0('Autres CBS de bureau ', b)                                     ,
      '3D08', 'Cols blancs administratives de la Poste et France Télécom'     , 'Cols blancs administratifs de la Poste et France Télécom'     , 'Cols blancs administratifs/tives de la Poste et France Télécom'           ,
      '3E11', 'Agentes de maîtrise employées du public'                       , 'Agents de maîtrise employés du public'                        , 'Agent\\u00b7es de maîtrise employé\\u00b7es du public'                            ,
      '3E12', paste0('Maitrise du BTP ', f)                                   , paste0('Maitrise du BTP ', m)                                  , paste0('Maitrise du BTP ', b)                                          ,
      '3E13', paste0('Maitrise de l’industrie ', f)                           , paste0('Maitrise de l’industrie ', m)                          , paste0('Maitrise de l’industrie ', b)                                  ,
      '3E14', paste0('Maitrise de la logistique ', f)                         , paste0('Maitrise de la logistique ', m)                        , paste0('Maitrise de la logistique ', b)                                ,
      '3E15', paste0('Maitrise autres ', f)                                   , paste0('Maitrise autres ', m)                                  , paste0('Maitrise autres ', b)                                          ,
      '3E21', 'Techniciennes employées du public (TP, labos…)'                , 'Techniciens employés du public (TP, labos…)'                  , 'Technicien\\u00b7nes employé\\u00b7es du public (TP, labos…)'                     ,
      '3E22', 'Techniciennes de production et méthodes'                       , 'Techniciens de production et méthodes'                        , 'Technicien\\u00b7nes de production et méthodes'                             ,
      '3E23', 'Techniciennes de maintenance'                                  , 'Techniciens de maintenance'                                   , 'Technicien\\u00b7nes de maintenance'                                        ,
      '3E24', 'Techniciennes d’étude (de R&D)'                                , 'Techniciens d’étude (de R&D)'                                 , 'Technicien\\u00b7nes d’étude (de R&D)'                                      ,
      '3E25', 'Techniciennes de l’informatique'                               , 'Techniciens de l’informatique'                                , 'Technicien\\u00b7nes de l’informatique'                                     ,
      '3E26', 'Techniciennes autres'                                          , 'Techniciens autres'                                           , 'Technicien\\u00b7nes autres'                                                ,
      '3F30', 'Techniciennes médicales (et ass.)'                             , 'Techniciens médicaux  (et ass.)'                              , 'Technicien\\u00b7nes médica\\u00b7les (et ass.)'                                             ,
      '3H00', paste0('Maitrise de l’hotellerie-restauration ', f)             , paste0('Maitrise de l’hotellerie-restauration ', m)            , paste0('Maitrise de l’hotellerie-restauration ', b)                    ,
      '4F10', 'Médecins hospitalières (dont internes)'                        , 'Médecins hospitaliers (dont internes)'                        , 'Médecins hospitalier\\u00b7es (dont internes)'                              ,
      '4F20', 'Infirmières'                                                   , 'Infirmiers'                                                   , 'Infirmie\\u00b7res'                                                         ,
      '4F41', 'Médecins (hors hospitalières)'                                 , 'Médecins (hors hospitaliers)'                                 , 'Médecins (hors hospitalier\\u00b7es)'                                       ,
      '4F42', paste0('Spécialistes de la rééducation ', f)                    , paste0('Spécialistes de la rééducation ', m)                   , paste0('Spécialistes de la rééducation ', b)                           ,
      '4F43', 'Sages-femmes'                                                  , paste0('Sages-femmes ', m)                                     , paste0('Sages-femmes ', b)                                             ,
      '4F44', 'Pharmaciennes'                                                 , 'Pharmaciens'                                                  , 'Pharmacien\\u00b7nes'                                                       ,
      '4F45', paste0('Psychologues (non médecins) ', f)                       , paste0('Psychologues (non médecins) ', m)                      , paste0('Psychologues (non médecins) ', b)                              ,
      '4I11', 'Enseignantes du supérieur'                                     , 'Enseignants du supérieur'                                     , 'Enseignant\\u00b7es du supérieur'                                           ,
      '4I12', 'Chercheuses du public'                                         , 'Chercheurs du public'                                         , 'Chercheu\\u00b7ses du public'                                              ,
      '4I13', 'Enseignantes du secondaire (et ass.)'                          , 'Enseignants du secondaire (et ass.)'                          , 'Enseignant\\u00b7es du secondaire (et ass.)'                         ,
      '4I14', 'Enseignantes du primaire'                                      , 'Enseignants du primaire'                                      , 'Enseignant\\u00b7es du primaire'                                            ,
      '4I21', 'Éducatrices'                                                   , 'Éducateurs'                                                   , 'Éducat\\u00b7rices'                                                         ,
      '4I22', 'Assistantes sociales'                                          , 'Assistants sociaux'                                           , 'Assistant\\u00b7es socia\\u00b7les'                                               ,
      '4I23', 'Conseillères en économie sociale familiale'                    , 'Conseillers en économie sociale familiale'                    , 'Conseille\\u00b7res en économie sociale familiale'                          ,
      '4I31', 'Animatrices socioculturelles'                                  , 'Animateurs socioculturels'                                    , 'Animat·rices socioculturel·les'                               ,
      '4I32', 'Formatrices d’entreprise (et d’écoles de conduite)'            , 'Formateurs d’entreprise (et d’écoles de conduite)'            , 'Formateurs/trices d’entreprise (et d’écoles de conduite)'                  ,
      '4I33', 'Éducatrices sportives (et sportives professionnelles)'         , 'Éducateurs sportifs (et sportifs professionnels)'             , 'Éducateurs/trices sporti\\u00b7ves (et sportifs/tives professionnel\\u00b7les)'            ,
      '4I34', paste0('Clergé ', f)                                            , paste0('Clergé ', m)                                           , paste0('Clergé ', b)                                                   ,
      '4J11', paste0('Artistes ', f)                                          , paste0('Artistes ', m)                                         , paste0('Artistes ', b)                                                 ,
      '4J12', paste0('Cadres technico-artistiques ', f)                       , paste0('Cadres technico-artistiques ', m)                      , paste0('Cadres technico-artistiques ', b)                              ,
      '4J13', 'Professeures d’art (hors établissements scolaires)'            , 'Professeurs d’art (hors établissements scolaires)'            , 'Professeur\\u00b7es d’art (hors établissements scolaires)'                  ,
      '4J21', 'Avocates, notaires, architectes'                               , 'Avocats, notaires, architectes'                               , 'Avocat\\u00b7es, notaires, architectes'                                     ,
      '4J22', paste0('Journalistes ', f)                                      , paste0('Journalistes ', m)                                     , paste0('Journalistes ', b)                                             ,
      '4J23', 'Magistrates'                                                   , 'Magistrats'                                                   , 'Magistrat\\u00b7es'                                                         ,
      '4J24', 'Professionnelles de la politique et permanentes syndicales'    , 'Professionnels de la politique et permanents syndicaux'       , 'Professionnel\\u00b7les de la politique et permanent\\u00b7es syndica\\u00b7les'        ,
      '4J25', paste0('PIS autres ', f)                                        , paste0('PIS autres ', m)                                       , paste0('PIS autres ', b)                                               ,
      '5B11', 'Vendeuses qualifiées'                                          , 'Vendeurs qualifiés'                                           , 'Vendeu\\u00b7ses qualifié\\u00b7es'                                               ,
      '5B12', 'Vendeuses NQ'                                                  , 'Vendeurs NQ'                                                  , 'Vendeu\\u00b7ses NQ'                                                        ,
      '5B13', 'Caissières (et assimilées)'                                    , 'Caissiers (et assimilés)'                                     , 'Caissie\\u00b7res (et assimilé\\u00b7es)'                                         ,
      '5B22', 'Petites commerçantes (0 à 2 salariés)'                         , 'Petits commerçants (0 à 2 salariés)'                          , 'Petit\\u00b7es commerçant\\u00b7es (0 à 2 salariés)'                              ,
      '5C01', 'Employées des Finances publiques (et Douanes)'                 , 'Employés des Finances publiques (et Douanes)'                 , 'Employé\\u00b7es des Finances publiques (et Douanes)'                       ,
      '5C02', 'Employées de banque, accueil'                                  , 'Employés de banque, accueil'                                  , 'Employé\\u00b7es de banque, accueil'                                        ,
      '5C03', 'Employées de banque, back-office'                              , 'Employés de banque, back-office'                              , 'Employé\\u00b7es de banque, back-office'                                    ,
      '5D01', 'Employées de bureau de la fonction publique'                   , 'Employés de bureau de la fonction publique'                   , 'Employé\\u00b7es de bureau de la fonction publique'                         ,
      '5D02', 'Employées de bureau NQ'                                        , 'Employés de bureau NQ'                                        , 'Employé\\u00b7es de bureau NQ'                                              ,
      '5D03', 'Employées de la Sécurité sociale'                              , 'Employés de la Sécurité sociale'                              , 'Employé\\u00b7es de la Sécurité sociale'                                    ,
      '5D04', 'Employées de la Poste (et France Télécom)'                     , 'Employés de la Poste (et France Télécom)'                     , 'Employé\\u00b7es de la Poste (et France Télécom)'                           ,
      '5D05', 'Employées d’accueil (et accompagnement)'                       , 'Employés d’accueil (et accompagnement)'                       , 'Employé\\u00b7es d’accueil (et accompagnement)'                             ,
      '5D06', paste0('Secrétaires ', f)                                       , paste0('Secrétaires ', m)                                      , paste0('Secrétaires ', b)                                              ,
      '5D07', 'Employées des services comptables'                             , 'Employés des services comptables'                             , 'Employé\\u00b7es des services comptables'                                   ,
      '5D08', 'Employées de back-office'                                      , 'Employés de back-office'                                      , 'Employé\\u00b7es de back-office'                                            ,
      '5F00', 'Employées de santé'                                            , 'Employés de santé'                                            , 'Employé\\u00b7es de santé'                                                  ,
      '5G10', 'Policières'                                                    , 'Policiers'                                                    , 'Policier\\u00b7es'                                                          ,
      '5G21', 'Sous-officières des Armées (et Gendarmerie)'                   , 'Sous-officiers des Armées (et de la Gendarmerie)'             , 'Sous-officier\\u00b7es des Armées (et de la Gendarmerie)'                   ,
      '5G22', paste0('Gendarmes ', f)                                         , paste0('Gendarmes ', m)                                        , paste0('Gendarmes ', b)                                                ,
      '5G23', paste0('Militaires ', f)                                        , paste0('Militaires ', m)                                       , paste0('Militaires ', b)                                               ,
      '5G24', 'Pompières'                                                     , 'Pompiers'                                                     , 'Pompier\\u00b7es'                                                           ,
      '5G31', 'Agentes de sécurité'                                           , 'Agents de sécurité'                                           , 'Agent\\u00b7es de sécurité'                                                 ,
      '5G32', paste0('Sécurité qualifiés autres ', f)                         , paste0('Sécurité qualifiés autres ', m)                        , paste0('Sécurité qualifiés autres ', b)                                ,
      '5H11', paste0('ESP de la fonction publique ', f)                       , paste0('ESP de la fonction publique ', m)                      , paste0('ESP de la fonction publique ', b)                              ,
      '5H12', paste0('ESP de l’hôtellerie-restauration ', f)                  , paste0('ESP de l’hôtellerie-restauration ', m)                 , paste0('ESP de l’hôtellerie-restauration ', b)                         ,
      '5H13', paste0('ESP à domicile ', f)                                    , paste0('ESP à domicile ', m)                                   , paste0('ESP à domicile ', b)                                           ,
      '5H14', paste0('ESP autres ', f)                                        , paste0('ESP autres ', m)                                       , paste0('ESP autres ', b)                                               ,
      '5H21', 'Artisanes des services'                                        , 'Artisans des services'                                        , 'Artisan\\u00b7es des services'                                              ,
      '5H22', 'Petit hôtelieres/restauratrices (0 à 2 salariés)'              , 'Petit hôteliers/restaurateurs (0 à 2 salariés)'               , 'Petit\\u00b7es hôtelier\\u00b7es/restaurateurs/trices (0 à 2 salariés)'                ,
      '6E10', paste0('OQ-I de l’extraction ', f)                              , paste0('OQ-I de l’extraction ', m)                             , paste0('OQ-I de l’extraction ', b)                                     ,
      '6E11', paste0('OQ-I du BTP ', f)                                       , paste0('OQ-I du BTP ', m)                                      , paste0('OQ-I du BTP ', b)                                              ,
      '6E12', paste0('OQ-I électricité ', f)                                  , paste0('OQ-I électricité ', m)                                 , paste0('OQ-I électricité ', b)                                         ,
      '6E13', paste0('OQ-I mécanique métaux ', f)                             , paste0('OQ-I mécanique métaux ', m)                            , paste0('OQ-I mécanique métaux ', b)                                    ,
      '6E14', paste0('OQ-I impression ', f)                                   , paste0('OQ-I impression ', m)                                  , paste0('OQ-I impression ', b)                                          ,
      '6E15', paste0('OQ-I transformation ', f)                               , paste0('OQ-I transformation ', m)                              , paste0('OQ-I transformation ', b)                                      ,
      '6E16', paste0('OQ-I textile ', f)                                      , paste0('OQ-I textile ', m)                                     , paste0('OQ-I textile ', b)                                             ,
      '6E17', paste0('OQ-I bois ', f)                                         , paste0('OQ-I bois ', m)                                        , paste0('OQ-I bois ', b)                                                ,
      '6E18', paste0('OQ-I maintenance ', f)                                  , paste0('OQ-I maintenance ', m)                                 , paste0('OQ-I maintenance ', b)                                         ,
      '6E19', paste0('OQ-I autres ', f)                                       , paste0('OQ-I autres ', m)                                      , paste0('OQ-I autres ', b)                                              ,
      '6E21', paste0('OQ-A jardinage ', f)                                    , paste0('OQ-A jardinage ', m)                                   , paste0('OQ-A jardinage ', b)                                           ,
      '6E22', paste0('OQ-A bois ', f)                                         , paste0('OQ-A bois ', m)                                        , paste0('OQ-A bois ', b)                                                ,
      '6E23', paste0('OQ-A bâtiment ', f)                                     , paste0('OQ-A bâtiment ', m)                                    , paste0('OQ-A bâtiment ', b)                                            ,
      '6E24', paste0('OQ-A électricité ', f)                                  , paste0('OQ-A électricité ', m)                                 , paste0('OQ-A électricité ', b)                                         ,
      '6E25', paste0('OQ-A mécanique métaux ', f)                             , paste0('OQ-A mécanique métaux ', m)                            , paste0('OQ-A mécanique métaux ', b)                                    ,
      '6E26', 'Ouvrières Q-A textile'                                         , 'Ouvriers Q-A textile'                                         , 'Ouvrie\\u00b7res Q-A textile'                                               ,
      '6E27', paste0('OQ-A alimentation ', f)                                 , paste0('OQ-A alimentation ', m)                                , paste0('OQ-A alimentation ', b)                                        ,
      '6E28', paste0('OQ-A autres', f)                                        , paste0('OQ-A autres', m)                                       , paste0('OQ-A autres', b)                                               ,
      '6E31', 'OQ routières'                                                  , 'OQ routiers'                                                  , 'OQ routie\\u00b7res'                                                        ,
      '6E32', 'OQ transport en commun'                                        , 'OQ transport en commun'                                       , 'OQ transport en commun'                                               ,
      '6E33', 'OQ chauffeuses de voiture'                                     , 'OQ chauffeurs de voiture'                                     , 'OQ chauffeurs/euses de voiture'                                           ,
      '6E34', 'OQ trains et engins lourds'                                    , 'OQ trains et engins lourds'                                   , 'OQ trains et engins lourds'                                           ,
      '6E35', 'OQ marins et dockeuses'                                        , 'OQ marins et dockers'                                         , 'OQ marins et dockers/euses'                                             ,
      '6E36', paste0('OQ logistique autres' , f)                              , paste0('OQ logistique autres' , m)                             , paste0('OQ logistique autres' , b)                                     ,
      '6E41', paste0('ONQ-I du BTP'         , f)                              , paste0('ONQ-I du BTP'         , m)                             , paste0('ONQ-I du BTP'         , b)                                     ,
      '6E42', paste0('ONQ-I électricité ', f)                                 , paste0('ONQ-I électricité ', m)                                , paste0('ONQ-I électricité ', b)                                        ,
      '6E43', paste0('ONQ-I mécanique métaux', f)                             , paste0('ONQ-I mécanique métaux', m)                            , paste0('ONQ-I mécanique métaux', b)                                    ,
      '6E44', paste0('ONQ-I transformation ', f)                              , paste0('ONQ-I transformation ', m)                             , paste0('ONQ-I transformation ', b)                                     ,
      '6E45', paste0('ONQ-I textile ', f)                                     , paste0('ONQ-I textile ', m)                                    , paste0('ONQ-I textile ', b)                                            ,
      '6E46', paste0('ONQ-I autres ', f)                                      , paste0('ONQ-I autres ', m)                                     , paste0('ONQ-I autres ', b)                                             ,
      '6E51', paste0('ONQ-manutention ', f)                                   , paste0('ONQ-manutention ', m)                                  , paste0('ONQ-manutention ', b)                                          ,
      '6E52', 'ONQ-coursières et livreuses'                                   , 'ONQ-coursiers et livreurs'                                    , 'ONQ-coursier\\u00b7es et livreurs/euses'                                        ,
      '6E53', paste0('ONQ-logistique autres', f)                              , paste0('ONQ-logistique autres', m)                             , paste0('ONQ-logistique autres', b)                                     ,
      '6E61', paste0('ONQ-A bâtiment ', f)                                    , paste0('ONQ-A bâtiment ', m)                                   , paste0('ONQ-A bâtiment ', b)                                           ,
      '6E62', paste0('ONQ-A mécanique ', f)                                   , paste0('ONQ-A mécanique ', m)                                  , paste0('ONQ-A mécanique ', b)                                          ,
      '6E63', paste0('ONQ-A alimentation ', f)                                , paste0('ONQ-A alimentation ', m)                               , paste0('ONQ-A alimentation ', b)                                       ,
      '6E64', 'ONQ-A nettoyeuses'                                             , 'ONQ-A nettoyeurs'                                             , 'ONQ-A nettoyeurs/euses'                                                   ,
      '6E65', 'ONQ-A autres'                                                  , 'ONQ-A autres'                                                 , 'ONQ-A autres'                                                         ,
      '6E71', 'Artisanes du bâtiment'                                         , 'Artisans du bâtiment'                                         , 'Artisan\\u00b7es du bâtiment'                                               ,
      '6E72', 'Artisanes méca, métaux, élec'                                  , 'Artisans méca, métaux, élec'                                  , 'Artisan\\u00b7es méca, métaux, élec'                                        ,
      '6E73', 'Artisanes textile'                                             , 'Artisans textile'                                             , 'Artisan\\u00b7es textile'                                                   ,
      '6E74', 'Artisanes bois'                                                , 'Artisans bois'                                                , 'Artisan\\u00b7es bois'                                                      ,
      '6E75', 'Artisanes alimentation'                                        , 'Artisans alimentation'                                        , 'Artisan\\u00b7es alimentation'                                              ,
      '6E76', 'Artisanes réparation'                                          , 'Artisans réparation'                                          , 'Artisan\\u00b7es réparation'                                                ,
      '6E77', 'Artisanes chauffeuses'                                         , 'Artisans chauffeurs'                                          , 'Artisan\\u00b7es chauffeurs/euses'                                              ,
      '6E78', 'Artisanes divers'                                              , 'Artisans divers'                                              , 'Artisan\\u00b7es divers'                                                    ,
      '7K13', 'Petites agricultrices'                                         , 'Petits agriculteurs'                                          , 'Petit\\u00b7es agriculteurs/trices'                                              ,
      '7K11', 'Grandes agricultrices'                                         , 'Grands agriculteurs'                                          , 'Grand\\u00b7es agriculteurs/trices'                                              ,
      '7K12', 'Moyennes agricultrices'                                        , 'Moyens agriculteurs'                                          , 'Moyen\\u00b7nes agriculteurs/trices'                                             ,
      '7K20', 'Ouvrières agricoles'                                           , 'Ouvriers agricoles'                                           , 'Ouvrier\\u00b7es agricoles'                                                 ,
    ) %>% 
      dplyr::mutate(dplyr::across(tidyselect::all_of(c("fem", "masc", "both")), 
                                  stringi::stri_unescape_unicode))
    
    
    PR_fem_to_PR_name <- function(PR_to_name, PR_fem) {
      dplyr::left_join(PR_to_name, PR_fem, by = "chiffre") %>% 
        dplyr::mutate(name = dplyr::case_when(
          fem_pct >= threshold[2]  ~ fem ,
          fem_pct >  threshold[1]  ~ both,
          TRUE                 ~ masc,
        ), 
        res = purrr::set_names(stringr::str_c(chiffre, "-", name), chiffre)
        ) %>% 
        dplyr::pull(res)
    }
    
    # With all professions names masculine -----------------------------------------------
    if (masculiniser) {
      PPP1_to_name <- PPP1_to_name %>% 
        dplyr::mutate(res = purrr::set_names(stringr::str_c(chiffre, "-", masc), 
                                             chiffre)) %>% 
        dplyr::pull(res)
      
      PPP2_to_name <- PPP2_to_name %>% 
        dplyr::mutate(res = purrr::set_names(stringr::str_c(chiffre, "-", masc), 
                                             chiffre)) %>% 
        dplyr::pull(res)
      
      PPP3_to_name <- PPP3_to_name %>% 
        dplyr::mutate(res = purrr::set_names(stringr::str_c(chiffre, "-", masc), 
                                             chiffre)) %>% 
        dplyr::pull(res)
      
      
      
      # Female and male names based on enquêtes Emploi -----------------------------------
    } else if (missing(sexe)) {
      # # Code to generate the tables for feminization, based on Enquêtes emploi 1982-2018
      
      # load("01-Scripts et workspaces\\Enquête Emploi (list).RData")
      #  # load recodages_pct() manually for now
      #  
      # gc()
      # emploi82_18_fem <-
      #   emploi_data_list[emploi_if_82_18] %>%
      #   purrr::imap(
      #     ~ dplyr::select(.x, P, EMP_ADM_ENT, SEXE, EXTRI, ANNEE) %>%
      #       dplyr::filter(!is.na(P)) %>%
      #       recodage_PCS(
      #         P, EMP_ADM_ENT,
      #         nomenclaturePCS = dplyr::if_else(
      #           .y %in%  c("ee2003_07", "ee2008_12", "ee2013_18"),
      #           true  = "2003",
      #           false = "1982"
      #         )
      #       ) %>%
      #       mutate(across(starts_with("PR"),
      #                     ~ fct_relabel(., ~ str_remove(., "-.+$") %>%
      #                                     str_to_lower())))
      # 
      #   )
      # save("emploi82_18_fem", file = "01-Scripts et workspaces\\Recodages CSP\\Emploi82_18_fem.RData")
      # 
      # rm(emploi_data_list) ; gc()
      # emploi82_18_fem <- emploi82_18_fem %>%
      #   tabxplor:::bind_datas_for_tab(names(.[[1]]))
      # 
      # 
      # save("emploi82_18_fem", file = "01-Scripts et workspaces\\Recodages CSP\\Emploi82_18_fem.RData")
      
      # # Générer les tableaux de féminisation pour tous les niveaux des CSP recodées ----
      # load("01-Scripts et workspaces\\Recodages CSP\\Emploi82_18_fem.RData")
      # 
      # #   ee2013_18 %>% filter(!is.na(PPP1)) %>%  tab(PPP1, pct = "col")
      # 
      # data <- emploi82_18_fem
      # var <- rlang::sym("PPP3")
      # 
      # generate_fem_tribble <- function(data, var) {
      #   var <- rlang::ensym(var)
      # 
      #   tabs <-
      #     tab(data, !!var, SEXE, ANNEE, wt = EXTRI, na = "drop", pct = "row",
      #         tot = "col", totaltab = "no") %>%
      #     select(-`1-Masculin`, -Total)
      # 
      #   tabs <- tabs %>%
      #     tab_spread(ANNEE) %>%
      #     rename_with(~ str_remove(., "2-Féminin_")) %>%
      #     mutate(across(where(tabxplor::is_fmt), ~ round(tabxplor:::get_pct(.) * 100, 1)))
      # 
      #   names_str <- str_c(
      #     rlang::as_name(var), "_fem <-", "tibble::tribble(\n",
      #     str_c("~`", str_pad(names(tabs), 4, "right"), "`", collapse = ", "),
      #     ",\n"
      #   )
      #  tabs %>%
      #     mutate(across(1, ~ str_c("'", ., "'"))) %>%
      #     mutate(across(.fns = ~ str_pad(., 7, "right"))) %>%
      #     unite(col = trb, sep = ", ") %>%
      #     mutate(trb = dplyr::if_else(dplyr::row_number() == 1,
      #                                    true  = str_c(names_str, trb),
      #                                    false = trb),
      #            trb = dplyr::if_else(dplyr::row_number() == max(dplyr::row_number()),
      #                                  true  = str_c(trb, "\n)\n\n"),
      #                                  false = trb),
      #            )
      # }
      # 
      # PPP1_fem <- generate_fem_tribble(emploi82_18_fem, PPP1)
      # PPP2_fem <- generate_fem_tribble(emploi82_18_fem, PPP2)
      # PPP3_fem <- generate_fem_tribble(emploi82_18_fem, PPP3)
      # PPP4_fem <- generate_fem_tribble(emploi82_18_fem, PPP4)
      # 
      # cat(PPP1_fem$trb, sep = ",\n")
      # cat(PPP2_fem$trb, sep = ",\n")
      # cat(PPP3_fem$trb, sep = ",\n")
      # cat(PPP4_fem$trb, sep = ",\n")
      # 
      # # sex_ratio <- c("PPP1", "PPP2", "PPP3", "PPP4") %>%
      # #   map_chr(~ generate_fem_tribble(emploi82_18_fem, !!rlang::sym(.)))
      # # cat(sex_ratio)
      
      PPP1_fem <- tibble::tribble(
        ~chiffre, ~`1982`, ~`1983`, ~`1984`, ~`1985`, ~`1986`, ~`1987`, ~`1988`, ~`1989`, ~`1990`, ~`1991`, ~`1992`, ~`1993`, ~`1994`, ~`1995`, ~`1996`, ~`1997`, ~`1998`, ~`1999`, ~`2000`, ~`2001`, ~`2002`, ~`2003`, ~`2004`, ~`2005`, ~`2006`, ~`2007`, ~`2008`, ~`2009`, ~`2010`, ~`2011`, ~`2012`, ~`2013`, ~`2014`, ~`2015`, ~`2016`, ~`2017`, ~`2018`,
        '1'     , 15.6 , 18.4 , 21.8 , 22.9 , 17.8 , 19.1 , 17.1 , 16.4 , 14.2 , 15.6 , 12.3 , 15.3 , 13.8 , 18.8 , 15.5 , 18.6 , 20   , 20   , 14.4 , 15.4 , 14.6 , 13.9 , 11.7 , 17   , 17.4 , 18.9 , 15.2 , 9.3  , 12.9 , 16.8 , 16.4 , 19.4 , 15.5 , 17.5 , 19.5 , 18.8 , 16.1 ,
        '2'     , 19.3 , 18.9 , 19.9 , 19.9 , 22.3 , 22.1 , 21.9 , 23   , 23   , 23.9 , 24.2 , 24.5 , 24.4 , 26.1 , 27.5 , 26.2 , 28   , 27.4 , 27.5 , 27.8 , 29.6 , 29.6 , 30.7 , 31.9 , 32.7 , 32.9 , 34.2 , 34.9 , 35   , 36   , 35.9 , 36.1 , 36.3 , 36.2 , 36.5 , 37.2 , 37.9 ,
        '3'     , 26.1 , 26   , 26.6 , 27.3 , 28.2 , 29   , 29.5 , 29.6 , 30.7 , 31.6 , 32.4 , 32.3 , 32.6 , 32.8 , 32.1 , 32.4 , 32.9 , 33.1 , 33.8 , 33.9 , 34.4 , 35.5 , 36.3 , 36.7 , 36.8 , 37.8 , 37.8 , 37.8 , 38.1 , 38.3 , 38.9 , 38.7 , 38.5 , 39.2 , 39.4 , 39.7 , 41   ,
        '4'     , 58.3 , 58.5 , 58.4 , 57.3 , 57.3 , 57.8 , 58.2 , 58.3 , 58   , 58.5 , 58.6 , 59.9 , 60.2 , 59.8 , 60.2 , 60.8 , 60.8 , 61.4 , 62.6 , 62.7 , 62.6 , 63   , 63.7 , 64.2 , 64.5 , 64.4 , 64.6 , 65.3 , 64.5 , 63.6 , 64.4 , 64.5 , 65.3 , 65.8 , 66.3 , 65.4 , 65.1 ,
        '5'     , 72.7 , 72.8 , 72.9 , 73.3 , 73.4 , 73   , 73.4 , 73.2 , 74   , 75.1 , 75   , 74.2 , 74.3 , 74.5 , 74.9 , 74.9 , 74.4 , 74.4 , 74.6 , 74   , 74.2 , 75   , 74.7 , 74.5 , 75   , 75.3 , 74.8 , 74.9 , 74.6 , 74.6 , 74.7 , 74.9 , 75.1 , 74.6 , 74.9 , 74.7 , 74.5 ,
        '6'     , 18.6 , 18.5 , 18.6 , 18.9 , 18.9 , 18.3 , 18.1 , 18   , 18.7 , 18.8 , 18.5 , 18.1 , 18.7 , 18.4 , 17.8 , 17.9 , 18.3 , 18.3 , 18.3 , 18.9 , 18.5 , 18.3 , 18.3 , 17.9 , 17.8 , 17.6 , 17.5 , 17.2 , 17.6 , 18.2 , 17.8 , 18   , 18.4 , 18.8 , 18.7 , 19   , 18.6 ,
        '7'     , 36   , 36   , 35.6 , 35.8 , 35.3 , 35   , 34.2 , 34.3 , 33.9 , 35.3 , 35.3 , 35.7 , 33.9 , 33.5 , 33   , 32.6 , 31.3 , 31.5 , 30.7 , 30.8 , 31   , 29.8 , 32.4 , 29.8 , 29.1 , 30.1 , 29.5 , 29.1 , 27.8 , 29   , 28.9 , 27.5 , 27.3 , 27.7 , 26.6 , 27.1 , 25.9 
      ) %>% 
        dplyr::mutate(chiffre = stringr::str_to_upper(chiffre)) %>% 
        dplyr::select(chiffre, tidyselect::all_of(sexeEE)) %>% 
        dplyr::rowwise() %>% 
        dplyr::mutate(fem_pct = mean(dplyr::c_across(tidyselect::all_of(sexeEE)), na.rm = TRUE)) %>% 
        dplyr::select(chiffre, fem_pct)
      
      
      PPP2_fem <-tibble::tribble(
        ~chiffre, ~`1982`, ~`1983`, ~`1984`, ~`1985`, ~`1986`, ~`1987`, ~`1988`, ~`1989`, ~`1990`, ~`1991`, ~`1992`, ~`1993`, ~`1994`, ~`1995`, ~`1996`, ~`1997`, ~`1998`, ~`1999`, ~`2000`, ~`2001`, ~`2002`, ~`2003`, ~`2004`, ~`2005`, ~`2006`, ~`2007`, ~`2008`, ~`2009`, ~`2010`, ~`2011`, ~`2012`, ~`2013`, ~`2014`, ~`2015`, ~`2016`, ~`2017`, ~`2018`,
        '1a0'   ,   15.6 ,   18.4 ,   21.8 ,   22.9 ,   17.8 ,   19.1 ,   17.1 ,   16.4 ,   14.2 ,   15.6 ,   12.3 ,   15.3 ,   13.8 ,   18.8 ,   15.5 ,   18.6 ,   20   ,   20   ,   14.4 ,   15.4 ,   14.6 ,   13.9 ,   11.7 ,   17   ,   17.4 ,   18.9 ,   15.2 ,   9.3  ,   12.9 ,   16.8 ,   16.4 ,   19.4 ,   15.5 ,   17.5 ,   19.5 ,   18.8 ,   16.1 ,
        '2c0'   ,   18.3 ,   15.8 ,   21.6 ,   35.6 ,   32.4 ,   31.9 ,   31.4 ,   28.2 ,   30.2 ,   36.1 ,   34.2 ,   40.5 ,   42   ,   46.8 ,   43.1 ,   43.5 ,   39.2 ,   36.1 ,   37.5 ,   38.4 ,   33.4 ,   41.8 ,   38   ,   36.3 ,   40.6 ,   44.1 ,   34.8 ,   43.3 ,   43.7 ,   42.9 ,   46   ,   51.7 ,   45.4 ,   46.9 ,   46.1 ,   50.9 ,   54   ,
        '2d2'   ,   21.7 ,   21.7 ,   22.1 ,   22.1 ,   24.5 ,   25.1 ,   24.4 ,   25.5 ,   27.7 ,   29.5 ,   30.4 ,   30.6 ,   29.4 ,   32.9 ,   35.1 ,   33.1 ,   34.4 ,   34.6 ,   35.4 ,   36.5 ,   38.9 ,   36.9 ,   39.8 ,   40.5 ,   42.6 ,   42.3 ,   44.4 ,   43.8 ,   44.3 ,   45   ,   45.2 ,   46.2 ,   47.7 ,   47.3 ,   47.4 ,   47.6 ,   48.5 ,
        '2e2'   ,   6.5  ,   5.6  ,   6.1  ,   6.6  ,   8.8  ,   8.4  ,   9    ,   9.7  ,   10.4 ,   10.6 ,   11.3 ,   11.1 ,   12.8 ,   12.9 ,   13.1 ,   12.5 ,   15.2 ,   15.1 ,   14.5 ,   14.7 ,   16   ,   17.5 ,   16.5 ,   17.5 ,   17.4 ,   17.7 ,   19.6 ,   22   ,   21.1 ,   21.9 ,   22   ,   21.9 ,   20.9 ,   20.2 ,   20.4 ,   22.4 ,   23.1 ,
        '2f0'   ,   87.7 ,   87.9 ,   85.6 ,   85.1 ,   87.4 ,   86.4 ,   89.6 ,   92.9 ,   92.2 ,   86.7 ,   87.9 ,   88.8 ,   86.3 ,   78.5 ,   77.8 ,   79.6 ,   84.8 ,   86.5 ,   80.7 ,   81.6 ,   83.6 ,   83.6 ,   83   ,   82.7 ,   92.2 ,   85.1 ,   79.9 ,   81.7 ,   79.5 ,   85.1 ,   80.5 ,   83.4 ,   79.6 ,   90.8 ,   90.3 ,   86.8 ,   87.2 ,
        '2g0'   ,   5.1  ,   3.6  ,   5    ,   5.9  ,   5.3  ,   3.9  ,   7.5  ,   8.2  ,   3.1  ,   8.2  ,   7.6  ,   8.6  ,   3.7  ,   5.8  ,   7.1  ,   9.4  ,   9.1  ,   7.1  ,   3    ,   7.8  ,   5.9  ,   12.3 ,   6.4  ,   8.1  ,   19.2 ,   22.6 ,   11.2 ,   8.9  ,   11.3 ,   13.7 ,   15.1 ,   19.1 ,   13.8 ,   14.9 ,   12.8 ,   12.2 ,   14.7 ,
        '2i1'   ,   25.7 ,   29.3 ,   34.4 ,   37.6 ,   31.9 ,   12.9 ,   19.3 ,   27.2 ,   32.2 ,   32   ,   31.1 ,   21.5 ,   26.6 ,   33.8 ,   35.7 ,   30.2 ,   33   ,   29.2 ,   30.9 ,   37.7 ,   34.4 ,   35.2 ,   43.8 ,   47.4 ,   42.9 ,   48.6 ,   45.3 ,   36.9 ,   40.5 ,   49.9 ,   51.5 ,   58.3 ,   46.3 ,   37.8 ,   39.4 ,   46.2 ,   35.7 ,
        '2i2'   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   58.6 ,   59.7 ,   66.4 ,   69.7 ,   63.9 ,   61.5 ,   66.8 ,   66   ,   65.8 ,   69.3 ,   66.8 ,   50.4 ,   53.5 ,   50.2 ,   58.1 ,   59.2 ,
        '2j0'   ,   63.5 ,   66.6 ,   64.9 ,   61.2 ,   70.3 ,   70.5 ,   73.1 ,   73.1 ,   73.6 ,   53.8 ,   50.5 ,   53.8 ,   54.9 ,   64.7 ,   64.3 ,   66.5 ,   64.2 ,   56.4 ,   53.5 ,   51.9 ,   46   ,   46.7 ,   56.5 ,   66.3 ,   59.1 ,   58.4 ,   55.2 ,   54.5 ,   58.8 ,   52.7 ,   57.7 ,   44.7 ,   39.8 ,   48.5 ,   57.2 ,   46.9 ,   45.9 ,
        '3b1'   ,   24.1 ,   22.7 ,   25.8 ,   26.5 ,   26.9 ,   27.1 ,   29.4 ,   30.4 ,   31.3 ,   32.6 ,   35.4 ,   35.9 ,   38.2 ,   38.7 ,   37.7 ,   37.5 ,   39.3 ,   41.3 ,   44   ,   42.2 ,   43.2 ,   40.4 ,   42.5 ,   45   ,   41.1 ,   43.9 ,   44.5 ,   43.1 ,   42.5 ,   42.6 ,   43.6 ,   44.9 ,   44.7 ,   44   ,   43.3 ,   44.3 ,   47.8 ,
        '3b2'   ,   31.1 ,   32.5 ,   34.2 ,   33.9 ,   33.9 ,   33.9 ,   31.2 ,   32.4 ,   36.8 ,   34.8 ,   34.8 ,   32.3 ,   34.1 ,   37.8 ,   34   ,   32.6 ,   34   ,   32.4 ,   33.7 ,   33.5 ,   33.2 ,   30.8 ,   31.6 ,   30   ,   30.9 ,   32   ,   32.8 ,   30.7 ,   30.6 ,   30.1 ,   29.3 ,   29.5 ,   34.6 ,   33.7 ,   33   ,   34.3 ,   34.9 ,
        '3c0'   ,   50.4 ,   48.4 ,   56.6 ,   59.2 ,   53.9 ,   56.6 ,   57.7 ,   57.9 ,   57.6 ,   58   ,   59   ,   61.2 ,   60.2 ,   61.3 ,   60.9 ,   60.7 ,   62.8 ,   68.7 ,   67.7 ,   67.8 ,   65.4 ,   73.1 ,   71   ,   64.3 ,   53.7 ,   56.2 ,   61.8 ,   70.1 ,   71.3 ,   64.2 ,   64.7 ,   58.9 ,   59.3 ,   60.2 ,   58.5 ,   62.4 ,   64.2 ,
        '3d0'   ,   58.4 ,   58.5 ,   58.9 ,   59.4 ,   60.1 ,   61.8 ,   62.1 ,   62.1 ,   62.7 ,   63.9 ,   63.9 ,   64.9 ,   64.8 ,   64.3 ,   64.2 ,   64.2 ,   63.5 ,   64.1 ,   63.4 ,   64   ,   63.8 ,   64.5 ,   64.6 ,   65.7 ,   66.9 ,   66.9 ,   67   ,   67.6 ,   67.8 ,   68.4 ,   68.6 ,   68.4 ,   67.9 ,   70   ,   68.5 ,   68.8 ,   70.6 ,
        '3e1'   ,   11   ,   11.5 ,   11.9 ,   11.6 ,   12.4 ,   13.7 ,   13   ,   11.7 ,   11.1 ,   11.6 ,   12.8 ,   13.6 ,   12.5 ,   13.3 ,   14   ,   13.6 ,   14.5 ,   13.6 ,   14.2 ,   14.2 ,   16.2 ,   18.3 ,   19.7 ,   20.6 ,   20.5 ,   20.8 ,   21.2 ,   21.7 ,   22.1 ,   23.2 ,   24.7 ,   24.2 ,   24.8 ,   23.6 ,   24.4 ,   25   ,   25.2 ,
        '3e2'   ,   10   ,   9.5  ,   9.3  ,   10.5 ,   10.7 ,   10.6 ,   10.4 ,   10.4 ,   12.7 ,   12.6 ,   12.5 ,   10.8 ,   11.7 ,   12   ,   12.2 ,   12.3 ,   12.6 ,   13.2 ,   12.5 ,   14.8 ,   13.8 ,   12.9 ,   13.6 ,   11.5 ,   11.3 ,   11.7 ,   12.1 ,   12.8 ,   13.3 ,   12.3 ,   13.2 ,   14.5 ,   14.1 ,   13.6 ,   15.4 ,   15.2 ,   16.6 ,
        '4f1'   ,   34.3 ,   30.1 ,   33.3 ,   33.8 ,   40.7 ,   40.8 ,   39.7 ,   42.3 ,   43   ,   43.5 ,   35.3 ,   40.6 ,   45.7 ,   46.3 ,   43.5 ,   43.9 ,   42.3 ,   49   ,   46.6 ,   43.3 ,   43.1 ,   47.6 ,   46   ,   42.7 ,   45.4 ,   48.9 ,   51.6 ,   52.2 ,   49   ,   50.9 ,   51.1 ,   47   ,   53.2 ,   52.5 ,   56.8 ,   53.7 ,   52.3 ,
        '4f2'   ,   87.8 ,   87.9 ,   86.6 ,   86.3 ,   87.3 ,   87.7 ,   88.3 ,   86.9 ,   87.8 ,   88.1 ,   87.6 ,   88.8 ,   87.1 ,   88.4 ,   88.4 ,   89.9 ,   89.5 ,   88.9 ,   89.6 ,   88.3 ,   86.5 ,   88   ,   88.8 ,   91.1 ,   88.3 ,   88   ,   86.8 ,   88.4 ,   88.4 ,   87.5 ,   87.4 ,   86.8 ,   86.4 ,   87   ,   86   ,   84.2 ,   85.4 ,
        '4f3'   ,   60.5 ,   57.9 ,   62.7 ,   59.1 ,   60.5 ,   69.5 ,   69.6 ,   69.6 ,   68   ,   62.7 ,   67.4 ,   68.8 ,   71.7 ,   70.4 ,   68.9 ,   73.8 ,   73.1 ,   69.3 ,   68.7 ,   70.1 ,   68.9 ,   70.2 ,   72.4 ,   74.8 ,   77.2 ,   75.6 ,   74   ,   76.5 ,   73.5 ,   74.2 ,   73   ,   73.9 ,   71   ,   73.1 ,   74.8 ,   73.4 ,   71.4 ,
        '4f4'   ,   46.3 ,   45.8 ,   48   ,   46.4 ,   45.3 ,   45.1 ,   46.7 ,   46.2 ,   42.6 ,   44.4 ,   47.2 ,   49.7 ,   49.5 ,   47.9 ,   47.9 ,   48.4 ,   50.1 ,   52.1 ,   52.8 ,   54.6 ,   54.4 ,   54.6 ,   55.6 ,   57   ,   56.2 ,   55.7 ,   60.5 ,   60.4 ,   59.2 ,   58.8 ,   59.5 ,   62.1 ,   64.5 ,   62.1 ,   63.4 ,   65.4 ,   65   ,
        '4i1'   ,   61.5 ,   62.7 ,   61.4 ,   60.5 ,   59.2 ,   60.2 ,   60.5 ,   60.7 ,   59.4 ,   61.4 ,   61.5 ,   62.4 ,   62.3 ,   61.4 ,   61.8 ,   62.5 ,   61.5 ,   61.6 ,   63   ,   63.5 ,   63.9 ,   63.1 ,   64.3 ,   64.4 ,   64.7 ,   64.2 ,   64.6 ,   65.9 ,   65.7 ,   64.4 ,   65   ,   64.4 ,   64.6 ,   66.9 ,   66.7 ,   65.1 ,   65.1 ,
        '4i2'   ,   70.3 ,   72.2 ,   72.3 ,   68   ,   66.4 ,   65.9 ,   67.7 ,   67.9 ,   69.7 ,   70.2 ,   69.4 ,   66.8 ,   70.3 ,   73.1 ,   75.5 ,   73.3 ,   74.9 ,   71.6 ,   70.6 ,   71.5 ,   71.8 ,   73   ,   69.8 ,   73.9 ,   75.2 ,   77.5 ,   77   ,   75.9 ,   74   ,   73.2 ,   72.7 ,   73.7 ,   78.3 ,   76.4 ,   77.7 ,   76.9 ,   76.3 ,
        '4i3'   ,   31.7 ,   33   ,   36.9 ,   36.3 ,   40.3 ,   38.9 ,   40.3 ,   39.5 ,   40.5 ,   40   ,   39.8 ,   44.3 ,   45.8 ,   45.5 ,   45.7 ,   47.2 ,   47.9 ,   49.1 ,   52.8 ,   51.6 ,   51.1 ,   51.9 ,   52.7 ,   52   ,   53.7 ,   54.8 ,   52.5 ,   51.4 ,   53.9 ,   54.3 ,   55.7 ,   53.9 ,   55.5 ,   55   ,   55.5 ,   56.3 ,   55.9 ,
        '4j1'   ,   39.6 ,   42.5 ,   36.2 ,   33.4 ,   35.9 ,   37   ,   39.1 ,   44.7 ,   43.9 ,   37.8 ,   37.8 ,   37.8 ,   39.3 ,   37.5 ,   37.8 ,   38.8 ,   33.5 ,   38.6 ,   40.7 ,   41.5 ,   42.6 ,   43.1 ,   45.2 ,   41.3 ,   36.9 ,   38.8 ,   42.1 ,   39.6 ,   34.5 ,   40   ,   45.6 ,   41.9 ,   38.2 ,   40.1 ,   41.8 ,   37.5 ,   41   ,
        '4j2'   ,   33.3 ,   33.6 ,   33.4 ,   35.8 ,   40.1 ,   38.5 ,   34.5 ,   33.6 ,   41.9 ,   42   ,   39.4 ,   34.9 ,   34.9 ,   37   ,   42.6 ,   40   ,   41   ,   44.1 ,   44   ,   42.7 ,   43.2 ,   41   ,   38.3 ,   41.4 ,   45.3 ,   43.3 ,   46.5 ,   49.7 ,   43.2 ,   41.3 ,   45.7 ,   43.4 ,   42.1 ,   46.4 ,   46   ,   46.8 ,   45.5 ,
        '5b1'   ,   79.2 ,   78.6 ,   79.1 ,   80.4 ,   80   ,   78   ,   77.4 ,   78.5 ,   78.8 ,   80   ,   79.2 ,   77.2 ,   77.3 ,   75.5 ,   77.4 ,   77   ,   75.7 ,   74.9 ,   75.2 ,   74.9 ,   73.7 ,   75.2 ,   76.6 ,   78.6 ,   76.8 ,   77.5 ,   76.9 ,   76.3 ,   75.6 ,   73.5 ,   74.4 ,   73.5 ,   73.6 ,   73.9 ,   73.4 ,   71.4 ,   72.2 ,
        '5b2'   ,   54   ,   55.8 ,   55.3 ,   56.2 ,   54.8 ,   56.2 ,   53.8 ,   54.8 ,   52.6 ,   56.3 ,   54.7 ,   52   ,   50.1 ,   52.3 ,   50   ,   53.2 ,   46.1 ,   44.3 ,   49.9 ,   51.3 ,   47.1 ,   49.6 ,   48.2 ,   47   ,   46   ,   49.5 ,   54.3 ,   48.2 ,   43.8 ,   47.3 ,   46   ,   44.7 ,   45.1 ,   46.7 ,   50.7 ,   49.8 ,   44.7 ,
        '5c0'   ,   68   ,   69   ,   71.8 ,   79.2 ,   82.4 ,   79.8 ,   82.1 ,   75.1 ,   70.9 ,   72.1 ,   73.6 ,   73.5 ,   74.6 ,   74.3 ,   73.4 ,   74.7 ,   72.6 ,   71   ,   64.9 ,   66.9 ,   63.3 ,   77.9 ,   76.8 ,   71.1 ,   68   ,   73.5 ,   68.8 ,   70.4 ,   64.9 ,   70.1 ,   64.1 ,   61.3 ,   65.8 ,   72.6 ,   78.6 ,   64.8 ,   76.9 ,
        '5d0'   ,   76.3 ,   76.5 ,   76.9 ,   78.3 ,   78.3 ,   77.7 ,   78.7 ,   78.6 ,   80.4 ,   80.7 ,   80.3 ,   80.7 ,   80.8 ,   81   ,   80.7 ,   80.5 ,   80.4 ,   79.9 ,   80.1 ,   79.2 ,   78.8 ,   80.7 ,   81   ,   80   ,   80.7 ,   81.4 ,   80.3 ,   78.9 ,   78.6 ,   79.9 ,   80   ,   79.7 ,   80.2 ,   79.8 ,   79.8 ,   79.3 ,   80.2 ,
        '5f0'   ,   86   ,   85.9 ,   85.4 ,   86.7 ,   88.8 ,   87.5 ,   87.9 ,   87.5 ,   86.9 ,   88.4 ,   89.4 ,   88   ,   88.4 ,   86.1 ,   86.5 ,   86.3 ,   86.4 ,   85.7 ,   86.9 ,   87.4 ,   87.4 ,   85.8 ,   85.7 ,   85.8 ,   87.6 ,   87.3 ,   85.8 ,   84.8 ,   84.8 ,   85.4 ,   86.9 ,   88.4 ,   86.5 ,   86.1 ,   85.4 ,   86.2 ,   86.9 ,
        '5g1'   ,   4.4  ,   4.2  ,   3.8  ,   3.3  ,   5    ,   3.6  ,   6.2  ,   5.8  ,   4.3  ,   4.6  ,   4.9  ,   7.5  ,   8    ,   6.6  ,   5    ,   8.6  ,   9.8  ,   10.4 ,   10.4 ,   14.8 ,   17.3 ,   18.3 ,   16.6 ,   16.2 ,   13.2 ,   23   ,   24.6 ,   22.4 ,   20.2 ,   23.4 ,   20.2 ,   18.6 ,   23.3 ,   23.3 ,   20.4 ,   17.9 ,   20.5 ,
        '5g2'   ,   3.2  ,   4.9  ,   5.5  ,   4.6  ,   4.5  ,   6.2  ,   6.2  ,   6.2  ,   6.7  ,   8    ,   10   ,   7    ,   5.4  ,   4.8  ,   5.7  ,   5.2  ,   5.9  ,   8.3  ,   9.1  ,   8.1  ,   8.3  ,   8.9  ,   6.9  ,   11   ,   10.7 ,   12.9 ,   11   ,   10.8 ,   12.6 ,   11.9 ,   9    ,   9.8  ,   12.1 ,   11.9 ,   13.1 ,   11.6 ,   12.7 ,
        '5g3'   ,   6.4  ,   8    ,   9    ,   5.4  ,   5.3  ,   7.8  ,   6.4  ,   8.4  ,   9    ,   9.9  ,   9.1  ,   8    ,   8.6  ,   10.6 ,   10   ,   7.9  ,   8.7  ,   10.3 ,   11.4 ,   8.3  ,   10.1 ,   10.4 ,   10.7 ,   10.8 ,   9    ,   13.6 ,   10   ,   11.7 ,   16.1 ,   14.7 ,   12.6 ,   15.3 ,   13.3 ,   12.2 ,   12.1 ,   12   ,   16.7 ,
        '5h1'   ,   84.3 ,   83   ,   82.7 ,   82.8 ,   83.9 ,   83.3 ,   83.7 ,   82.9 ,   84   ,   84.5 ,   84.9 ,   84.7 ,   84.2 ,   83.9 ,   84.9 ,   84.6 ,   85   ,   84.5 ,   84.2 ,   84   ,   84.9 ,   84.6 ,   83.7 ,   82.8 ,   83.7 ,   83.6 ,   82.5 ,   84   ,   83.7 ,   83.2 ,   83.1 ,   84.2 ,   84.5 ,   83.1 ,   83.9 ,   83.8 ,   82.6 ,
        '5h2'   ,   70.4 ,   70.8 ,   70.5 ,   68.4 ,   67.9 ,   66.4 ,   66.1 ,   66.9 ,   68.8 ,   69.9 ,   68.4 ,   66   ,   67.3 ,   67.7 ,   67.2 ,   68.1 ,   67.9 ,   65.2 ,   62.7 ,   62.3 ,   66   ,   59.8 ,   57.8 ,   57.5 ,   61.9 ,   59.5 ,   58.4 ,   59.4 ,   59.8 ,   59.3 ,   56.8 ,   58   ,   58.7 ,   59.8 ,   59.7 ,   62.6 ,   60.5 ,
        '6e1'   ,   12.8 ,   11.4 ,   12.2 ,   12.1 ,   12.5 ,   12.1 ,   13   ,   13.1 ,   15.2 ,   15   ,   15.4 ,   13.9 ,   16.2 ,   16.3 ,   16.3 ,   16.1 ,   15.8 ,   16   ,   15.2 ,   16   ,   15.4 ,   15.7 ,   17.6 ,   15.9 ,   15.6 ,   16   ,   15.8 ,   14.7 ,   14.6 ,   15.4 ,   15.1 ,   15.5 ,   16.1 ,   15.4 ,   15.3 ,   16.8 ,   16.4 ,
        '6e2'   ,   7.7  ,   7.4  ,   7.2  ,   6.7  ,   6.1  ,   6.3  ,   6.6  ,   6.5  ,   6.8  ,   7.1  ,   7.1  ,   7.8  ,   7.7  ,   8.3  ,   8.5  ,   7.7  ,   8.4  ,   8.2  ,   8.6  ,   9.7  ,   8.7  ,   8.3  ,   8.2  ,   8.4  ,   8.7  ,   8.9  ,   7.6  ,   8.2  ,   9.9  ,   9.5  ,   9.7  ,   11.2 ,   10.7 ,   11.1 ,   11.3 ,   11.4 ,   10.6 ,
        '6e3'   ,   1.7  ,   2    ,   1.5  ,   1.7  ,   1.9  ,   1.9  ,   1.8  ,   1.8  ,   1.9  ,   2.3  ,   3.1  ,   3.2  ,   3.6  ,   3    ,   3.8  ,   3.6  ,   3.5  ,   3.7  ,   4.2  ,   5.7  ,   5    ,   4.7  ,   4.1  ,   5.7  ,   6    ,   7.3  ,   7.5  ,   8.1  ,   9.4  ,   7.7  ,   7.6  ,   6.9  ,   6.1  ,   8.1  ,   8.5  ,   7    ,   6.3  ,
        '6e4'   ,   39.6 ,   39.9 ,   39.9 ,   41.2 ,   40.7 ,   39.6 ,   38.6 ,   38.5 ,   39.2 ,   40.2 ,   39.2 ,   38.8 ,   39.6 ,   38.2 ,   36.7 ,   37.4 ,   37.4 ,   37.4 ,   36.5 ,   37.2 ,   38.2 ,   36.4 ,   35.8 ,   36.9 ,   36   ,   34.8 ,   36   ,   33.9 ,   30.9 ,   31.8 ,   32.2 ,   31.2 ,   30.8 ,   30.9 ,   30.1 ,   30.3 ,   30.6 ,
        '6e5'   ,   20.2 ,   19.9 ,   18.8 ,   18.9 ,   20.1 ,   20   ,   20.2 ,   21   ,   19.4 ,   21.1 ,   18.2 ,   19.5 ,   18.7 ,   18.7 ,   18.5 ,   18.4 ,   19.2 ,   19.1 ,   18.5 ,   18.5 ,   19   ,   21.5 ,   20.1 ,   20.3 ,   20.2 ,   18.7 ,   20.6 ,   19.3 ,   18.8 ,   21.1 ,   20.2 ,   20   ,   19.8 ,   20.6 ,   21.5 ,   21.2 ,   21   ,
        '6e6'   ,   26.4 ,   27.5 ,   29.7 ,   31.1 ,   33.8 ,   30.4 ,   30.2 ,   30.1 ,   36   ,   38.4 ,   38.3 ,   38.3 ,   42.7 ,   38.7 ,   38   ,   39.7 ,   39.7 ,   39.7 ,   39.1 ,   39   ,   39   ,   36.6 ,   34.6 ,   30.8 ,   32.6 ,   34.4 ,   33.2 ,   35.2 ,   36.1 ,   38.2 ,   35.9 ,   35.1 ,   39.1 ,   39.6 ,   39   ,   38.2 ,   38.9 ,
        '6e7'   ,   7.5  ,   8.4  ,   8.4  ,   8.2  ,   8.7  ,   9.3  ,   9.6  ,   9.1  ,   7.1  ,   7    ,   8.1  ,   8.5  ,   8.1  ,   7.6  ,   6.5  ,   7.8  ,   7.6  ,   7.5  ,   8.6  ,   8.4  ,   8.7  ,   11.4 ,   11.5 ,   12   ,   11.8 ,   9    ,   9    ,   9.7  ,   9.5  ,   10.9 ,   11   ,   13.2 ,   13.7 ,   13.5 ,   12.1 ,   13   ,   13   ,
        '7k1'   ,   38.4 ,   39   ,   38.9 ,   38.6 ,   37.8 ,   37   ,   37   ,   37.1 ,   36.6 ,   37.6 ,   37.7 ,   38.2 ,   37   ,   36.8 ,   35.8 ,   35.2 ,   33.8 ,   34   ,   32.5 ,   32.6 ,   32.4 ,   31.8 ,   33.7 ,   29.8 ,   29.1 ,   29.8 ,   29.8 ,   29.2 ,   27.8 ,   28   ,   28.1 ,   27.6 ,   28.5 ,   27.5 ,   26.9 ,   26.5 ,   25.3 ,
        '7k2'   ,   23.4 ,   16.7 ,   15.8 ,   18.2 ,   20.7 ,   22.9 ,   19.6 ,   19.7 ,   19.4 ,   24   ,   24.6 ,   25.7 ,   22.1 ,   21.3 ,   24   ,   24.5 ,   24   ,   24.3 ,   26.3 ,   26.3 ,   27.1 ,   24   ,   29.3 ,   29.7 ,   29.1 ,   30.8 ,   28.8 ,   28.7 ,   27.6 ,   31.1 ,   30.7 ,   27.1 ,   24.6 ,   28.2 ,   26.3 ,   28.1 ,   26.9 
      ) %>% 
        dplyr::mutate(chiffre = stringr::str_to_upper(chiffre)) %>% 
        dplyr::select(chiffre, tidyselect::all_of(sexeEE)) %>% 
        dplyr::rowwise() %>% 
        dplyr::mutate(fem_pct = mean(dplyr::c_across(tidyselect::all_of(sexeEE)), na.rm = TRUE)) %>% 
        dplyr::select(chiffre, fem_pct)
      
      PPP3_fem <-tibble::tribble(
        ~chiffre,~`1982`, ~`1983`, ~`1984`, ~`1985`, ~`1986`, ~`1987`, ~`1988`, ~`1989`, ~`1990`, ~`1991`, ~`1992`, ~`1993`, ~`1994`, ~`1995`, ~`1996`, ~`1997`, ~`1998`, ~`1999`, ~`2000`, ~`2001`, ~`2002`, ~`2003`, ~`2004`, ~`2005`, ~`2006`, ~`2007`, ~`2008`, ~`2009`, ~`2010`, ~`2011`, ~`2012`, ~`2013`, ~`2014`, ~`2015`, ~`2016`, ~`2017`, ~`2018`,
        '1a01'  ,  0    ,   13.2 ,   22   ,   17.6 ,   10.8 ,   18   ,   14.7 ,   15.5 ,   5.3  ,   10.9 ,   16.4 ,   10   ,   11.1 ,   33.7 ,   5.1  ,   0    ,   13.2 ,   31.5 ,   21.2 ,   7.7  ,   0    ,   24.7 ,   11   ,   0    ,   10.8 ,   8.4  ,   0    ,   12.1 ,   17.3 ,   15.2 ,   22.7 ,   18   ,   22.9 ,   30.8 ,   23.8 ,   21   ,   24.1 ,
        '1a02'  ,  16.8 ,   17.3 ,   15.9 ,   16.7 ,   14.4 ,   16.7 ,   14.8 ,   16.1 ,   12.9 ,   14.1 ,   8.3  ,   16.8 ,   12.4 ,   14   ,   14.5 ,   11.2 ,   10.9 ,   12.4 ,   12.6 ,   7.7  ,   13.1 ,   15.5 ,   3.3  ,   6.5  ,   14.3 ,   23.2 ,   14   ,   2.7  ,   10.1 ,   10.7 ,   9.8  ,   18   ,   11.8 ,   13.6 ,   14.8 ,   17.1 ,   14.4 ,
        '1a03'  ,  15.2 ,   21.2 ,   25   ,   26.3 ,   20.7 ,   20   ,   18.2 ,   16.7 ,   15.2 ,   16.6 ,   13.2 ,   15.2 ,   14.4 ,   18.9 ,   16.5 ,   21.5 ,   22   ,   20.3 ,   14.4 ,   16.9 ,   15.2 ,   13   ,   14.2 ,   20.3 ,   18.6 ,   18.4 ,   16.4 ,   10.8 ,   13.4 ,   18.4 ,   17.4 ,   19.8 ,   15.6 ,   16.8 ,   20.4 ,   19   ,   15.6 ,
        '2c01'  ,  18.3 ,   15.8 ,   21.6 ,   35.6 ,   32.4 ,   31.9 ,   31.4 ,   28.2 ,   30.2 ,   36.1 ,   34.2 ,   40.5 ,   42   ,   46.8 ,   43.1 ,   43.5 ,   39.2 ,   36.1 ,   37.5 ,   38.4 ,   33.4 ,   41.8 ,   38   ,   36.3 ,   40.6 ,   44.1 ,   34.8 ,   43.3 ,   43.7 ,   42.9 ,   46   ,   51.7 ,   45.4 ,   46.9 ,   46.1 ,   50.9 ,   54   ,
        '2d21'  ,  13   ,   20   ,   18.5 ,   11   ,   9.5  ,   7.9  ,   14.6 ,   21.1 ,   16   ,   24.4 ,   22   ,   15.8 ,   28.8 ,   24   ,   24.9 ,   24.3 ,   29.4 ,   29.4 ,   28.2 ,   25.4 ,   29.4 ,   42.3 ,   41.5 ,   45.9 ,   19.6 ,   24.1 ,   54.7 ,   34.2 ,   24.8 ,   43.9 ,   43.4 ,   42.7 ,   35.1 ,   27.9 ,   47.8 ,   39.6 ,   46.9 ,
        '2d23'  ,  8.7  ,   15.1 ,   10.8 ,   10.8 ,   10.7 ,   10.9 ,   8.5  ,   9.4  ,   17.2 ,   17.7 ,   19.1 ,   13.2 ,   13.9 ,   16.8 ,   23.2 ,   25.4 ,   24.7 ,   26.2 ,   17   ,   18   ,   21.6 ,   20.6 ,   19.8 ,   26   ,   25.8 ,   20.5 ,   35.5 ,   30.4 ,   25.8 ,   27.6 ,   27.5 ,   34.5 ,   28.1 ,   28.7 ,   34.9 ,   35   ,   33.8 ,
        '2d24'  ,  22   ,   22.2 ,   22.9 ,   22.8 ,   25.1 ,   25.7 ,   25.1 ,   26   ,   28.7 ,   30.1 ,   30.9 ,   31.4 ,   29.9 ,   33.8 ,   36.1 ,   33.7 ,   34.9 ,   35.1 ,   36.1 ,   37   ,   39.3 ,   37.2 ,   40.3 ,   40.5 ,   43.2 ,   43.3 ,   44   ,   43.7 ,   45   ,   45.4 ,   45.7 ,   46.2 ,   48.4 ,   48.1 ,   47.9 ,   48.2 ,   48.9 ,
        '2d26'  ,  NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   51.3 ,   59.5 ,   65.8 ,   55.6 ,   51.4 ,   67.2 ,   67.9 ,   54.6 ,   60.5 ,   63.6 ,   72.3 ,   73.9 ,   68.8 ,   69.7 ,   62.8 ,   68.9 ,
        '2d27'  ,  20.4 ,   15.4 ,   13.4 ,   19   ,   27.1 ,   31.2 ,   29.4 ,   30.8 ,   22.3 ,   24.2 ,   31.6 ,   27.9 ,   24.7 ,   21   ,   20.6 ,   27.1 ,   29.8 ,   25.9 ,   29.9 ,   40   ,   39.2 ,   31.6 ,   25.5 ,   30.3 ,   40.8 ,   38.9 ,   45.9 ,   44.3 ,   40.7 ,   42.1 ,   36.4 ,   43.8 ,   36.3 ,   36.1 ,   31.5 ,   32.4 ,   38.4 ,
        '2e22'  ,  12   ,   0    ,   21.6 ,   0    ,   0    ,   3    ,   6.6  ,   13.5 ,   15.6 ,   7.8  ,   11.5 ,   0    ,   0    ,   13.8 ,   8.1  ,   14.4 ,   16.7 ,   13.3 ,   13.1 ,   11.3 ,   12.2 ,   8.7  ,   5.4  ,   3.1  ,   5.3  ,   5.6  ,   6.6  ,   5.4  ,   8.9  ,   8.6  ,   9.9  ,   9.3  ,   8.3  ,   8.3  ,   10.3 ,   7.6  ,   9.7  ,
        '2e23'  ,  6.4  ,   5.7  ,   6    ,   6.6  ,   8.9  ,   8.5  ,   9.1  ,   9.6  ,   10.3 ,   10.7 ,   11.3 ,   11.2 ,   12.9 ,   12.9 ,   13.2 ,   12.4 ,   15.1 ,   15.2 ,   14.5 ,   14.8 ,   16.1 ,   17.7 ,   16.7 ,   17.9 ,   17.7 ,   18   ,   20   ,   22.5 ,   21.6 ,   22.5 ,   22.4 ,   22.3 ,   21.3 ,   20.6 ,   20.8 ,   22.9 ,   23.5 ,
        '2f01'  ,  87.7 ,   87.9 ,   85.6 ,   85.1 ,   87.4 ,   86.4 ,   89.6 ,   92.9 ,   92.2 ,   86.7 ,   87.9 ,   88.8 ,   86.3 ,   78.5 ,   77.8 ,   79.6 ,   84.8 ,   86.5 ,   80.7 ,   81.6 ,   83.6 ,   83.6 ,   83   ,   82.7 ,   92.2 ,   85.1 ,   79.9 ,   81.7 ,   79.5 ,   85.1 ,   80.5 ,   83.4 ,   79.6 ,   90.8 ,   90.3 ,   86.8 ,   87.2 ,
        '2g00'  ,  5.1  ,   3.6  ,   5    ,   5.9  ,   5.3  ,   3.9  ,   7.5  ,   8.2  ,   3.1  ,   8.2  ,   7.6  ,   8.6  ,   3.7  ,   5.8  ,   7.1  ,   9.4  ,   9.1  ,   7.1  ,   3    ,   7.8  ,   5.9  ,   12.3 ,   6.4  ,   8.1  ,   19.2 ,   22.6 ,   11.2 ,   8.9  ,   11.3 ,   13.7 ,   15.1 ,   19.1 ,   13.8 ,   14.9 ,   12.8 ,   12.2 ,   14.7 ,
        '2i11'  ,  25.7 ,   29.3 ,   34.4 ,   37.6 ,   31.9 ,   12.9 ,   19.3 ,   27.2 ,   32.2 ,   32   ,   31.1 ,   21.5 ,   26.6 ,   33.8 ,   35.7 ,   30.2 ,   33   ,   29.2 ,   30.9 ,   37.7 ,   34.4 ,   35.2 ,   43.8 ,   47.4 ,   42.9 ,   48.6 ,   45.3 ,   36.9 ,   40.5 ,   49.9 ,   51.5 ,   58.3 ,   46.3 ,   37.8 ,   39.4 ,   46.2 ,   35.7 ,
        '2I21'  ,  NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   58.6 ,   59.7 ,   66.4 ,   69.7 ,   63.9 ,   61.5 ,   66.8 ,   66   ,   65.8 ,   69.3 ,   66.8 ,   50.4 ,   53.5 ,   50.2 ,   58.1 ,   59.2 ,
        '2I23'  ,  NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   61.7 ,   56.2 ,   73.4 ,   50.8 ,   59.4 ,   49.8 ,   58.4 ,   59.9 ,   49   ,   66.2 ,   68.8 ,   60.5 ,   51.7 ,   71.4 ,   60   ,   61.8 ,
        '2j01'  ,  74.2 ,   76.6 ,   73.2 ,   73.5 ,   81.8 ,   80.7 ,   80.8 ,   83.9 ,   87.5 ,   74.4 ,   68.8 ,   68.5 ,   72.7 ,   85.1 ,   81.5 ,   80.2 ,   77.5 ,   80.5 ,   85.3 ,   76.8 ,   73.6 ,   80.2 ,   83   ,   91.8 ,   74.1 ,   78.7 ,   76.3 ,   68.4 ,   83   ,   77.1 ,   75.6 ,   63.6 ,   58.1 ,   73.7 ,   73.5 ,   67.5 ,   73.4 ,
        '2j02'  ,  25.3 ,   31.4 ,   12   ,   28.3 ,   36.3 ,   37.4 ,   50.8 ,   34.6 ,   30.3 ,   28.2 ,   23.3 ,   30   ,   32.9 ,   37.9 ,   40.7 ,   48.6 ,   45.8 ,   28.9 ,   28.2 ,   27.1 ,   25.8 ,   28.3 ,   32.3 ,   44.3 ,   48.7 ,   40.3 ,   42.1 ,   43.3 ,   42.6 ,   40.3 ,   51.5 ,   36.8 ,   28.5 ,   40.6 ,   50.3 ,   37.5 ,   36.4 ,
        '3b13'  ,  24.1 ,   22.7 ,   25.8 ,   26.5 ,   26.9 ,   27.1 ,   29.4 ,   30.4 ,   31.3 ,   32.6 ,   35.4 ,   35.9 ,   38.2 ,   38.7 ,   37.7 ,   37.5 ,   39.3 ,   41.3 ,   44   ,   42.2 ,   43.2 ,   40.4 ,   42.5 ,   45   ,   41.1 ,   43.9 ,   44.5 ,   43.1 ,   42.5 ,   42.6 ,   43.6 ,   44.9 ,   44.7 ,   44   ,   43.3 ,   44.3 ,   47.8 ,
        '3b21'  ,  33.4 ,   36.9 ,   37.4 ,   37.1 ,   35.8 ,   34.6 ,   33.2 ,   34.3 ,   32.8 ,   33.2 ,   31.4 ,   33.1 ,   36.9 ,   40   ,   36.9 ,   33.7 ,   34.1 ,   33.4 ,   36.7 ,   34.5 ,   36.1 ,   30.7 ,   33.2 ,   31.1 ,   30.7 ,   32.6 ,   35.7 ,   31.6 ,   31.8 ,   30.5 ,   29   ,   30.2 ,   31.3 ,   33.9 ,   34.1 ,   32.9 ,   30.6 ,
        '3b22'  ,  27.4 ,   24.4 ,   28.8 ,   29.2 ,   31   ,   32.7 ,   27.8 ,   29.5 ,   39.8 ,   36.3 ,   37.5 ,   31.2 ,   30.7 ,   34.9 ,   30.4 ,   31.3 ,   33.9 ,   31.2 ,   29.9 ,   32.4 ,   30.4 ,   31   ,   29.8 ,   28.8 ,   31.1 ,   31.6 ,   30.7 ,   30   ,   29.6 ,   29.7 ,   29.5 ,   28.9 ,   37.3 ,   33.5 ,   32.2 ,   35.4 ,   38   ,
        '3c01'  ,  50.4 ,   48.4 ,   56.6 ,   59.2 ,   53.9 ,   56.6 ,   57.7 ,   57.9 ,   57.6 ,   58   ,   59   ,   61.2 ,   60.2 ,   61.3 ,   60.9 ,   60.7 ,   62.8 ,   68.7 ,   67.7 ,   67.8 ,   65.4 ,   73.1 ,   71   ,   64.3 ,   53.7 ,   56.2 ,   61.8 ,   70.1 ,   71.3 ,   64.2 ,   64.7 ,   58.9 ,   59.3 ,   60.2 ,   58.5 ,   62.4 ,   64.2 ,
        '3d01'  ,  58.7 ,   58.4 ,   59.3 ,   59.4 ,   60.7 ,   62.9 ,   63.9 ,   63.7 ,   63.8 ,   65.3 ,   65.8 ,   66.7 ,   66.6 ,   66.1 ,   65.9 ,   65.5 ,   64.9 ,   65.3 ,   64.4 ,   65.1 ,   64.7 ,   64.3 ,   64.9 ,   65.9 ,   67.6 ,   67   ,   66.6 ,   67.2 ,   67.2 ,   68.3 ,   68.6 ,   68.4 ,   67.4 ,   69.9 ,   68.4 ,   68.8 ,   70.7 ,
        '3d04'  ,  NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   75   ,   71.5 ,   72.9 ,   64.8 ,   71.5 ,   79.8 ,   82.4 ,   84.2 ,   82.1 ,   76   ,   79.1 ,   88.5 ,   81.8 ,   85.2 ,   85.8 ,   77.7 ,
        '3d08'  ,  56.4 ,   59.5 ,   55.8 ,   59.4 ,   56.2 ,   53.6 ,   49.1 ,   51   ,   55.6 ,   53.3 ,   51   ,   51.6 ,   51   ,   48.5 ,   48.2 ,   49.9 ,   45.9 ,   44.7 ,   46.6 ,   47.7 ,   47.1 ,   60.7 ,   53.5 ,   55.9 ,   46.5 ,   60.5 ,   63.4 ,   64.8 ,   72.5 ,   53.9 ,   49.7 ,   47.6 ,   73.1 ,   58   ,   52   ,   44.8 ,   51.5 ,
        '3e11'  ,  11   ,   11.5 ,   11.9 ,   11.6 ,   12.4 ,   13.7 ,   13   ,   11.7 ,   11.1 ,   11.6 ,   12.8 ,   13.6 ,   12.5 ,   13.3 ,   14   ,   13.6 ,   14.5 ,   13.6 ,   14.2 ,   14.2 ,   16.2 ,   18.3 ,   19.7 ,   20.6 ,   20.5 ,   20.8 ,   21.2 ,   21.7 ,   22.1 ,   23.2 ,   24.7 ,   24.2 ,   24.8 ,   23.6 ,   24.4 ,   25   ,   25.2 ,
        '3e21'  ,  10   ,   9.5  ,   9.3  ,   10.5 ,   10.7 ,   10.6 ,   10.4 ,   10.4 ,   12.7 ,   12.6 ,   12.5 ,   10.8 ,   11.7 ,   12   ,   12.2 ,   12.3 ,   12.6 ,   13.2 ,   12.5 ,   14.8 ,   13.8 ,   12.9 ,   13.6 ,   11.5 ,   11.3 ,   11.7 ,   12.1 ,   12.8 ,   13.3 ,   12.3 ,   13.2 ,   14.5 ,   14.1 ,   13.6 ,   15.4 ,   15.2 ,   16.6 ,
        '4f10'  ,  34.3 ,   30.1 ,   33.3 ,   33.8 ,   40.7 ,   40.8 ,   39.7 ,   42.3 ,   43   ,   43.5 ,   35.3 ,   40.6 ,   45.7 ,   46.3 ,   43.5 ,   43.9 ,   42.3 ,   49   ,   46.6 ,   43.3 ,   43.1 ,   47.6 ,   46   ,   42.7 ,   45.4 ,   48.9 ,   51.6 ,   52.2 ,   49   ,   50.9 ,   51.1 ,   47   ,   53.2 ,   52.5 ,   56.8 ,   53.7 ,   52.3 ,
        '4f20'  ,  87.8 ,   87.9 ,   86.6 ,   86.3 ,   87.3 ,   87.7 ,   88.3 ,   86.9 ,   87.8 ,   88.1 ,   87.6 ,   88.8 ,   87.1 ,   88.4 ,   88.4 ,   89.9 ,   89.5 ,   88.9 ,   89.6 ,   88.3 ,   86.5 ,   88   ,   88.8 ,   91.1 ,   88.3 ,   88   ,   86.8 ,   88.4 ,   88.4 ,   87.5 ,   87.4 ,   86.8 ,   86.4 ,   87   ,   86   ,   84.2 ,   85.4 ,
        '4f30'  ,  60.5 ,   57.9 ,   62.7 ,   59.1 ,   60.5 ,   69.5 ,   69.6 ,   69.6 ,   68   ,   62.7 ,   67.4 ,   68.8 ,   71.7 ,   70.4 ,   68.9 ,   73.8 ,   73.1 ,   69.3 ,   68.7 ,   70.1 ,   68.9 ,   70.2 ,   72.4 ,   74.8 ,   77.2 ,   75.6 ,   74   ,   76.5 ,   73.5 ,   74.2 ,   73   ,   73.9 ,   71   ,   73.1 ,   74.8 ,   73.4 ,   71.4 ,
        '4f41'  ,  28.8 ,   28   ,   28.9 ,   29   ,   25.8 ,   26   ,   29.1 ,   29.8 ,   28.7 ,   29.2 ,   33.2 ,   33.6 ,   31.6 ,   30.2 ,   29.6 ,   32.9 ,   32   ,   36   ,   35   ,   37.9 ,   35.8 ,   38.4 ,   39.9 ,   40.5 ,   35.1 ,   37.7 ,   42.6 ,   38.7 ,   37.7 ,   38.8 ,   40   ,   42.5 ,   42.7 ,   42   ,   42.6 ,   46.3 ,   48.7 ,
        '4f42'  ,  60.6 ,   59.4 ,   56.9 ,   56.8 ,   55.5 ,   56.6 ,   58.5 ,   56.8 ,   53.7 ,   53.6 ,   56.2 ,   58.6 ,   57.9 ,   59.3 ,   62.3 ,   58.6 ,   64.5 ,   63.4 ,   64.9 ,   65.5 ,   64.3 ,   62.4 ,   62.6 ,   58   ,   57.8 ,   59.8 ,   71.6 ,   69.2 ,   66.3 ,   63.1 ,   64.2 ,   63.3 ,   69.6 ,   68.7 ,   69.2 ,   69.9 ,   64.3 ,
        '4f43'  ,  100  ,   96.8 ,   97.3 ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   99.5 ,   99.5 ,   100  ,   100  ,   100  ,   100  ,   95.4 ,   92.8 ,   96.5 ,   99.2 ,   98.3 ,   100  ,   98.1 ,   96   ,   99.5 ,   100  ,
        '4f44'  ,  57.7 ,   60.2 ,   61.5 ,   61.1 ,   59.7 ,   62.1 ,   63.6 ,   60.2 ,   57.9 ,   65   ,   59.1 ,   59.4 ,   66   ,   60.7 ,   59.4 ,   56.7 ,   60.8 ,   64.4 ,   59.4 ,   60.5 ,   60.5 ,   64.2 ,   63.5 ,   66.2 ,   69.6 ,   70.4 ,   70.2 ,   65.6 ,   65.9 ,   69.3 ,   65.6 ,   69.1 ,   71.5 ,   66.9 ,   69.3 ,   67.3 ,   73.3 ,
        '4f45'  ,  67.4 ,   69.6 ,   74.8 ,   61.7 ,   64.6 ,   62.2 ,   61.6 ,   65.2 ,   56.9 ,   65.9 ,   62.2 ,   69.9 ,   72.9 ,   69.9 ,   73.4 ,   73.9 ,   74.6 ,   74.6 ,   75.2 ,   77.5 ,   81.7 ,   73   ,   77.3 ,   81   ,   87.4 ,   82.3 ,   81.3 ,   85.7 ,   84.1 ,   80.5 ,   80.5 ,   88.6 ,   86.4 ,   85   ,   88.1 ,   88.9 ,   84.9 ,
        '4i11'  ,  27.7 ,   34.3 ,   26.9 ,   32.5 ,   28.7 ,   30.2 ,   24.1 ,   26   ,   28.3 ,   31.4 ,   31.4 ,   30.3 ,   31.5 ,   25.5 ,   27.6 ,   39.2 ,   34.9 ,   36.3 ,   43   ,   38   ,   41.7 ,   35.3 ,   36   ,   37.2 ,   39.3 ,   40.2 ,   38   ,   44.7 ,   42.7 ,   40.6 ,   42.4 ,   40.6 ,   44.4 ,   49.6 ,   47.9 ,   47.6 ,   52.9 ,
        '4i12'  ,  22.5 ,   27.9 ,   22.2 ,   31   ,   27.7 ,   35.5 ,   29.5 ,   28   ,   30.5 ,   38.1 ,   39.5 ,   35.4 ,   36.7 ,   37.9 ,   33.7 ,   40.9 ,   37.7 ,   36.8 ,   32.2 ,   36.1 ,   42.4 ,   33.1 ,   36.3 ,   43.5 ,   35.5 ,   31.1 ,   34.2 ,   43.2 ,   39   ,   42.4 ,   40   ,   41   ,   42.2 ,   42.6 ,   36.5 ,   34.1 ,   29   ,
        '4i13'  ,  57.6 ,   57.2 ,   57.1 ,   55.7 ,   54.8 ,   55.6 ,   57.3 ,   57.4 ,   54.7 ,   55.9 ,   57.3 ,   58.9 ,   58.9 ,   58.1 ,   58.1 ,   57   ,   56.9 ,   56.3 ,   58.5 ,   58.5 ,   59.5 ,   60.2 ,   61.9 ,   60.7 ,   61.2 ,   62.3 ,   62.5 ,   63   ,   62.2 ,   60.5 ,   62.3 ,   62.1 ,   60.6 ,   62.4 ,   63   ,   61.3 ,   60.6 ,
        '4i14'  ,  73   ,   76.5 ,   75.5 ,   74.2 ,   72.4 ,   73.1 ,   73.4 ,   74.6 ,   74.8 ,   75.6 ,   75.7 ,   76.7 ,   77.2 ,   77.6 ,   78.3 ,   79.2 ,   77.1 ,   78.8 ,   79.2 ,   79.8 ,   78.8 ,   80.2 ,   80.7 ,   80.2 ,   82.5 ,   78.9 ,   79.1 ,   79.9 ,   80.9 ,   80.8 ,   80.9 ,   82.2 ,   83.4 ,   84.8 ,   84.1 ,   82.3 ,   84   ,
        '4i21'  ,  59.7 ,   59.6 ,   62   ,   57.4 ,   54.4 ,   54.4 ,   56.5 ,   56.8 ,   58.1 ,   58.5 ,   58.4 ,   57.4 ,   59.2 ,   62.8 ,   65.6 ,   63.8 ,   67.2 ,   65.1 ,   63.1 ,   65.5 ,   66.4 ,   61.7 ,   60.8 ,   66.6 ,   66.1 ,   70   ,   70.1 ,   68.9 ,   65.1 ,   65   ,   65.5 ,   66.4 ,   71.7 ,   70.3 ,   69.5 ,   68.4 ,   69.7 ,
        '4i22'  ,  97.5 ,   98.2 ,   95.4 ,   94.9 ,   97.2 ,   97.3 ,   95.9 ,   96.3 ,   95.6 ,   95   ,   94.8 ,   92.8 ,   96.2 ,   94.6 ,   96.3 ,   94.4 ,   94   ,   95.2 ,   95.7 ,   92.5 ,   91.9 ,   95.9 ,   91.4 ,   90.8 ,   93.2 ,   93.6 ,   94.4 ,   91.5 ,   93.5 ,   89   ,   87.4 ,   84.4 ,   89.9 ,   90   ,   94.4 ,   94.2 ,   93.4 ,
        '4i23'  ,  76.8 ,   100  ,   94.8 ,   82.2 ,   81.5 ,   86   ,   85.2 ,   80.7 ,   89.4 ,   90.1 ,   90.3 ,   74.3 ,   90.9 ,   95.4 ,   87.6 ,   91.3 ,   95.4 ,   88.8 ,   81.7 ,   82.1 ,   79.1 ,   82.8 ,   84.1 ,   89.2 ,   94.1 ,   95.6 ,   87.2 ,   87.2 ,   91.3 ,   96.3 ,   92.2 ,   88.7 ,   94.2 ,   95.3 ,   90.8 ,   95   ,   85.7 ,
        '4I31'  ,  56   ,   58.5 ,   57.1 ,   59   ,   62.7 ,   57.9 ,   58.4 ,   56.8 ,   60.1 ,   59.2 ,   60.4 ,   59.7 ,   66.8 ,   63.9 ,   65.2 ,   65.2 ,   68.1 ,   65.1 ,   67.2 ,   67.7 ,   70.9 ,   72.1 ,   65.2 ,   63.2 ,   73.1 ,   72.9 ,   69.5 ,   67.2 ,   71.1 ,   69   ,   70.5 ,   68   ,   69   ,   68.8 ,   74.5 ,   75.6 ,   75.5 ,
        '4I32'  ,  31.7 ,   28.7 ,   38.6 ,   30   ,   41.3 ,   38.4 ,   43.9 ,   43.1 ,   48.2 ,   41.9 ,   45.6 ,   48.2 ,   47.2 ,   45.3 ,   44.2 ,   47.5 ,   44.9 ,   45.3 ,   53.4 ,   49.5 ,   49   ,   48.5 ,   50.6 ,   53.9 ,   55.6 ,   53.1 ,   52.6 ,   50.5 ,   54.1 ,   54.9 ,   55.2 ,   53.9 ,   54.9 ,   53.2 ,   48.2 ,   49.5 ,   50.6 ,
        '4I33'  ,  15.7 ,   18.2 ,   27.2 ,   31.7 ,   27.8 ,   29.2 ,   22.2 ,   24.1 ,   24   ,   25.6 ,   18.8 ,   23.3 ,   24.5 ,   25.8 ,   29.4 ,   29.3 ,   30.5 ,   32.8 ,   35.1 ,   36.7 ,   34.1 ,   28.8 ,   39.1 ,   34.3 ,   34.5 ,   38.3 ,   33.6 ,   32.5 ,   33.4 ,   36.8 ,   35.9 ,   36   ,   38.3 ,   40.9 ,   37.6 ,   37.2 ,   35.3 ,
        '4I34'  ,  3.3  ,   7.4  ,   6.4  ,   9.1  ,   2.5  ,   6.3  ,   3.2  ,   10.2 ,   1.3  ,   1.8  ,   4.5  ,   8.8  ,   9.1  ,   7.4  ,   5.1  ,   10.9 ,   6.4  ,   14.8 ,   18.9 ,   20   ,   11.5 ,   11.4 ,   18   ,   13.3 ,   14.5 ,   9.8  ,   0    ,   4.6  ,   16   ,   11.2 ,   8    ,   12.8 ,   12.3 ,   16.1 ,   20.4 ,   17.9 ,   25   ,
        '4j11'  ,  33.2 ,   36   ,   30.9 ,   26   ,   29.5 ,   29.9 ,   35.2 ,   41.5 ,   37.3 ,   32.3 ,   31.5 ,   27.4 ,   36   ,   24.4 ,   33.9 ,   34.2 ,   28.3 ,   32.4 ,   35   ,   34.9 ,   38.2 ,   38.4 ,   39.7 ,   33.6 ,   30.6 ,   31.9 ,   34.8 ,   32   ,   34.6 ,   39.4 ,   43.2 ,   36.8 ,   34.6 ,   39.6 ,   39.8 ,   35.9 ,   39.9 ,
        '4j12'  ,  40.5 ,   28   ,   22.2 ,   12.7 ,   20.3 ,   15.6 ,   14.5 ,   29.4 ,   23.3 ,   22.4 ,   25.8 ,   38   ,   16.5 ,   33.3 ,   26.9 ,   23.2 ,   19   ,   20.9 ,   32.2 ,   39.9 ,   29.3 ,   28.7 ,   47.8 ,   34.3 ,   34.7 ,   26.8 ,   36.3 ,   48.3 ,   22   ,   19.7 ,   27.1 ,   30.3 ,   23.7 ,   21.9 ,   26   ,   20.2 ,   21.7 ,
        '4j13'  ,  54.7 ,   65.5 ,   58.7 ,   58.5 ,   59.6 ,   60.9 ,   63.5 ,   61.7 ,   67.9 ,   62.3 ,   64.4 ,   59.9 ,   58.6 ,   63.8 ,   55.5 ,   60.7 ,   54.6 ,   60.6 ,   60.7 ,   57.2 ,   59.1 ,   59.6 ,   54.8 ,   57.4 ,   51.9 ,   60.7 ,   60.7 ,   51.5 ,   40.2 ,   51.8 ,   60.7 ,   59   ,   56.4 ,   54.3 ,   56.1 ,   53.6 ,   59   ,
        '4j21'  ,  17.2 ,   17.3 ,   18.8 ,   17.7 ,   14.1 ,   14.6 ,   15.4 ,   17.9 ,   14.7 ,   23.2 ,   27   ,   21.6 ,   20.1 ,   22.6 ,   26.2 ,   27.8 ,   29.7 ,   35.9 ,   33.8 ,   33.3 ,   32.6 ,   33.9 ,   30.5 ,   32.7 ,   40.6 ,   42   ,   39.8 ,   41   ,   36.9 ,   39.2 ,   45.1 ,   42.8 ,   40   ,   44.4 ,   45.4 ,   45.7 ,   44.4 ,
        '4j22'  ,  35.5 ,   32.5 ,   38.6 ,   37.5 ,   46.8 ,   39.5 ,   37.8 ,   36.9 ,   43.9 ,   43.8 ,   36.5 ,   32.9 ,   36.3 ,   41.3 ,   45.9 ,   37.3 ,   42.5 ,   45   ,   46.7 ,   44.1 ,   48.4 ,   41   ,   49.8 ,   54.3 ,   56.4 ,   51.9 ,   54.2 ,   64.2 ,   51.4 ,   42.3 ,   45   ,   48.5 ,   46.4 ,   53.6 ,   58   ,   49.8 ,   48.3 ,
        '4j23'  ,  30.8 ,   25   ,   17.5 ,   27.5 ,   46.2 ,   45   ,   40.9 ,   53   ,   49.8 ,   53.9 ,   43.6 ,   40   ,   29.5 ,   38.1 ,   45.4 ,   44.4 ,   53.5 ,   60.3 ,   50.3 ,   41.5 ,   41.9 ,   61.8 ,   47.3 ,   63   ,   54.4 ,   52.9 ,   52.5 ,   47.5 ,   59.6 ,   73.6 ,   68.6 ,   53.1 ,   57.9 ,   52.1 ,   43.8 ,   66.8 ,   68.7 ,
        '4j24'  ,  5.6  ,   7.6  ,   12.9 ,   17.6 ,   17.7 ,   31.9 ,   33.1 ,   5.7  ,   31.1 ,   18.5 ,   6.8  ,   27.8 ,   24.9 ,   20.4 ,   29.3 ,   18.6 ,   18.2 ,   17.2 ,   28.4 ,   26.4 ,   19.4 ,   41.5 ,   8.7  ,   9.2  ,   19   ,   18.8 ,   27.3 ,   45.3 ,   29.1 ,   28.2 ,   24.6 ,   21.8 ,   28.8 ,   35.1 ,   32.5 ,   32.5 ,   24.9 ,
        '4j25'  ,  75.1 ,   77.2 ,   73.6 ,   79.5 ,   81.8 ,   77.4 ,   65.8 ,   69.5 ,   82.8 ,   76.2 ,   76.2 ,   77.4 ,   77.7 ,   76   ,   88.5 ,   84.2 ,   74.8 ,   72.6 ,   73.4 ,   83.7 ,   80.8 ,   66.6 ,   50.4 ,   51.7 ,   56.6 ,   55.1 ,   70.4 ,   69.4 ,   60.1 ,   52.4 ,   62   ,   56.5 ,   61.3 ,   57.2 ,   55.8 ,   65.8 ,   68.1 ,
        '5b11'  ,  75.1 ,   75.3 ,   75.4 ,   75.1 ,   75.7 ,   74.1 ,   71.7 ,   73.9 ,   74   ,   75.3 ,   73.1 ,   70.5 ,   69.5 ,   66.6 ,   69.9 ,   67.5 ,   65.7 ,   68.3 ,   67.6 ,   65   ,   62.6 ,   69.1 ,   70.3 ,   71.4 ,   70   ,   73.2 ,   72   ,   71.1 ,   72.1 ,   69.1 ,   70.1 ,   71.3 ,   70.6 ,   69.5 ,   72.2 ,   70.8 ,   69.6 ,
        '5b12'  ,  74.6 ,   74.5 ,   74.3 ,   79.8 ,   76.6 ,   75   ,   76.6 ,   76.2 ,   79.9 ,   79.8 ,   81   ,   77.2 ,   78.3 ,   75.8 ,   76.8 ,   77.6 ,   77   ,   76.2 ,   76.4 ,   76.5 ,   75.9 ,   75.5 ,   75.6 ,   81.4 ,   78.5 ,   76.7 ,   77.9 ,   77.6 ,   74.3 ,   74.3 ,   75.2 ,   72.2 ,   71.4 ,   72.4 ,   71.5 ,   69.6 ,   71.2 ,
        '5b13'  ,  90.1 ,   87.6 ,   89.8 ,   89.2 ,   89.4 ,   86   ,   86.1 ,   87.3 ,   85.5 ,   87.8 ,   87.4 ,   84.8 ,   84.7 ,   84.3 ,   86   ,   85.5 ,   83.9 ,   79.7 ,   81.6 ,   83.4 ,   83.9 ,   83.2 ,   85.4 ,   84.4 ,   83.5 ,   84.3 ,   82.2 ,   82.1 ,   82.5 ,   78.5 ,   79.2 ,   78.4 ,   81.3 ,   82.2 ,   77.9 ,   75   ,   77.4 ,
        '5b22'  ,  54   ,   55.8 ,   55.3 ,   56.2 ,   54.8 ,   56.2 ,   53.8 ,   54.8 ,   52.6 ,   56.3 ,   54.7 ,   52   ,   50.1 ,   52.3 ,   50   ,   53.2 ,   46.1 ,   44.3 ,   49.9 ,   51.3 ,   47.1 ,   49.6 ,   48.2 ,   47   ,   46   ,   49.5 ,   54.3 ,   48.2 ,   43.8 ,   47.3 ,   46   ,   44.7 ,   45.1 ,   46.7 ,   50.7 ,   49.8 ,   44.7 ,
        '5c01'  ,  68   ,   69   ,   71.8 ,   79.2 ,   82.4 ,   79.8 ,   82.1 ,   75.1 ,   70.9 ,   72.1 ,   73.6 ,   73.5 ,   74.6 ,   74.3 ,   73.4 ,   74.7 ,   72.6 ,   71   ,   64.9 ,   66.9 ,   63.3 ,   77.9 ,   76.8 ,   71.1 ,   68   ,   73.5 ,   68.8 ,   70.4 ,   64.9 ,   70.1 ,   64.1 ,   61.3 ,   65.8 ,   72.6 ,   78.6 ,   64.8 ,   76.9 ,
        '5d01'  ,  78.3 ,   78.6 ,   79.2 ,   80.8 ,   80.9 ,   80.2 ,   81.3 ,   81.1 ,   83.1 ,   83.5 ,   83   ,   83.1 ,   83.3 ,   83.5 ,   82.9 ,   82.7 ,   82.4 ,   82.1 ,   82.4 ,   81.6 ,   81.1 ,   83.1 ,   83.2 ,   82.4 ,   83.1 ,   83.4 ,   82.4 ,   81.1 ,   80.3 ,   81.9 ,   81.9 ,   82   ,   82.4 ,   81.8 ,   82.2 ,   81.4 ,   81.7 ,
        '5d02'  ,  91.5 ,   93   ,   93.3 ,   92.2 ,   94.2 ,   92.1 ,   92.3 ,   90.8 ,   93.8 ,   91.2 ,   87.2 ,   89.6 ,   84.6 ,   87.1 ,   90.7 ,   88.8 ,   89.4 ,   85.5 ,   86.3 ,   86.9 ,   86.8 ,   84.3 ,   83.6 ,   83.5 ,   87.5 ,   80.1 ,   71.1 ,   74.9 ,   73.7 ,   76.9 ,   77.7 ,   63.1 ,   67.7 ,   79.9 ,   64.6 ,   61.3 ,   54.4 ,
        '5d03'  ,  NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   79.2 ,   75.7 ,   71.7 ,   83.3 ,   79.2 ,   74   ,   83.1 ,   85.9 ,   82.4 ,   81.9 ,   83   ,   85.9 ,   87.3 ,   85.5 ,   88.6 ,   87.7 ,
        '5d04'  ,  40.5 ,   38.2 ,   39.1 ,   41.3 ,   42.4 ,   43.2 ,   42.9 ,   40.1 ,   38.6 ,   38.8 ,   43.3 ,   46.3 ,   46   ,   48.1 ,   45.5 ,   46.7 ,   48.4 ,   45.7 ,   46.9 ,   46   ,   45.3 ,   54   ,   59.2 ,   58.7 ,   53.5 ,   56.4 ,   57.9 ,   50.7 ,   54.7 ,   51.4 ,   53.5 ,   52.3 ,   54.2 ,   53.2 ,   52.8 ,   54.4 ,   58.1 ,
        '5f00'  ,  86   ,   85.9 ,   85.4 ,   86.7 ,   88.8 ,   87.5 ,   87.9 ,   87.5 ,   86.9 ,   88.4 ,   89.4 ,   88   ,   88.4 ,   86.1 ,   86.5 ,   86.3 ,   86.4 ,   85.7 ,   86.9 ,   87.4 ,   87.4 ,   85.8 ,   85.7 ,   85.8 ,   87.6 ,   87.3 ,   85.8 ,   84.8 ,   84.8 ,   85.4 ,   86.9 ,   88.4 ,   86.5 ,   86.1 ,   85.4 ,   86.2 ,   86.9 ,
        '5g10'  ,  4.4  ,   4.2  ,   3.8  ,   3.3  ,   5    ,   3.6  ,   6.2  ,   5.8  ,   4.3  ,   4.6  ,   4.9  ,   7.5  ,   8    ,   6.6  ,   5    ,   8.6  ,   9.8  ,   10.4 ,   10.4 ,   14.8 ,   17.3 ,   18.3 ,   16.6 ,   16.2 ,   13.2 ,   23   ,   24.6 ,   22.4 ,   20.2 ,   23.4 ,   20.2 ,   18.6 ,   23.3 ,   23.3 ,   20.4 ,   17.9 ,   20.5 ,
        '5g21'  ,  4.4  ,   2.7  ,   2.7  ,   4.1  ,   4.7  ,   5.4  ,   5.4  ,   5.5  ,   10.4 ,   10.8 ,   16.1 ,   8.6  ,   6.1  ,   7.8  ,   5.5  ,   4.6  ,   5    ,   7.8  ,   10.5 ,   10.1 ,   10   ,   7.1  ,   5.6  ,   8.3  ,   7.9  ,   6.8  ,   8    ,   6.4  ,   5.9  ,   8.4  ,   6.9  ,   7.1  ,   8.8  ,   7.1  ,   14.4 ,   12.7 ,   6.2  ,
        '5g22'  ,  0    ,   0    ,   0    ,   0    ,   0    ,   2.3  ,   2.8  ,   3.8  ,   2.9  ,   2.7  ,   2    ,   2.2  ,   3.4  ,   1.7  ,   2.9  ,   2.4  ,   1.9  ,   5.9  ,   4.6  ,   4.8  ,   6.3  ,   8.7  ,   7.6  ,   14.5 ,   12.9 ,   15.2 ,   12.7 ,   5.5  ,   20.4 ,   20.3 ,   15.5 ,   17.9 ,   16   ,   15.9 ,   18.2 ,   17.9 ,   22.2 ,
        '5g23'  ,  5.9  ,   10.7 ,   13   ,   11.8 ,   10.8 ,   13.3 ,   13.9 ,   12.9 ,   12.9 ,   13.6 ,   16.8 ,   14.3 ,   9.9  ,   9.6  ,   11.4 ,   9.7  ,   12.3 ,   14.1 ,   16.2 ,   13.8 ,   10.9 ,   14.1 ,   9.3  ,   15.9 ,   17.8 ,   20.2 ,   17   ,   20.9 ,   16.1 ,   12.3 ,   9.2  ,   8.5  ,   14.1 ,   18.1 ,   18.5 ,   11.1 ,   13.6 ,
        '5g24'  ,  0    ,   0    ,   1.5  ,   0    ,   0    ,   4.2  ,   2    ,   0    ,   0    ,   0    ,   0    ,   1.3  ,   0.8  ,   0.8  ,   2.3  ,   2.4  ,   3.1  ,   2    ,   1.6  ,   3.1  ,   4.9  ,   3.2  ,   2.9  ,   0.5  ,   0.2  ,   2.8  ,   2.4  ,   3.1  ,   2.7  ,   1.6  ,   3.4  ,   6    ,   8.1  ,   4.3  ,   1.8  ,   3.4  ,   4.3  ,
        '5g31'  ,  6.7  ,   8.4  ,   9.3  ,   5.5  ,   5.4  ,   8    ,   6.6  ,   8.6  ,   9.4  ,   10.1 ,   9.2  ,   8.4  ,   9    ,   10.8 ,   10.3 ,   7.9  ,   9    ,   10.5 ,   11.8 ,   8.4  ,   10.3 ,   10.1 ,   9.7  ,   8.8  ,   9.8  ,   14.5 ,   8.5  ,   10.4 ,   13.1 ,   12   ,   12.1 ,   12.1 ,   10.6 ,   10.5 ,   11.6 ,   12.1 ,   16.6 ,
        '5g32'  ,  0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   5.9  ,   7    ,   0    ,   0    ,   6.1  ,   0    ,   6.8  ,   0    ,   3.6  ,   0    ,   0    ,   0    ,   11.7 ,   14.3 ,   17.8 ,   5.7  ,   6.8  ,   19.6 ,   19.8 ,   35.1 ,   28.2 ,   15.2 ,   33.2 ,   26.9 ,   22.5 ,   16.4 ,   11.5 ,   17   ,
        '5h11'  ,  84.4 ,   83.1 ,   82.9 ,   82.9 ,   83.5 ,   83   ,   83.3 ,   82.7 ,   84.2 ,   84.4 ,   84.7 ,   84.4 ,   84   ,   83.7 ,   84.7 ,   84.4 ,   84.9 ,   84.4 ,   83.9 ,   83.8 ,   84.5 ,   84.1 ,   83.2 ,   82.2 ,   83.2 ,   83.2 ,   82.1 ,   83.7 ,   83.3 ,   82.8 ,   82.6 ,   83.6 ,   84.2 ,   82.8 ,   83.6 ,   83.5 ,   82.3 ,
        '5h12'  ,  83.7 ,   81.5 ,   79.3 ,   81.2 ,   90   ,   87.7 ,   89.6 ,   85.6 ,   81.6 ,   86.6 ,   88.8 ,   88.3 ,   87.6 ,   86.9 ,   88.9 ,   88.8 ,   85.7 ,   84.9 ,   88.8 ,   89   ,   90.4 ,   93.8 ,   93.8 ,   93.2 ,   93.6 ,   90.6 ,   88.6 ,   90.9 ,   91.4 ,   90.8 ,   92.7 ,   95.5 ,   91.8 ,   89.3 ,   91.3 ,   90.9 ,   88.6 ,
        '5h21'  ,  79.5 ,   80.9 ,   81.9 ,   81.7 ,   80.4 ,   79.4 ,   79.3 ,   78.5 ,   81.7 ,   82.9 ,   83.3 ,   82.8 ,   82.2 ,   82.3 ,   82.9 ,   84.7 ,   84.4 ,   82.6 ,   77.9 ,   78.3 ,   79.7 ,   79.3 ,   78.4 ,   74.1 ,   78   ,   76.7 ,   81.1 ,   81.5 ,   82.4 ,   78.4 ,   77.4 ,   80.1 ,   80.9 ,   79.4 ,   78.1 ,   80.6 ,   77.3 ,
        '5h22'  ,  58.8 ,   59.1 ,   58.1 ,   53.4 ,   55.3 ,   53.8 ,   53.1 ,   55.1 ,   52.9 ,   54.1 ,   48.4 ,   47.5 ,   50.2 ,   52   ,   49.4 ,   49.5 ,   49.7 ,   45.7 ,   45.5 ,   46.1 ,   51.2 ,   41.8 ,   40.9 ,   43.7 ,   46.5 ,   42.9 ,   38.8 ,   38.2 ,   37.9 ,   40.5 ,   37.7 ,   39.6 ,   38.6 ,   41.3 ,   38.5 ,   41.6 ,   39.9 ,
        '6e10'  ,  0    ,   1.8  ,   0    ,   0    ,   0    ,   0    ,   1.7  ,   1.8  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   9.7  ,   12.1 ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,
        '6e11'  ,  0.7  ,   0.2  ,   0    ,   0    ,   0.2  ,   0.2  ,   0.4  ,   0.8  ,   0    ,   0.2  ,   0.2  ,   1.4  ,   0.5  ,   0.6  ,   1.1  ,   0.5  ,   0    ,   0.9  ,   1.4  ,   1    ,   1.1  ,   1    ,   1.5  ,   2    ,   2    ,   0.5  ,   0.7  ,   0.9  ,   2.1  ,   3.3  ,   2.3  ,   1.4  ,   1.3  ,   2.4  ,   2.2  ,   0.6  ,   1.5  ,
        '6e12'  ,  20.3 ,   22.6 ,   27.9 ,   35.2 ,   30.9 ,   35.8 ,   33.7 ,   28.5 ,   28.6 ,   30.9 ,   33.4 ,   28.9 ,   36.6 ,   33.1 ,   35.2 ,   34.5 ,   35.1 ,   34.6 ,   35   ,   35.3 ,   34.4 ,   38.8 ,   40   ,   37.1 ,   41.2 ,   37.8 ,   28.3 ,   35.8 ,   34.5 ,   36.8 ,   34.6 ,   36.9 ,   30.1 ,   27.4 ,   25.7 ,   28.4 ,   23.8 ,
        '6e13'  ,  2.6  ,   2.8  ,   3.8  ,   3.4  ,   3.6  ,   4.1  ,   4    ,   4.8  ,   5.3  ,   5.5  ,   6.3  ,   6.1  ,   6.7  ,   6.5  ,   6.5  ,   6.5  ,   6.2  ,   7.2  ,   7.4  ,   8.1  ,   6.6  ,   8.8  ,   11.1 ,   9.7  ,   10.5 ,   10   ,   10.8 ,   10.3 ,   10.1 ,   11.8 ,   11.1 ,   11   ,   11.1 ,   12.2 ,   11.6 ,   13.5 ,   11.5 ,
        '6e14'  ,  18.8 ,   20   ,   19.3 ,   18.2 ,   23.7 ,   21.6 ,   22.4 ,   22.7 ,   24   ,   26   ,   24.5 ,   23.6 ,   24.4 ,   23.2 ,   23.7 ,   22.1 ,   22.8 ,   18.8 ,   19.6 ,   21   ,   23.7 ,   18.5 ,   30.6 ,   27.7 ,   32.3 ,   38.3 ,   31.9 ,   26.1 ,   17.7 ,   21.1 ,   24.6 ,   25.2 ,   19.6 ,   17.1 ,   18.8 ,   20.9 ,   24.2 ,
        '6e15'  ,  18.4 ,   14.7 ,   15   ,   15.7 ,   16.8 ,   15.7 ,   18.3 ,   19.1 ,   16.6 ,   16.1 ,   16.8 ,   13.9 ,   17.1 ,   19.2 ,   19.2 ,   19.8 ,   18.5 ,   18.9 ,   17.6 ,   20.1 ,   19.7 ,   23.3 ,   27.5 ,   24.9 ,   20.1 ,   23.6 ,   22   ,   19.5 ,   22.4 ,   24.1 ,   24.1 ,   25.9 ,   29.7 ,   26.7 ,   24.5 ,   27.6 ,   30.7 ,
        '6e16'  ,  72.1 ,   70.6 ,   71.8 ,   71   ,   66.8 ,   60.4 ,   65.2 ,   65.6 ,   70.7 ,   71.7 ,   71.2 ,   67.8 ,   67.5 ,   69.1 ,   70   ,   65   ,   66.8 ,   63.7 ,   63.8 ,   65.4 ,   68.8 ,   67.4 ,   69.9 ,   70.3 ,   62.4 ,   61.1 ,   65.1 ,   61.8 ,   54.8 ,   58.4 ,   65.6 ,   67.3 ,   54.2 ,   52.9 ,   61.1 ,   68.1 ,   54.1 ,
        '6e17'  ,  7.3  ,   4.6  ,   6.6  ,   3.8  ,   3    ,   4    ,   2.4  ,   2.4  ,   5.5  ,   7.6  ,   10.9 ,   7.1  ,   5.7  ,   6.5  ,   8.1  ,   7.1  ,   4.8  ,   2.4  ,   4.5  ,   3.4  ,   5.6  ,   12   ,   14.7 ,   10.5 ,   14.4 ,   7.7  ,   8.6  ,   7.4  ,   6.2  ,   7.5  ,   5.4  ,   4.4  ,   6.7  ,   7.2  ,   5.5  ,   4.8  ,   6.9  ,
        '6e18'  ,  1.9  ,   1    ,   1.5  ,   0.9  ,   1.2  ,   1.4  ,   2.2  ,   1.9  ,   1.8  ,   2.4  ,   1.2  ,   1.2  ,   1.6  ,   1.8  ,   2.2  ,   1.6  ,   1.1  ,   2    ,   1.9  ,   1.8  ,   2.1  ,   1.8  ,   1.1  ,   1.1  ,   1.4  ,   3.2  ,   3.6  ,   3.3  ,   3.5  ,   1.3  ,   1.7  ,   3.3  ,   2.7  ,   1.8  ,   3.4  ,   4.3  ,   3.7  ,
        '6e19'  ,  33.9 ,   22   ,   19.5 ,   23.7 ,   20.5 ,   16.9 ,   20.9 ,   20.5 ,   30.7 ,   25.3 ,   22   ,   24.6 ,   26.8 ,   24.8 ,   23.7 ,   28.8 ,   26.7 ,   28.3 ,   23   ,   24.7 ,   25.9 ,   23.8 ,   19.8 ,   15.2 ,   19.1 ,   22.8 ,   28.2 ,   25.5 ,   22.8 ,   21.2 ,   22.4 ,   26.9 ,   23.9 ,   21.3 ,   25.1 ,   23.2 ,   24.7 ,
        '6e21'  ,  1.5  ,   1    ,   1    ,   1.8  ,   3.2  ,   2.2  ,   2.1  ,   0    ,   1.1  ,   1.7  ,   2.6  ,   2.4  ,   4.1  ,   4.6  ,   3.1  ,   3.8  ,   3.2  ,   3.7  ,   3.9  ,   5.2  ,   5.9  ,   8.1  ,   7.5  ,   5    ,   4.2  ,   10.9 ,   7.7  ,   4.7  ,   5.3  ,   6.7  ,   6.4  ,   6.4  ,   4.4  ,   6.9  ,   5.9  ,   4.7  ,   4.9  ,
        '6e22'  ,  0    ,   0    ,   0.4  ,   0    ,   0    ,   0    ,   0    ,   0.4  ,   0.4  ,   0.6  ,   0    ,   0    ,   0.2  ,   0    ,   1.1  ,   0.4  ,   0.3  ,   0.4  ,   0.9  ,   1.1  ,   0.4  ,   0    ,   0    ,   0.6  ,   0.4  ,   0.3  ,   1.4  ,   0.9  ,   1.1  ,   0.1  ,   0.2  ,   0.3  ,   0    ,   0.6  ,   1.3  ,   2.8  ,   0.5  ,
        '6e23'  ,  0.8  ,   0.4  ,   0.7  ,   0.5  ,   0.4  ,   0.8  ,   0.6  ,   0.6  ,   0.9  ,   1.8  ,   1.5  ,   2    ,   2.6  ,   3.3  ,   4.3  ,   3.6  ,   4.1  ,   3.5  ,   4.4  ,   4.6  ,   4.8  ,   2.2  ,   2.5  ,   1.8  ,   2.2  ,   2.7  ,   1.8  ,   1.7  ,   1.9  ,   2.3  ,   3.5  ,   3.1  ,   3.1  ,   3.8  ,   4.2  ,   4.4  ,   3.3  ,
        '6e24'  ,  0.8  ,   1.2  ,   0.6  ,   0.5  ,   0.4  ,   0.3  ,   0.7  ,   0.3  ,   0.5  ,   0.5  ,   0.5  ,   1.3  ,   1    ,   1.2  ,   0.8  ,   0.6  ,   2    ,   2.1  ,   0.7  ,   1.2  ,   0.3  ,   1.9  ,   1.1  ,   0.2  ,   0.6  ,   2.4  ,   0.9  ,   0.6  ,   2    ,   0.4  ,   0.6  ,   1.5  ,   1.5  ,   0.7  ,   3    ,   6    ,   1    ,
        '6e25'  ,  0    ,   0.4  ,   0.1  ,   0.4  ,   0.4  ,   0.4  ,   0.3  ,   0.5  ,   0.4  ,   1.1  ,   0.5  ,   1.1  ,   1    ,   1.1  ,   1.2  ,   1.3  ,   1.1  ,   1.4  ,   1.9  ,   1.6  ,   1.6  ,   0.3  ,   0.6  ,   0.7  ,   1.5  ,   1.5  ,   1.5  ,   0.7  ,   1.2  ,   1.1  ,   0.3  ,   1    ,   1.9  ,   1.2  ,   2.2  ,   0.9  ,   0.8  ,
        '6e26'  ,  74.2 ,   70.9 ,   67.4 ,   67.8 ,   65.3 ,   66.7 ,   66.4 ,   67.8 ,   62.3 ,   58.9 ,   65.9 ,   64.6 ,   69.2 ,   65.2 ,   69.4 ,   64.8 ,   68.2 ,   58.7 ,   66.2 ,   69   ,   79.5 ,   64.8 ,   57.9 ,   70   ,   69.7 ,   59.4 ,   58   ,   64.9 ,   75.4 ,   71.6 ,   86.7 ,   86.4 ,   75.5 ,   68.7 ,   73.8 ,   67   ,   77.4 ,
        '6e27'  ,  16.8 ,   17.1 ,   17.3 ,   14.2 ,   12.9 ,   14.7 ,   15.1 ,   16   ,   17   ,   17.3 ,   16.5 ,   17.1 ,   16.9 ,   17.9 ,   18   ,   17   ,   17.8 ,   16.6 ,   15.5 ,   18.6 ,   16.8 ,   17.9 ,   18.4 ,   21.3 ,   21.5 ,   18.4 ,   18.7 ,   20.2 ,   23.5 ,   23.7 ,   22.8 ,   23.7 ,   22.7 ,   24.4 ,   24.5 ,   23   ,   21.9 ,
        '6e28'  ,  32.7 ,   34.1 ,   29.4 ,   31.5 ,   30.6 ,   29   ,   35.1 ,   28.8 ,   31.7 ,   31.7 ,   28.8 ,   32.6 ,   26.2 ,   39.3 ,   36.3 ,   29.6 ,   32.7 ,   35   ,   38.1 ,   43.4 ,   37.6 ,   38.2 ,   30.2 ,   34.5 ,   49.9 ,   46.9 ,   37.2 ,   33.9 ,   37.3 ,   33.5 ,   29.3 ,   49.4 ,   42.9 ,   36.5 ,   37.5 ,   43.7 ,   47.4 ,
        '6e31'  ,  0.3  ,   0.4  ,   0.2  ,   0.6  ,   0.4  ,   0.4  ,   0.3  ,   0.1  ,   0.2  ,   0.2  ,   0.7  ,   0.4  ,   0.7  ,   0.6  ,   0.6  ,   0.7  ,   0.9  ,   0.9  ,   0.9  ,   1.4  ,   0.5  ,   0.9  ,   0.8  ,   1.5  ,   1.9  ,   2    ,   1.7  ,   1.8  ,   1.7  ,   1.9  ,   2.3  ,   2.7  ,   1.7  ,   2.8  ,   3.2  ,   2.5  ,   2.5  ,
        '6e32'  ,  5.1  ,   3.9  ,   5.2  ,   5.8  ,   7    ,   6.8  ,   7    ,   6.5  ,   5.5  ,   8.5  ,   10.4 ,   11.3 ,   10.6 ,   8.9  ,   11.9 ,   12.6 ,   13.9 ,   12.2 ,   15.2 ,   17.8 ,   19.9 ,   19.2 ,   17.8 ,   21.4 ,   23.8 ,   29.1 ,   22.3 ,   23.8 ,   27.4 ,   21.9 ,   21   ,   17.9 ,   18   ,   22   ,   23   ,   17.6 ,   13.6 ,
        '6e33'  ,  5    ,   7.9  ,   5.9  ,   3.8  ,   2.8  ,   5.5  ,   4.4  ,   4.8  ,   5    ,   6.3  ,   5.3  ,   12.5 ,   11.7 ,   12.1 ,   10.7 ,   10   ,   8.2  ,   13.4 ,   12.1 ,   22.5 ,   16.9 ,   7.2  ,   4.7  ,   8.2  ,   13.1 ,   19.8 ,   24.4 ,   21.2 ,   25.5 ,   22.6 ,   23.5 ,   19.1 ,   15.2 ,   21.1 ,   16.7 ,   17.1 ,   16.8 ,
        '6e34'  ,  3    ,   2.4  ,   0.9  ,   0.9  ,   1.7  ,   1.5  ,   1.7  ,   1.4  ,   1.9  ,   1.6  ,   2.4  ,   1.4  ,   2.6  ,   0.9  ,   3.4  ,   2.4  ,   1    ,   0.4  ,   0    ,   1.9  ,   1.9  ,   1    ,   2    ,   2.1  ,   1.4  ,   1.7  ,   3.7  ,   2.8  ,   4.2  ,   5.3  ,   2.3  ,   1.9  ,   2.9  ,   2.2  ,   0.6  ,   1.9  ,   2.7  ,
        '6e35'  ,  1.4  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   1.4  ,   1.6  ,   0    ,   0    ,   1.2  ,   1.6  ,   2    ,   2.2  ,   2.4  ,   0    ,   0    ,   0    ,   3    ,   2.9  ,   0    ,   0    ,   0    ,   2.4  ,   0    ,   0    ,   0    ,   6.1  ,   2.3  ,   1.4  ,   1.6  ,   0    ,   0    ,   5.8  ,   0    ,   2.5  ,
        '6e36'  ,  3.6  ,   7.6  ,   5.8  ,   3.9  ,   6    ,   4    ,   4.7  ,   6.6  ,   4.7  ,   5.5  ,   7.1  ,   4.3  ,   4    ,   2    ,   3.9  ,   3.9  ,   3.3  ,   6.1  ,   5    ,   4.2  ,   5.3  ,   11.8 ,   2.9  ,   6.2  ,   3.4  ,   6    ,   11.8 ,   14.4 ,   13.6 ,   13.2 ,   16.2 ,   8.1  ,   6.4  ,   3.9  ,   7.3  ,   15.6 ,   9.9  ,
        '6e41'  ,  0.4  ,   0.7  ,   0.4  ,   0.5  ,   0.5  ,   1.4  ,   1.5  ,   1.2  ,   0.6  ,   1    ,   1.1  ,   4.2  ,   1.4  ,   1    ,   0.8  ,   2.1  ,   2    ,   3    ,   2.1  ,   1.9  ,   1.1  ,   3    ,   4.4  ,   4.6  ,   7.8  ,   4.7  ,   6.2  ,   7.7  ,   5.3  ,   4.9  ,   3.4  ,   9.5  ,   8.3  ,   10.5 ,   10.4 ,   9    ,   13   ,
        '6e42'  ,  49.3 ,   50.5 ,   57.7 ,   59.3 ,   52.6 ,   52   ,   51.6 ,   55.5 ,   51.8 ,   56.7 ,   56.2 ,   51   ,   60.6 ,   53.3 ,   51.7 ,   57.2 ,   55.8 ,   53   ,   55.2 ,   52.7 ,   60.1 ,   52.3 ,   52.1 ,   50.8 ,   53   ,   49.3 ,   49.6 ,   43.1 ,   42.2 ,   44   ,   40.3 ,   40.4 ,   47   ,   41.5 ,   46.1 ,   50.9 ,   34.1 ,
        '6e43'  ,  27.7 ,   28.1 ,   27   ,   26.8 ,   26.9 ,   24   ,   25.5 ,   25.2 ,   31.1 ,   33.7 ,   29.5 ,   26.9 ,   30.7 ,   30.7 ,   29.2 ,   26.9 ,   26.2 ,   27.8 ,   26.9 ,   27.5 ,   31.1 ,   28.9 ,   27.9 ,   25   ,   28.8 ,   27.1 ,   24.7 ,   26.2 ,   22.5 ,   28.5 ,   28.5 ,   25.9 ,   28.3 ,   24.7 ,   27.3 ,   27.4 ,   25.9 ,
        '6e44'  ,  32.9 ,   32   ,   32   ,   34.4 ,   35.6 ,   37.4 ,   34.8 ,   36.6 ,   36   ,   40.1 ,   37   ,   37.2 ,   40.8 ,   41   ,   39.9 ,   43.3 ,   41.7 ,   41.6 ,   42.1 ,   45.1 ,   42.2 ,   43.9 ,   44.2 ,   48.9 ,   46.6 ,   47   ,   50.8 ,   48   ,   43.7 ,   42.5 ,   47.5 ,   45.8 ,   43.6 ,   43.8 ,   40.3 ,   41.7 ,   43.4 ,
        '6e45'  ,  81.7 ,   82.7 ,   79.2 ,   76.8 ,   77.8 ,   79.6 ,   80   ,   78.6 ,   79.7 ,   79.2 ,   77.6 ,   77.6 ,   76.4 ,   76.9 ,   70.4 ,   72.7 ,   73.3 ,   74.4 ,   71.4 ,   69.2 ,   73.8 ,   68.6 ,   73.5 ,   77.8 ,   78.1 ,   76.3 ,   59.4 ,   73.9 ,   73.2 ,   70.7 ,   68   ,   68.4 ,   67.7 ,   65.9 ,   59.1 ,   58.8 ,   67.6 ,
        '6e46'  ,  36.3 ,   35.6 ,   35.7 ,   39.3 ,   36.6 ,   30.8 ,   33.5 ,   32.9 ,   35.2 ,   34.4 ,   36.7 ,   35.7 ,   33.6 ,   31.2 ,   34.6 ,   30.1 ,   30.8 ,   31.5 ,   33.6 ,   33.5 ,   32.8 ,   34.7 ,   31.7 ,   32.6 ,   30.3 ,   26.3 ,   32.3 ,   26.7 ,   30.1 ,   24.6 ,   22.5 ,   22.3 ,   19.8 ,   19   ,   22.2 ,   19.8 ,   25.7 ,
        '6e51'  ,  16.1 ,   15.8 ,   15.1 ,   13.1 ,   12.8 ,   13.5 ,   14.2 ,   14.4 ,   17   ,   18.4 ,   15.3 ,   16.6 ,   15.6 ,   15.3 ,   15.3 ,   14.4 ,   17.1 ,   16.5 ,   15.3 ,   14.8 ,   16.1 ,   19.5 ,   19.6 ,   17.9 ,   18.2 ,   18.5 ,   19.6 ,   18.5 ,   17.6 ,   18.8 ,   18   ,   18.4 ,   18.2 ,   18.7 ,   20.7 ,   19.1 ,   19.2 ,
        '6e52'  ,  6    ,   5.9  ,   5.7  ,   6    ,   7.2  ,   7.1  ,   5.8  ,   8.8  ,   4.3  ,   4.9  ,   5.4  ,   5.7  ,   6.2  ,   6.8  ,   7.3  ,   6.8  ,   6.5  ,   7.3  ,   5.5  ,   5.7  ,   4.6  ,   9.5  ,   9.9  ,   9.9  ,   10   ,   8.2  ,   10.8 ,   9.4  ,   9.4  ,   12.4 ,   11.1 ,   9.8  ,   9    ,   10.6 ,   9    ,   11.9 ,   10.6 ,
        '6e53'  ,  54.1 ,   44.9 ,   38.6 ,   43   ,   46.9 ,   45.1 ,   47.4 ,   47.5 ,   42.6 ,   46.4 ,   42.7 ,   42.5 ,   41.1 ,   43.7 ,   43.3 ,   45.2 ,   41.5 ,   40.4 ,   43.2 ,   42.9 ,   41.9 ,   40.1 ,   33.9 ,   38.6 ,   36.8 ,   33.5 ,   35.9 ,   34.7 ,   34.8 ,   36.7 ,   36   ,   36.5 ,   35.8 ,   35   ,   37.2 ,   35.9 ,   35.6 ,
        '6e61'  ,  1.4  ,   0.9  ,   0.9  ,   0.9  ,   1.5  ,   1.6  ,   1.5  ,   1.1  ,   1.1  ,   1.3  ,   1.2  ,   1.7  ,   2.9  ,   4    ,   4.3  ,   4.6  ,   3.6  ,   3.6  ,   3.7  ,   4.1  ,   3.7  ,   5.5  ,   3.8  ,   4.7  ,   4.1  ,   3.7  ,   3.8  ,   2.2  ,   2.4  ,   5.2  ,   4.2  ,   4.2  ,   5.1  ,   4.9  ,   6.6  ,   5.6  ,   6.5  ,
        '6e62'  ,  2.4  ,   2.9  ,   2.2  ,   0.7  ,   1.1  ,   0.3  ,   0    ,   1.6  ,   2.5  ,   2.8  ,   2.2  ,   2.3  ,   2.4  ,   3.2  ,   1.9  ,   3.6  ,   3    ,   2.6  ,   4    ,   2.2  ,   1.5  ,   7    ,   3.8  ,   2.1  ,   0.3  ,   3.1  ,   1.8  ,   1.7  ,   4.8  ,   4.9  ,   1.5  ,   4.6  ,   4.5  ,   4    ,   2.9  ,   3.5  ,   2    ,
        '6e63'  ,  2.1  ,   1.6  ,   6.5  ,   6    ,   6.2  ,   0.9  ,   6.6  ,   10.6 ,   1.9  ,   0.9  ,   11.1 ,   10.2 ,   9.7  ,   3.5  ,   11.5 ,   8.3  ,   4.9  ,   9.7  ,   8.3  ,   5.1  ,   5.8  ,   9.5  ,   17.6 ,   10   ,   3.7  ,   12.2 ,   13   ,   17.3 ,   15   ,   15.3 ,   18.1 ,   14.6 ,   15.9 ,   16   ,   16.2 ,   20.9 ,   19.3 ,
        '6e64'  ,  66.4 ,   69.1 ,   69.5 ,   68.9 ,   70   ,   67.8 ,   68.7 ,   65.1 ,   73.2 ,   74.7 ,   75   ,   69.1 ,   73.2 ,   69.8 ,   68.8 ,   69.4 ,   70   ,   71.6 ,   71.1 ,   67.9 ,   67.7 ,   64.8 ,   61.9 ,   57.7 ,   61.9 ,   63.4 ,   62   ,   64.2 ,   67.4 ,   68   ,   65.2 ,   61.2 ,   62.2 ,   63.3 ,   64.5 ,   60.4 ,   59.4 ,
        '6e65'  ,  52.7 ,   53.3 ,   48.6 ,   52.3 ,   53.4 ,   48.1 ,   46.5 ,   54.3 ,   53.7 ,   48   ,   52.4 ,   58.8 ,   65.6 ,   66.2 ,   58.7 ,   59.9 ,   56.5 ,   59.1 ,   49.2 ,   51.4 ,   51.6 ,   49.4 ,   53.6 ,   56.9 ,   48   ,   46.7 ,   53.3 ,   48.1 ,   40.7 ,   50.3 ,   44.6 ,   45   ,   51.8 ,   52.1 ,   43.6 ,   49.1 ,   52.5 ,
        '6e71'  ,  1.3  ,   1.4  ,   1.6  ,   1.9  ,   2.6  ,   3.2  ,   2.7  ,   2    ,   2.2  ,   1.4  ,   2.8  ,   2.5  ,   2.8  ,   2.3  ,   1.2  ,   2.1  ,   2.3  ,   2.3  ,   2.3  ,   1.5  ,   1.5  ,   4    ,   3.5  ,   3.1  ,   4.5  ,   4    ,   4    ,   3.6  ,   3.9  ,   3.3  ,   3.3  ,   5.1  ,   6.3  ,   5.5  ,   5.4  ,   5.2  ,   6    ,
        '6e72'  ,  3.8  ,   1.4  ,   2.9  ,   4.3  ,   5.2  ,   5.7  ,   6.7  ,   8.1  ,   7.7  ,   7.8  ,   2.9  ,   7    ,   7.2  ,   12.3 ,   7.3  ,   8.3  ,   8.7  ,   8.3  ,   15.2 ,   9.7  ,   5.5  ,   3.2  ,   1.3  ,   14.4 ,   13   ,   3.7  ,   7.1  ,   8.9  ,   3.8  ,   3    ,   2.4  ,   2.7  ,   6.7  ,   10.8 ,   8.3  ,   6.1  ,   11.1 ,
        '6e73'  ,  38.5 ,   47.7 ,   48.1 ,   53.4 ,   43.4 ,   42.2 ,   35.3 ,   46.2 ,   45.9 ,   48   ,   40.3 ,   44   ,   39.6 ,   38.8 ,   45.6 ,   43.8 ,   58.4 ,   61.4 ,   48.2 ,   48.7 ,   52   ,   69.6 ,   55.2 ,   54.2 ,   64.9 ,   60.5 ,   53.6 ,   60.1 ,   69   ,   80.4 ,   82.8 ,   74.2 ,   78.9 ,   81.1 ,   70.8 ,   76.5 ,   90.5 ,
        '6e74'  ,  0    ,   2.8  ,   2.7  ,   4.6  ,   1.5  ,   2.3  ,   0    ,   3.1  ,   4.4  ,   4.7  ,   7    ,   5.3  ,   4.6  ,   4.6  ,   4.1  ,   4.9  ,   3.4  ,   4.9  ,   1.1  ,   0    ,   8.8  ,   20   ,   18.3 ,   26.4 ,   12.3 ,   8.9  ,   10   ,   6    ,   9.9  ,   17.3 ,   20.9 ,   32.8 ,   25.8 ,   21   ,   26   ,   28.7 ,   22.5 ,
        '6e75'  ,  17.6 ,   15.6 ,   14.4 ,   13.6 ,   15.5 ,   17   ,   18.7 ,   18.8 ,   11.6 ,   11.1 ,   10.1 ,   13   ,   13.8 ,   11.7 ,   11.1 ,   11.5 ,   11.8 ,   9.9  ,   15.9 ,   16   ,   18.3 ,   27.1 ,   26.9 ,   26.3 ,   27.7 ,   20.9 ,   19.6 ,   17.9 ,   20.9 ,   28.1 ,   26.5 ,   33.7 ,   31   ,   30.7 ,   29.7 ,   29.9 ,   26.6 ,
        '6e76'  ,  3.1  ,   3.5  ,   3.4  ,   3.2  ,   4.6  ,   6.3  ,   8.2  ,   7    ,   3    ,   4.9  ,   6.9  ,   5.3  ,   2    ,   1.6  ,   3    ,   4.4  ,   3.5  ,   3.4  ,   3.5  ,   2.8  ,   4    ,   4    ,   13.1 ,   11.9 ,   8.6  ,   6.3  ,   8    ,   5.7  ,   4.4  ,   6.4  ,   8.6  ,   8.7  ,   8    ,   11.7 ,   9.9  ,   6.2  ,   6.2  ,
        '6e77'  ,  6.3  ,   11.7 ,   12.9 ,   8.9  ,   11.5 ,   11   ,   10.4 ,   10.3 ,   8.8  ,   9.8  ,   11.3 ,   10.4 ,   10.8 ,   10.8 ,   10.4 ,   12.7 ,   7.8  ,   12.8 ,   12.8 ,   13.1 ,   13.7 ,   12.7 ,   11.6 ,   13.6 ,   12.3 ,   5    ,   10   ,   12.2 ,   11.7 ,   6.6  ,   10   ,   10.1 ,   13.5 ,   16.5 ,   9.5  ,   10.7 ,   9.2  ,
        '6e78'  ,  20.2 ,   20.4 ,   21.2 ,   20   ,   22.7 ,   19.4 ,   22.2 ,   18.9 ,   19.1 ,   17.6 ,   22.2 ,   21   ,   21.5 ,   22.2 ,   20.9 ,   22.8 ,   21   ,   19.1 ,   15.2 ,   23.8 ,   24.5 ,   31.9 ,   28.2 ,   25.1 ,   29.1 ,   29.1 ,   26.6 ,   44.2 ,   34.5 ,   41.5 ,   40.1 ,   37.3 ,   39.3 ,   34.6 ,   39.1 ,   47   ,   39.7 ,
        '7k11'  ,  34.2 ,   36.1 ,   36.7 ,   36.1 ,   34.2 ,   35.3 ,   35.5 ,   35.1 ,   34.3 ,   35   ,   34   ,   34.3 ,   33.6 ,   33   ,   32.6 ,   32   ,   31.4 ,   31.4 ,   29.2 ,   30.5 ,   30.7 ,   20.7 ,   21.6 ,   22   ,   21.2 ,   23.1 ,   21.7 ,   22.2 ,   19.6 ,   18.9 ,   22.6 ,   23.1 ,   25.3 ,   26.8 ,   24.4 ,   25.1 ,   25   ,
        '7k12'  ,  37.2 ,   37.3 ,   37.1 ,   37.3 ,   36.8 ,   36.1 ,   35.5 ,   34.4 ,   35.9 ,   35.7 ,   36.9 ,   36.2 ,   35.1 ,   35   ,   33.8 ,   33.3 ,   33.8 ,   33.3 ,   33.9 ,   32.8 ,   30.1 ,   28.6 ,   32.4 ,   27.2 ,   24.7 ,   25.1 ,   28   ,   23.6 ,   22.7 ,   26   ,   22   ,   18.9 ,   23.6 ,   22.6 ,   21.8 ,   19.1 ,   20.5 ,
        '7k13'  ,  41.2 ,   42.1 ,   41.9 ,   41.5 ,   41.9 ,   39.3 ,   39.6 ,   41.8 ,   40.5 ,   43.7 ,   44.7 ,   47.7 ,   46.8 ,   48.6 ,   47.6 ,   48.7 ,   41.7 ,   44.9 ,   42.6 ,   40.9 ,   42.6 ,   45.1 ,   46.9 ,   40   ,   38.4 ,   38.3 ,   39.3 ,   38.2 ,   37.9 ,   37.1 ,   35.9 ,   35   ,   33.7 ,   30.7 ,   32.4 ,   31.7 ,   27.9 ,
        '7k20'  ,  23.4 ,   16.7 ,   15.8 ,   18.2 ,   20.7 ,   22.9 ,   19.6 ,   19.7 ,   19.4 ,   24   ,   24.6 ,   25.7 ,   22.1 ,   21.3 ,   24   ,   24.5 ,   24   ,   24.3 ,   26.3 ,   26.3 ,   27.1 ,   24   ,   29.3 ,   29.7 ,   29.1 ,   30.8 ,   28.8 ,   28.7 ,   27.6 ,   31.1 ,   30.7 ,   27.1 ,   24.6 ,   28.2 ,   26.3 ,   28.1 ,   26.9 
      ) %>% 
        dplyr::mutate(chiffre = stringr::str_to_upper(chiffre)) %>% 
        dplyr::select(chiffre, tidyselect::all_of(sexeEE)) %>% 
        dplyr::rowwise() %>% 
        dplyr::mutate(fem_pct = mean(dplyr::c_across(tidyselect::all_of(sexeEE)), na.rm = TRUE)) %>% 
        dplyr::select(chiffre, fem_pct)
      
      PPP4_fem <- tibble::tribble(
        ~chiffre , ~`1982`, ~`1983`, ~`1984`, ~`1985`, ~`1986`, ~`1987`, ~`1988`, ~`1989`, ~`1990`, ~`1991`, ~`1992`, ~`1993`, ~`1994`, ~`1995`, ~`1996`, ~`1997`, ~`1998`, ~`1999`, ~`2000`, ~`2001`, ~`2002`, ~`2003`, ~`2004`, ~`2005`, ~`2006`, ~`2007`, ~`2008`, ~`2009`, ~`2010`, ~`2011`, ~`2012`, ~`2013`, ~`2014`, ~`2015`, ~`2016`, ~`2017`, ~`2018`,
        '1a01a'  , 0    ,   13.2 ,   22   ,   17.6 ,   10.8 ,   18   ,   14.7 ,   15.5 ,   5.3  ,   10.9 ,   16.4 ,   10   ,   11.1 ,   33.7 ,   5.1  ,   0    ,   13.2 ,   31.5 ,   21.2 ,   7.7  ,   0    ,   24.7 ,   11   ,   0    ,   10.8 ,   8.4  ,   0    ,   12.1 ,   17.3 ,   15.2 ,   22.7 ,   18   ,   22.9 ,   30.8 ,   23.8 ,   21   ,   24.1 ,
        '1a02a'  , 16.8 ,   17.3 ,   15.9 ,   16.7 ,   14.4 ,   16.7 ,   14.8 ,   16.1 ,   12.9 ,   14.1 ,   8.3  ,   16.8 ,   12.4 ,   14   ,   14.5 ,   11.2 ,   10.9 ,   12.4 ,   12.6 ,   7.7  ,   13.1 ,   15.5 ,   3.3  ,   6.5  ,   14.3 ,   23.2 ,   14   ,   2.7  ,   10.1 ,   10.7 ,   9.8  ,   18   ,   11.8 ,   13.6 ,   14.8 ,   17.1 ,   14.4 ,
        '1a03a'  , 12   ,   10.1 ,   9.8  ,   20.3 ,   18.4 ,   15.9 ,   9.2  ,   16.8 ,   9.6  ,   8.9  ,   1.5  ,   3.8  ,   9.9  ,   6.4  ,   8.7  ,   9.1  ,   15   ,   13.2 ,   14.3 ,   11.6 ,   10.8 ,   3.8  ,   3.3  ,   1.9  ,   3    ,   8.1  ,   9.6  ,   6.2  ,   4.7  ,   5    ,   5.4  ,   2.6  ,   2.8  ,   3.1  ,   9.6  ,   6.6  ,   0.3  ,
        '1a03b'  , 17.2 ,   24.8 ,   19.8 ,   19.2 ,   14.5 ,   16.7 ,   17.9 ,   13.2 ,   10.1 ,   14.1 ,   15.5 ,   16.4 ,   16.1 ,   17.5 ,   18.8 ,   14.1 ,   17.3 ,   18.4 ,   10.7 ,   17.3 ,   15.4 ,   14.6 ,   14.9 ,   21.2 ,   13.8 ,   21.3 ,   18.4 ,   16.8 ,   18.1 ,   16.2 ,   12.6 ,   15.8 ,   14.9 ,   16.8 ,   14.1 ,   18.9 ,   16.7 ,
        '1a03c'  , 17.4 ,   24.8 ,   38.6 ,   33.3 ,   23.7 ,   22.9 ,   23.4 ,   19.4 ,   21   ,   25.6 ,   19.6 ,   14.6 ,   8.3  ,   16.1 ,   14.4 ,   28.9 ,   30.1 ,   23.6 ,   22.3 ,   19.4 ,   17.7 ,   18.2 ,   21.4 ,   28.6 ,   22.8 ,   15.9 ,   13.5 ,   12   ,   19.8 ,   32.3 ,   23.7 ,   26.3 ,   21.2 ,   19.8 ,   28.7 ,   33.7 ,   22.9 ,
        '1a03d'  , 13   ,   20.8 ,   37.6 ,   38.6 ,   33.4 ,   32.3 ,   27.6 ,   23.3 ,   27.3 ,   19.9 ,   10.7 ,   23.5 ,   22.6 ,   28.6 ,   20.1 ,   30.5 ,   24.5 ,   24.9 ,   13   ,   18.1 ,   16   ,   10.1 ,   11.4 ,   15   ,   29.8 ,   27.5 ,   23.2 ,   6.1  ,   9.5  ,   16.5 ,   24.1 ,   28.2 ,   16.2 ,   21.4 ,   22.8 ,   9.9  ,   15.5 ,
        '2c01a'  , 18.3 ,   15.8 ,   21.6 ,   35.6 ,   32.4 ,   31.9 ,   31.4 ,   28.2 ,   30.2 ,   36.1 ,   34.2 ,   40.5 ,   42   ,   46.8 ,   43.1 ,   43.5 ,   39.2 ,   36.1 ,   37.5 ,   38.4 ,   33.4 ,   41.8 ,   38   ,   36.3 ,   40.6 ,   44.1 ,   34.8 ,   43.3 ,   43.7 ,   42.9 ,   46   ,   51.7 ,   45.4 ,   46.9 ,   46.1 ,   50.9 ,   54   ,
        '2d21a'  , 13   ,   20   ,   18.5 ,   11   ,   9.5  ,   7.9  ,   14.6 ,   21.1 ,   16   ,   24.4 ,   22   ,   15.8 ,   28.8 ,   24   ,   24.9 ,   24.3 ,   29.4 ,   29.4 ,   28.2 ,   25.4 ,   29.4 ,   42.3 ,   41.5 ,   45.9 ,   19.6 ,   24.1 ,   54.7 ,   34.2 ,   24.8 ,   43.9 ,   43.4 ,   42.7 ,   35.1 ,   27.9 ,   47.8 ,   39.6 ,   46.9 ,
        '2d23a'  , 6.8  ,   18.2 ,   10   ,   14.8 ,   4.1  ,   9.9  ,   4.6  ,   9    ,   14.9 ,   2.9  ,   7.4  ,   5.6  ,   14.8 ,   7.6  ,   26.6 ,   17.1 ,   29.4 ,   32.4 ,   22.4 ,   12.7 ,   22.5 ,   20.7 ,   10.2 ,   22.5 ,   25.7 ,   19   ,   32.5 ,   21.7 ,   5.2  ,   9.6  ,   21.6 ,   28.2 ,   24.1 ,   14   ,   20.3 ,   31.6 ,   23.6 ,
        '2d23b'  , 10.3 ,   11.1 ,   11.6 ,   6.7  ,   16.8 ,   12   ,   12.8 ,   9.9  ,   18.9 ,   27.3 ,   32.8 ,   25.4 ,   12.2 ,   30.3 ,   14.3 ,   36.1 ,   19.8 ,   19.9 ,   11.7 ,   22   ,   20.4 ,   20.5 ,   25.2 ,   29.6 ,   25.9 ,   21   ,   36.2 ,   36   ,   36.3 ,   37.9 ,   30   ,   36.1 ,   29.6 ,   32.7 ,   40.4 ,   36.2 ,   37.8 ,
        '2d24a'  , 40.5 ,   35   ,   33.9 ,   32   ,   37.3 ,   37.6 ,   41.8 ,   33.5 ,   39.6 ,   33.4 ,   39   ,   43.9 ,   41   ,   40.9 ,   46.7 ,   39.3 ,   39.7 ,   44.2 ,   41.1 ,   47.3 ,   54.5 ,   44.9 ,   50.4 ,   46   ,   52.3 ,   54.6 ,   56.3 ,   49.3 ,   46.2 ,   50.1 ,   51.5 ,   47.4 ,   49.5 ,   53.1 ,   51.8 ,   50.4 ,   50   ,
        '2d24b'  , 37.1 ,   36.6 ,   33.4 ,   26.9 ,   22.8 ,   25.5 ,   22.6 ,   28.7 ,   34   ,   38.9 ,   44.3 ,   40.7 ,   37   ,   39.3 ,   42.9 ,   46.7 ,   48.3 ,   47.7 ,   45.2 ,   45.2 ,   41.3 ,   52.8 ,   48.7 ,   49.6 ,   57.3 ,   58.1 ,   60.8 ,   54.6 ,   51   ,   54.3 ,   59.8 ,   61.4 ,   63.3 ,   60.2 ,   61.5 ,   61.3 ,   63.4 ,
        '2d24c'  , 19.2 ,   19.9 ,   21   ,   21.7 ,   24.3 ,   24.8 ,   23.7 ,   25.1 ,   27.5 ,   29.6 ,   29.7 ,   30.1 ,   28.6 ,   33   ,   34.9 ,   32.6 ,   33.8 ,   33.5 ,   35.2 ,   35.8 ,   37.9 ,   35.1 ,   38.8 ,   39.2 ,   40.9 ,   40.8 ,   41.4 ,   42.2 ,   44.3 ,   44.1 ,   43.8 ,   44.3 ,   46.3 ,   46.1 ,   45.8 ,   46.4 ,   47.1 ,
        '2d26a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   51.3 ,   59.5 ,   65.8 ,   55.6 ,   51.4 ,   67.2 ,   67.9 ,   54.6 ,   60.5 ,   63.6 ,   72.3 ,   73.9 ,   68.8 ,   69.7 ,   62.8 ,   68.9 ,
        '2d27a'  , 20.4 ,   15.4 ,   13.4 ,   19   ,   27.1 ,   31.2 ,   29.4 ,   30.8 ,   22.3 ,   24.2 ,   31.6 ,   27.9 ,   24.7 ,   21   ,   20.6 ,   27.1 ,   29.8 ,   25.9 ,   29.9 ,   40   ,   39.2 ,   31.6 ,   25.5 ,   30.3 ,   40.8 ,   38.9 ,   45.9 ,   44.3 ,   40.7 ,   42.1 ,   36.4 ,   43.8 ,   36.3 ,   36.1 ,   31.5 ,   32.4 ,   38.4 ,
        '2e22a'  , 12   ,   0    ,   21.6 ,   0    ,   0    ,   3    ,   6.6  ,   13.5 ,   15.6 ,   7.8  ,   11.5 ,   0    ,   0    ,   13.8 ,   8.1  ,   14.4 ,   16.7 ,   13.3 ,   13.1 ,   11.3 ,   12.2 ,   8.7  ,   5.4  ,   3.1  ,   5.3  ,   5.6  ,   6.6  ,   5.4  ,   8.9  ,   8.6  ,   9.9  ,   9.3  ,   8.3  ,   8.3  ,   10.3 ,   7.6  ,   9.7  ,
        '2e23a'  , 6    ,   6.7  ,   8.1  ,   6.1  ,   11.5 ,   11.1 ,   9.7  ,   8.1  ,   8.8  ,   14.6 ,   16.6 ,   12.7 ,   11.2 ,   16   ,   21.6 ,   21.7 ,   22.7 ,   19.9 ,   20.7 ,   23.2 ,   23.8 ,   29.9 ,   27.4 ,   25.9 ,   29.3 ,   28.5 ,   31.2 ,   31.1 ,   39.8 ,   36.4 ,   33.3 ,   35.4 ,   31.8 ,   32.9 ,   30.2 ,   36.8 ,   44.2 ,
        '2e23b'  , 6.4  ,   5.6  ,   5.8  ,   6.7  ,   8.7  ,   8.2  ,   9    ,   9.7  ,   10.4 ,   10.3 ,   10.9 ,   11.1 ,   13.1 ,   12.6 ,   12.4 ,   11.6 ,   14.4 ,   14.8 ,   14   ,   14.2 ,   15.6 ,   16.8 ,   16   ,   17.3 ,   17.1 ,   17.3 ,   19.3 ,   22   ,   20.4 ,   21.5 ,   21.7 ,   21.5 ,   20.8 ,   20   ,   20.3 ,   22.2 ,   22.6 ,
        '2f01a'  , 87.7 ,   87.9 ,   85.6 ,   85.1 ,   87.4 ,   86.4 ,   89.6 ,   92.9 ,   92.2 ,   86.7 ,   87.9 ,   88.8 ,   86.3 ,   78.5 ,   77.8 ,   79.6 ,   84.8 ,   86.5 ,   80.7 ,   81.6 ,   83.6 ,   83.6 ,   83   ,   82.7 ,   92.2 ,   85.1 ,   79.9 ,   81.7 ,   79.5 ,   85.1 ,   80.5 ,   83.4 ,   79.6 ,   90.8 ,   90.3 ,   86.8 ,   87.2 ,
        '2g00a'  , 5.8  ,   1.3  ,   2.8  ,   3.1  ,   2.5  ,   2.5  ,   4.6  ,   4.7  ,   0    ,   6.8  ,   5.2  ,   5.7  ,   1.5  ,   6.5  ,   7.8  ,   10   ,   8.8  ,   7.2  ,   2.5  ,   6.2  ,   6.3  ,   10.3 ,   5.2  ,   4.3  ,   16.9 ,   20.5 ,   7.1  ,   6.6  ,   7.9  ,   12.5 ,   13.2 ,   14.7 ,   8.4  ,   7.6  ,   7    ,   11.6 ,   16.6 ,
        '2g00b'  , 3.1  ,   7.4  ,   8.8  ,   11.5 ,   10.2 ,   6.4  ,   15.7 ,   15.4 ,   9.1  ,   12.4 ,   14   ,   17.7 ,   9.3  ,   4.4  ,   5    ,   8.2  ,   9.7  ,   6.8  ,   5.3  ,   14.1 ,   4.5  ,   15.6 ,   8.9  ,   18.9 ,   26.1 ,   26.6 ,   18.3 ,   16.4 ,   21.2 ,   16.9 ,   18.4 ,   27.2 ,   32.3 ,   39.9 ,   22.9 ,   13.2 ,   7.1  ,
        '2i11a'  , 25.7 ,   29.3 ,   34.4 ,   37.6 ,   31.9 ,   12.9 ,   19.3 ,   27.2 ,   32.2 ,   32   ,   31.1 ,   21.5 ,   26.6 ,   33.8 ,   35.7 ,   30.2 ,   33   ,   29.2 ,   30.9 ,   37.7 ,   34.4 ,   35.2 ,   43.8 ,   47.4 ,   42.9 ,   48.6 ,   45.3 ,   36.9 ,   40.5 ,   49.9 ,   51.5 ,   58.3 ,   46.3 ,   37.8 ,   39.4 ,   46.2 ,   35.7 ,
        '2i23a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   58.6 ,   59.7 ,   66.4 ,   69.7 ,   63.9 ,   61.5 ,   66.8 ,   66   ,   65.8 ,   69.3 ,   66.8 ,   50.4 ,   53.5 ,   50.2 ,   58.1 ,   59.2 ,
        '2i25a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   61.7 ,   56.2 ,   73.4 ,   50.8 ,   59.4 ,   49.8 ,   58.4 ,   59.9 ,   49   ,   66.2 ,   68.8 ,   60.5 ,   51.7 ,   71.4 ,   60   ,   61.8 ,
        '2j01a'  , 74.2 ,   76.6 ,   73.2 ,   73.5 ,   81.8 ,   80.7 ,   80.8 ,   83.9 ,   87.5 ,   74.4 ,   68.8 ,   68.5 ,   72.7 ,   85.1 ,   81.5 ,   80.2 ,   77.5 ,   80.5 ,   85.3 ,   76.8 ,   73.6 ,   80.2 ,   83   ,   91.8 ,   74.1 ,   78.7 ,   76.3 ,   68.4 ,   83   ,   77.1 ,   75.6 ,   63.6 ,   58.1 ,   73.7 ,   73.5 ,   67.5 ,   73.4 ,
        '2j02a'  , 25.3 ,   31.4 ,   12   ,   28.3 ,   36.3 ,   37.4 ,   50.8 ,   34.6 ,   30.3 ,   28.2 ,   23.3 ,   30   ,   32.9 ,   37.9 ,   40.7 ,   48.6 ,   45.8 ,   28.9 ,   28.2 ,   27.1 ,   25.8 ,   28.3 ,   32.3 ,   44.3 ,   48.7 ,   40.3 ,   42.1 ,   43.3 ,   42.6 ,   40.3 ,   51.5 ,   36.8 ,   28.5 ,   40.6 ,   50.3 ,   37.5 ,   36.4 ,
        '3b13d'  , 24.1 ,   22.7 ,   25.8 ,   26.5 ,   26.9 ,   27.1 ,   29.4 ,   30.4 ,   31.3 ,   32.6 ,   35.4 ,   35.9 ,   38.2 ,   38.7 ,   37.7 ,   37.5 ,   39.3 ,   41.3 ,   44   ,   42.2 ,   43.2 ,   40.4 ,   42.5 ,   45   ,   41.1 ,   43.9 ,   44.5 ,   43.1 ,   42.5 ,   42.6 ,   43.6 ,   44.9 ,   44.7 ,   44   ,   43.3 ,   44.3 ,   47.8 ,
        '3b21a'  , 21.9 ,   31.2 ,   31.8 ,   13.5 ,   29   ,   27.4 ,   26.8 ,   26.5 ,   27.8 ,   26.4 ,   19.6 ,   23.8 ,   29.6 ,   27.5 ,   25.3 ,   14   ,   11.8 ,   18.4 ,   24.9 ,   25.7 ,   20.9 ,   24.9 ,   11.7 ,   7    ,   17.5 ,   21.2 ,   14.4 ,   12.9 ,   11.2 ,   20   ,   8.5  ,   4.3  ,   11.6 ,   17.6 ,   14.4 ,   20   ,   35.6 ,
        '3b21b'  , 19.6 ,   26.7 ,   30.1 ,   26.3 ,   25.1 ,   27.9 ,   23.1 ,   24.3 ,   23.6 ,   25.9 ,   26.6 ,   21.4 ,   18.3 ,   21.8 ,   22.8 ,   28.7 ,   28.5 ,   19.6 ,   21.7 ,   23   ,   19.9 ,   17.2 ,   21   ,   23.6 ,   14.6 ,   16   ,   25.7 ,   15.2 ,   20   ,   16.4 ,   15.9 ,   12.1 ,   20.8 ,   21.5 ,   17.5 ,   20.7 ,   26.7 ,
        '3b21c'  , 41.6 ,   43.4 ,   44.5 ,   49.1 ,   47.1 ,   43.9 ,   41.6 ,   42.4 ,   43.7 ,   44.4 ,   41.8 ,   46   ,   49   ,   53.2 ,   49.2 ,   45.8 ,   47   ,   47.1 ,   47.1 ,   47.6 ,   47.9 ,   45.3 ,   40.5 ,   38.2 ,   42.6 ,   48.5 ,   46.2 ,   42.3 ,   45.1 ,   43.4 ,   40.5 ,   42.8 ,   43.4 ,   50   ,   50.9 ,   44.2 ,   35.2 ,
        '3b21d'  , 45.5 ,   43.8 ,   49.5 ,   53   ,   44   ,   45.4 ,   44.8 ,   45.8 ,   40.9 ,   37.6 ,   38.5 ,   41.9 ,   40.5 ,   34.6 ,   33.8 ,   31.4 ,   38.1 ,   37.1 ,   36.9 ,   29.7 ,   39.6 ,   17.9 ,   34.5 ,   35.7 ,   35.9 ,   45.5 ,   32.6 ,   31.9 ,   43.6 ,   41.3 ,   25   ,   28.7 ,   28   ,   32.8 ,   33.6 ,   32.5 ,   23.6 ,
        '3b21e'  , 34.2 ,   30.4 ,   18.1 ,   9.3  ,   7.2  ,   15.2 ,   16.8 ,   24.1 ,   20   ,   22.7 ,   16.9 ,   14.6 ,   19.9 ,   27.9 ,   18.1 ,   18.6 ,   16.1 ,   13.3 ,   25.8 ,   14.6 ,   23.8 ,   14.6 ,   33.1 ,   28.9 ,   32.5 ,   23.5 ,   34.1 ,   34.3 ,   25.4 ,   24.1 ,   28.4 ,   32   ,   26.9 ,   24.1 ,   28.8 ,   30.4 ,   31.2 ,
        '3b22a'  , 18.3 ,   18.7 ,   23.8 ,   22.9 ,   22.3 ,   20.6 ,   22.6 ,   21.6 ,   28.8 ,   26.2 ,   30.2 ,   28.2 ,   24.6 ,   31.7 ,   29.7 ,   31.9 ,   38.1 ,   34.7 ,   28.1 ,   19.6 ,   17.8 ,   45.2 ,   4.4  ,   18.3 ,   41.2 ,   29.5 ,   18.8 ,   19.5 ,   28.2 ,   20.7 ,   6.4  ,   15.8 ,   21.9 ,   15.3 ,   12   ,   13.3 ,   24   ,
        '3b22b'  , 9.7  ,   0    ,   22   ,   30.3 ,   50.3 ,   26.4 ,   24.9 ,   24.3 ,   14.9 ,   38.6 ,   37.3 ,   11.8 ,   0    ,   17.2 ,   14   ,   0    ,   16.2 ,   33.2 ,   18.2 ,   20.5 ,   35.3 ,   47.1 ,   38.1 ,   18.8 ,   24.5 ,   44.4 ,   19   ,   43.6 ,   66.7 ,   68.2 ,   59.2 ,   28.9 ,   42.8 ,   44   ,   54.7 ,   31.1 ,   29.4 ,
        '3b22c'  , 11.8 ,   16   ,   26.3 ,   35.6 ,   27   ,   33.3 ,   19.3 ,   22.8 ,   26.7 ,   29.3 ,   30.9 ,   27.6 ,   22.2 ,   31.3 ,   22.9 ,   25.2 ,   25.4 ,   20.3 ,   16.5 ,   32.2 ,   27   ,   24.8 ,   17.2 ,   26.6 ,   33.3 ,   36   ,   32.3 ,   29.9 ,   30.2 ,   25.5 ,   28.7 ,   25.9 ,   47.6 ,   48.2 ,   31.3 ,   38.1 ,   41.5 ,
        '3b22d'  , 33   ,   22.2 ,   37.6 ,   33.7 ,   36.4 ,   39   ,   22.1 ,   34.7 ,   35.5 ,   59.8 ,   24.3 ,   20.8 ,   15.3 ,   23   ,   16.7 ,   28.9 ,   29.4 ,   33   ,   24.8 ,   26.3 ,   34.1 ,   25.9 ,   25.2 ,   53.5 ,   41.9 ,   34.1 ,   41   ,   40   ,   52.1 ,   42.4 ,   35.2 ,   41.4 ,   49.8 ,   21.8 ,   30.1 ,   29.2 ,   40.3 ,
        '3b22e'  , 44.5 ,   34.2 ,   30.8 ,   26   ,   33.1 ,   34.1 ,   22   ,   19.6 ,   43.9 ,   29.8 ,   30.8 ,   29.5 ,   20.7 ,   35.3 ,   16   ,   28.9 ,   32   ,   30.8 ,   17.9 ,   42   ,   38.7 ,   23.1 ,   39.8 ,   46.7 ,   39.7 ,   15.5 ,   23.5 ,   44.5 ,   40.6 ,   33.5 ,   33   ,   40.8 ,   48.4 ,   35.8 ,   51.8 ,   41.2 ,   29.1 ,
        '3b22f'  , 69.8 ,   66.9 ,   40.5 ,   40.6 ,   36.6 ,   50.3 ,   34.4 ,   45.8 ,   59.9 ,   52.2 ,   62.3 ,   65.5 ,   70.2 ,   60.2 ,   62.5 ,   90.9 ,   73.8 ,   69.9 ,   63.4 ,   74.2 ,   73.2 ,   51.5 ,   77.6 ,   60.9 ,   67.9 ,   73.6 ,   63   ,   67.3 ,   51.4 ,   62.3 ,   59.2 ,   75.5 ,   75.5 ,   66.4 ,   64.6 ,   70.4 ,   71   ,
        '3b22g'  , 36.3 ,   41.7 ,   34   ,   30.5 ,   40.1 ,   38.2 ,   41.4 ,   39.5 ,   45.3 ,   38.9 ,   41.6 ,   36.1 ,   36.1 ,   38   ,   35.5 ,   33.1 ,   34.7 ,   30.9 ,   33.5 ,   34.1 ,   30.9 ,   30.3 ,   32.5 ,   27.6 ,   24.6 ,   29.6 ,   30.1 ,   26.1 ,   23.3 ,   28.1 ,   28.5 ,   26.3 ,   29.3 ,   28.5 ,   28.9 ,   32.6 ,   34.3 ,
        '3c01a'  , 50.4 ,   48.4 ,   56.6 ,   59.2 ,   53.9 ,   56.6 ,   57.7 ,   57.9 ,   57.6 ,   58   ,   59   ,   61.2 ,   60.2 ,   61.3 ,   60.9 ,   60.7 ,   62.8 ,   68.7 ,   67.7 ,   67.8 ,   65.4 ,   73.1 ,   71   ,   64.3 ,   53.7 ,   56.2 ,   61.8 ,   70.1 ,   71.3 ,   64.2 ,   64.7 ,   58.9 ,   59.3 ,   60.2 ,   58.5 ,   62.4 ,   64.2 ,
        '3d01a'  , 65.1 ,   66.6 ,   63.8 ,   65.8 ,   67   ,   69.5 ,   68.9 ,   65.4 ,   61.1 ,   69.5 ,   69.1 ,   70   ,   69.5 ,   73.5 ,   73.7 ,   71.4 ,   68.3 ,   67.6 ,   68.6 ,   68.6 ,   64.8 ,   65.4 ,   64.3 ,   65.9 ,   69.4 ,   71.1 ,   65.4 ,   67.8 ,   71.2 ,   67.6 ,   68.4 ,   70.4 ,   70.3 ,   70.9 ,   69.4 ,   70.2 ,   71.9 ,
        '3d01b'  , 56.4 ,   55.6 ,   57.7 ,   57.2 ,   58.4 ,   60.7 ,   62.1 ,   63.1 ,   64.7 ,   64   ,   64.6 ,   65.6 ,   65.6 ,   63.6 ,   63.1 ,   63.5 ,   63.6 ,   64.5 ,   62.8 ,   63.8 ,   64.6 ,   63.9 ,   65.1 ,   65.8 ,   66.9 ,   65.6 ,   67   ,   66.9 ,   65.7 ,   68.6 ,   68.7 ,   67.7 ,   66.3 ,   69.5 ,   68   ,   68.3 ,   70.3 ,
        '3d04a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   75   ,   71.5 ,   72.9 ,   64.8 ,   71.5 ,   79.8 ,   82.4 ,   84.2 ,   82.1 ,   76   ,   79.1 ,   88.5 ,   81.8 ,   85.2 ,   85.8 ,   77.7 ,
        '3d08a'  , 56.4 ,   59.5 ,   55.8 ,   59.4 ,   56.2 ,   53.6 ,   49.1 ,   51   ,   55.6 ,   53.3 ,   51   ,   51.6 ,   51   ,   48.5 ,   48.2 ,   49.9 ,   45.9 ,   44.7 ,   46.6 ,   47.7 ,   47.1 ,   60.7 ,   53.5 ,   55.9 ,   46.5 ,   60.5 ,   63.4 ,   64.8 ,   72.5 ,   53.9 ,   49.7 ,   47.6 ,   73.1 ,   58   ,   52   ,   44.8 ,   51.5 ,
        '3e11a'  , 11   ,   11.5 ,   11.9 ,   11.6 ,   12.4 ,   13.7 ,   13   ,   11.7 ,   11.1 ,   11.6 ,   12.8 ,   13.6 ,   12.5 ,   13.3 ,   14   ,   13.6 ,   14.5 ,   13.6 ,   14.2 ,   14.2 ,   16.2 ,   18.3 ,   19.7 ,   20.6 ,   20.5 ,   20.8 ,   21.2 ,   21.7 ,   22.1 ,   23.2 ,   24.7 ,   24.2 ,   24.8 ,   23.6 ,   24.4 ,   25   ,   25.2 ,
        '3e21a'  , 10   ,   9.5  ,   9.3  ,   10.5 ,   10.7 ,   10.6 ,   10.4 ,   10.4 ,   12.7 ,   12.6 ,   12.5 ,   10.8 ,   11.7 ,   12   ,   12.2 ,   12.3 ,   12.6 ,   13.2 ,   12.5 ,   14.8 ,   13.8 ,   12.9 ,   13.6 ,   11.5 ,   11.3 ,   11.7 ,   12.1 ,   12.8 ,   13.3 ,   12.3 ,   13.2 ,   14.5 ,   14.1 ,   13.6 ,   15.4 ,   15.2 ,   16.6 ,
        '4f10a'  , 34.2 ,   28.7 ,   32.9 ,   33.4 ,   39.6 ,   40.7 ,   38.8 ,   40.7 ,   41.5 ,   42.5 ,   36   ,   39.9 ,   45.2 ,   45.6 ,   41.5 ,   42.3 ,   42.5 ,   49.7 ,   46.5 ,   42.9 ,   42.5 ,   44.5 ,   42.1 ,   36.9 ,   41.1 ,   49.2 ,   50.1 ,   46.5 ,   45.2 ,   48   ,   49.1 ,   46.4 ,   51.3 ,   51.8 ,   54.6 ,   51.3 ,   52.5 ,
        '4f10b'  , 35   ,   44.9 ,   38.9 ,   41.1 ,   55.9 ,   43.6 ,   54   ,   67.2 ,   68.7 ,   56.3 ,   29.5 ,   53.7 ,   53.5 ,   66   ,   75.7 ,   67.1 ,   37.6 ,   44   ,   49.9 ,   48.8 ,   53.2 ,   55.8 ,   58.1 ,   58.8 ,   58   ,   47.4 ,   55.8 ,   67.7 ,   60.8 ,   59.4 ,   57.5 ,   48.6 ,   57.5 ,   53.9 ,   62.7 ,   61.4 ,   51.9 ,
        '4f20a'  , 70.1 ,   68.2 ,   62.1 ,   65.9 ,   67   ,   69.2 ,   62.3 ,   59.3 ,   67.8 ,   68.2 ,   72.4 ,   71.9 ,   68.6 ,   71.9 ,   66.1 ,   74.3 ,   65.3 ,   76.7 ,   77.9 ,   72.3 ,   71.8 ,   59   ,   56.6 ,   77.4 ,   62.9 ,   66.2 ,   65.5 ,   58.8 ,   68   ,   77.8 ,   54.1 ,   66.4 ,   72.4 ,   81.2 ,   70.1 ,   73.6 ,   83.8 ,
        '4f20b'  , 100  ,   100  ,   95.4 ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   97.5 ,   97.7 ,   97.8 ,   100  ,   97.4 ,   97.5 ,   100  ,   100  ,   100  ,   98.2 ,   100  ,   100  ,   100  ,   100  ,   100  ,   90.1 ,   95.7 ,   100  ,   100  ,   100  ,   100  ,   100  ,   99.1 ,   99.4 ,   100  ,
        '4f20c'  , 88   ,   89.6 ,   87.8 ,   84.7 ,   84.1 ,   86.5 ,   87.4 ,   90.2 ,   89.5 ,   88.2 ,   93   ,   79.3 ,   84.8 ,   88.2 ,   76.7 ,   84.4 ,   88.3 ,   92.7 ,   86.9 ,   87   ,   85.2 ,   85.1 ,   88.6 ,   84.3 ,   78.1 ,   74.8 ,   77.5 ,   81.7 ,   79.9 ,   74.1 ,   74.2 ,   71.8 ,   71.3 ,   76.5 ,   76.4 ,   66.7 ,   70.4 ,
        '4f20d'  , 91   ,   92.9 ,   92.3 ,   91.8 ,   92.8 ,   91.5 ,   93.8 ,   91.6 ,   89.4 ,   89.9 ,   88.7 ,   91   ,   88.6 ,   89.6 ,   90.6 ,   91.1 ,   91.3 ,   89.2 ,   90   ,   88.6 ,   86.5 ,   88.7 ,   89.7 ,   91.8 ,   89.3 ,   88.7 ,   87.4 ,   89.1 ,   88.8 ,   87.8 ,   88   ,   87.1 ,   86.7 ,   86.8 ,   85.7 ,   84   ,   85.2 ,
        '3f30a'  , 59   ,   52   ,   59.2 ,   55.3 ,   55.4 ,   66.3 ,   67   ,   67.1 ,   64.1 ,   58.7 ,   62.3 ,   64.9 ,   66   ,   61.6 ,   61   ,   68   ,   67.8 ,   63.1 ,   61.1 ,   62.7 ,   59.5 ,   63.2 ,   63.7 ,   65.6 ,   67.4 ,   64   ,   62.7 ,   64.9 ,   59.4 ,   63.4 ,   62.6 ,   65.4 ,   60.6 ,   61.9 ,   60.9 ,   61.3 ,   61   ,
        '3f30b'  , 63.7 ,   70.1 ,   71.3 ,   69.3 ,   74.1 ,   77.4 ,   76.2 ,   74.7 ,   74.6 ,   69.5 ,   76.3 ,   76.6 ,   81.9 ,   86.9 ,   83.3 ,   84.5 ,   82.7 ,   79.6 ,   80.2 ,   80.7 ,   83.3 ,   86.4 ,   90.9 ,   93.2 ,   95   ,   95.2 ,   95.9 ,   96.4 ,   95.5 ,   92   ,   91.7 ,   89.3 ,   92.2 ,   95.1 ,   95.8 ,   91.9 ,   88.5 ,
        '4f41a'  , 38.4 ,   30.3 ,   33.7 ,   28.5 ,   26   ,   32.1 ,   31.8 ,   29.7 ,   23.6 ,   26   ,   34.8 ,   39   ,   40.7 ,   36.2 ,   32.9 ,   35.9 ,   36.6 ,   37.8 ,   34.8 ,   39.1 ,   34   ,   39.6 ,   31.8 ,   30.7 ,   32.8 ,   37.8 ,   37.7 ,   25.6 ,   41   ,   33.8 ,   29.5 ,   31.3 ,   36.2 ,   38.4 ,   26.9 ,   35.5 ,   36.9 ,
        '4f41b'  , 13   ,   14.3 ,   15.5 ,   18.6 ,   16   ,   14.5 ,   18.8 ,   22.8 ,   20.7 ,   21.5 ,   24.7 ,   22.2 ,   24.4 ,   20.9 ,   25.2 ,   26.9 ,   23   ,   23.1 ,   24.8 ,   27   ,   24.4 ,   29.9 ,   33.2 ,   33.7 ,   31   ,   33   ,   38.2 ,   37.3 ,   30.3 ,   37   ,   39.7 ,   43.8 ,   41.6 ,   39   ,   52.8 ,   53.1 ,   53.9 ,
        '4f41c'  , 32.9 ,   36.3 ,   33.8 ,   37.3 ,   31.5 ,   24.1 ,   29.2 ,   29.3 ,   24   ,   28   ,   30.1 ,   30.7 ,   23.2 ,   24.7 ,   20.1 ,   27.8 ,   28   ,   33.2 ,   33.2 ,   33.6 ,   34.1 ,   33.2 ,   47.3 ,   41.3 ,   31.6 ,   33   ,   35.6 ,   39.3 ,   32.5 ,   38.2 ,   38.6 ,   39.4 ,   49.7 ,   52.2 ,   39.4 ,   45   ,   48   ,
        '4f41d'  , 30.7 ,   23.1 ,   28.1 ,   16.5 ,   16.9 ,   20.5 ,   22.5 ,   25.1 ,   33.9 ,   24.2 ,   36.3 ,   37.2 ,   17   ,   17.1 ,   21.7 ,   27.1 ,   31.9 ,   50.3 ,   45.3 ,   46.6 ,   40.5 ,   48.4 ,   50.2 ,   56.6 ,   33.7 ,   33.8 ,   68.2 ,   34.2 ,   36.3 ,   38.2 ,   44.4 ,   43.6 ,   38.7 ,   46.5 ,   32.4 ,   35.6 ,   51.1 ,
        '4f41e'  , 52.9 ,   46.8 ,   49.5 ,   49   ,   46.2 ,   48.9 ,   49.4 ,   53.8 ,   57.7 ,   56.3 ,   60.9 ,   68.7 ,   56.8 ,   65   ,   65.4 ,   59.9 ,   64.2 ,   63.7 ,   62.8 ,   65.4 ,   61.5 ,   75.5 ,   64   ,   66.8 ,   66.7 ,   68.2 ,   70   ,   71.5 ,   71.2 ,   57.8 ,   68.4 ,   73.9 ,   58.3 ,   39.9 ,   62.4 ,   60.6 ,   60.1 ,
        '4f42a'  , 60.6 ,   59.4 ,   56.9 ,   56.8 ,   55.5 ,   56.6 ,   58.5 ,   56.8 ,   53.7 ,   53.6 ,   56.2 ,   58.6 ,   57.9 ,   59.3 ,   62.3 ,   58.6 ,   64.5 ,   63.4 ,   64.9 ,   65.5 ,   64.3 ,   62.4 ,   62.6 ,   58   ,   57.8 ,   59.8 ,   71.6 ,   69.2 ,   66.3 ,   63.1 ,   64.2 ,   63.3 ,   69.6 ,   68.7 ,   69.2 ,   69.9 ,   64.3 ,
        '4f43a'  , 100  ,   96.8 ,   97.3 ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   99.5 ,   99.5 ,   100  ,   100  ,   100  ,   100  ,   95.4 ,   92.8 ,   96.5 ,   99.2 ,   98.3 ,   100  ,   98.1 ,   96   ,   99.5 ,   100  ,
        '4f44a'  , 52.6 ,   52.2 ,   52.8 ,   52.7 ,   51.5 ,   60   ,   51.3 ,   50.4 ,   47.2 ,   53.4 ,   43.1 ,   43.5 ,   49.2 ,   44.7 ,   40.8 ,   37.8 ,   46.5 ,   48.6 ,   50   ,   49.5 ,   50   ,   36   ,   42   ,   54.9 ,   50.6 ,   51.5 ,   56.4 ,   49.5 ,   48.6 ,   47.7 ,   49.7 ,   51.6 ,   55.7 ,   50.4 ,   61.9 ,   56.5 ,   64.4 ,
        '4f44b'  , 62.3 ,   68.8 ,   68.4 ,   68.9 ,   65.4 ,   63.5 ,   72.2 ,   66.5 ,   65.3 ,   73.1 ,   74.5 ,   77   ,   81.5 ,   76.7 ,   76.3 ,   70   ,   73.4 ,   76.6 ,   70.1 ,   72   ,   68.4 ,   82   ,   79   ,   76.1 ,   81.8 ,   82.6 ,   80.9 ,   74.6 ,   76.3 ,   83.1 ,   75.9 ,   80   ,   80.8 ,   76.3 ,   74   ,   75.6 ,   78.3 ,
        '4f45a'  , 72   ,   75.3 ,   72.2 ,   69.3 ,   84.2 ,   74.2 ,   75.6 ,   72.5 ,   66.1 ,   75.2 ,   75.9 ,   78.1 ,   82.1 ,   79.3 ,   81.1 ,   81.3 ,   76.6 ,   77.9 ,   80.3 ,   81.2 ,   81.4 ,   72.1 ,   76.9 ,   85.4 ,   91.4 ,   86.5 ,   86.1 ,   85.6 ,   83.9 ,   81.7 ,   81.4 ,   89.9 ,   87.3 ,   85.2 ,   87.9 ,   87.9 ,   85.3 ,
        '4f45b'  , 64.1 ,   63.6 ,   77.6 ,   55.9 ,   51.3 ,   50.2 ,   52.3 ,   59.1 ,   47.5 ,   56.7 ,   48.2 ,   63.8 ,   63.7 ,   59.2 ,   65.7 ,   66.6 ,   71.3 ,   67.6 ,   66.7 ,   71.2 ,   82.1 ,   76.7 ,   78.4 ,   71.3 ,   77.8 ,   70.8 ,   68   ,   85.8 ,   84.8 ,   76.7 ,   77.2 ,   83   ,   82.1 ,   84.6 ,   89   ,   100  ,   81   ,
        '4i11a'  , 27.7 ,   34.3 ,   26.9 ,   32.5 ,   28.7 ,   30.2 ,   24.1 ,   26   ,   28.3 ,   31.4 ,   31.4 ,   30.3 ,   31.5 ,   25.5 ,   27.6 ,   39.2 ,   34.9 ,   36.3 ,   43   ,   38   ,   41.7 ,   35.3 ,   36   ,   37.2 ,   39.3 ,   40.2 ,   38   ,   44.7 ,   42.7 ,   40.6 ,   42.4 ,   40.6 ,   44.4 ,   49.6 ,   47.9 ,   47.6 ,   52.9 ,
        '4i12a'  , 22.5 ,   27.9 ,   22.2 ,   31   ,   27.7 ,   35.5 ,   29.5 ,   28   ,   30.5 ,   38.1 ,   39.5 ,   35.4 ,   36.7 ,   37.9 ,   33.7 ,   40.9 ,   37.7 ,   36.8 ,   32.2 ,   36.1 ,   42.4 ,   33.1 ,   36.3 ,   43.5 ,   35.5 ,   31.1 ,   34.2 ,   43.2 ,   39   ,   42.4 ,   40   ,   41   ,   42.2 ,   42.6 ,   36.5 ,   34.1 ,   29   ,
        '4i13a'  , 50   ,   54.8 ,   57.6 ,   55.9 ,   55.5 ,   55.9 ,   58.2 ,   59.7 ,   53.4 ,   56   ,   56.6 ,   59.3 ,   58.9 ,   57.9 ,   57   ,   54.6 ,   54.5 ,   55.7 ,   57.6 ,   58.1 ,   59.7 ,   58.7 ,   60   ,   59   ,   59.9 ,   59.6 ,   59.6 ,   61.2 ,   59.3 ,   56.4 ,   59.5 ,   60.8 ,   60.3 ,   60.8 ,   60.3 ,   59.6 ,   58.5 ,
        '4i13b'  , 67.2 ,   63   ,   62.2 ,   59.7 ,   59.4 ,   59   ,   61.3 ,   58.7 ,   58.2 ,   58   ,   61.6 ,   61.8 ,   64.2 ,   65.2 ,   66   ,   64.3 ,   65.9 ,   59.3 ,   64.8 ,   63.2 ,   61.5 ,   60.6 ,   62.7 ,   67.2 ,   65.2 ,   70.2 ,   70.8 ,   64.5 ,   64.9 ,   65.2 ,   68.7 ,   65   ,   63.6 ,   62.8 ,   63.7 ,   59.1 ,   60.2 ,
        '4i13c'  , 51.1 ,   47.8 ,   46.1 ,   48.3 ,   46.9 ,   40.7 ,   44.4 ,   46.8 ,   47.4 ,   49.4 ,   46.6 ,   46.8 ,   45.3 ,   44.9 ,   50.3 ,   51.2 ,   55.4 ,   46.4 ,   43.4 ,   47   ,   49.8 ,   53.7 ,   55.5 ,   51.5 ,   53.7 ,   60.4 ,   54   ,   48.3 ,   50.1 ,   53.9 ,   49.3 ,   49.8 ,   46.5 ,   47.4 ,   50.3 ,   49.9 ,   54.2 ,
        '4i13d'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   65.9 ,   70.6 ,   59.4 ,   65   ,   61.4 ,   63.8 ,   60.8 ,   63   ,   62.2 ,   73.4 ,   74.4 ,   69.3 ,   59.4 ,   65.5 ,   73   ,   63.9 ,
        '4i13e'  , 57.5 ,   60.7 ,   60.9 ,   54.8 ,   50.5 ,   65.3 ,   60.3 ,   63.1 ,   60.4 ,   58.1 ,   62.5 ,   62.3 ,   61   ,   59.4 ,   59.6 ,   65.2 ,   61.7 ,   63.3 ,   65.7 ,   62.6 ,   63.8 ,   65.1 ,   68.2 ,   68.5 ,   65.6 ,   68.2 ,   70.1 ,   74.3 ,   72   ,   71.7 ,   68.3 ,   64   ,   61.6 ,   72.2 ,   73.7 ,   68.3 ,   68.4 ,
        '4i14a'  , 73   ,   76.5 ,   75.5 ,   74.2 ,   72.4 ,   73.1 ,   73.4 ,   74.6 ,   74.8 ,   75.6 ,   75.7 ,   76.7 ,   77.2 ,   77.6 ,   78.3 ,   79.2 ,   77.1 ,   78.8 ,   79.2 ,   79.8 ,   78.8 ,   80.2 ,   80.7 ,   80.2 ,   82.5 ,   78.9 ,   79.1 ,   79.9 ,   80.9 ,   80.8 ,   80.9 ,   82.2 ,   83.4 ,   84.8 ,   84.1 ,   82.3 ,   84   ,
        '4i21a'  , 59.7 ,   59.6 ,   62   ,   57.4 ,   54.4 ,   54.4 ,   56.5 ,   56.8 ,   58.1 ,   58.5 ,   58.4 ,   57.4 ,   59.2 ,   62.8 ,   65.6 ,   63.8 ,   67.2 ,   65.1 ,   63.1 ,   65.5 ,   66.4 ,   59.5 ,   64.3 ,   71   ,   65.7 ,   70.6 ,   68.1 ,   73.5 ,   66.1 ,   66.1 ,   69   ,   65.7 ,   73.7 ,   71   ,   71.5 ,   68.9 ,   70.7 ,
        '4i21b'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   83   ,   63.2 ,   63.8 ,   73.5 ,   71.2 ,   79.4 ,   70.2 ,   68.3 ,   62.5 ,   58.9 ,   70.1 ,   67   ,   66.7 ,   67.4 ,   68.4 ,   63.9 ,
        '4i21c'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   37.5 ,   32   ,   31   ,   24.8 ,   27.7 ,   44.4 ,   19.1 ,   25.3 ,   35.9 ,   30.9 ,   31.1 ,   34.7 ,   45.1 ,   30.4 ,   27.8 ,   47.5 ,
        '4i21d'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   89.3 ,   92.5 ,   94.4 ,   100  ,   100  ,   99.2 ,   93.7 ,   86.2 ,   90.9 ,   89.8 ,   91   ,   86.5 ,   90.5 ,   96.5 ,   97.3 ,   95   ,
        '4i22a'  , 97.5 ,   98.2 ,   95.4 ,   94.9 ,   97.2 ,   97.3 ,   95.9 ,   96.3 ,   95.6 ,   95   ,   94.8 ,   92.8 ,   96.2 ,   94.6 ,   96.3 ,   94.4 ,   94   ,   95.2 ,   95.7 ,   92.5 ,   91.9 ,   95.9 ,   91.4 ,   90.8 ,   93.2 ,   93.6 ,   94.4 ,   91.5 ,   93.5 ,   89   ,   87.4 ,   84.4 ,   89.9 ,   90   ,   94.4 ,   94.2 ,   93.4 ,
        '4i23a'  , 76.8 ,   100  ,   94.8 ,   82.2 ,   81.5 ,   86   ,   85.2 ,   80.7 ,   89.4 ,   90.1 ,   90.3 ,   74.3 ,   90.9 ,   95.4 ,   87.6 ,   91.3 ,   95.4 ,   88.8 ,   81.7 ,   82.1 ,   79.1 ,   82.8 ,   84.1 ,   89.2 ,   94.1 ,   95.6 ,   87.2 ,   87.2 ,   91.3 ,   96.3 ,   92.2 ,   88.7 ,   94.2 ,   95.3 ,   90.8 ,   95   ,   85.7 ,
        '4i32a'  , 56   ,   58.5 ,   57.1 ,   59   ,   62.7 ,   57.9 ,   58.4 ,   56.8 ,   60.1 ,   59.2 ,   60.4 ,   59.7 ,   66.8 ,   63.9 ,   65.2 ,   65.2 ,   68.1 ,   65.1 ,   67.2 ,   67.7 ,   70.9 ,   72.1 ,   65.2 ,   63.2 ,   73.1 ,   72.9 ,   69.5 ,   67.2 ,   71.1 ,   69   ,   70.5 ,   68   ,   69   ,   68.8 ,   74.5 ,   75.6 ,   75.5 ,
        '4i33a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   40.5 ,   12.2 ,   26.5 ,   54.6 ,   62.1 ,   47.6 ,   43.2 ,   49.1 ,   37.8 ,   42.4 ,   47   ,   51   ,   47.7 ,   32.8 ,   37.7 ,   32.5 ,
        '4i33b'  , 31.7 ,   28.7 ,   38.6 ,   30   ,   41.3 ,   38.4 ,   43.9 ,   43.1 ,   48.2 ,   41.9 ,   45.6 ,   48.2 ,   47.2 ,   45.3 ,   44.2 ,   47.5 ,   44.9 ,   45.3 ,   53.4 ,   49.5 ,   49   ,   50   ,   55.1 ,   57.8 ,   55.7 ,   51.8 ,   53.4 ,   51.4 ,   54.8 ,   57.8 ,   57.6 ,   55.2 ,   55.6 ,   54.1 ,   51   ,   51.4 ,   53.5 ,
        '4i34a'  , 15.7 ,   18.2 ,   27.2 ,   31.7 ,   27.8 ,   29.2 ,   22.2 ,   24.1 ,   24   ,   25.6 ,   18.8 ,   23.3 ,   24.5 ,   25.8 ,   29.4 ,   29.3 ,   30.5 ,   32.8 ,   35.1 ,   36.7 ,   34.1 ,   28.8 ,   39.1 ,   34.3 ,   34.5 ,   38.3 ,   33.6 ,   32.5 ,   33.4 ,   36.8 ,   35.9 ,   36   ,   38.3 ,   40.9 ,   37.6 ,   37.2 ,   35.3 ,
        '4i35a'  , 3.3  ,   7.4  ,   6.4  ,   9.1  ,   2.5  ,   6.3  ,   3.2  ,   10.2 ,   1.3  ,   1.8  ,   4.5  ,   8.8  ,   9.1  ,   7.4  ,   5.1  ,   10.9 ,   6.4  ,   14.8 ,   18.9 ,   20   ,   11.5 ,   11.4 ,   18   ,   13.3 ,   14.5 ,   9.8  ,   0    ,   4.6  ,   16   ,   11.2 ,   8    ,   12.8 ,   12.3 ,   16.1 ,   20.4 ,   17.9 ,   25   ,
        '4j11a'  , 35.9 ,   46.1 ,   51   ,   35.6 ,   38.1 ,   36.2 ,   42.1 ,   39.4 ,   49.9 ,   32.8 ,   55.5 ,   38   ,   40.8 ,   38.8 ,   31.1 ,   33.4 ,   24.9 ,   28.5 ,   41.6 ,   46.1 ,   41.5 ,   38.9 ,   38.8 ,   39.2 ,   30.4 ,   18.9 ,   30.5 ,   30.2 ,   31.3 ,   35.2 ,   41.4 ,   37.1 ,   35.6 ,   40.1 ,   47.6 ,   37.2 ,   27.6 ,
        '4j11b'  , 28.9 ,   30.5 ,   31.9 ,   14   ,   30.2 ,   36.3 ,   45.4 ,   45   ,   37.7 ,   33   ,   29.4 ,   20.8 ,   33.5 ,   23.3 ,   40.3 ,   35.8 ,   27.1 ,   29.1 ,   38.2 ,   33.8 ,   43   ,   34.1 ,   41.2 ,   39.3 ,   43.6 ,   44.4 ,   40.4 ,   34.5 ,   47   ,   44.9 ,   47.2 ,   40.4 ,   42.6 ,   43.9 ,   42.6 ,   40.9 ,   42   ,
        '4j11c'  , 33.9 ,   34.9 ,   26.7 ,   27   ,   23.1 ,   22.5 ,   24.1 ,   35.1 ,   27.5 ,   27.9 ,   22.6 ,   19.3 ,   21.9 ,   14   ,   25.5 ,   28.2 ,   22.6 ,   25.3 ,   30.4 ,   24.3 ,   25.3 ,   25.1 ,   28.1 ,   18.3 ,   17.5 ,   19.6 ,   22.7 ,   16.4 ,   13.6 ,   24.2 ,   26   ,   21.4 ,   27.7 ,   30   ,   28.4 ,   21.2 ,   26.6 ,
        '4j11d'  , 37.6 ,   49.4 ,   33.4 ,   39   ,   43.5 ,   24   ,   38.4 ,   50.3 ,   50   ,   39.8 ,   40   ,   58.3 ,   58.1 ,   38.3 ,   48.8 ,   50.7 ,   43.1 ,   55.5 ,   35.5 ,   55.6 ,   52.8 ,   53.7 ,   56   ,   44.4 ,   34.3 ,   34   ,   41.4 ,   49.3 ,   43.7 ,   49.1 ,   54.3 ,   45.8 ,   33.4 ,   44.8 ,   47   ,   42.2 ,   54.7 ,
        '4j12a'  , 40.5 ,   28   ,   22.2 ,   12.7 ,   20.3 ,   15.6 ,   14.5 ,   29.4 ,   23.3 ,   22.4 ,   25.8 ,   38   ,   16.5 ,   33.3 ,   26.9 ,   23.2 ,   19   ,   20.9 ,   32.2 ,   39.9 ,   29.3 ,   28.7 ,   47.8 ,   34.3 ,   34.7 ,   26.8 ,   36.3 ,   48.3 ,   22   ,   19.7 ,   27.1 ,   30.3 ,   23.7 ,   21.9 ,   26   ,   20.2 ,   21.7 ,
        '4j13a'  , 54.7 ,   65.5 ,   58.7 ,   58.5 ,   59.6 ,   60.9 ,   63.5 ,   61.7 ,   67.9 ,   62.3 ,   64.4 ,   59.9 ,   58.6 ,   63.8 ,   55.5 ,   60.7 ,   54.6 ,   60.6 ,   60.7 ,   57.2 ,   59.1 ,   59.6 ,   54.8 ,   57.4 ,   51.9 ,   60.7 ,   60.7 ,   51.5 ,   40.2 ,   51.8 ,   60.7 ,   59   ,   56.4 ,   54.3 ,   56.1 ,   53.6 ,   59   ,
        '4j21a'  , 39   ,   35.9 ,   39.6 ,   37.2 ,   33.7 ,   35   ,   38.6 ,   40.7 ,   31.5 ,   47.2 ,   43.8 ,   34   ,   30.4 ,   30.4 ,   37.2 ,   42.7 ,   44.7 ,   51.6 ,   48.7 ,   54.9 ,   52.2 ,   44.7 ,   40.4 ,   44.5 ,   49.3 ,   53.5 ,   52.5 ,   52.6 ,   49.7 ,   47.3 ,   50.9 ,   52.5 ,   53.1 ,   54   ,   55.2 ,   58.3 ,   50.7 ,
        '4j21b'  , 13.3 ,   5.6  ,   4.5  ,   0    ,   9.9  ,   0    ,   3.8  ,   5.5  ,   8.7  ,   18.1 ,   20.5 ,   7.9  ,   9.8  ,   22.7 ,   18.9 ,   17.5 ,   20.8 ,   35.9 ,   47.5 ,   29.1 ,   27.1 ,   30   ,   30.7 ,   45.1 ,   54.2 ,   57.4 ,   42.6 ,   33.6 ,   40   ,   49.5 ,   62.5 ,   40.8 ,   42.5 ,   54.5 ,   59.7 ,   50.6 ,   48.5 ,
        '4j21c'  , 0    ,   4    ,   6.5  ,   7.9  ,   3.5  ,   7.1  ,   5.1  ,   7    ,   8.3  ,   7.2  ,   13.4 ,   10.1 ,   10.7 ,   9.6  ,   10.7 ,   9.4  ,   6.4  ,   5    ,   3.6  ,   3.4  ,   8.3  ,   22.9 ,   19   ,   15   ,   16.5 ,   14.7 ,   14.2 ,   27.6 ,   20   ,   12.6 ,   23.7 ,   27.8 ,   23.5 ,   23.2 ,   20.1 ,   21.8 ,   30.9 ,
        '4j22a'  , 35.5 ,   32.5 ,   38.6 ,   37.5 ,   46.8 ,   39.5 ,   37.8 ,   36.9 ,   43.9 ,   43.8 ,   36.5 ,   32.9 ,   36.3 ,   41.3 ,   45.9 ,   37.3 ,   42.5 ,   45   ,   46.7 ,   44.1 ,   48.4 ,   41   ,   49.8 ,   54.3 ,   56.4 ,   51.9 ,   54.2 ,   64.2 ,   51.4 ,   42.3 ,   45   ,   48.5 ,   46.4 ,   53.6 ,   58   ,   49.8 ,   48.3 ,
        '4j23a'  , 30.8 ,   25   ,   17.5 ,   27.5 ,   46.2 ,   45   ,   40.9 ,   53   ,   49.8 ,   53.9 ,   43.6 ,   40   ,   29.5 ,   38.1 ,   45.4 ,   44.4 ,   53.5 ,   60.3 ,   50.3 ,   41.5 ,   41.9 ,   61.8 ,   47.3 ,   63   ,   54.4 ,   52.9 ,   52.5 ,   47.5 ,   59.6 ,   73.6 ,   68.6 ,   53.1 ,   57.9 ,   52.1 ,   43.8 ,   66.8 ,   68.7 ,
        '4j24a'  , 5.6  ,   7.6  ,   12.9 ,   17.6 ,   17.7 ,   31.9 ,   33.1 ,   5.7  ,   31.1 ,   18.5 ,   6.8  ,   27.8 ,   24.9 ,   20.4 ,   29.3 ,   18.6 ,   18.2 ,   17.2 ,   28.4 ,   26.4 ,   19.4 ,   41.5 ,   8.7  ,   9.2  ,   19   ,   18.8 ,   27.3 ,   45.3 ,   29.1 ,   28.2 ,   24.6 ,   21.8 ,   28.8 ,   35.1 ,   32.5 ,   32.5 ,   24.9 ,
        '4j25a'  , 15   ,   14.2 ,   26.3 ,   24.1 ,   43.8 ,   26.7 ,   14.8 ,   22.3 ,   29.4 ,   21.7 ,   26.3 ,   12.3 ,   9.6  ,   15.4 ,   41.5 ,   56   ,   48.2 ,   30.1 ,   24.5 ,   34.4 ,   40.4 ,   26.6 ,   7.2  ,   4.5  ,   29.3 ,   20.9 ,   51.9 ,   58   ,   51.7 ,   46.6 ,   57.9 ,   55.3 ,   61.3 ,   57.2 ,   50.8 ,   62.2 ,   67.2 ,
        '4j25b'  , 90   ,   95.3 ,   95.1 ,   97.8 ,   98.2 ,   98   ,   92.4 ,   100  ,   98.4 ,   92.8 ,   91.7 ,   98   ,   97   ,   100  ,   100  ,   95.5 ,   90.5 ,   89.9 ,   93.4 ,   95.9 ,   93.8 ,   95.3 ,   97.4 ,   100  ,   97.9 ,   92.2 ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   NA   ,   NA   ,   100  ,   100  ,   100  ,
        '5b11a'  , 56.1 ,   60.5 ,   68.8 ,   65   ,   61.7 ,   58.7 ,   54.3 ,   56.7 ,   52.1 ,   56.1 ,   49.9 ,   40.1 ,   43.9 ,   41.2 ,   48.6 ,   43.1 ,   50.4 ,   57.9 ,   43.8 ,   46   ,   41   ,   59.3 ,   59.8 ,   60.2 ,   60   ,   60.8 ,   57.6 ,   51.6 ,   58.1 ,   52.7 ,   56.3 ,   60.7 ,   53.3 ,   65.3 ,   68.2 ,   61.1 ,   57.3 ,
        '5b11b'  , 56.3 ,   43.5 ,   44.4 ,   44.7 ,   44.6 ,   37.7 ,   33   ,   35.3 ,   31.8 ,   33.3 ,   34.9 ,   36.6 ,   38.7 ,   38.6 ,   28.5 ,   24.9 ,   20.7 ,   18.6 ,   32.6 ,   27.5 ,   30.5 ,   36.2 ,   37.9 ,   34.7 ,   36.2 ,   33.9 ,   31.5 ,   35.9 ,   35.4 ,   31.5 ,   27.4 ,   32.1 ,   29.4 ,   31   ,   37.4 ,   35   ,   33.2 ,
        '5b11c'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   73.2 ,   73.9 ,   82.3 ,   86.1 ,   84.2 ,   82.7 ,   79.1 ,   71.1 ,   72.1 ,   77.4 ,   68   ,   84.2 ,   74   ,   72.4 ,   77.8 ,   77.7 ,
        '5b11d'  , 85.8 ,   87.8 ,   85.8 ,   87   ,   87.9 ,   87.2 ,   87.1 ,   87.7 ,   89.9 ,   89.2 ,   85.7 ,   83.1 ,   84.8 ,   81.1 ,   83.5 ,   84.8 ,   83.8 ,   80.9 ,   81.8 ,   78.8 ,   82.5 ,   80.6 ,   83.8 ,   82.7 ,   78.7 ,   83.2 ,   84.6 ,   83.1 ,   85.1 ,   80.7 ,   83.8 ,   82.5 ,   82.5 ,   83.1 ,   83.1 ,   81.4 ,   80.7 ,
        '5b11e'  , 88.6 ,   85.7 ,   83.8 ,   86.4 ,   87.9 ,   87.9 ,   81.9 ,   89.6 ,   88.6 ,   92   ,   88.6 ,   88.1 ,   86.3 ,   84.8 ,   84.6 ,   82.9 ,   78   ,   85.2 ,   83.9 ,   83.3 ,   80.7 ,   89   ,   83.5 ,   79.6 ,   80.7 ,   88.5 ,   88   ,   92.1 ,   90.1 ,   85.2 ,   85.2 ,   88.2 ,   82.7 ,   63.5 ,   78.6 ,   81   ,   81.7 ,
        '5b11f'  , 73.8 ,   76.1 ,   77   ,   73   ,   66.9 ,   70.7 ,   73.6 ,   69.7 ,   69.2 ,   75.8 ,   82.8 ,   74.4 ,   63.7 ,   60.4 ,   75.2 ,   69.3 ,   66.5 ,   69.6 ,   67.3 ,   64   ,   57.3 ,   63.1 ,   60.5 ,   68.5 ,   67.6 ,   64   ,   68.4 ,   70.1 ,   74.1 ,   73.8 ,   66.7 ,   71.1 ,   76.8 ,   66.6 ,   61.9 ,   64.1 ,   76.9 ,
        '5b11g'  , 32   ,   42.8 ,   35.1 ,   35.4 ,   38.3 ,   35.3 ,   37.6 ,   43.8 ,   42.9 ,   41.1 ,   45.1 ,   37.8 ,   48.8 ,   46.7 ,   51   ,   54.1 ,   48.4 ,   45.4 ,   47.6 ,   47.8 ,   41.9 ,   56.5 ,   57   ,   63.3 ,   69.2 ,   73.3 ,   67.4 ,   70   ,   74.6 ,   67.9 ,   64.3 ,   67.4 ,   71.7 ,   74.1 ,   72   ,   66   ,   67.8 ,
        '5b12a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   74.9 ,   71.8 ,   79.1 ,   80.2 ,   77.3 ,   75.7 ,   75.7 ,   72.8 ,   70.6 ,   71.7 ,   69.8 ,   67.8 ,   68.5 ,   69.8 ,   63.6 ,   68.6 ,
        '5b12b'  , 82.1 ,   81.6 ,   82   ,   84.6 ,   82.8 ,   82.5 ,   83.2 ,   81.4 ,   84.4 ,   83.8 ,   85.2 ,   80   ,   81.3 ,   79   ,   80.3 ,   80   ,   79   ,   77.3 ,   77.9 ,   78.5 ,   77.7 ,   80.6 ,   77.9 ,   87.2 ,   79.6 ,   79.6 ,   84.8 ,   84.3 ,   80.3 ,   79.6 ,   80.8 ,   77.5 ,   77.9 ,   79.8 ,   80.1 ,   76.8 ,   74.7 ,
        '5b12c'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   71.8 ,   82.5 ,   79   ,   73.9 ,   73.3 ,   67   ,   67.5 ,   73.3 ,   75.2 ,   67   ,   63.9 ,   61.8 ,   63.7 ,   48.3 ,   71.4 ,   69.6 ,
        '5b12d'  , 27.7 ,   29.9 ,   23.4 ,   39.3 ,   28.4 ,   20.4 ,   20.9 ,   29.7 ,   34.7 ,   41   ,   36.1 ,   42.9 ,   34.3 ,   33.3 ,   34.6 ,   36.5 ,   41.4 ,   52.2 ,   42.8 ,   41.1 ,   46.2 ,   47.9 ,   69.7 ,   53.2 ,   43   ,   47.4 ,   66.1 ,   59.6 ,   46   ,   41.7 ,   51   ,   55.9 ,   48   ,   38.3 ,   33.1 ,   34.9 ,   60.8 ,
        '5b12e'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   72.6 ,   79.2 ,   79.3 ,   81.8 ,   75   ,   74.9 ,   77.7 ,   70.8 ,   78.8 ,   79.7 ,   73.9 ,   78.6 ,   78.8 ,   76.5 ,   70.2 ,   69.6 ,
        '5b13a'  , 82.8 ,   78.6 ,   81.1 ,   80.4 ,   81   ,   72.9 ,   73.9 ,   78.3 ,   73.4 ,   78   ,   73.8 ,   69.9 ,   69.6 ,   72.6 ,   72.1 ,   71.8 ,   69.1 ,   61.2 ,   66.6 ,   69.8 ,   69.9 ,   59.3 ,   64.6 ,   64.9 ,   62.5 ,   70.5 ,   62.6 ,   59.9 ,   59.7 ,   57.8 ,   53.2 ,   51.7 ,   61.6 ,   66.2 ,   59.2 ,   52.9 ,   55.9 ,
        '5b13b'  , 94.9 ,   93.8 ,   95.9 ,   95.4 ,   95.3 ,   95.5 ,   95.5 ,   94.4 ,   92.9 ,   92.6 ,   94.2 ,   95   ,   93.7 ,   93.1 ,   96.2 ,   94.8 ,   93.2 ,   93.1 ,   92.1 ,   92.3 ,   93.4 ,   93.6 ,   94.8 ,   94.8 ,   94.3 ,   92   ,   93.1 ,   92.9 ,   92.2 ,   89.1 ,   92.3 ,   94   ,   91.7 ,   89.2 ,   86.3 ,   87.9 ,   90   ,
        '5b22a'  , 53.1 ,   57.8 ,   56.4 ,   53   ,   57.3 ,   56.8 ,   52.5 ,   53   ,   53.5 ,   53.6 ,   56.1 ,   53.8 ,   52.7 ,   53.4 ,   46.1 ,   46.8 ,   44.1 ,   44.7 ,   44.7 ,   37.4 ,   41.4 ,   47.1 ,   40.1 ,   42.4 ,   43.2 ,   58.9 ,   61.4 ,   48   ,   36.1 ,   43.9 ,   39.1 ,   41.6 ,   38.8 ,   41.3 ,   45.6 ,   47.6 ,   40.5 ,
        '5b22b'  , 43.2 ,   42.2 ,   48.2 ,   45.4 ,   42.7 ,   49.3 ,   42.6 ,   46   ,   42.9 ,   47.5 ,   35.5 ,   34.4 ,   35.9 ,   40.4 ,   33.1 ,   46.8 ,   32   ,   35.4 ,   35.7 ,   38.9 ,   27.4 ,   30.9 ,   29   ,   30.7 ,   35.8 ,   33.6 ,   43   ,   48   ,   32.7 ,   34.8 ,   43.9 ,   42.5 ,   37.4 ,   33.5 ,   45   ,   54.8 ,   31.9 ,
        '5b22c'  , 46.6 ,   50.3 ,   50   ,   45.3 ,   43.3 ,   44.7 ,   44.9 ,   47.5 ,   44.6 ,   46.3 ,   46.5 ,   35.8 ,   38   ,   38.6 ,   46.2 ,   44.6 ,   29.8 ,   27.6 ,   33.5 ,   26.4 ,   37   ,   29.6 ,   46.3 ,   41.8 ,   13   ,   10.7 ,   29.4 ,   18.9 ,   24.9 ,   31.1 ,   18.3 ,   21.6 ,   29.2 ,   24.6 ,   27.7 ,   20.7 ,   28.2 ,
        '5b22d'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   82.4 ,   81.5 ,   63   ,   49.6 ,   60.9 ,   51.6 ,   62.5 ,   71.8 ,   74   ,   65.7 ,   63.8 ,   79.7 ,   78.2 ,   62.8 ,   66.7 ,   72.8 ,
        '5b22e'  , 63.5 ,   63   ,   61.3 ,   65   ,   63.5 ,   64.6 ,   62.9 ,   61.1 ,   61.2 ,   62.6 ,   62.6 ,   60.5 ,   54.7 ,   58.5 ,   56.3 ,   65.9 ,   62.2 ,   50.5 ,   62   ,   65.1 ,   70.2 ,   56.4 ,   54.5 ,   51.9 ,   51.9 ,   51.2 ,   59.3 ,   58.1 ,   50.6 ,   54.5 ,   51.8 ,   53.4 ,   50.4 ,   54.7 ,   50.4 ,   44.2 ,   50.7 ,
        '5b22f'  , 51.9 ,   57.4 ,   57.3 ,   64   ,   56.8 ,   62.4 ,   56.3 ,   55.1 ,   51.7 ,   63.6 ,   57.5 ,   55.1 ,   54.5 ,   56.2 ,   57.4 ,   60.2 ,   52.6 ,   51.7 ,   57.9 ,   62.5 ,   56.4 ,   65.6 ,   42.5 ,   41.3 ,   55.5 ,   55.3 ,   61.1 ,   45.4 ,   46.2 ,   66.4 ,   68.7 ,   49.7 ,   58.6 ,   62.7 ,   71.6 ,   67.4 ,   52   ,
        '5b22g'  , 49.4 ,   53.4 ,   52   ,   46.9 ,   50.6 ,   46.6 ,   40.5 ,   52.4 ,   48.9 ,   57.3 ,   54.6 ,   52.3 ,   51.7 ,   52.1 ,   47.1 ,   37.9 ,   37.9 ,   39.9 ,   42.2 ,   48.7 ,   36.2 ,   43.4 ,   47.2 ,   55.2 ,   45.4 ,   41.2 ,   53.7 ,   45.6 ,   51.7 ,   45.1 ,   28.2 ,   32   ,   32.3 ,   20.3 ,   32.5 ,   50.1 ,   33   ,
        '5b22h'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   52.4 ,   54.9 ,   51.1 ,   53.3 ,   58.2 ,   54.1 ,   40.9 ,   35.9 ,   39.3 ,   42.2 ,   30.5 ,   40.4 ,   45.1 ,   60.7 ,   44.3 ,   26.6 ,
        '5b22i'  , 39.5 ,   39.4 ,   42.9 ,   44.5 ,   42.2 ,   34.4 ,   44   ,   42.5 ,   36.8 ,   37.1 ,   48.1 ,   42.9 ,   43.7 ,   16.4 ,   0    ,   50   ,   41.2 ,   47.3 ,   63.4 ,   58.2 ,   41.2 ,   43.1 ,   19.2 ,   0    ,   30.5 ,   50.8 ,   69.9 ,   49.4 ,   70.1 ,   24.3 ,   21   ,   29.8 ,   31.2 ,   53.3 ,   77.7 ,   68.7 ,   19.7 ,
        '5c01a'  , 68   ,   69   ,   71.8 ,   79.2 ,   82.4 ,   79.8 ,   82.1 ,   75.1 ,   70.9 ,   72.1 ,   73.6 ,   73.5 ,   74.6 ,   74.3 ,   73.4 ,   74.7 ,   72.6 ,   71   ,   64.9 ,   66.9 ,   63.3 ,   77.9 ,   76.8 ,   71.1 ,   68   ,   73.5 ,   68.8 ,   70.4 ,   64.9 ,   70.1 ,   64.1 ,   61.3 ,   65.8 ,   72.6 ,   78.6 ,   64.8 ,   76.9 ,
        '5d01a'  , 82.8 ,   82.7 ,   82.5 ,   84.2 ,   84.3 ,   82.7 ,   84   ,   82   ,   85.3 ,   83.1 ,   82.3 ,   83.5 ,   82.6 ,   84.4 ,   83.6 ,   82.8 ,   82.3 ,   82.3 ,   81.2 ,   80.9 ,   81.7 ,   82.8 ,   80.3 ,   80.6 ,   82.1 ,   82.5 ,   81.4 ,   80.2 ,   77.9 ,   79.8 ,   80.9 ,   82.7 ,   82.3 ,   82.9 ,   82.7 ,   82.6 ,   82.8 ,
        '5d01b'  , 77   ,   77.5 ,   78.2 ,   79.8 ,   79.9 ,   79.5 ,   80.5 ,   80.8 ,   82.5 ,   83.6 ,   83.2 ,   83   ,   83.6 ,   83.2 ,   82.7 ,   82.7 ,   82.4 ,   82.1 ,   82.7 ,   81.9 ,   80.9 ,   83.2 ,   84.3 ,   83   ,   83.5 ,   83.8 ,   82.9 ,   81.4 ,   81.3 ,   82.8 ,   82.3 ,   81.8 ,   82.5 ,   81.4 ,   82   ,   81   ,   81.3 ,
        '5d02a'  , 91.1 ,   94.4 ,   92.2 ,   92.4 ,   95.9 ,   91.4 ,   92.5 ,   92.2 ,   95.4 ,   90.4 ,   89.7 ,   92.8 ,   87.9 ,   90.1 ,   90.4 ,   91.3 ,   88.6 ,   87.5 ,   86.9 ,   88.7 ,   87.5 ,   89.4 ,   91.9 ,   93.7 ,   93   ,   88.7 ,   86.5 ,   89.2 ,   77.9 ,   89.1 ,   93.5 ,   84.5 ,   79.5 ,   92.3 ,   82.3 ,   75.4 ,   72.7 ,
        '5d02b'  , 91.6 ,   92.7 ,   93.5 ,   92.1 ,   93.7 ,   92.4 ,   92.2 ,   90.4 ,   93.3 ,   91.6 ,   86.1 ,   88.1 ,   82.9 ,   85.2 ,   90.9 ,   86.9 ,   90.1 ,   84.3 ,   85.9 ,   85.4 ,   86.2 ,   69.3 ,   63.8 ,   59.6 ,   70.7 ,   56.8 ,   40.6 ,   44.6 ,   63.2 ,   50.9 ,   44.1 ,   36.1 ,   44.3 ,   58.8 ,   45.5 ,   46.3 ,   40.1 ,
        '5d03a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   79.2 ,   75.7 ,   71.7 ,   83.3 ,   79.2 ,   74   ,   83.1 ,   85.9 ,   82.4 ,   81.9 ,   83   ,   85.9 ,   87.3 ,   85.5 ,   88.6 ,   87.7 ,
        '5d04a'  , 40.5 ,   38.2 ,   39.1 ,   41.3 ,   42.4 ,   43.2 ,   42.9 ,   40.1 ,   38.6 ,   38.8 ,   43.3 ,   46.3 ,   46   ,   48.1 ,   45.5 ,   46.7 ,   48.4 ,   45.7 ,   46.9 ,   46   ,   45.3 ,   54   ,   59.2 ,   58.7 ,   53.5 ,   56.4 ,   57.9 ,   50.7 ,   54.7 ,   51.4 ,   53.5 ,   52.3 ,   54.2 ,   53.2 ,   52.8 ,   54.4 ,   58.1 ,
        '5f00a'  , 90.2 ,   89.6 ,   90.3 ,   90.6 ,   92.6 ,   91.8 ,   92.5 ,   92.4 ,   91.7 ,   92.8 ,   93.3 ,   92   ,   93.6 ,   92.1 ,   92.6 ,   90.8 ,   90.7 ,   91   ,   91.2 ,   92.4 ,   91.2 ,   88.6 ,   90.5 ,   90.6 ,   91.7 ,   90.4 ,   89.9 ,   88.2 ,   88.8 ,   89.1 ,   89.7 ,   92.1 ,   89.6 ,   89.8 ,   88.4 ,   89   ,   89.1 ,
        '5f00b'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   95.4 ,   92.9 ,   87.6 ,   89.3 ,   97.2 ,   93.2 ,   93   ,   94.4 ,   92.9 ,   88.6 ,   86.2 ,   93   ,   98.3 ,   94   ,   92   ,   94   ,
        '5f00c'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   99.9 ,   99.7 ,   100  ,   100  ,   100  ,   100  ,   99.1 ,   98.1 ,   98.8 ,   98.6 ,   96.9 ,   98.3 ,   99.7 ,   99.2 ,   99.6 ,   99.4 ,
        '5f00d'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   75.7 ,   74   ,   86   ,   89.5 ,   84.7 ,   78.3 ,   84   ,   83.7 ,   85.5 ,   86.1 ,   89.5 ,   82.4 ,   85.3 ,   86.6 ,   85.2 ,   89.5 ,
        '5f00e'  , 17.5 ,   25.2 ,   19.6 ,   25.9 ,   28.2 ,   32.3 ,   34.3 ,   26   ,   23.4 ,   36.5 ,   46.1 ,   45.9 ,   37.8 ,   21.8 ,   23.2 ,   27.3 ,   28.5 ,   27.9 ,   30.9 ,   32.4 ,   35.4 ,   36.7 ,   25.4 ,   27   ,   27.8 ,   30.9 ,   31.1 ,   34.8 ,   32.8 ,   24   ,   36.1 ,   37.6 ,   29.8 ,   21.3 ,   32.6 ,   29.9 ,   25.6 ,
        '5g10a'  , 4.4  ,   4.2  ,   3.8  ,   3.3  ,   5    ,   3.6  ,   6.2  ,   5.8  ,   4.3  ,   4.6  ,   4.9  ,   7.5  ,   8    ,   6.6  ,   5    ,   8.6  ,   9.8  ,   10.4 ,   10.4 ,   14.8 ,   17.3 ,   18.3 ,   16.6 ,   16.2 ,   13.2 ,   23   ,   24.6 ,   22.4 ,   20.2 ,   23.4 ,   20.2 ,   18.6 ,   23.3 ,   23.3 ,   20.4 ,   17.9 ,   20.5 ,
        '5g21a'  , 4.4  ,   2.7  ,   2.7  ,   4.1  ,   4.7  ,   5.4  ,   5.4  ,   5.5  ,   10.4 ,   10.8 ,   16.1 ,   8.6  ,   6.1  ,   7.8  ,   5.5  ,   4.6  ,   5    ,   7.8  ,   10.5 ,   10.1 ,   10   ,   7.1  ,   5.6  ,   8.3  ,   7.9  ,   6.8  ,   8    ,   6.4  ,   5.9  ,   8.4  ,   6.9  ,   7.1  ,   8.8  ,   7.1  ,   14.4 ,   12.7 ,   6.2  ,
        '5g22a'  , 0    ,   0    ,   0    ,   0    ,   0    ,   2.3  ,   2.8  ,   3.8  ,   2.9  ,   2.7  ,   2    ,   2.2  ,   3.4  ,   1.7  ,   2.9  ,   2.4  ,   1.9  ,   5.9  ,   4.6  ,   4.8  ,   6.3  ,   8.7  ,   7.6  ,   14.5 ,   12.9 ,   15.2 ,   12.7 ,   5.5  ,   20.4 ,   20.3 ,   15.5 ,   17.9 ,   16   ,   15.9 ,   18.2 ,   17.9 ,   22.2 ,
        '5g23a'  , 5.5  ,   10   ,   14.2 ,   11.7 ,   12.6 ,   15.3 ,   15.2 ,   15.6 ,   16.4 ,   14.9 ,   14.6 ,   12.2 ,   7.9  ,   8.5  ,   13.7 ,   10.1 ,   11.4 ,   13.7 ,   15.4 ,   16.3 ,   10   ,   14.1 ,   11.7 ,   16.8 ,   16.5 ,   17.7 ,   22.8 ,   24.5 ,   17.4 ,   12.2 ,   10.4 ,   8.8  ,   20.5 ,   15.1 ,   7.3  ,   4.4  ,   7.3  ,
        '5g23b'  , 6.8  ,   12.4 ,   10.5 ,   12.1 ,   6.5  ,   8.8  ,   11   ,   6.4  ,   5.2  ,   11.2 ,   22.3 ,   19.1 ,   13.9 ,   12.2 ,   6.6  ,   9    ,   13.8 ,   14.9 ,   17.6 ,   10.9 ,   11.8 ,   14.1 ,   7.6  ,   15.3 ,   18.8 ,   22.4 ,   11   ,   17.8 ,   14.7 ,   12.5 ,   8.3  ,   8.3  ,   10.4 ,   19.8 ,   26.5 ,   16.1 ,   18.1 ,
        '5g24a'  , 0    ,   0    ,   1.5  ,   0    ,   0    ,   4.2  ,   2    ,   0    ,   0    ,   0    ,   0    ,   1.3  ,   0.8  ,   0.8  ,   2.3  ,   2.4  ,   3.1  ,   2    ,   1.6  ,   3.1  ,   4.9  ,   3.2  ,   2.9  ,   0.5  ,   0.2  ,   2.8  ,   2.4  ,   3.1  ,   2.7  ,   1.6  ,   3.4  ,   6    ,   8.1  ,   4.3  ,   1.8  ,   3.4  ,   4.3  ,
        '5g31a'  , 6.7  ,   8.4  ,   9.3  ,   5.5  ,   5.4  ,   8    ,   6.6  ,   8.6  ,   9.4  ,   10.1 ,   9.2  ,   8.4  ,   9    ,   10.8 ,   10.3 ,   7.9  ,   9    ,   10.5 ,   11.8 ,   8.4  ,   10.3 ,   10.1 ,   9.7  ,   8.8  ,   9.8  ,   14.5 ,   8.5  ,   10.4 ,   13.1 ,   12   ,   12.1 ,   12.1 ,   10.6 ,   10.5 ,   11.6 ,   12.1 ,   16.6 ,
        '5g32a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   10.8 ,   11.2 ,   16.3 ,   7.2  ,   2.7  ,   13.2 ,   22.6 ,   36.7 ,   30.5 ,   14.8 ,   14.4 ,   20.6 ,   25.1 ,   14.8 ,   11.2 ,   13.5 ,
        '5g32b'  , 0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   5.9  ,   7    ,   0    ,   0    ,   6.1  ,   0    ,   6.8  ,   0    ,   3.6  ,   0    ,   0    ,   0    ,   13.2 ,   24.1 ,   25.3 ,   1.6  ,   17.7 ,   29.4 ,   16.7 ,   29.7 ,   17.3 ,   16.2 ,   64.7 ,   47.9 ,   12.2 ,   26.7 ,   13.2 ,   30.3 ,
        '5h11a'  , 87.2 ,   84.7 ,   87.3 ,   88.3 ,   89.2 ,   87.3 ,   86.5 ,   86.8 ,   86.5 ,   88.1 ,   88   ,   85.7 ,   87.1 ,   86.7 ,   89.7 ,   87.6 ,   91.3 ,   88.7 ,   86   ,   86.9 ,   88   ,   88.5 ,   87.2 ,   87.5 ,   86.1 ,   86.8 ,   86.8 ,   87.8 ,   88.5 ,   87.1 ,   87.7 ,   87.2 ,   91.5 ,   90.7 ,   88.5 ,   92.1 ,   92.7 ,
        '5h11b'  , 73.2 ,   71.5 ,   72.5 ,   74.4 ,   76.7 ,   75.2 ,   75.7 ,   75.1 ,   77.5 ,   77   ,   77.6 ,   74.8 ,   71.5 ,   72.5 ,   70   ,   69.5 ,   72   ,   70.4 ,   65.5 ,   63.2 ,   63.7 ,   60.2 ,   56.1 ,   59.5 ,   61   ,   60.2 ,   59.2 ,   61.3 ,   61.6 ,   57.6 ,   54.9 ,   58.1 ,   60.6 ,   61.1 ,   65.2 ,   65.5 ,   64.7 ,
        '5h11c'  , 85.8 ,   84.4 ,   84.9 ,   81   ,   80.2 ,   82.3 ,   83.7 ,   82.2 ,   84   ,   84.7 ,   86.3 ,   85.9 ,   82.9 ,   82.6 ,   84.2 ,   85.2 ,   82.8 ,   83.2 ,   84.7 ,   83.9 ,   82   ,   81.5 ,   79.6 ,   78.2 ,   79.4 ,   78.6 ,   80.8 ,   80   ,   79.3 ,   79.1 ,   77.3 ,   81.3 ,   81.5 ,   78.7 ,   81.2 ,   80   ,   78.1 ,
        '5h11d'  , 85.2 ,   84.3 ,   83.1 ,   83.5 ,   84.2 ,   83.4 ,   83.8 ,   83.1 ,   84.9 ,   84.8 ,   84.9 ,   85.8 ,   86   ,   85.3 ,   86.4 ,   86.1 ,   86.1 ,   86.1 ,   86.3 ,   86.5 ,   87.5 ,   88.9 ,   88.6 ,   86.9 ,   87.7 ,   88.2 ,   86.7 ,   88.1 ,   87.1 ,   87.4 ,   87.8 ,   88   ,   88   ,   86.6 ,   86.3 ,   85.5 ,   84.5 ,
        '5h12d'  , 100  ,   95.6 ,   91.4 ,   95.7 ,   100  ,   100  ,   100  ,   100  ,   96.7 ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   100  ,   96.1 ,   100  ,   96.2 ,   97.7 ,   97.7 ,   99.5 ,   96.4 ,   99.1 ,   100  ,   100  ,   100  ,   100  ,   99.1 ,   97.7 ,   98.8 ,   98.9 ,   98.7 ,   98   ,   99.8 ,   99.5 ,   97.5 ,
        '5h12e'  , 81.9 ,   80.4 ,   78.1 ,   79.7 ,   88.7 ,   86.2 ,   88.4 ,   83.7 ,   79.8 ,   84.8 ,   87   ,   86.2 ,   85.9 ,   84.9 ,   87.3 ,   87.5 ,   84.4 ,   82   ,   87   ,   87.2 ,   88.8 ,   92.4 ,   93   ,   91.8 ,   91.9 ,   88.3 ,   86   ,   88.1 ,   89.1 ,   88.7 ,   90.6 ,   94.3 ,   89.3 ,   85.4 ,   87.5 ,   87.4 ,   84.5 ,
        '5h21a'  , 56.6 ,   58.1 ,   61.4 ,   62.4 ,   63   ,   64   ,   66.4 ,   69.2 ,   67.3 ,   73.5 ,   75   ,   68.3 ,   68.7 ,   68   ,   70.8 ,   71.7 ,   74.3 ,   73.2 ,   67.3 ,   69.6 ,   73.8 ,   76.1 ,   74.9 ,   65.6 ,   70.1 ,   73.4 ,   79.9 ,   81.2 ,   85.7 ,   81   ,   81.1 ,   86.9 ,   87   ,   83.8 ,   82.9 ,   83.8 ,   81.7 ,
        '5h21b'  , 51.8 ,   52.9 ,   51.8 ,   52.9 ,   53.3 ,   40.7 ,   52.5 ,   51.2 ,   55.7 ,   49.7 ,   50.2 ,   57.8 ,   56   ,   64.7 ,   60.6 ,   75.9 ,   66.6 ,   56.2 ,   50.3 ,   53.2 ,   55.8 ,   81.2 ,   72.2 ,   83.7 ,   63.7 ,   58   ,   65.5 ,   77.6 ,   62.9 ,   53.8 ,   48.2 ,   65   ,   71.8 ,   68.4 ,   63.5 ,   66.7 ,   67.3 ,
        '5h21c'  , 17.7 ,   20.8 ,   14.9 ,   12   ,   23.1 ,   19.3 ,   23.2 ,   18.8 ,   12.8 ,   15.1 ,   19.7 ,   24.5 ,   17.2 ,   24.7 ,   26.1 ,   33.1 ,   24.9 ,   17.1 ,   20.4 ,   14.3 ,   21.8 ,   21.4 ,   37.6 ,   44.5 ,   36.4 ,   30.4 ,   36.9 ,   36.6 ,   41.3 ,   36.8 ,   38.3 ,   34.6 ,   35.5 ,   47.9 ,   51.4 ,   57.8 ,   47.5 ,
        '5h21d'  , 96.8 ,   98.9 ,   98.7 ,   97.7 ,   98.1 ,   98.6 ,   97.6 ,   95.8 ,   98.4 ,   98.4 ,   98.2 ,   99.5 ,   98.9 ,   98.6 ,   98.5 ,   98.6 ,   99.2 ,   99.3 ,   99.4 ,   98.6 ,   97.5 ,   93.2 ,   93.8 ,   97   ,   100  ,   99.5 ,   97.7 ,   93.6 ,   98.2 ,   98.8 ,   94.5 ,   93.2 ,   87.4 ,   84.7 ,   84.2 ,   88.5 ,   80.9 ,
        '5h22a'  , 56.7 ,   55.2 ,   52.5 ,   48.2 ,   54.2 ,   51.4 ,   48   ,   51.9 ,   49.7 ,   50.7 ,   46.9 ,   44.2 ,   50.2 ,   52   ,   46.7 ,   49.2 ,   47.4 ,   45.7 ,   44.2 ,   46.2 ,   50   ,   36.1 ,   40.2 ,   40.4 ,   42.6 ,   39.3 ,   36.1 ,   35.5 ,   36.3 ,   38.5 ,   33.5 ,   35.6 ,   35.9 ,   32.9 ,   34   ,   37.8 ,   35.1 ,
        '5h22b'  , 61.9 ,   61.6 ,   62   ,   57.2 ,   58.1 ,   56.5 ,   58   ,   58.6 ,   56.9 ,   56.9 ,   49.2 ,   49.6 ,   49.5 ,   49.9 ,   52.6 ,   47.6 ,   50.5 ,   46.2 ,   45.4 ,   46.2 ,   52.5 ,   49.8 ,   33.6 ,   40.9 ,   43.8 ,   39.8 ,   38.7 ,   49.4 ,   39.9 ,   52.4 ,   56.9 ,   49.4 ,   36.2 ,   52   ,   53.7 ,   47.2 ,   48.6 ,
        '5h22c'  , 56.3 ,   59.8 ,   59.1 ,   55.9 ,   52.9 ,   53.9 ,   54.8 ,   56.8 ,   53.9 ,   57.9 ,   51   ,   52.7 ,   52.1 ,   57.5 ,   49.8 ,   53.9 ,   57.6 ,   44   ,   50.9 ,   45.6 ,   52.6 ,   50.2 ,   53   ,   55.9 ,   67   ,   63.1 ,   49.9 ,   40.8 ,   44.4 ,   46.9 ,   57.7 ,   55.5 ,   50.2 ,   62.9 ,   46.2 ,   51.2 ,   53   ,
        '6e10a'  , 0    ,   1.8  ,   0    ,   0    ,   0    ,   0    ,   1.7  ,   1.8  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   9.7  ,   12.1 ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,
        '6e11a'  , 0    ,   0    ,   0    ,   0    ,   0    ,   1.7  ,   1.4  ,   1.8  ,   0    ,   0    ,   2.5  ,   3.5  ,   0    ,   0    ,   2.7  ,   1.9  ,   0    ,   0    ,   3.1  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   18.7 ,
        '6e11b'  , 0.8  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   2.6  ,   1.2  ,   0    ,   0    ,   0    ,   0    ,   0    ,   1.3  ,   2.7  ,   2.3  ,   0    ,   1.2  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0.5  ,   1.2  ,   0    ,   1.9  ,   1    ,   0.5  ,   0.2  ,   0.9  ,   0    ,
        '6e11c'  , 0.8  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   1    ,   0    ,   0    ,   0    ,   0.7  ,   0.7  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0.4  ,   0.4  ,   0    ,   0    ,   0    ,   1.2  ,   0.4  ,   0.7  ,   0    ,   0    ,   0    ,   1.5  ,   1.4  ,   1.9  ,   0.8  ,   2    ,   2    ,   0.7  ,   0    ,
        '6e11d'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   18.2 ,   8.7  ,   5.5  ,   8.3  ,   0    ,   0    ,   0    ,   7.1  ,   4.3  ,   6.4  ,   0    ,   0    ,   16.8 ,   25.2 ,   0    ,   1.5  ,
        '6e11e'  , 1.1  ,   0.6  ,   0    ,   0    ,   0.7  ,   0    ,   0.6  ,   0.8  ,   0    ,   0.6  ,   0    ,   0.9  ,   0    ,   1.7  ,   2.4  ,   1    ,   0    ,   2.7  ,   2.4  ,   1.4  ,   1.6  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   1.1  ,   2.2  ,   3.1  ,   2.8  ,   0.2  ,   2.5  ,   3.3  ,   1.2  ,   0.5  ,   1.3  ,
        '6e11f'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   0    ,   4.6  ,   7.9  ,   6.1  ,   1.2  ,   3.3  ,   5.3  ,   11.1 ,   12.6 ,   6.3  ,   1.7  ,   4.3  ,   4    ,   0    ,   0    ,   20.4 ,
        '6e12a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   37.8 ,   34.3 ,   14.6 ,   56.3 ,   86.2 ,   71.5 ,   75.3 ,   41.6 ,   45.1 ,   19.3 ,   0    ,   0    ,   82.2 ,   77.9 ,   45.1 ,   32.8 ,
        '6e12b'  , 19.3 ,   20.1 ,   24.3 ,   28.4 ,   23.9 ,   30.9 ,   31.5 ,   26.3 ,   27.7 ,   29.6 ,   32.6 ,   24.7 ,   34.1 ,   30.8 ,   33.5 ,   34.5 ,   34.6 ,   33   ,   31.5 ,   32.4 ,   33.9 ,   38.7 ,   39.4 ,   38.2 ,   39.5 ,   35.4 ,   26.1 ,   34.3 ,   34.2 ,   36.2 ,   34.5 ,   38.3 ,   29.6 ,   25.2 ,   22.6 ,   26.2 ,   22.1 ,
        '6e12c'  , 27   ,   38.4 ,   45.4 ,   58.6 ,   60.5 ,   57.6 ,   43.1 ,   40.8 ,   32.3 ,   35.8 ,   37.8 ,   42.4 ,   45   ,   39.9 ,   41.4 ,   34.5 ,   37.4 ,   40.3 ,   48.5 ,   45.6 ,   36.1 ,   40.2 ,   75.3 ,   100  ,   75.6 ,   60.7 ,   47.2 ,   22.7 ,   21.5 ,   30.3 ,   50   ,   28.7 ,   60.8 ,   50   ,   41   ,   74.5 ,   38.7 ,
        '6e13a'  , 0.8  ,   0.4  ,   1.7  ,   0.5  ,   0    ,   1.1  ,   1.5  ,   1.6  ,   1.4  ,   1.8  ,   2.5  ,   2.5  ,   0.5  ,   2    ,   1.5  ,   3.2  ,   0.8  ,   2.8  ,   2.7  ,   2.8  ,   2.7  ,   4    ,   8.5  ,   7.3  ,   3.5  ,   1.3  ,   4.5  ,   7.9  ,   2.8  ,   3.2  ,   3.8  ,   1.7  ,   3.6  ,   3.2  ,   2.4  ,   1.1  ,   0    ,
        '6e13b'  , 0    ,   0    ,   0    ,   0    ,   0    ,   1.5  ,   0    ,   0    ,   2.1  ,   2.3  ,   0    ,   0    ,   4.7  ,   1.9  ,   0    ,   0    ,   0    ,   0    ,   0    ,   1.6  ,   0    ,   0    ,   0    ,   0    ,   5.3  ,   1.4  ,   0    ,   0    ,   0    ,   0    ,   0.8  ,   0    ,   0    ,   1.9  ,   0    ,   0    ,   0    ,
        '6e13c'  , 3.2  ,   2.7  ,   3.2  ,   4.1  ,   3.2  ,   4.6  ,   5    ,   4.9  ,   2.1  ,   1.9  ,   2.1  ,   3    ,   3.3  ,   2.7  ,   5    ,   2.9  ,   4.3  ,   5.1  ,   3.3  ,   4.2  ,   3.3  ,   3.1  ,   1.3  ,   2.2  ,   1.5  ,   5    ,   3.9  ,   3.5  ,   1.1  ,   0.9  ,   6.5  ,   2.8  ,   3.5  ,   2.4  ,   7    ,   4.1  ,   2.3  ,
        '6e13d'  , 0    ,   0    ,   1.4  ,   2.9  ,   7    ,   2.8  ,   1.3  ,   2.8  ,   8.5  ,   9.5  ,   5.4  ,   6.1  ,   4.4  ,   3.5  ,   2.3  ,   1.6  ,   2.9  ,   1.7  ,   1.9  ,   0    ,   2.3  ,   1.1  ,   3.9  ,   0    ,   0    ,   0    ,   0    ,   0    ,   7.4  ,   15.2 ,   8.7  ,   33.2 ,   28.2 ,   0    ,   13.1 ,   10.4 ,   12.2 ,
        '6e13e'  , 0.7  ,   0.5  ,   1.9  ,   0.8  ,   1.3  ,   1.4  ,   2.1  ,   2.4  ,   2.5  ,   4.5  ,   3.6  ,   2.3  ,   3.3  ,   3.3  ,   3.8  ,   3.9  ,   3.3  ,   4    ,   5.7  ,   8.1  ,   6.4  ,   7.9  ,   9.7  ,   6    ,   6.7  ,   11.3 ,   14.9 ,   11   ,   8.8  ,   10.6 ,   7.7  ,   9.6  ,   8.5  ,   14.8 ,   15.1 ,   13.3 ,   15.7 ,
        '6e13f'  , 5.9  ,   5.7  ,   9.2  ,   7.8  ,   10.8 ,   8.4  ,   7.8  ,   8.1  ,   12.4 ,   8.1  ,   15.3 ,   11.4 ,   14.5 ,   12.5 ,   12.1 ,   12.9 ,   9.7  ,   11.3 ,   8.1  ,   10.6 ,   8.4  ,   8.7  ,   14.7 ,   7.2  ,   14.3 ,   7.8  ,   5.4  ,   5.5  ,   6.4  ,   13.4 ,   10.9 ,   9.1  ,   13.5 ,   10.4 ,   10.8 ,   20   ,   9.3  ,
        '6e13g'  , 0    ,   0    ,   0    ,   0    ,   0    ,   3.6  ,   3.4  ,   2.6  ,   0    ,   0    ,   0    ,   0    ,   3    ,   4.2  ,   0    ,   3.4  ,   0    ,   3.5  ,   3.3  ,   0    ,   0    ,   4.7  ,   3.3  ,   2.8  ,   4.7  ,   1.8  ,   0    ,   0    ,   4    ,   4.8  ,   4.8  ,   3.3  ,   8.9  ,   11.6 ,   3    ,   0    ,   0    ,
        '6e13h'  , 13.1 ,   13.7 ,   16.4 ,   17.6 ,   13.5 ,   15.1 ,   15.5 ,   19.7 ,   18.3 ,   20.2 ,   13.4 ,   18.5 ,   20   ,   17.1 ,   12.9 ,   16   ,   19   ,   21.6 ,   36.4 ,   25   ,   19.6 ,   27.2 ,   22   ,   22.6 ,   13.9 ,   17.1 ,   39.9 ,   36.4 ,   32.4 ,   31.6 ,   38.2 ,   43.8 ,   31.5 ,   27.1 ,   35.7 ,   47   ,   42.9 ,
        '6e13i'  , 3    ,   3    ,   4.8  ,   5.9  ,   4.9  ,   5.2  ,   1.2  ,   2.2  ,   1.3  ,   2.8  ,   4.7  ,   6.7  ,   6.5  ,   1.4  ,   4.7  ,   3    ,   3.2  ,   5.8  ,   3.9  ,   2.2  ,   3.1  ,   6.6  ,   4.4  ,   7.2  ,   28.2 ,   7.1  ,   11.7 ,   8.4  ,   7.1  ,   10.1 ,   6.8  ,   13.2 ,   15.1 ,   10.3 ,   15.2 ,   18   ,   16.2 ,
        '6e13j'  , 2.7  ,   4.9  ,   4    ,   3.6  ,   2.9  ,   3.7  ,   4.9  ,   7.3  ,   8.4  ,   9.7  ,   11.3 ,   11.8 ,   12.1 ,   13.4 ,   13.2 ,   13.5 ,   16.1 ,   13.6 ,   13.8 ,   15.6 ,   12.2 ,   16.9 ,   22   ,   22.2 ,   19.1 ,   20.8 ,   19.2 ,   18.6 ,   21.6 ,   22.4 ,   22.9 ,   18.6 ,   17   ,   20.7 ,   13.4 ,   16.2 ,   20.1 ,
        '6e14a'  , 21.2 ,   28.7 ,   27.7 ,   28.6 ,   26.9 ,   20.7 ,   27.3 ,   30.8 ,   27.8 ,   37.4 ,   32.1 ,   26.3 ,   27.5 ,   30   ,   25   ,   37.2 ,   41.4 ,   23.4 ,   27.7 ,   35   ,   30.4 ,   33.4 ,   45.1 ,   35.6 ,   35.8 ,   32.1 ,   53.5 ,   25.7 ,   45.5 ,   34.4 ,   25.1 ,   38.7 ,   61   ,   22.5 ,   45   ,   26   ,   46.9 ,
        '6e14b'  , 18.2 ,   17.4 ,   16.8 ,   16   ,   23   ,   21.8 ,   21.3 ,   20.4 ,   22.9 ,   23.7 ,   23   ,   23.2 ,   23.8 ,   22   ,   23.5 ,   19   ,   19.4 ,   17.9 ,   18.7 ,   19.5 ,   23   ,   16.1 ,   28.4 ,   26.2 ,   31.8 ,   38.6 ,   31.3 ,   26.1 ,   16.5 ,   20.7 ,   24.6 ,   24.8 ,   17   ,   16.7 ,   17.1 ,   20.8 ,   23.8 ,
        '6e15a'  , 7.1  ,   5    ,   7.2  ,   7.4  ,   11.1 ,   7.6  ,   11.8 ,   10.9 ,   15   ,   14.5 ,   16.7 ,   11.8 ,   13.9 ,   16.7 ,   22.6 ,   21.5 ,   19   ,   17.8 ,   17.4 ,   18.2 ,   16.1 ,   9.5  ,   10.3 ,   35.6 ,   20.7 ,   23.3 ,   25.7 ,   41.5 ,   22   ,   21.8 ,   18.4 ,   35.4 ,   48.8 ,   33.7 ,   32.1 ,   34.6 ,   37.2 ,
        '6e15b'  , 60.7 ,   48.3 ,   46   ,   48.8 ,   48.3 ,   52.9 ,   53.5 ,   52.5 ,   44.4 ,   36.6 ,   45.1 ,   35.1 ,   36.3 ,   36.8 ,   40.8 ,   33.6 ,   34.1 ,   36.8 ,   25.5 ,   38.1 ,   31.4 ,   30.3 ,   36.1 ,   28.4 ,   25.6 ,   29.3 ,   29.5 ,   20.3 ,   27.6 ,   28.1 ,   29.6 ,   28.9 ,   32   ,   29.2 ,   26.4 ,   32.6 ,   34.7 ,
        '6e15c'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   28.9 ,   30.4 ,   29.1 ,   23.5 ,   26.2 ,   31   ,   31.7 ,   27   ,   23.8 ,   29.9 ,   35.2 ,   41.1 ,   34   ,   29.8 ,   34.7 ,   33.1 ,
        '6e15d'  , 21.3 ,   20.7 ,   15.7 ,   15.4 ,   14.9 ,   13.7 ,   17.2 ,   23.5 ,   21.6 ,   22.3 ,   19.4 ,   16.9 ,   19.3 ,   22.1 ,   19.8 ,   23   ,   19.6 ,   23.7 ,   20.2 ,   25.4 ,   25   ,   29.4 ,   29.4 ,   34.4 ,   32.9 ,   35.6 ,   23.8 ,   15.2 ,   23.8 ,   29.8 ,   26.3 ,   28.5 ,   31.9 ,   30.5 ,   27.3 ,   27.2 ,   31   ,
        '6e15e'  , 4.6  ,   6.8  ,   5.2  ,   9.1  ,   9.5  ,   7.5  ,   8.4  ,   8.2  ,   6.9  ,   8.1  ,   6.8  ,   5.2  ,   13.1 ,   13.2 ,   10.1 ,   9.1  ,   11.2 ,   8.5  ,   12.6 ,   11.2 ,   15.7 ,   9.3  ,   15.8 ,   7.9  ,   3.2  ,   8.6  ,   5    ,   8.6  ,   10.5 ,   11.5 ,   13.2 ,   13.4 ,   12.3 ,   9.9  ,   10.7 ,   15.4 ,   18.9 ,
        '6e15f'  , 15.8 ,   16.1 ,   7.7  ,   5.5  ,   5.7  ,   5.5  ,   14.4 ,   13.3 ,   11.3 ,   4.5  ,   12.5 ,   15.5 ,   12.7 ,   18   ,   7.4  ,   17.4 ,   18.9 ,   19.5 ,   15.4 ,   12.3 ,   7.1  ,   11.7 ,   4.9  ,   8.8  ,   2.9  ,   1.6  ,   3.4  ,   6.5  ,   22.5 ,   19.7 ,   3.5  ,   0    ,   0    ,   7    ,   14.5 ,   17.6 ,   28.1 ,
        '6e16a'  , 43.7 ,   44.2 ,   55.1 ,   62.6 ,   49.7 ,   45.1 ,   53.7 ,   54.8 ,   48   ,   48.3 ,   46   ,   41.1 ,   44.1 ,   43.2 ,   48.9 ,   45.9 ,   43.6 ,   38.4 ,   41.2 ,   43.1 ,   47.2 ,   49.6 ,   45.8 ,   57.9 ,   51.4 ,   32.9 ,   36.5 ,   28.9 ,   43.7 ,   36   ,   39.8 ,   53.8 ,   36.9 ,   38.1 ,   94.9 ,   88.6 ,   64.4 ,
        '6e16b'  , 82.6 ,   83.2 ,   84.2 ,   80.5 ,   82.4 ,   75.9 ,   78.4 ,   73.5 ,   85.6 ,   88.7 ,   88.9 ,   83.7 ,   82.1 ,   84.6 ,   84.7 ,   79.2 ,   78.9 ,   78.3 ,   79.7 ,   84.4 ,   89.6 ,   70.8 ,   76.4 ,   80.8 ,   73.2 ,   67.2 ,   67.6 ,   64.7 ,   53   ,   59.5 ,   67.7 ,   65.7 ,   53.6 ,   57.3 ,   58.7 ,   60   ,   49.6 ,
        '6e16c'  , 67.5 ,   69.6 ,   62.8 ,   60.6 ,   50   ,   41.8 ,   43.8 ,   62.3 ,   56   ,   56.8 ,   61.6 ,   66.6 ,   71.9 ,   65   ,   66.5 ,   62   ,   70   ,   68.5 ,   63.2 ,   62.1 ,   62.4 ,   73.2 ,   75.1 ,   42.7 ,   42.5 ,   52.2 ,   60.9 ,   74.2 ,   80.7 ,   73.9 ,   82.9 ,   93   ,   68.6 ,   54   ,   54.8 ,   78.9 ,   68.1 ,
        '6e17a'  , 7.3  ,   4.6  ,   6.6  ,   3.8  ,   3    ,   4    ,   2.4  ,   2.4  ,   5.5  ,   7.6  ,   10.9 ,   7.1  ,   5.7  ,   6.5  ,   8.1  ,   7.1  ,   4.8  ,   2.4  ,   4.5  ,   3.4  ,   5.6  ,   12   ,   14.7 ,   10.5 ,   14.4 ,   7.7  ,   8.6  ,   7.4  ,   6.2  ,   7.5  ,   5.4  ,   4.4  ,   6.7  ,   7.2  ,   5.5  ,   4.8  ,   6.9  ,
        '6e18a'  , 1.4  ,   0.9  ,   1.2  ,   0.2  ,   0.4  ,   1.1  ,   1.9  ,   1.5  ,   0.3  ,   2.6  ,   0.8  ,   1.2  ,   2.1  ,   2.3  ,   1.6  ,   1    ,   0.2  ,   0.8  ,   0.8  ,   1.2  ,   0.4  ,   0.8  ,   0.2  ,   1.1  ,   0.7  ,   2.6  ,   2.1  ,   1.6  ,   1.6  ,   0    ,   0.3  ,   2.6  ,   2.4  ,   2.2  ,   3.4  ,   4.7  ,   2.3  ,
        '6e18b'  , 1    ,   0.3  ,   1.3  ,   2.2  ,   2.5  ,   0.8  ,   1.5  ,   1.3  ,   2.6  ,   2.1  ,   0.7  ,   0.7  ,   1.1  ,   0.3  ,   1.6  ,   0.5  ,   0.9  ,   2.3  ,   2.2  ,   1.3  ,   2.3  ,   0.3  ,   0    ,   1.5  ,   0.8  ,   1.8  ,   1    ,   3.3  ,   1.4  ,   1.3  ,   1.2  ,   0    ,   0    ,   0.9  ,   0    ,   0.6  ,   1.7  ,
        '6e18c'  , 3.6  ,   2    ,   2.5  ,   0    ,   0    ,   3.5  ,   2.6  ,   3.3  ,   3.1  ,   0    ,   2.6  ,   0.9  ,   0.8  ,   6.7  ,   7.3  ,   5.2  ,   0    ,   1.8  ,   4.1  ,   1.3  ,   6.2  ,   0.4  ,   3.2  ,   0.6  ,   4.9  ,   9.4  ,   18   ,   9.6  ,   3.2  ,   2.7  ,   7.6  ,   7.1  ,   6.1  ,   2.7  ,   7.2  ,   4.5  ,   5.9  ,
        '6e18d'  , 14.3 ,   4.7  ,   8.3  ,   0    ,   3.9  ,   3.8  ,   12.5 ,   10.8 ,   7.9  ,   5.3  ,   4.6  ,   5    ,   1.4  ,   1.2  ,   4.1  ,   8.7  ,   7.3  ,   7.1  ,   3.1  ,   7.5  ,   3.9  ,   17.4 ,   9.2  ,   0    ,   5.2  ,   3.5  ,   1.6  ,   8.6  ,   21.5 ,   10.6 ,   3.7  ,   11.6 ,   7.8  ,   0    ,   5.2  ,   9.4  ,   19.8 ,
        '6e19a'  , 3.1  ,   0    ,   0    ,   0    ,   0    ,   2.9  ,   0    ,   0    ,   0    ,   0    ,   2.2  ,   1.8  ,   3.9  ,   0    ,   0    ,   2.2  ,   2.5  ,   0    ,   0    ,   0    ,   2.6  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   16   ,   13.3 ,   11   ,   11.3 ,   2    ,   0    ,   0    ,   0    ,   0    ,   4    ,
        '6e19b'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   6.8  ,   3.6  ,   0    ,   0    ,   0    ,   4    ,   3.5  ,   4.5  ,   11.5 ,   13.5 ,   5.7  ,   2.7  ,   0    ,   3.9  ,   1.1  ,   13.5 ,
        '6e19c'  , 38.9 ,   30.5 ,   34.8 ,   53   ,   53.3 ,   35.8 ,   51.4 ,   59   ,   70.9 ,   71.4 ,   63.6 ,   55.6 ,   47.8 ,   63.9 ,   56   ,   64.6 ,   61.1 ,   65.1 ,   61.2 ,   61.4 ,   63.2 ,   59   ,   47.2 ,   43.1 ,   52.7 ,   70.6 ,   82.3 ,   76.8 ,   53.1 ,   61.2 ,   46.8 ,   50.6 ,   62   ,   68.1 ,   89.3 ,   55.5 ,   42.8 ,
        '6e19d'  , 39.8 ,   29.8 ,   26.5 ,   26.8 ,   24.9 ,   18.5 ,   19.9 ,   22.2 ,   24.5 ,   22.4 ,   19.4 ,   27.3 ,   28.7 ,   24.1 ,   24.3 ,   30.5 ,   26.2 ,   28.7 ,   23.8 ,   25.7 ,   26.1 ,   23.7 ,   31.2 ,   23.7 ,   25.8 ,   26.3 ,   33.3 ,   34.9 ,   29.1 ,   23.3 ,   25.4 ,   39.3 ,   15.5 ,   33.7 ,   26.5 ,   28.8 ,   37.6 ,
        '6e21a'  , 1.5  ,   1    ,   1    ,   1.8  ,   3.2  ,   2.2  ,   2.1  ,   0    ,   1.1  ,   1.7  ,   2.6  ,   2.4  ,   4.1  ,   4.6  ,   3.1  ,   3.8  ,   3.2  ,   3.7  ,   3.9  ,   5.2  ,   5.9  ,   8.1  ,   7.5  ,   5    ,   4.2  ,   10.9 ,   7.7  ,   4.7  ,   5.3  ,   6.7  ,   6.4  ,   6.4  ,   4.4  ,   6.9  ,   5.9  ,   4.7  ,   4.9  ,
        '6e22a'  , 0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0.9  ,   2.7  ,   1    ,
        '6e22b'  , 0    ,   0    ,   0.5  ,   0    ,   0    ,   0    ,   0    ,   0.5  ,   0.5  ,   0.7  ,   0    ,   0    ,   0.2  ,   0    ,   1.4  ,   0.4  ,   0.3  ,   0.5  ,   1.1  ,   1.4  ,   0.4  ,   0    ,   0    ,   0.7  ,   0.5  ,   0.3  ,   2    ,   1.5  ,   1.7  ,   0.2  ,   0.4  ,   0.5  ,   0    ,   1.1  ,   1.8  ,   3    ,   0    ,
        '6e23a'  , 0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0.2  ,   0    ,   0    ,   0    ,   0.2  ,   0    ,   0.1  ,   0.1  ,   0.4  ,   0.5  ,   0.6  ,   0.7  ,   0.3  ,   0.4  ,   0.4  ,   0.2  ,   1    ,   1.4  ,   0.5  ,   0.6  ,   1    ,   0.8  ,   0.7  ,   1    ,   0.9  ,   0.8  ,   0.7  ,   0.5  ,   1.1  ,   0.4  ,   0.4  ,
        '6e23b'  , 0    ,   0    ,   0    ,   3.6  ,   4.1  ,   0    ,   0    ,   0    ,   6.3  ,   4.5  ,   0    ,   0    ,   2.2  ,   2.6  ,   3.6  ,   0    ,   4.3  ,   2.1  ,   5.5  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   2.4  ,   4.6  ,   0    ,   0    ,   0    ,   3.2  ,   3.2  ,   0    ,
        '6e23c'  , 0    ,   0    ,   0    ,   0    ,   1.3  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   1.7  ,   2.2  ,   1    ,   1.1  ,   1.4  ,   0    ,   1.1  ,   1.1  ,   0    ,   0    ,   0    ,   2    ,   3.1  ,   0    ,   0.2  ,   0    ,   0    ,   0.8  ,   2    ,   0    ,   0    ,   0.9  ,   1    ,   0.2  ,
        '6e23d'  , 0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0.3  ,   0.4  ,   0    ,   0    ,   0.4  ,   0.8  ,   0.8  ,   1.1  ,   0.2  ,   0.7  ,   0.6  ,   0.5  ,   0.3  ,   0.4  ,   0    ,   0.1  ,   0    ,   0    ,   0.1  ,   0.4  ,   0.1  ,   0.7  ,   1    ,   0.5  ,   0.7  ,   0.3  ,   0    ,   0    ,   0.1  ,   0.5  ,
        '6e23e'  , 0.4  ,   0    ,   0    ,   0    ,   0.3  ,   0.6  ,   0.9  ,   0    ,   0.7  ,   0.6  ,   0.5  ,   0.7  ,   1.8  ,   1.3  ,   2.1  ,   0.4  ,   1.1  ,   0.7  ,   2    ,   1.6  ,   1.7  ,   2.1  ,   2.6  ,   0.4  ,   2.8  ,   3.5  ,   3.7  ,   4.5  ,   1.8  ,   1.9  ,   3.6  ,   3.2  ,   8.1  ,   8.4  ,   4.5  ,   4.3  ,   4.8  ,
        '6e23f'  , 0    ,   0    ,   0    ,   0    ,   0    ,   1.3  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   1.3  ,   2.4  ,   1.6  ,   0.9  ,   1.6  ,   0    ,   0    ,   3    ,   1.7  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   5.9  ,   0    ,   0    ,   4.2  ,   5.6  ,   0.3  ,   2.4  ,
        '6e23g'  , 11.3 ,   5.4  ,   8.9  ,   5.5  ,   2.6  ,   7.9  ,   4.7  ,   6.1  ,   6.4  ,   13.8 ,   10.9 ,   12.7 ,   12.4 ,   14.7 ,   16.2 ,   15.7 ,   15.7 ,   13.6 ,   18   ,   21.1 ,   21.1 ,   10.5 ,   12.1 ,   8.3  ,   10.9 ,   13.1 ,   5.9  ,   4.7  ,   8.8  ,   11.6 ,   17.3 ,   15.8 ,   9.6  ,   12.3 ,   16   ,   21.7 ,   14.5 ,
        '6e24a'  , 0.4  ,   1.4  ,   0.7  ,   0.3  ,   0.5  ,   0    ,   0.7  ,   0.3  ,   0.3  ,   0    ,   0.4  ,   1.2  ,   0.7  ,   0.8  ,   0.2  ,   0    ,   0.6  ,   1.2  ,   1    ,   1.1  ,   0.4  ,   1.4  ,   0.6  ,   0.3  ,   0.6  ,   2.1  ,   0.5  ,   0.6  ,   2.2  ,   0.4  ,   0.7  ,   1.7  ,   1.6  ,   0.7  ,   3.4  ,   6    ,   0.3  ,
        '6e24b'  , 3.2  ,   1.5  ,   0    ,   1.9  ,   0    ,   0    ,   0    ,   0    ,   3.2  ,   4.5  ,   0    ,   4.1  ,   3.6  ,   5.7  ,   4    ,   2.9  ,   10.9 ,   10   ,   0    ,   3.6  ,   0    ,   10.9 ,   16.3 ,   0    ,   0    ,   0    ,   0    ,   0    ,   1.2  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   13.1 ,   20.9 ,
        '6e24c'  , 0    ,   0    ,   0    ,   0    ,   0    ,   2.6  ,   2.1  ,   0    ,   0    ,   0    ,   1.1  ,   0    ,   0    ,   0    ,   1.3  ,   2.4  ,   1.5  ,   1.7  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,
        '6e24d'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   0    ,   0    ,   0    ,   0    ,   6.6  ,   5.4  ,   3    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,
        '6e25a'  , 0    ,   0    ,   0    ,   0    ,   0    ,   0.7  ,   0.8  ,   0.8  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0.9  ,   0    ,   2    ,   0    ,   0    ,   0    ,   0    ,   0.9  ,   2    ,   0    ,   1.1  ,   2    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,
        '6e25b'  , 0    ,   0.4  ,   0.5  ,   1.1  ,   0.7  ,   1.3  ,   0    ,   0    ,   0    ,   2    ,   0.7  ,   1.5  ,   1.2  ,   0    ,   0    ,   0    ,   0    ,   1.5  ,   0    ,   0.6  ,   0    ,   0    ,   0.8  ,   1.4  ,   1.8  ,   0    ,   0    ,   2.3  ,   2.5  ,   1.8  ,   0    ,   0.3  ,   1.2  ,   0.7  ,   0    ,   0.5  ,   0.8  ,
        '6e25c'  , 0    ,   0.5  ,   0    ,   0    ,   0.5  ,   0    ,   0.3  ,   0.3  ,   0.3  ,   0.3  ,   0    ,   0.7  ,   0.3  ,   1.2  ,   0.9  ,   1.1  ,   1    ,   1.2  ,   2    ,   2.2  ,   1.7  ,   0.6  ,   0.5  ,   0.4  ,   0.3  ,   1    ,   1.6  ,   0.5  ,   0.6  ,   0.7  ,   0.6  ,   1.8  ,   2    ,   0.9  ,   1.8  ,   1    ,   0.9  ,
        '6e25d'  , 0    ,   0    ,   0    ,   2    ,   0    ,   0    ,   0    ,   3.5  ,   1.6  ,   3    ,   1.7  ,   4.4  ,   4.4  ,   3.6  ,   4.6  ,   4.9  ,   3.5  ,   3.1  ,   4.9  ,   3.1  ,   2.9  ,   0    ,   2.4  ,   3.6  ,   9.8  ,   10.1 ,   3.4  ,   0.2  ,   1.7  ,   0    ,   0    ,   0    ,   7.7  ,   6.1  ,   12.5 ,   2.8  ,   1.9  ,
        '6e26a'  , 74.2 ,   70.9 ,   67.4 ,   67.8 ,   65.3 ,   66.7 ,   66.4 ,   67.8 ,   62.3 ,   58.9 ,   65.9 ,   64.6 ,   69.2 ,   65.2 ,   69.4 ,   64.8 ,   68.2 ,   58.7 ,   66.2 ,   69   ,   79.5 ,   64.8 ,   57.9 ,   70   ,   69.7 ,   59.4 ,   58   ,   64.9 ,   75.4 ,   71.6 ,   86.7 ,   86.4 ,   75.5 ,   68.7 ,   73.8 ,   67   ,   77.4 ,
        '6e27a'  , 0.8  ,   1.7  ,   0    ,   1    ,   0.7  ,   0.6  ,   1.2  ,   2.4  ,   2.9  ,   1.4  ,   3    ,   1.3  ,   1.2  ,   2.1  ,   2.5  ,   3.1  ,   5.3  ,   3.8  ,   1.6  ,   0    ,   1.6  ,   0.3  ,   2.1  ,   2.2  ,   0    ,   0.2  ,   0.3  ,   2.9  ,   2.1  ,   4.6  ,   8.4  ,   7.9  ,   4.5  ,   3.6  ,   4.9  ,   4.9  ,   1.5  ,
        '6e27b'  , 14.3 ,   17.7 ,   12.2 ,   7.6  ,   9    ,   13   ,   3.9  ,   16   ,   13.4 ,   15.9 ,   20.7 ,   9.4  ,   24.8 ,   7    ,   13.4 ,   16   ,   11.7 ,   18.2 ,   18.6 ,   22.1 ,   17.9 ,   14.7 ,   13.4 ,   6.2  ,   13.5 ,   31.9 ,   17   ,   43.9 ,   38.6 ,   24   ,   6.3  ,   10.6 ,   14.2 ,   9    ,   36.3 ,   38.3 ,   18   ,
        '6e27c'  , 2.1  ,   5.2  ,   2.8  ,   2.1  ,   2.2  ,   3.7  ,   3.8  ,   4.3  ,   1.9  ,   2.1  ,   2.3  ,   2.8  ,   2.3  ,   4.1  ,   2.9  ,   4.1  ,   3    ,   2.5  ,   4.2  ,   3.3  ,   5.1  ,   7.9  ,   9.4  ,   12.7 ,   12.6 ,   9.3  ,   14.3 ,   13.8 ,   16.6 ,   8.7  ,   8.6  ,   11.6 ,   14.9 ,   11.9 ,   11.9 ,   13.9 ,   12.3 ,
        '6e27d'  , 33.1 ,   31.3 ,   33.6 ,   28.1 ,   25.9 ,   27.3 ,   27.2 ,   26.7 ,   28.2 ,   27.4 ,   25.3 ,   26.2 ,   26.1 ,   26.5 ,   26.8 ,   24.1 ,   26.4 ,   24.7 ,   22.5 ,   28.4 ,   25.3 ,   24.6 ,   25   ,   28.7 ,   28.9 ,   25.6 ,   24.6 ,   24   ,   27.7 ,   30.5 ,   30.2 ,   30.3 ,   28.2 ,   33   ,   32.7 ,   28.7 ,   28.5 ,
        '6e28a'  , 4.4  ,   20.8 ,   21.3 ,   17   ,   26.5 ,   30.4 ,   34   ,   20.7 ,   29.3 ,   27.3 ,   36.3 ,   19.9 ,   17.6 ,   19.3 ,   17.9 ,   30.1 ,   13.2 ,   18.6 ,   31.2 ,   52.4 ,   44.3 ,   42.6 ,   34.9 ,   55.5 ,   55.8 ,   57.4 ,   68.1 ,   0    ,   12.4 ,   43.6 ,   21.6 ,   54.6 ,   79.1 ,   65.7 ,   50.7 ,   73   ,   88   ,
        '6e28b'  , 25.7 ,   26.7 ,   29.6 ,   32.3 ,   28.5 ,   24.4 ,   30.4 ,   24.8 ,   19.3 ,   19.1 ,   15.9 ,   28.9 ,   19.1 ,   24.6 ,   26.6 ,   23.4 ,   22.4 ,   34.6 ,   36.2 ,   39.5 ,   28.3 ,   35.2 ,   27.1 ,   33.6 ,   43.9 ,   44.3 ,   35.4 ,   28   ,   25.2 ,   30.4 ,   25.2 ,   53.3 ,   34.7 ,   44.2 ,   54.6 ,   53   ,   55.4 ,
        '6e28c'  , 16.9 ,   32   ,   20.6 ,   20.3 ,   23.7 ,   34.8 ,   29.7 ,   24.4 ,   36.1 ,   31.1 ,   24.3 ,   25.4 ,   34.7 ,   54.9 ,   38.9 ,   25.7 ,   25.5 ,   30.1 ,   29.6 ,   37.4 ,   39.6 ,   21.8 ,   18.1 ,   26.3 ,   20.7 ,   34.8 ,   32.9 ,   26.4 ,   44.2 ,   29.3 ,   19.6 ,   38.7 ,   40.1 ,   21.7 ,   23.7 ,   28.6 ,   52.4 ,
        '6e28d'  , 62.5 ,   50.4 ,   35.6 ,   42.5 ,   43.6 ,   33.4 ,   49.1 ,   41.8 ,   59.8 ,   59.6 ,   53.5 ,   48.1 ,   35.8 ,   62.9 ,   55.6 ,   44.7 ,   60.3 ,   48   ,   46.5 ,   47.6 ,   46.7 ,   49.9 ,   39.8 ,   38.8 ,   71.4 ,   53.4 ,   37.4 ,   42.8 ,   45.5 ,   36.2 ,   40.7 ,   51.7 ,   50.3 ,   35.1 ,   36.6 ,   41.4 ,   37.3 ,
        '6e31a'  , 0.3  ,   0.4  ,   0.2  ,   0.6  ,   0.4  ,   0.4  ,   0.3  ,   0.1  ,   0.2  ,   0.2  ,   0.7  ,   0.4  ,   0.7  ,   0.6  ,   0.6  ,   0.7  ,   0.9  ,   0.9  ,   0.9  ,   1.4  ,   0.5  ,   0.9  ,   0.8  ,   1.5  ,   1.9  ,   2    ,   1.7  ,   1.8  ,   1.7  ,   1.9  ,   2.3  ,   2.7  ,   1.7  ,   2.8  ,   3.2  ,   2.5  ,   2.5  ,
        '6e32a'  , 5.1  ,   3.9  ,   5.2  ,   5.8  ,   7    ,   6.8  ,   7    ,   6.5  ,   5.5  ,   8.5  ,   10.4 ,   11.3 ,   10.6 ,   8.9  ,   11.9 ,   12.6 ,   13.9 ,   12.2 ,   15.2 ,   17.8 ,   19.9 ,   19.2 ,   17.8 ,   21.4 ,   23.8 ,   29.1 ,   22.3 ,   23.8 ,   27.4 ,   21.9 ,   21   ,   17.9 ,   18   ,   22   ,   23   ,   17.6 ,   13.6 ,
        '6e33a'  , 3.6  ,   10.5 ,   0    ,   7.8  ,   3.9  ,   4.8  ,   7.6  ,   10   ,   11.6 ,   13.2 ,   14   ,   26.1 ,   22.3 ,   25.2 ,   21.7 ,   19.1 ,   18.1 ,   31.8 ,   20.5 ,   33   ,   25.9 ,   18.3 ,   11.8 ,   9.3  ,   19.3 ,   27   ,   34.1 ,   26.2 ,   36.5 ,   34.3 ,   31.7 ,   34.6 ,   21.7 ,   26.8 ,   22.2 ,   23.8 ,   25.5 ,
        '6e33b'  , 5.7  ,   6.6  ,   9.2  ,   2    ,   2.2  ,   5.8  ,   2.1  ,   2.2  ,   0    ,   2.7  ,   0    ,   4.6  ,   2.3  ,   1.3  ,   0    ,   2.3  ,   0    ,   6.1  ,   5.5  ,   3.5  ,   5.6  ,   3.7  ,   1.8  ,   7.7  ,   7.1  ,   8.4  ,   10.8 ,   18.2 ,   6.3  ,   11.7 ,   16.7 ,   5.6  ,   7.2  ,   15.6 ,   8.2  ,   8.4  ,   6.8  ,
        '6e34a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   2.1  ,   13.8 ,   5    ,   0    ,   3.7  ,   8.7  ,   0    ,   0    ,   0    ,
        '6e34b'  , 3.5  ,   3.7  ,   0.8  ,   1.4  ,   0.6  ,   1    ,   1.8  ,   2    ,   2.2  ,   2.5  ,   3.4  ,   2.3  ,   4    ,   1.4  ,   3.7  ,   2.8  ,   1.5  ,   0.5  ,   0    ,   1.1  ,   1.8  ,   0.9  ,   0    ,   0    ,   1.2  ,   0    ,   0    ,   1.7  ,   3.4  ,   3.1  ,   0    ,   0    ,   1.6  ,   0    ,   0.8  ,   2.2  ,   0.6  ,
        '6e34c'  , 1.6  ,   0    ,   1.2  ,   0    ,   4.5  ,   2.7  ,   1.6  ,   0    ,   1.3  ,   0    ,   0    ,   0    ,   0    ,   0    ,   2.9  ,   1.5  ,   0    ,   0    ,   0    ,   3.7  ,   2.1  ,   1.8  ,   6.3  ,   5.8  ,   2.6  ,   6.1  ,   8.7  ,   5.4  ,   6.4  ,   3.3  ,   3.6  ,   5.8  ,   3.7  ,   0.9  ,   0.8  ,   2.6  ,   5.3  ,
        '6e35a'  , 3.1  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   2.8  ,   0    ,   0    ,   1.9  ,   3    ,   3.4  ,   3.4  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,
        '6e35b'  , 0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   4.3  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   4.6  ,   0    ,   0    ,   0    ,   11.3 ,   7.5  ,   0    ,   0    ,   0    ,   4.5  ,   0    ,   0    ,   0    ,   13.1 ,   3.9  ,   2.9  ,   3.2  ,   0    ,   0    ,   9    ,   0    ,   5.2  ,
        '6e36a'  , 3.6  ,   7.6  ,   5.8  ,   3.9  ,   6    ,   4    ,   4.7  ,   6.6  ,   4.7  ,   5.5  ,   7.1  ,   4.3  ,   4    ,   2    ,   3.9  ,   3.9  ,   3.3  ,   6.1  ,   5    ,   4.2  ,   5.3  ,   11.8 ,   2.9  ,   6.2  ,   3.4  ,   6    ,   11.8 ,   14.4 ,   13.6 ,   13.2 ,   16.2 ,   8.1  ,   6.4  ,   3.9  ,   7.3  ,   15.6 ,   9.9  ,
        '6e41a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   5.9  ,   11.4 ,   20.2 ,   24.5 ,   11   ,   12.8 ,   15.7 ,   12.6 ,   17.7 ,   12.6 ,   24.9 ,   18.1 ,   22   ,   23.2 ,   20.2 ,   33   ,
        '6e41b'  , 0.4  ,   0.7  ,   0.4  ,   0.5  ,   0.5  ,   1.4  ,   1.5  ,   1.2  ,   0.6  ,   1    ,   1.1  ,   4.2  ,   1.4  ,   1    ,   0.8  ,   2.1  ,   2    ,   3    ,   2.1  ,   1.9  ,   1.1  ,   1.9  ,   1.7  ,   0.3  ,   0.1  ,   1.9  ,   2.8  ,   3.6  ,   1.4  ,   0    ,   0    ,   0.1  ,   0.4  ,   1.6  ,   1.4  ,   0.8  ,   0.6  ,
        '6e42a'  , 49.3 ,   50.5 ,   57.7 ,   59.3 ,   52.6 ,   52   ,   51.6 ,   55.5 ,   51.8 ,   56.7 ,   56.2 ,   51   ,   60.6 ,   53.3 ,   51.7 ,   57.2 ,   55.8 ,   53   ,   55.2 ,   52.7 ,   60.1 ,   52.3 ,   52.1 ,   50.8 ,   53   ,   49.3 ,   49.6 ,   43.1 ,   42.2 ,   44   ,   40.3 ,   40.4 ,   47   ,   41.5 ,   46.1 ,   50.9 ,   34.1 ,
        '6e43a'  , 20.4 ,   21.6 ,   18.1 ,   12.5 ,   18.9 ,   18.5 ,   21.5 ,   16.9 ,   20.4 ,   19.1 ,   16.6 ,   16.5 ,   34   ,   33   ,   34.4 ,   22.3 ,   30.6 ,   34.4 ,   24.8 ,   30.7 ,   32.3 ,   31   ,   28.9 ,   28   ,   39.2 ,   33.5 ,   22.8 ,   38.1 ,   25.4 ,   33.2 ,   33.5 ,   27.1 ,   27.4 ,   31   ,   24.8 ,   36.7 ,   36.4 ,
        '6e43b'  , 29.7 ,   25.9 ,   27.6 ,   29.6 ,   23.7 ,   23.4 ,   20.2 ,   18.4 ,   16.1 ,   22.8 ,   20.4 ,   22   ,   17.9 ,   14.3 ,   16.2 ,   18.1 ,   11.9 ,   15.6 ,   17.8 ,   17.8 ,   24.9 ,   13.8 ,   31.5 ,   20   ,   24   ,   20.2 ,   25.5 ,   13.2 ,   14.2 ,   19.9 ,   23.3 ,   7.2  ,   20.7 ,   9.5  ,   22.3 ,   16.7 ,   10.4 ,
        '6e43c'  , 29.6 ,   30.9 ,   28.9 ,   29.4 ,   29.5 ,   25.2 ,   27.5 ,   28.5 ,   36.4 ,   38.7 ,   33.8 ,   29.9 ,   33.2 ,   33.3 ,   31   ,   30.2 ,   28   ,   28   ,   29.1 ,   28.4 ,   32   ,   30.7 ,   27.1 ,   24.6 ,   26.4 ,   25.9 ,   25.1 ,   24.6 ,   22.7 ,   28.3 ,   28   ,   28.2 ,   29.4 ,   24.9 ,   28.7 ,   26.6 ,   24.4 ,
        '6e44a'  , 32.1 ,   28.1 ,   29.7 ,   31.6 ,   33   ,   36.2 ,   34.4 ,   36.6 ,   36.9 ,   36.7 ,   39.2 ,   36.6 ,   43.8 ,   47.5 ,   42.5 ,   44.2 ,   43.5 ,   36.6 ,   38.5 ,   48.5 ,   46.1 ,   41   ,   42   ,   49.8 ,   49.4 ,   45.2 ,   47.5 ,   47.7 ,   43.7 ,   48.2 ,   48.9 ,   46.8 ,   45.1 ,   46.3 ,   39.9 ,   47.3 ,   49.3 ,
        '6e44b'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   56.9 ,   46.9 ,   58.9 ,   55.9 ,   58.6 ,   64.1 ,   61.4 ,   50.6 ,   44.8 ,   56.6 ,   52.9 ,   51.1 ,   44.7 ,   44.1 ,   47.8 ,   45.3 ,
        '6e44c'  , 44.2 ,   41.9 ,   42.1 ,   42.4 ,   44.5 ,   45.6 ,   44   ,   47.8 ,   42.9 ,   49.4 ,   42.6 ,   46.5 ,   45.2 ,   42.8 ,   46.7 ,   48.1 ,   47.2 ,   52.3 ,   52.9 ,   51.6 ,   47.7 ,   57.6 ,   58.1 ,   54.2 ,   54.1 ,   59   ,   60.7 ,   56.5 ,   50   ,   49.8 ,   52.5 ,   50.8 ,   55.5 ,   50.2 ,   47.2 ,   41.1 ,   43.8 ,
        '6e44d'  , 20.2 ,   21.4 ,   18.4 ,   22.7 ,   22.7 ,   24.9 ,   20.2 ,   17.6 ,   23.5 ,   30.2 ,   26.4 ,   26.9 ,   24   ,   23.9 ,   21.8 ,   28.8 ,   25.2 ,   25.1 ,   26.6 ,   27.6 ,   21.1 ,   14.1 ,   21.3 ,   27.4 ,   28   ,   21.4 ,   23.6 ,   21.4 ,   22.2 ,   15.8 ,   25.4 ,   27.8 ,   16.4 ,   28.9 ,   17.8 ,   18.1 ,   28.7 ,
        '6e44e'  , 34.5 ,   34.7 ,   31.7 ,   42   ,   41.9 ,   36.3 ,   30.2 ,   34.2 ,   38.7 ,   37.3 ,   31.8 ,   29.1 ,   39.4 ,   42.1 ,   29.6 ,   40.6 ,   39.3 ,   35.9 ,   29.2 ,   32.6 ,   35.1 ,   37.1 ,   23.1 ,   36.2 ,   34.7 ,   59.1 ,   35   ,   25.3 ,   15.5 ,   17.7 ,   25.7 ,   15.9 ,   12.1 ,   25.1 ,   6.3  ,   46.2 ,   31   ,
        '6e45a'  , 81.7 ,   82.7 ,   79.2 ,   76.8 ,   77.8 ,   79.6 ,   80   ,   78.6 ,   79.7 ,   79.2 ,   77.6 ,   77.6 ,   76.4 ,   76.9 ,   70.4 ,   72.7 ,   73.3 ,   74.4 ,   71.4 ,   69.2 ,   73.8 ,   68.6 ,   73.5 ,   77.8 ,   78.1 ,   76.3 ,   59.4 ,   73.9 ,   73.2 ,   70.7 ,   68   ,   68.4 ,   67.7 ,   65.9 ,   59.1 ,   58.8 ,   67.6 ,
        '6e46a'  , 22.9 ,   24.4 ,   20.6 ,   21.3 ,   19.5 ,   17.3 ,   15.4 ,   17.2 ,   21.8 ,   21.4 ,   26.6 ,   21.9 ,   19.9 ,   20.9 ,   12.2 ,   15.4 ,   17.4 ,   17.2 ,   17.1 ,   12.4 ,   13.8 ,   21.8 ,   31.5 ,   33.5 ,   25.4 ,   17.7 ,   25.3 ,   16.1 ,   22.1 ,   20   ,   17.7 ,   10.3 ,   10.5 ,   10.5 ,   15.8 ,   21.2 ,   18.5 ,
        '6e46b'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   45.8 ,   50.2 ,   53.1 ,   43.8 ,   46   ,   73.1 ,   85.2 ,   45.8 ,   41.5 ,   28.9 ,   33.1 ,   37.8 ,   48.2 ,   33.1 ,   27.9 ,   41.4 ,
        '6e46c'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   24.6 ,   17.5 ,   15.5 ,   14   ,   7.4  ,   2.4  ,   13.6 ,   14.4 ,   11   ,   10.9 ,   14.1 ,   12.2 ,   13.1 ,   7.8  ,   4.8  ,   4.8  ,
        '6e46d'  , 43.9 ,   43.9 ,   46.2 ,   50   ,   47.5 ,   40.2 ,   47   ,   44.6 ,   40.1 ,   39.1 ,   40   ,   42.9 ,   39.2 ,   35.7 ,   44   ,   36.1 ,   35.1 ,   37.7 ,   37.9 ,   39.3 ,   38.5 ,   41.3 ,   28.2 ,   26.1 ,   37.4 ,   38.9 ,   34.1 ,   30.9 ,   38.8 ,   30.2 ,   31.2 ,   40   ,   31.4 ,   23.6 ,   40   ,   30.3 ,   45.5 ,
        '6e51a'  , 16.1 ,   15.8 ,   15.1 ,   13.1 ,   12.8 ,   13.5 ,   14.2 ,   14.4 ,   17   ,   18.4 ,   15.3 ,   16.6 ,   15.6 ,   15.3 ,   15.3 ,   14.4 ,   17.1 ,   16.5 ,   15.3 ,   14.8 ,   16.1 ,   19.5 ,   19.6 ,   17.9 ,   18.2 ,   18.5 ,   19.6 ,   18.5 ,   17.6 ,   18.8 ,   18   ,   18.4 ,   18.2 ,   18.7 ,   20.7 ,   19.1 ,   19.2 ,
        '6e52a'  , 6    ,   5.9  ,   5.7  ,   6    ,   7.2  ,   7.1  ,   5.8  ,   8.8  ,   4.3  ,   4.9  ,   5.4  ,   5.7  ,   6.2  ,   6.8  ,   7.3  ,   6.8  ,   6.5  ,   7.3  ,   5.5  ,   5.7  ,   4.6  ,   9.5  ,   9.9  ,   9.9  ,   10   ,   8.2  ,   10.8 ,   9.4  ,   9.4  ,   12.4 ,   11.1 ,   9.8  ,   9    ,   10.6 ,   9    ,   11.9 ,   10.6 ,
        '6e53a'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   0    ,   0    ,   0    ,   7.8  ,   0    ,   0    ,   0    ,   11.8 ,   4.9  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,
        '6e53b'  , 54.1 ,   44.9 ,   38.6 ,   43   ,   46.9 ,   45.1 ,   47.4 ,   47.5 ,   42.6 ,   46.4 ,   42.7 ,   42.5 ,   41.1 ,   43.7 ,   43.3 ,   45.2 ,   41.5 ,   40.4 ,   43.2 ,   42.9 ,   41.9 ,   41.1 ,   35.4 ,   40.1 ,   37.9 ,   35.1 ,   37.4 ,   36   ,   35.6 ,   37.8 ,   37.3 ,   38.3 ,   37.5 ,   36.9 ,   38.7 ,   37.3 ,   37.3 ,
        '6e61a'  , 0.5  ,   0.1  ,   0.2  ,   0.2  ,   0.5  ,   0.2  ,   0.7  ,   0    ,   0.2  ,   0.3  ,   0.4  ,   0    ,   0.3  ,   0.6  ,   1.7  ,   1.6  ,   1.7  ,   0.6  ,   0.6  ,   0.7  ,   1.3  ,   0.9  ,   0.8  ,   0.1  ,   0.5  ,   0.2  ,   1.2  ,   0.6  ,   0.3  ,   0.9  ,   0.5  ,   2    ,   0.9  ,   0    ,   1.1  ,   1.4  ,   0.3  ,
        '6e61b'  , 2.6  ,   2.2  ,   1.8  ,   1.8  ,   2.4  ,   2.9  ,   2.3  ,   2.1  ,   1.9  ,   2.2  ,   1.9  ,   3.6  ,   5.3  ,   6.8  ,   6.8  ,   7.2  ,   5.4  ,   6.3  ,   6.7  ,   7    ,   5.7  ,   9    ,   6.2  ,   8    ,   7    ,   6.9  ,   6.3  ,   3.6  ,   4.4  ,   9.2  ,   7.3  ,   5.8  ,   7.7  ,   8    ,   10.7 ,   8.6  ,   11.3 ,
        '6e62a'  , 2.4  ,   2.9  ,   2.2  ,   0.7  ,   1.1  ,   0.3  ,   0    ,   1.6  ,   2.5  ,   2.8  ,   2.2  ,   2.3  ,   2.4  ,   3.2  ,   1.9  ,   3.6  ,   3    ,   2.6  ,   4    ,   2.2  ,   1.5  ,   7    ,   3.8  ,   2.1  ,   0.3  ,   3.1  ,   1.8  ,   1.7  ,   4.8  ,   4.9  ,   1.5  ,   4.6  ,   4.5  ,   4    ,   2.9  ,   3.5  ,   2    ,
        '6e63a'  , 2.1  ,   1.6  ,   6.5  ,   6    ,   6.2  ,   0.9  ,   6.6  ,   10.6 ,   1.9  ,   0.9  ,   11.1 ,   10.2 ,   9.7  ,   3.5  ,   11.5 ,   8.3  ,   4.9  ,   9.7  ,   8.3  ,   5.1  ,   5.8  ,   9.5  ,   17.6 ,   10   ,   3.7  ,   12.2 ,   13   ,   17.3 ,   15   ,   15.3 ,   18.1 ,   14.6 ,   15.9 ,   16   ,   16.2 ,   20.9 ,   19.3 ,
        '6e64a'  , 66.4 ,   69.1 ,   69.5 ,   68.9 ,   70   ,   67.8 ,   68.7 ,   65.1 ,   73.2 ,   74.7 ,   75   ,   69.1 ,   73.2 ,   69.8 ,   68.8 ,   69.4 ,   70   ,   71.6 ,   71.1 ,   67.9 ,   67.7 ,   70.2 ,   69.1 ,   64.5 ,   67.8 ,   68.7 ,   68.6 ,   69.9 ,   71.9 ,   72.3 ,   69.3 ,   66.6 ,   68   ,   69.3 ,   70   ,   67.1 ,   67.4 ,
        '6e64b'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   10.9 ,   4.3  ,   2.7  ,   3.8  ,   5    ,   7.4  ,   9.7  ,   9.1  ,   14.4 ,   19.5 ,   9.9  ,   4.5  ,   5.3  ,   5.6  ,   6.3  ,   4.4  ,
        '6e65a'  , 52.7 ,   53.3 ,   48.6 ,   52.3 ,   53.4 ,   48.1 ,   46.5 ,   54.3 ,   53.7 ,   48   ,   52.4 ,   58.8 ,   65.6 ,   66.2 ,   58.7 ,   59.9 ,   56.5 ,   59.1 ,   49.2 ,   51.4 ,   51.6 ,   49.4 ,   53.6 ,   56.9 ,   48   ,   46.7 ,   53.3 ,   48.1 ,   40.7 ,   50.3 ,   44.6 ,   45   ,   51.8 ,   52.1 ,   43.6 ,   49.1 ,   52.5 ,
        '6e71a'  , 0.9  ,   1    ,   1.6  ,   1.6  ,   2.4  ,   3    ,   2.8  ,   1.6  ,   1.4  ,   1.2  ,   3.8  ,   1.8  ,   1    ,   0.6  ,   0.7  ,   1.9  ,   2.3  ,   2.6  ,   1.6  ,   0.5  ,   1.2  ,   4.3  ,   3.4  ,   2.4  ,   5.4  ,   5.3  ,   4.2  ,   4.2  ,   3.6  ,   4.1  ,   2.9  ,   3.6  ,   5.6  ,   4.1  ,   3.1  ,   3.8  ,   4.7  ,
        '6e71b'  , 0    ,   2.3  ,   1.4  ,   3.8  ,   2.6  ,   2.6  ,   2.6  ,   2.4  ,   2.2  ,   0.8  ,   3    ,   1.3  ,   0.5  ,   0.6  ,   0.5  ,   0    ,   0    ,   0.6  ,   1.1  ,   2.6  ,   2.1  ,   3.6  ,   3.1  ,   0.4  ,   0    ,   2.6  ,   5.2  ,   1.5  ,   3.7  ,   2.4  ,   2    ,   2.9  ,   5.7  ,   4.2  ,   4.4  ,   1.8  ,   3    ,
        '6e71c'  , 1.8  ,   1.4  ,   0.7  ,   2    ,   1.2  ,   2.5  ,   1.4  ,   1.8  ,   1.2  ,   0.6  ,   0.6  ,   1    ,   2.5  ,   3.3  ,   2    ,   1.6  ,   4.3  ,   2.1  ,   1.8  ,   0.5  ,   1.1  ,   4.7  ,   1.5  ,   1.1  ,   2.4  ,   3.1  ,   0.9  ,   2.1  ,   2.6  ,   0.4  ,   2.3  ,   6.1  ,   8.4  ,   6.2  ,   4.5  ,   3.6  ,   2.1  ,
        '6e71d'  , 0    ,   1.1  ,   3.3  ,   0    ,   2.6  ,   2.8  ,   2.3  ,   0.9  ,   1.9  ,   1.1  ,   2.1  ,   1.4  ,   4.7  ,   2    ,   0.7  ,   0    ,   0    ,   0    ,   0    ,   1.6  ,   0    ,   5.6  ,   2.9  ,   2.1  ,   0    ,   2.5  ,   1.2  ,   0.7  ,   1.7  ,   0.1  ,   0.7  ,   4    ,   3.8  ,   4.4  ,   5.6  ,   5.2  ,   4.8  ,
        '6e71e'  , 1.4  ,   0.8  ,   0.7  ,   1.6  ,   3.5  ,   2.4  ,   3.1  ,   2.5  ,   2.8  ,   3.4  ,   3.9  ,   4.5  ,   5.6  ,   6.4  ,   1.3  ,   3.3  ,   2.5  ,   1.8  ,   5.4  ,   1.1  ,   1.2  ,   4    ,   5.3  ,   7.5  ,   9.5  ,   5.6  ,   6.1  ,   6.1  ,   5.4  ,   5    ,   6.2  ,   8    ,   9.6  ,   8.7  ,   9.1  ,   6.9  ,   10.7 ,
        '6e71f'  , 0    ,   0    ,   2.1  ,   3.9  ,   5.6  ,   5.7  ,   7.1  ,   5.2  ,   5.2  ,   0    ,   2.2  ,   5.5  ,   6.8  ,   3.1  ,   6.7  ,   4.9  ,   7.5  ,   10.1 ,   6.1  ,   4.1  ,   0    ,   1.3  ,   7.9  ,   7    ,   8.8  ,   2.1  ,   4.7  ,   8.5  ,   3.2  ,   1.9  ,   2.4  ,   3.3  ,   3.5  ,   9.3  ,   6.2  ,   11.1 ,   15.5 ,
        '6e71g'  , 7.9  ,   7.3  ,   5.8  ,   0    ,   3.6  ,   8.6  ,   2.2  ,   2    ,   6.2  ,   1.7  ,   1.2  ,   6    ,   3    ,   2.4  ,   0    ,   7.3  ,   1.5  ,   3.2  ,   2.4  ,   4.9  ,   5.7  ,   1.2  ,   0    ,   0    ,   3.7  ,   3.3  ,   5    ,   4.1  ,   5.9  ,   8.1  ,   5    ,   4.8  ,   1.2  ,   2.1  ,   4    ,   8    ,   5.7  ,
        '6e72a'  , 4.4  ,   0    ,   0    ,   0    ,   0    ,   3.1  ,   0    ,   8.3  ,   0    ,   0    ,   0    ,   10   ,   4.7  ,   0    ,   5.1  ,   3.9  ,   0    ,   0    ,   5    ,   6    ,   0    ,   0    ,   0    ,   4.8  ,   16.2 ,   0    ,   5.4  ,   4    ,   0    ,   4.8  ,   0    ,   0    ,   3.9  ,   17.1 ,   3.6  ,   0    ,   11   ,
        '6e72b'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   0    ,   0    ,   0    ,   2.9  ,   15.9 ,   12.6 ,   2.3  ,   0    ,   0    ,   0    ,   0    ,   0.9  ,   3.9  ,   7.5  ,   0    ,   3.7  ,
        '6e72c'  , 3.6  ,   1.9  ,   3.9  ,   5.7  ,   7.3  ,   6.9  ,   8.9  ,   8    ,   9.4  ,   10.6 ,   3.6  ,   6.2  ,   7.7  ,   14.4 ,   7.7  ,   9.2  ,   9.8  ,   9.3  ,   16.6 ,   10.1 ,   6.2  ,   6    ,   2.6  ,   23.7 ,   13.9 ,   2.8  ,   6.2  ,   15   ,   8.7  ,   3.2  ,   4.8  ,   5    ,   10.9 ,   12.6 ,   12   ,   10.9 ,   13.5 ,
        '6e73a'  , 38.5 ,   47.7 ,   48.1 ,   53.4 ,   43.4 ,   42.2 ,   35.3 ,   46.2 ,   45.9 ,   48   ,   40.3 ,   44   ,   39.6 ,   38.8 ,   45.6 ,   43.8 ,   58.4 ,   61.4 ,   48.2 ,   48.7 ,   52   ,   69.6 ,   55.2 ,   54.2 ,   64.9 ,   60.5 ,   53.6 ,   60.1 ,   69   ,   80.4 ,   82.8 ,   74.2 ,   78.9 ,   81.1 ,   70.8 ,   76.5 ,   90.5 ,
        '6e74a'  , 0    ,   1.6  ,   3.2  ,   5.7  ,   2    ,   2.9  ,   0    ,   4.1  ,   4.9  ,   4.9  ,   4.3  ,   4.3  ,   4    ,   3.3  ,   3    ,   3.9  ,   4.7  ,   6.7  ,   1.4  ,   0    ,   10.9 ,   16.4 ,   15.3 ,   21.7 ,   15.7 ,   12   ,   13.7 ,   7.2  ,   11.2 ,   17.3 ,   24.4 ,   41.4 ,   28   ,   24.8 ,   27.1 ,   29.5 ,   26.4 ,
        '6e74b'  , 0    ,   8.4  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   3.6  ,   4.4  ,   16.4 ,   8.8  ,   6.6  ,   9.5  ,   9.3  ,   8.7  ,   0    ,   0    ,   0    ,   0    ,   0    ,   40.2 ,   31.8 ,   41.7 ,   0    ,   0    ,   0    ,   0    ,   4.4  ,   17.1 ,   13   ,   2    ,   11.7 ,   3    ,   20.6 ,   25.3 ,   5.1  ,
        '6e75a'  , 16.5 ,   15   ,   16.8 ,   13.4 ,   12   ,   14.5 ,   15.5 ,   19.7 ,   11.4 ,   9.5  ,   11.2 ,   11.4 ,   12.4 ,   11.1 ,   12.8 ,   13.4 ,   14.2 ,   12.5 ,   18.8 ,   13.2 ,   19.6 ,   33.6 ,   29.8 ,   31.6 ,   27.6 ,   20.8 ,   12.3 ,   18.2 ,   23.1 ,   34.1 ,   29.9 ,   39.1 ,   36   ,   36.2 ,   37.8 ,   34.6 ,   32.9 ,
        '6e75b'  , 16.6 ,   12.4 ,   10.2 ,   13.6 ,   16   ,   17.4 ,   20   ,   12.8 ,   7.2  ,   8.4  ,   4.4  ,   10.8 ,   10.5 ,   8.4  ,   8.1  ,   7.1  ,   11.8 ,   5.8  ,   12.6 ,   14.1 ,   15.4 ,   15.2 ,   15.8 ,   16.5 ,   25   ,   20.1 ,   27.4 ,   10.1 ,   7.3  ,   8.1  ,   10.1 ,   15.3 ,   12.1 ,   13.3 ,   14.1 ,   27.8 ,   17.3 ,
        '6e75c'  , 18.5 ,   21.7 ,   15.9 ,   16.1 ,   25.2 ,   23.9 ,   24.6 ,   36   ,   18   ,   28.5 ,   17.6 ,   23.8 ,   27.1 ,   27.6 ,   9.6  ,   7.4  ,   1.2  ,   1.8  ,   3.6  ,   25   ,   15.6 ,   23.4 ,   21.2 ,   11.7 ,   40.5 ,   30.7 ,   34.3 ,   23.4 ,   26.5 ,   23.8 ,   36.1 ,   24.4 ,   35.8 ,   26.4 ,   20.2 ,   9.2  ,   15.4 ,
        '6e75d'  , 30   ,   24.3 ,   15.6 ,   0    ,   19.6 ,   18.5 ,   22.9 ,   23.3 ,   26.5 ,   11   ,   16.8 ,   26.2 ,   39.4 ,   13.9 ,   18.9 ,   36.1 ,   0    ,   20.6 ,   24.6 ,   40.7 ,   19.8 ,   43.9 ,   51.4 ,   31.9 ,   37.3 ,   15.6 ,   37.8 ,   31.1 ,   34.2 ,   17.8 ,   23   ,   29.4 ,   29.5 ,   32.1 ,   26.1 ,   24.4 ,   24.3 ,
        '6e76a'  , 2.8  ,   2.7  ,   3.7  ,   3.4  ,   6.1  ,   8.5  ,   7.4  ,   5    ,   2.4  ,   4.6  ,   7.2  ,   6    ,   2.9  ,   1.1  ,   3.6  ,   6    ,   3.4  ,   3.8  ,   4.3  ,   3    ,   4.2  ,   6    ,   13.9 ,   11.2 ,   8.3  ,   7    ,   7.9  ,   3.4  ,   3.4  ,   5    ,   8.1  ,   10.4 ,   9.5  ,   13   ,   10.5 ,   5.3  ,   4.8  ,
        '6e76b'  , 3    ,   3.4  ,   0    ,   0    ,   0    ,   0    ,   0    ,   4    ,   4.5  ,   8.2  ,   6    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   3.4  ,   3.2  ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   0    ,   6.4  ,   14.6 ,   3.1  ,   0    ,   0    ,   2.3  ,   0.9  ,   0    ,   2.1  ,   1.3  ,
        '6e76c'  , 4.3  ,   6    ,   4.5  ,   4    ,   3    ,   3.4  ,   14.3 ,   12.6 ,   4.1  ,   4.1  ,   6.5  ,   6.6  ,   0    ,   4.2  ,   2.7  ,   1    ,   6.4  ,   1.3  ,   0    ,   3.8  ,   6.5  ,   0    ,   19.6 ,   19.5 ,   16.4 ,   5.6  ,   14.3 ,   11.8 ,   3.1  ,   13   ,   16.5 ,   4.5  ,   4.7  ,   14.4 ,   13.4 ,   14.4 ,   15.9 ,
        '6e77a'  , 6.1  ,   13.6 ,   17.7 ,   9.6  ,   13.2 ,   13.1 ,   14   ,   12.5 ,   12.1 ,   12.2 ,   16.1 ,   16.4 ,   13.2 ,   14.3 ,   16   ,   15.3 ,   7.3  ,   10.1 ,   11.6 ,   13.2 ,   15.7 ,   17.3 ,   15.7 ,   20.5 ,   13.6 ,   5.4  ,   9.1  ,   13.2 ,   14.3 ,   6.2  ,   10   ,   9.8  ,   13.8 ,   19.3 ,   11   ,   10.2 ,   8.1  ,
        '6e77b'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   18.6 ,   14.4 ,   0    ,   0    ,   0    ,   NA   ,   0    ,   0    ,   0    ,   29.4 ,   8.2  ,   37.3 ,   0    ,   0    ,   0    ,   0    ,
        '6e77c'  , 6.5  ,   9.9  ,   8.6  ,   8.1  ,   10   ,   8.7  ,   6.4  ,   8.3  ,   5    ,   7.4  ,   5.7  ,   3.7  ,   8.1  ,   6.9  ,   5.2  ,   10.4 ,   8.2  ,   16   ,   14.7 ,   12.9 ,   11.7 ,   8    ,   7.1  ,   3.9  ,   11.5 ,   4.6  ,   11.2 ,   10.4 ,   7.5  ,   7.3  ,   8.7  ,   10.6 ,   12   ,   11.9 ,   7.6  ,   11.5 ,   10.8 ,
        '6e78a'  , 13.5 ,   4.8  ,   11.9 ,   10.8 ,   22   ,   12.3 ,   23.2 ,   25.7 ,   14.9 ,   10.9 ,   12.8 ,   10.8 ,   18.5 ,   15.5 ,   14.2 ,   10.7 ,   17.9 ,   15.7 ,   11.6 ,   24.9 ,   16   ,   31.8 ,   34.7 ,   19.5 ,   15.1 ,   20.2 ,   25.3 ,   46.1 ,   28.9 ,   32.6 ,   35.7 ,   36.2 ,   25.6 ,   12.7 ,   30.9 ,   31.6 ,   22.1 ,
        '6e78b'  , NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   NA   ,   24.8 ,   31   ,   16.3 ,   12   ,   10   ,   15.6 ,   14.2 ,   12.5 ,   31.5 ,   41   ,   42.4 ,   32.2 ,   15.2 ,   14   ,   41.9 ,   48.1 ,
        '6e78c'  , 25.2 ,   29.6 ,   22.1 ,   24.7 ,   23.5 ,   21.1 ,   25.1 ,   17.8 ,   24.6 ,   18   ,   24.9 ,   32.1 ,   27.5 ,   32.7 ,   27.3 ,   34.3 ,   34.7 ,   26.8 ,   24.2 ,   22.3 ,   30.3 ,   48.7 ,   48.4 ,   42.7 ,   50.8 ,   41.5 ,   45.4 ,   60   ,   54.9 ,   55.2 ,   43.8 ,   38.5 ,   45.7 ,   57.9 ,   71.8 ,   63.2 ,   43.6 ,
        '6e78d'  , 17.3 ,   16.5 ,   25.1 ,   18.5 ,   22   ,   20.6 ,   18   ,   16   ,   16.3 ,   22.9 ,   26.8 ,   13.8 ,   14.4 ,   18.5 ,   19.8 ,   23.2 ,   6.7  ,   14.4 ,   5.2  ,   25   ,   22.2 ,   24.5 ,   5.6  ,   5.9  ,   34.3 ,   27.5 ,   18.6 ,   28.1 ,   26   ,   36.6 ,   35.4 ,   32.1 ,   45.9 ,   34.9 ,   30.9 ,   42.4 ,   37.1 ,
        '7k11a'  , 27.9 ,   34.9 ,   30.5 ,   32.8 ,   30.1 ,   31.3 ,   30.2 ,   31.3 ,   30.7 ,   31.5 ,   29.3 ,   27.9 ,   27.3 ,   27.1 ,   27.2 ,   24.1 ,   25.6 ,   24.8 ,   27.6 ,   22.8 ,   24.6 ,   19.6 ,   21.1 ,   26.3 ,   24.7 ,   19.6 ,   12.3 ,   18.3 ,   16.4 ,   20.5 ,   19.8 ,   18.5 ,   22.6 ,   22.1 ,   22   ,   22.2 ,   21   ,
        '7k11b'  , 39.1 ,   36.1 ,   40.2 ,   40.6 ,   32.1 ,   35.1 ,   38.8 ,   37.1 ,   37.1 ,   37.3 ,   34.6 ,   35.7 ,   38.8 ,   34.4 ,   36.3 ,   37   ,   31.7 ,   31.4 ,   19.7 ,   40   ,   44.5 ,   20.3 ,   23.5 ,   19.8 ,   16.1 ,   24.2 ,   27.3 ,   12.3 ,   20.7 ,   29.2 ,   30.1 ,   27   ,   31.7 ,   24.3 ,   23.1 ,   28.1 ,   31.9 ,
        '7k11c'  , 34   ,   29.5 ,   31.7 ,   33.1 ,   31.6 ,   27.5 ,   34.6 ,   37.2 ,   37.1 ,   37.4 ,   35   ,   35.2 ,   37.3 ,   38.9 ,   36.3 ,   33.6 ,   32.1 ,   34.2 ,   27.7 ,   33.6 ,   36.7 ,   20.5 ,   23.9 ,   15.3 ,   19.4 ,   21.2 ,   21   ,   23   ,   16   ,   25   ,   25.9 ,   26.5 ,   23.1 ,   31.9 ,   20.6 ,   20.1 ,   27.8 ,
        '7k11d'  , 33.6 ,   38   ,   35.2 ,   36.4 ,   32.8 ,   38.5 ,   32   ,   35.5 ,   34.2 ,   34.6 ,   35.3 ,   30.9 ,   35   ,   34.8 ,   31.6 ,   33.8 ,   31.3 ,   33.3 ,   30   ,   29.8 ,   28.1 ,   22.2 ,   23.7 ,   26.1 ,   17.7 ,   24.5 ,   32   ,   25.1 ,   20.2 ,   16.7 ,   20.7 ,   21.1 ,   26.3 ,   28   ,   27.5 ,   29.5 ,   25.9 ,
        '7k11e'  , 34.5 ,   45.4 ,   47.4 ,   39.4 ,   37.3 ,   38.4 ,   39.4 ,   37.5 ,   38.9 ,   43.7 ,   37.4 ,   37.3 ,   34   ,   41.1 ,   39.8 ,   38.5 ,   35.9 ,   38.3 ,   30.3 ,   41.8 ,   25.7 ,   19.5 ,   19.1 ,   17.3 ,   31.9 ,   40.3 ,   7.7  ,   17.6 ,   24.9 ,   13.8 ,   17.9 ,   25.8 ,   21.1 ,   33.4 ,   24.4 ,   19.1 ,   27.4 ,
        '7k11f'  , 36   ,   36.5 ,   38.1 ,   37.4 ,   36.9 ,   37.2 ,   37.5 ,   35.6 ,   34.2 ,   34.7 ,   35.3 ,   37.8 ,   34   ,   32.2 ,   33.1 ,   32.9 ,   33.2 ,   31.7 ,   30.6 ,   31.9 ,   32   ,   20.7 ,   19.5 ,   19.6 ,   20   ,   23.5 ,   24.6 ,   26.2 ,   23.4 ,   12.9 ,   27.8 ,   28   ,   26.2 ,   24   ,   24.6 ,   23.2 ,   21.2 ,
        '7k12a'  , 36.1 ,   35.6 ,   36.3 ,   41.1 ,   35.2 ,   32.3 ,   33.2 ,   32.4 ,   34.5 ,   32.7 ,   42.3 ,   39.8 ,   42.4 ,   40.3 ,   27.8 ,   32.1 ,   31.1 ,   43   ,   40.8 ,   35.4 ,   34.4 ,   35.5 ,   35.5 ,   34.4 ,   38   ,   45.6 ,   18.4 ,   18.8 ,   20.9 ,   44.1 ,   26.8 ,   4.9  ,   30.3 ,   34   ,   25.3 ,   12.6 ,   23.2 ,
        '7k12b'  , 21.1 ,   18.7 ,   33.9 ,   27   ,   39.4 ,   43.3 ,   44.6 ,   40.4 ,   46.6 ,   32.6 ,   29.6 ,   37   ,   45   ,   50.5 ,   60.9 ,   36.9 ,   26.1 ,   15.1 ,   51.9 ,   38.7 ,   27.2 ,   100  ,   NA   ,   0    ,   0    ,   NA   ,   100  ,   100  ,   NA   ,   100  ,   45.6 ,   30.9 ,   34.6 ,   45.3 ,   40.8 ,   43.2 ,   28.7 ,
        '7k12c'  , 27.7 ,   27.1 ,   25   ,   22.2 ,   33.9 ,   39.8 ,   36.7 ,   31.9 ,   31.9 ,   35.4 ,   32.7 ,   26.2 ,   28.5 ,   35.9 ,   40.5 ,   38.9 ,   46.8 ,   40.4 ,   37   ,   33.6 ,   33   ,   14.2 ,   29.6 ,   2.6  ,   4.3  ,   11.5 ,   30.2 ,   36.2 ,   41.3 ,   36.1 ,   29.6 ,   27.1 ,   24.1 ,   19.8 ,   37.5 ,   23.4 ,   29.5 ,
        '7k12d'  , 39.8 ,   40.4 ,   39.3 ,   41.8 ,   41.5 ,   40.7 ,   35.7 ,   37.3 ,   38.9 ,   39.9 ,   39.3 ,   37.2 ,   39.4 ,   35.8 ,   36.2 ,   36.6 ,   40.9 ,   34.6 ,   37.1 ,   37.7 ,   35.3 ,   29.6 ,   35.2 ,   27.8 ,   40.3 ,   34.2 ,   31.8 ,   25.2 ,   31.5 ,   30.5 ,   27.6 ,   28   ,   28.9 ,   32.3 ,   26.4 ,   27.9 ,   32.2 ,
        '7k12e'  , 40.3 ,   43.5 ,   27.4 ,   42.5 ,   42.1 ,   44.9 ,   36   ,   37.4 ,   52.6 ,   58.2 ,   40.7 ,   47.9 ,   43.9 ,   22.1 ,   51.9 ,   30.5 ,   52.2 ,   23.8 ,   53.5 ,   58.4 ,   42.2 ,   0    ,   0    ,   12.4 ,   30.9 ,   100  ,   82.1 ,   47.2 ,   43.7 ,   32.4 ,   38.8 ,   19.9 ,   90.2 ,   78.4 ,   80.4 ,   NA   ,   12.2 ,
        '7k12f'  , 40.6 ,   40.7 ,   41.6 ,   39.1 ,   38.3 ,   35.9 ,   39.1 ,   37.7 ,   39.1 ,   39.1 ,   41.3 ,   41.2 ,   37.6 ,   38.4 ,   37.7 ,   36.3 ,   33.6 ,   35.7 ,   36.1 ,   38.5 ,   36.2 ,   32   ,   39   ,   56.1 ,   35.3 ,   25.2 ,   41.5 ,   29.7 ,   18   ,   14.4 ,   28.5 ,   34.2 ,   26.6 ,   37.4 ,   16.8 ,   21.1 ,   11.9 ,
        '7k12g'  , 4.5  ,   21.1 ,   4.5  ,   18.9 ,   11   ,   13.7 ,   17.8 ,   5.6  ,   29.8 ,   16.2 ,   20.7 ,   9.9  ,   0    ,   19.7 ,   9.2  ,   11.2 ,   12.7 ,   0    ,   17.4 ,   8.3  ,   3.4  ,   37.4 ,   35.4 ,   22   ,   16.1 ,   28.3 ,   15.5 ,   14   ,   26   ,   15.5 ,   11.5 ,   8.3  ,   15.7 ,   9.1  ,   17.6 ,   17.2 ,   15.4 ,
        '7k12h'  , 7.1  ,   10.5 ,   9.9  ,   5.9  ,   12.5 ,   7.4  ,   6.4  ,   5.7  ,   6.4  ,   5.5  ,   4.6  ,   7.6  ,   8.7  ,   4    ,   8.1  ,   11.2 ,   5.3  ,   12.3 ,   3    ,   5.6  ,   4.2  ,   2.9  ,   15.6 ,   2    ,   4.3  ,   8.4  ,   23.4 ,   19.6 ,   1    ,   16.5 ,   6.8  ,   4.8  ,   0    ,   0.2  ,   0.5  ,   1.9  ,   7.4  ,
        '7k12i'  , 21.1 ,   20.4 ,   13.4 ,   19.9 ,   3.1  ,   21.3 ,   13.5 ,   18.3 ,   21.3 ,   23.1 ,   24   ,   22.9 ,   25.3 ,   28.8 ,   21.6 ,   26   ,   20.7 ,   25   ,   8.5  ,   6.4  ,   17.8 ,   30.4 ,   20.6 ,   14.3 ,   15.8 ,   12.7 ,   18.9 ,   16.2 ,   11.7 ,   22.2 ,   27.3 ,   26.7 ,   30.7 ,   23.2 ,   32.3 ,   21.3 ,   0    ,
        '7k13a'  , 40.7 ,   41.3 ,   44.1 ,   43.2 ,   44.8 ,   37.4 ,   39.5 ,   39.2 ,   43.3 ,   36.7 ,   45.1 ,   50.5 ,   46.4 ,   50.6 ,   44.5 ,   44.3 ,   43.2 ,   42.7 ,   45.7 ,   38   ,   43.1 ,   44.2 ,   47.3 ,   30.8 ,   29.9 ,   33   ,   41   ,   41.4 ,   35.8 ,   35.7 ,   37.4 ,   32.1 ,   20   ,   22   ,   24.9 ,   23.6 ,   23.2 ,
        '7k13b'  , 44.8 ,   39.6 ,   37.7 ,   40.6 ,   42   ,   41   ,   43.2 ,   39.9 ,   36.2 ,   41   ,   41.8 ,   35.8 ,   43.8 ,   57.8 ,   47.8 ,   46.1 ,   31.4 ,   39.9 ,   28.2 ,   36.8 ,   34.8 ,   30.2 ,   50.9 ,   53   ,   37.7 ,   52.9 ,   48.1 ,   17.7 ,   33.7 ,   27.6 ,   31.6 ,   42.5 ,   42.9 ,   34.6 ,   32.4 ,   42.7 ,   53.8 ,
        '7k13c'  , 29.7 ,   34.7 ,   30.3 ,   29.1 ,   32.9 ,   32.6 ,   37.1 ,   42.9 ,   37.4 ,   44.2 ,   44.5 ,   47.5 ,   47.4 ,   47.5 ,   48.6 ,   51.8 ,   38.6 ,   43.9 ,   48.5 ,   40.6 ,   43.7 ,   45.2 ,   44.9 ,   50.2 ,   40.4 ,   37.5 ,   31.6 ,   35.9 ,   32.8 ,   33   ,   33   ,   33   ,   41.7 ,   37.8 ,   31.3 ,   33.3 ,   28   ,
        '7k13d'  , 43.4 ,   44   ,   42.4 ,   45.2 ,   40.9 ,   41.6 ,   43.8 ,   44.5 ,   44.1 ,   46.2 ,   47.6 ,   53.6 ,   53.4 ,   52.9 ,   51.6 ,   53.2 ,   43.4 ,   45.3 ,   39.5 ,   40.6 ,   41.5 ,   52.2 ,   45.8 ,   40.4 ,   37.6 ,   35.4 ,   46.1 ,   44.5 ,   38.8 ,   37.6 ,   37.1 ,   36.6 ,   39.5 ,   33.8 ,   37.1 ,   33.2 ,   24.2 ,
        '7k13e'  , 51   ,   48.7 ,   53.9 ,   48.9 ,   55   ,   35   ,   35.9 ,   38   ,   29.6 ,   52.5 ,   50.7 ,   54.7 ,   43.1 ,   48.2 ,   57   ,   47.4 ,   35.1 ,   44.8 ,   51.3 ,   71.6 ,   70.7 ,   46.5 ,   46.4 ,   48.4 ,   45.7 ,   36.4 ,   36.6 ,   42.7 ,   48.5 ,   46.9 ,   46.7 ,   44.7 ,   43.4 ,   52.9 ,   53.4 ,   41.8 ,   36.2 ,
        '7k13f'  , 41.4 ,   42.6 ,   43.3 ,   41.4 ,   42.3 ,   40.2 ,   38.2 ,   41.5 ,   39.2 ,   43.2 ,   40.7 ,   41.2 ,   41   ,   41.5 ,   41.3 ,   46.3 ,   45.1 ,   47.1 ,   45.4 ,   37.5 ,   38.9 ,   44   ,   47.9 ,   38.3 ,   43.3 ,   42.6 ,   34.7 ,   22.7 ,   39.4 ,   40.9 ,   30.3 ,   31   ,   27.8 ,   19.6 ,   23.2 ,   27.1 ,   31   ,
        '7k20a'  , 4.8  ,   0    ,   1    ,   2.8  ,   4.4  ,   3.4  ,   5    ,   4.9  ,   0    ,   2    ,   0    ,   2.5  ,   0    ,   0    ,   0    ,   0    ,   0    ,   1.9  ,   1.7  ,   5.5  ,   3.6  ,   1.1  ,   1.2  ,   1.3  ,   7.1  ,   5.1  ,   0    ,   0    ,   0    ,   3.5  ,   3.6  ,   0    ,   0    ,   0    ,   0    ,   0    ,   2.6  ,
        '7k20b'  , 18.7 ,   19.5 ,   19.1 ,   9    ,   21.5 ,   22.8 ,   20.8 ,   16.2 ,   19   ,   25.2 ,   28.3 ,   32.1 ,   22.3 ,   26.6 ,   26.5 ,   25.9 ,   26.1 ,   29   ,   29.3 ,   33.2 ,   30.4 ,   30.1 ,   42   ,   39.6 ,   27   ,   37.8 ,   26.5 ,   34.2 ,   32.8 ,   35.7 ,   35.5 ,   32.8 ,   29.7 ,   35.7 ,   31.9 ,   38.8 ,   38   ,
        '7k20c'  , 26   ,   24.1 ,   25.6 ,   30.5 ,   35.9 ,   39.7 ,   34.5 ,   32.3 ,   32.1 ,   35.7 ,   37.8 ,   38.9 ,   32.8 ,   35.6 ,   36.1 ,   36.6 ,   36.3 ,   43.5 ,   47.4 ,   42.8 ,   42.8 ,   36.8 ,   50.7 ,   44.2 ,   46.6 ,   44.8 ,   52.7 ,   43.3 ,   41.2 ,   43.6 ,   40.9 ,   40.6 ,   35.4 ,   40.7 ,   42.1 ,   53.8 ,   42.8 ,
        '7k20d'  , 29.6 ,   23.3 ,   24.6 ,   33.4 ,   28.1 ,   37.1 ,   30.9 ,   38.8 ,   29.1 ,   33   ,   29.2 ,   30.1 ,   30   ,   27.8 ,   27.4 ,   26.8 ,   27.2 ,   26   ,   30.4 ,   30.9 ,   28.4 ,   32.2 ,   34.2 ,   37.3 ,   34.8 ,   38.1 ,   38.9 ,   32.7 ,   35.8 ,   41.8 ,   39.7 ,   32.9 ,   30.7 ,   34.6 ,   29.7 ,   27.7 ,   29   ,
        '7k20e'  , 35   ,   16.9 ,   13.5 ,   13.1 ,   15.1 ,   17.9 ,   14.6 ,   13.7 ,   16.6 ,   19.1 ,   17.3 ,   18.3 ,   17.3 ,   11   ,   20.5 ,   23.9 ,   19.4 ,   16.8 ,   15.5 ,   17.5 ,   20.7 ,   20.8 ,   21.5 ,   24.5 ,   27.2 ,   32.1 ,   26.8 ,   24.9 ,   22.2 ,   22.4 ,   23.2 ,   20   ,   22   ,   20.9 ,   19   ,   18   ,   21.9 ,
        '7k20f'  , 2.1  ,   0    ,   0    ,   3.9  ,   3.5  ,   1.8  ,   0    ,   1.4  ,   2.5  ,   3.5  ,   4.4  ,   2.3  ,   0    ,   5.4  ,   2    ,   1.7  ,   2.2  ,   1.7  ,   2.2  ,   0    ,   0    ,   3.8  ,   7.5  ,   9.1  ,   0.2  ,   0    ,   0.4  ,   1.5  ,   0.3  ,   1.8  ,   0    ,   1.8  ,   1.4  ,   1.8  ,   2.9  ,   2.7  ,   0    ,
        '7k20g'  , 15.9 ,   21.8 ,   20   ,   13.8 ,   17.8 ,   13.2 ,   10.8 ,   10.5 ,   11.3 ,   15.6 ,   15.8 ,   16.3 ,   16   ,   6.7  ,   16   ,   22.4 ,   25.8 ,   20   ,   12.7 ,   13.9 ,   16.2 ,   11.8 ,   15.4 ,   6.3  ,   16.1 ,   10.9 ,   8.6  ,   19.1 ,   6.3  ,   19.6 ,   17   ,   6.1  ,   13.9 ,   16.5 ,   10.9 ,   7.3  ,   3.1  
      ) %>% 
        dplyr::mutate(chiffre = stringr::str_to_upper(chiffre)) %>% 
        dplyr::select(chiffre, tidyselect::all_of(sexeEE)) %>% 
        dplyr::rowwise() %>% 
        dplyr::mutate(fem_pct = mean(dplyr::c_across(tidyselect::all_of(sexeEE)), na.rm = TRUE)) %>% 
        dplyr::select(chiffre, fem_pct)
      
      
      PPP1_to_name <- PR_fem_to_PR_name(PPP1_to_name, PPP1_fem)
      PPP2_to_name <- PR_fem_to_PR_name(PPP2_to_name, PPP2_fem)
      PPP3_to_name <- PR_fem_to_PR_name(PPP3_to_name, PPP3_fem)
      
      
      # Female and male names based on a user's provided variable ------------------------
    } else { #If non missing sexe
      
      data_new <- dplyr::mutate(
        data_new, 
        PPP1 = forcats::fct_relabel(PPP4, ~ stringr::str_sub(., 1, 1)) %>% 
          forcats::fct_relevel(sort),
        PPP2 = forcats::fct_relabel(PPP4, ~ stringr::str_sub(., 1, 3)) %>% 
          forcats::fct_relevel(sort),
        PPP3 = forcats::fct_relabel(PPP4, ~ stringr::str_sub(., 1, 4)) %>% 
          forcats::fct_relevel(sort)
      )
      
      if (!"SEXE_WT" %in% names(data_new)) {
        data_new <- data_new %>% dplyr::mutate(SEXE_WT = 1)
      }
      
      PPP1_fem <- 
        tabxplor::tab(data_new, PPP1, SEXE, wt = SEXE_WT, na = "drop", pct = "row",
                      tot = "col", totaltab = "no") %>%
        dplyr::select(-tidyselect::matches(stringr::regex("masc|hom|^man|^men|tot", 
                                                          ignore_case = TRUE))) %>% 
        dplyr::mutate(dplyr::across(where(tabxplor::is_fmt), ~ round(as.double(.) * 100, 1))) %>% 
        dplyr::rename_with(
          ~dplyr::if_else(stringr::str_detect(., stringr::regex("fem|fém|wom", 
                                                                ignore_case = TRUE)),
                          true  = rep("fem_pct", length(.)), 
                          false = .)
        ) %>% 
        dplyr::rename(chiffre = PPP1)
      
      PPP2_fem <- 
        tabxplor::tab(data_new, PPP2, SEXE, wt = SEXE_WT, na = "drop", pct = "row",
                      tot = "col", totaltab = "no") %>%
        dplyr::select(-tidyselect::matches(stringr::regex("masc|hom|^man|^men|tot", 
                                                   ignore_case = TRUE))) %>% 
        dplyr::mutate(dplyr::across(where(tabxplor::is_fmt), ~ round(as.double(.) * 100, 1))) %>% 
        dplyr::rename_with(
          ~dplyr::if_else(stringr::str_detect(., stringr::regex("fem|fém|wom", 
                                                                ignore_case = TRUE)),
                          true  = rep("fem_pct", length(.)), 
                          false = .)
        ) %>% 
        dplyr::rename(chiffre = PPP2)
      
      PPP3_fem <- 
        tabxplor::tab(data_new, PPP3, SEXE, wt = SEXE_WT, na = "drop", pct = "row",
                      tot = "col", totaltab = "no") %>%
        dplyr::select(-tidyselect::matches(stringr::regex("masc|hom|^man|^men|tot", 
                                                   ignore_case = TRUE))) %>% 
        dplyr::mutate(dplyr::across(where(tabxplor::is_fmt), ~ round(as.double(.) * 100, 1))) %>% 
        dplyr::rename_with(
          ~dplyr::if_else(stringr::str_detect(., stringr::regex("fem|fém|wom", 
                                                                ignore_case = TRUE)),
                          true  = rep("fem_pct", length(.)), 
                          false = .)
        ) %>% 
        dplyr::rename(chiffre = PPP3)
      
      PPP1_to_name <- PR_fem_to_PR_name(PPP1_to_name, PPP1_fem)
      PPP2_to_name <- PR_fem_to_PR_name(PPP2_to_name, PPP2_fem)
      PPP3_to_name <- PR_fem_to_PR_name(PPP3_to_name, PPP3_fem)
      
    }
    
    if (!gender_sign | masculiniser) {
      PPP1_to_name <- PPP1_to_name %>% 
        stringr::str_remove_all(stringr::str_c(f, m, collapse = "|")) %>% 
        stringr::str_squish() %>% purrr::set_names(names(PPP1_to_name))
      
      PPP2_to_name <- PPP2_to_name %>% 
        stringr::str_remove_all(stringr::str_c(f, m, collapse = "|")) %>% 
        stringr::str_squish() %>% purrr::set_names(names(PPP2_to_name))
      
      PPP3_to_name <- PPP3_to_name %>% 
        stringr::str_remove_all(stringr::str_c(f, m, collapse = "|")) %>% 
        stringr::str_squish() %>% purrr::set_names(names(PPP3_to_name))
      
      PPP4_to_name <- PPP4_to_name %>% 
        stringr::str_remove_all(stringr::str_c(f, m, collapse = "|")) %>% 
        stringr::str_squish() %>% purrr::set_names(names(PPP4_to_name))
    }
    
    
    # Creates all variables by renaming PPP4's levels -------------------------------------
    
    # data_new <- data_new %>%
    #   mutate(PPP1   = factor(NA, levels(data_ok$PPP1)),
    #          FAPPP = factor(NA, levels(data_ok$FAPPP)),
    #          PPP2   = factor(NA, levels(data_ok$PPP2)),
    #          PPP3   = factor(NA, levels(data_ok$PPP3)),
    #          PPP4   = factor(NA, levels(data_ok$PPP4))) %>% 
    #   select(-EMP)
    
    # BOOM !
    #data_new[!is.na(data_new$PROF),] <- data_ok
    
    data_new <- data_new %>% 
      dplyr::mutate(
        # PPP1 = forcats::fct_relabel(PPP4, ~ tidyr::replace_na(purrr::set_names(
        #   paste0(PPP1_to_name$chiffre, "-", PPP1_to_name$fem), PPP1_to_name$chiffre
        # )[stringr::str_sub(., 1, 1)], "NULL")) %>% forcats::fct_relevel(sort),
        # PPP2 = forcats::fct_relabel(PPP4, ~ tidyr::replace_na(purrr::set_names(
        #   paste0(PPP2_to_name$chiffre, "-", PPP2_to_name$fem), PPP2_to_name$chiffre
        # )[stringr::str_sub(., 1, 3)], "NULL")) %>% forcats::fct_relevel(sort),
        # PPP3 = forcats::fct_relabel(PPP4, ~ tidyr::replace_na(purrr::set_names(
        #   paste0(PPP3_to_name$chiffre, "-", PPP3_to_name$fem), PPP3_to_name$chiffre
        # )[stringr::str_sub(., 1, 4)], "NULL")) %>% forcats::fct_relevel(sort),
        
        PPP1 = forcats::fct_relabel(PPP4, ~ tidyr::replace_na(PPP1_to_name[stringr::str_sub(., 1, 1)], "NULL")) %>% 
          forcats::fct_relevel(sort),
        FAPPP = forcats::fct_relabel(PPP4, ~ tidyr::replace_na(FAPPP_to_name[stringr::str_sub(., 2, 2)], "NULL"))  %>% 
          forcats::fct_relevel(sort),
        PPP2 = forcats::fct_relabel(PPP4, ~ tidyr::replace_na(PPP2_to_name[stringr::str_sub(., 1, 3)], "NULL")) %>% 
          forcats::fct_relevel(sort),
        PPP3 = forcats::fct_relabel(PPP4, ~ tidyr::replace_na(PPP3_to_name[stringr::str_sub(., 1, 4)], "NULL")) %>% 
          forcats::fct_relevel(sort),
        PPP4 = forcats::fct_relabel(PPP4, ~ tidyr::replace_na(PPP4_to_name[stringr::str_sub(., 1, 5)], "NULL")) %>% 
          forcats::fct_relevel(sort),
      ) %>% 
      dplyr::select(PPP1, FAPPP, PPP2, PPP3, PPP4)
    
    data %>% 
      dplyr::select(-tidyselect::any_of(c("PPP1", "FAPPP", "PPP2", "PPP3", "PPP4"))) %>%
      dplyr::bind_cols(data_new)
  }











# PCS to FAP -----------------------------------------------------------------------------


# PCS2003toFAP <- 
# c(
# "111a","111f","121a","121f","122a","131a","131f"        =   "A0Z00",
# "111d","111e","121d","121e","131d","131e"               =   "A0Z01",
# "122b"                                                  =   "A0Z02",
# "100x","691e"                                           =   "A0Z40",
# "691b"                                                  =   "A0Z41",
# "533b","691f"                                           =   "A0Z42",
# "691a"                                                  =   "A0Z43",
# "111b","121b","131b"                                    =   "A1Z00",
# "111c","121c","131c"                                    =   "A1Z01",
# "691c"                                                  =   "A1Z40",
# "631a"                                                  =   "A1Z41",
# "691d"                                                  =   "A1Z42",
# "471a","471b","480a"                                    =   "A2Z70",
# "381a","381b","381c"                                    =   "A2Z90",
# "122c"                                                  =   "A3Z00",
# "692a"                                                  =   "A3Z40",
# "656a","656b","656c"                                    =   "A3Z41",
# "389c","480b"                                           =   "A3Z90",
# "671a","671b","671c","671d"                             =   "B0Z20",
# "681a"                                                  =   "B0Z21",
# "211h","621a","621b","621d","621e","621f","621g"        =   "B1Z40",
# "211a","632a"                                           =   "B2Z40",
# "214d","632b"                                           =   "B2Z41",
# "624d"                                                  =   "B2Z42",
# "632c"                                                  =   "B2Z43",
# "211c","632e"                                           =   "B2Z44",
# "681b"                                                  =   "B3Z20",
# "211d","632f"                                           =   "B4Z41",
# "211b","632d","632j"                                    =   "B4Z42",
# "211e","633a"                                           =   "B4Z43",
# "211f","632g","632h"                                    =   "B4Z44",
# "621c","651a"                                           =   "B5Z40",
# "472b"                                                  =   "B6Z70",
# "211j","472c","472d"                                    =   "B6Z71",
# "472a"                                                  =   "B6Z72",
# "481a","481b"                                           =   "B6Z73",
# "312f","382b"                                           =   "B7Z90",
# "382a","382c"                                           =   "B7Z91",
# "672a"                                                  =   "C0Z20",
# "622a","622b","622c","622d","622e","622f","622g"        =   "C1Z40",
# "473b","473c"                                           =   "C2Z70",
# "473a"                                                  =   "C2Z71",
# "482a"                                                  =   "C2Z80",
# "673a","673b"                                           =   "D0Z20",
# "628c","628d"                                           =   "D1Z40",
# "623f","623g"                                           =   "D1Z41",
# "211g","212b","623a","634b"                             =   "D2Z40",
# "623b"                                                  =   "D2Z41",
# "623c","623d","623e"                                    =   "D2Z42",
# "673c","682a"                                           =   "D3Z20",
# "624a","624b","624c","624e","624g"                      =   "D4Z40",
# "624f"                                                  =   "D4Z41",
# "474b","474c"                                           =   "D6Z70",
# "474a"                                                  =   "D6Z71",
# "212c","212d","483a"                                    =   "D6Z80",
# "674a"                                                  =   "E0Z20",
# "674b","674c"                                           =   "E0Z21",
# "674d"                                                  =   "E0Z22",
# "674e"                                                  =   "E0Z23",
# "676e"                                                  =   "E0Z24",
# "625a","626a"                                           =   "E1Z40",
# "625c"                                                  =   "E1Z41",
# "625e","625f","625g"                                    =   "E1Z42",
# "625h","626b","637a"                                    =   "E1Z43",
# "626c"                                                  =   "E1Z44",
# "479a","625b","628f"                                    =   "E1Z46",
# "628g"                                                  =   "E1Z47",
# "475a","475b","485a"                                    =   "E2Z70",
# "484a","484b"                                           =   "E2Z80",
# "675a"                                                  =   "F0Z20",
# "627a","627b","627c"                                    =   "F1Z40",
# "213a","635a"                                           =   "F1Z41",
# "675b"                                                  =   "F2Z20",
# "214a","214b"                                           =   "F3Z40",
# "627d"                                                  =   "F3Z41",
# "675c"                                                  =   "F4Z20",
# "214c","627e","627f"                                    =   "F4Z41",
# "476a","476b","485b"                                    =   "F5Z70",
# "628a","634d"                                           =   "G0A40",
# "628b","633d"                                           =   "G0A41",
# "216c","633b"                                           =   "G0A42",
# "632k"                                                  =   "G0A43",
# "216b","634a"                                           =   "G0B40",
# "212a","216a","633c","634c"                             =   "G0B41",
# "477b","477c","477d","486a","486b","486c","486d"        =   "G1Z70",
# "479b"                                                  =   "G1Z71",
# "486e"                                                  =   "G1Z80",
# "380a","383b","384b","385b","386d","386e"               =   "H0Z90",
# "387e","387f"                                           =   "H0Z91",
# "387c","387d"                                           =   "H0Z92",
# "676a","676b","676c","676d"                             =   "J0Z20",
# "652a","652b","653a"                                    =   "J1Z40",
# "487a","487b"                                           =   "J1Z80",
# "217a","526e","642a","642b"                             =   "J3Z40",
# "641b"                                                  =   "J3Z41",
# "643a","644a"                                           =   "J3Z42",
# "217b","218a","641a"                                    =   "J3Z43",
# "651b","654a","654b","654c"                             =   "J3Z44",
# "655a"                                                  =   "J4Z40",
# "546a"                                                  =   "J4Z60",
# "466c","477a"                                           =   "J4Z80",
# "546d","546e"                                           =   "J5Z60",
# "546c"                                                  =   "J5Z61",
# "546b"                                                  =   "J5Z62",
# "226b","466a","466b"                                    =   "J5Z80",
# "389a","451d"                                           =   "J6Z90",
# "389b"                                                  =   "J6Z91",
# "387b"                                                  =   "J6Z92",
# "685a"                                                  =   "K0Z20",
# "210x","214e","214f","217d","637b","637d"               =   "K0Z40",
# "542a","542b"                                           =   "L0Z60",
# "543a","543b","543c"                                    =   "L1Z60",
# "313a","541a","541b","541c","541d"                      =   "L2Z60",
# "543d","543e","543f","543g","543h"                      =   "L2Z61",
# "461a","461b","461c"                                    =   "L3Z80",
# "461e","461f"                                           =   "L4Z80",
# "461d"                                                  =   "L4Z81",
# "312c","312d","372a","372b","373a","373b","373c","373d" =   "L5Z90",
# "372e"                                                  =   "L5Z91",
# "372c","372d"                                           =   "L5Z92",
# "232a","233a","233b","233c","233d"                      =   "L6Z00",
# "231a","371a"                                           =   "L6Z90",
# "544a"                                                  =   "M0Z60",
# "478a"                                                  =   "M1Z80",
# "478b","478c","478d"                                    =   "M1Z81",
# "388a","388c"                                           =   "M2Z90",
# "388b"                                                  =   "M2Z91",
# "388e"                                                  =   "M2Z92",
# "312e","383a","384a","385a","386a","386b","386c"        =   "N0Z90",
# "342e","342f","342g","342h"                             =   "N0Z91",
# "522a"                                                  =   "P0Z60",
# "523a","523b","523c","523d","524a","524b","524c","524d" =   "P0Z61",
# "533c"                                                  =   "P0Z61",
# "521a","521b"                                           =   "P0Z62",
# "451c"                                                  =   "P1Z80",
# "451e","451f","451g","451h"                             =   "P1Z81",
# "451a","451b"                                           =   "P1Z82",
# "331a","332a","332b","333b","333e","333f","351a"        =   "P2Z90",
# "333c","333d"                                           =   "P2Z91",
# "334a"                                                  =   "P2Z92",
# "312a","312b","312g"                                    =   "P3Z90",
# "333a"                                                  =   "P3Z91",
# "531a","531c","532a","532b","532c","533a"               =   "P4Z60",
# "531b"                                                  =   "P4Z61",
# "452a","452b"                                           =   "P4Z80",
# "545a","545b","545c","545d"                             =   "Q0Z60",
# "467a","467b"                                           =   "Q1Z80",
# "467c","467d"                                           =   "Q1Z81",
# "376a","376b","376c","376d"                             =   "Q2Z90",
# "226a","376e","376f"                                    =   "Q2Z91",
# "551a"                                                  =   "R0Z60",
# "552a","554j"                                           =   "R0Z61",
# "219a","554a"                                           =   "R1Z60",
# "554b","554c"                                           =   "R1Z61",
# "554d","554e","554f","554g"                             =   "R1Z62",
# "556a"                                                  =   "R1Z63",
# "553a","553b","553c","554h"                             =   "R1Z66",
# "555a"                                                  =   "R1Z67",
# "225a","463a","463b","463c","463d"                      =   "R2Z80",
# "463e"                                                  =   "R2Z83",
# "220x","222a","222b","223a","223b","223c","223d","223e" =   "R3Z80",
# "223f","223g","223h","462a","462b","462d"               =   "R3Z80",
# "221a","221b"                                           =   "R3Z81",
# "462c","462e"                                           =   "R3Z82",
# "374b","374c","374d"                                    =   "R4Z90",
# "382d","383c","384c","385c","387a","388d"               =   "R4Z91",
# "374a"                                                  =   "R4Z92",
# "226c","376g"                                           =   "R4Z93",
# "215d","683a"                                           =   "S0Z20",
# "215b","625d","636a"                                    =   "S0Z40",
# "215c","636b"                                           =   "S0Z41",
# "215a","636c"                                           =   "S0Z42",
# "561d"                                                  =   "S1Z20",
# "636d"                                                  =   "S1Z40",
# "488a"                                                  =   "S1Z80",
# "561e","561f"                                           =   "S2Z60",
# "561a","561b","561c"                                    =   "S2Z61",
# "468a"                                                  =   "S2Z80",
# "468b"                                                  =   "S2Z81",
# "224a","224b","224c","224d"                             =   "S3Z00",
# "377a","488b"                                           =   "S3Z90",
# "217c","562a","562b"                                    =   "T0Z60",
# "563c"                                                  =   "T1Z60",
# "563b"                                                  =   "T2A60",
# "563a"                                                  =   "T2B60",
# "564a"                                                  =   "T3Z60",
# "534a","534b"                                           =   "T3Z61",
# "217e","525a","525b","525c","684a"                      =   "T4Z60",
# "525d"                                                  =   "T4Z61",
# "628e","684b"                                           =   "T4Z62",
# "227c","227d","564b"                                    =   "T6Z61",
# "464a"                                                  =   "U0Z80",
# "464b"                                                  =   "U0Z81",
# "375a","375b"                                           =   "U0Z90",
# "372f","425a"                                           =   "U0Z91",
# "352a","353a"                                           =   "U0Z92",
# "353b","353c","465b","637c"                             =   "U1Z80",
# "465c"                                                  =   "U1Z81",
# "465a"                                                  =   "U1Z82",
# "354b","354c","354d","354e","354f","354g"               =   "U1Z91",
# "352b"                                                  =   "U1Z92",
# "354a"                                                  =   "U1Z93",
# "526a","526b","526c","526d"                             =   "V0Z60",
# "431a","431b","431c","431d","431f","431g"               =   "V1Z80",
# "431e"                                                  =   "V1Z81",
# "311a","311b","344a","344b","344c"                      =   "V2Z90",
# "311c"                                                  =   "V2Z91",
# "311e"                                                  =   "V2Z92",
# "311f","344d"                                           =   "V2Z93",
# "433a","433d"                                           =   "V3Z70",
# "433b","433c"                                           =   "V3Z71",
# "432a","432b","432c","432d"                             =   "V3Z80",
# "311d"                                                  =   "V3Z90",
# "343a"                                                  =   "V4Z80",
# "434a","434d","434e","434f","434g"                      =   "V4Z83",
# "434b","434c"                                           =   "V4Z85",
# "227a"                                                  =   "V5Z00",
# "435a","435b"                                           =   "V5Z81",
# "424a"                                                  =   "V5Z82",
# "422d","422e"                                           =   "V5Z84",
# "421a","421b"                                           =   "W0Z80",
# "341a","422a","422b","422c"                             =   "W0Z90",
# "227b","341b"                                           =   "W0Z91",
# "342a","342b","342c","342d"                             =   "W0Z92",
# "423a","423b"                                           =   "W1Z80",
# "335a"                                                  =   "X0Z00",
# "441a","441b"                                           =   "X0Z01"
# )



#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

# Rlang .data to bind data masking variable in dplyr
#' @keywords internal
#' @importFrom rlang .data
NULL

# binding for global variables not found by R cmd check
. = NULL
where = NULL
globalVariables(c(":="))



#Table des correspondances PCS2003 / PCSPP -----------------------------------------------


# c(
#   "NA"                                                                                                                            = "0000-Non renseigné", 
#   "7K13a-Agriculteurs sur petite exploitation de céréales-grandes cultures"                                                       = "111a-Agriculteurs sur petite exploitation de céréales-grandes cultures", 
#   "7K13b-Maraîcher·es, horticult·rices sur petite exploitation"                                                                   = "111b-Maraîchers, horticulteurs sur petite exploitation", 
#   "7K13c-Viticult·rices, arboricult·rices fruitier·es, sur petite exploitation"                                                   = "111c-Viticulteurs, arboriculteurs fruitiers, sur petite exploitation", 
#   "7K13d-Éleveu·ses d’herbivores, sur petite exploitation"                                                                        = "111d-Éleveurs d’herbivores, sur petite exploitation", 
#   "7K13e-Éleveu·ses de granivores et éleveu·ses mixtes, sur petite exploitation"                                                  = "111e-Éleveurs de granivores et éleveurs mixtes, sur petite exploitation", 
#   "7K13f-Agriculteurs sur petite exploitation sans orientation dominante"                                                         = "111f-Agriculteurs sur petite exploitation sans orientation dominante", 
#   "7K12a-Agriculteurs sur moyenne exploitation de céréales grandes cultures"                                                      = "121a-Agriculteurs sur moyenne exploitation de céréales grandes cultures", 
#   "7K12b-Maraîcher·es, horticult·rices sur moyenne exploitation"                                                                  = "121b-Maraîchers, horticulteurs sur moyenne exploitation", 
#   "7K12c-Viticulteurs, arboriculteurs fruitiers, sur moyenne exploitation"                                                        = "121c-Viticulteurs, arboriculteurs fruitiers, sur moyenne exploitation", 
#   "7K12d-Éleveurs d’herbivores sur moyenne exploitation"                                                                          = "121d-Éleveurs d’herbivores sur moyenne exploitation", 
#   "7K12e-Éleveu·ses de granivores et éleveurs mixtes, sur moyenne exploitation"                                                   = "121e-Éleveurs de granivores et éleveurs mixtes, sur moyenne exploitation", 
#   "7K12f-Agriculteurs sur moyenne exploitation sans orientation dominante"                                                        = "121f-Agriculteurs sur moyenne exploitation sans orientation dominante", 
#   "7K12g-Entrepreneurs de travaux agricoles à façon"                                                                              = "122a-Entrepreneurs de travaux agricoles à façon, de 0 à 9 salariés", 
#   "7K12h-Exploitants forestiers indépendants"                                                                                     = "122b-Exploitants forestiers indépendants, de 0 à 9 salariés", 
#   "7K12i-Patrons pêcheurs et aquaculteurs"                                                                                        = "122c-Patrons pêcheurs et aquaculteurs, de 0 à 9 salariés", 
#   "7K11a-Agriculteurs sur grande exploitation de céréales grandes cultures"                                                       = "131a-Agriculteurs sur grande exploitation de céréales grandes cultures", 
#   "7K11b-Maraîchers, horticulteurs, sur grande exploitation"                                                                      = "131b-Maraîchers, horticulteurs, sur grande exploitation", 
#   "7K11c-Viticulteurs, arboriculteurs fruitiers, sur grande exploitation"                                                         = "131c-Viticulteurs, arboriculteurs fruitiers, sur grande exploitation", 
#   "7K11d-Éleveurs d’herbivores, sur grande exploitation"                                                                          = "131d-Éleveurs d’herbivores, sur grande exploitation", 
#   "7K11e-Éleveurs de granivores et éleveurs mixtes, sur grande exploitation"                                                      = "131e-Éleveurs de granivores et éleveurs mixtes, sur grande exploitation", 
#   "7K11f-Agriculteurs sur grande exploitation sans orientation dominante"                                                         = "131f-Agriculteurs sur grande exploitation sans orientation dominante", 
#   "6E71a-Artisans maçons"                                                                                                         = "211a-Artisans maçons", 
#   "6E71b-Artisans menuisiers du bâtiment, charpentiers en bois"                                                                   = "211b-Artisans menuisiers du bâtiment, charpentiers en bois", 
#   "6E71c-Artisans plombiers, couvreurs, chauffagistes"                                                                            = "211c-Artisans couvreurs", 
#   "6E71c-Artisans plombiers, couvreurs, chauffagistes"                                                                            = "211d-Artisans plombiers, chauffagistes", 
#   "6E71d-Artisans électriciens du bâtiment"                                                                                       = "211e-Artisans électriciens du bâtiment", 
#   "6E71e-Artisans de la peinture et des finitions du bâtiment"                                                                    = "211f-Artisans de la peinture et des finitions du bâtiment", 
#   "6E71f-Artisans serruriers, métalliers"                                                                                         = "211g-Artisans serruriers, métalliers", 
#   "6E71g-Artisans en terrassement, travaux publics, parcs et jardins"                                                             = "211h-Artisans en terrassement, travaux publics", 
#   "6E71g-Artisans en terrassement, travaux publics, parcs et jardins"                                                             = "211j-Entrepreneurs en parcs et jardins, paysagistes", 
#   "6E72a-Artisans mécaniciens en machines agricoles"                                                                              = "212a-Artisans mécaniciens en machines agricoles", 
#   "6E72b-Artisans chaudronniers"                                                                                                  = "212b-Artisans chaudronniers", 
#   "6E72c-Artisans en mécanique générale, fabrication et travail des métaux "                                                      = "212c-Artisans en mécanique générale, fabrication et travail des métaux (hors horlogerie et matériel de précision)", 
#   "6E72c-Artisans en mécanique générale, fabrication et travail des métaux "                                                      = "212d-Artisans divers de fabrication de machines", 
#   "6E73a-Artisanes de l’habillement, du textile et du cuir"                                                                       = "213a-Artisans de l’habillement, du textile et du cuir", 
#   "6E74a-Artisans de l’ameublement"                                                                                               = "214a-Artisans de l’ameublement", 
#   "6E74b-Artisans du travail mécanique du bois"                                                                                   = "214b-Artisans du travail mécanique du bois", 
#   "6E78a-Artisans du papier, de l’imprimerie et de la reproduction"                                                               = "214c-Artisans du papier, de l’imprimerie et de la reproduction", 
#   "6E78b-Artisans de fabrication en matériaux de construction "                                                                   = "214d-Artisans de fabrication en matériaux de construction (hors artisanat d’art)", 
#   "6E78c-Artisan·es d’art"                                                                                                        = "214e-Artisans d’art", 
#   "6E78d-Autres artisan·es de fabrication "                                                                                       = "214f-Autres artisans de fabrication (y.c. horlogers, matériel de précision)", 
#   "6E75a-Artisan·es boulanger·es, pâtissier·es"                                                                                   = "215a-Artisans boulangers, pâtissiers, de 0 à 9 salariés", 
#   "6E75b-Artisans bouchers"                                                                                                       = "215b-Artisans bouchers, de 0 à 9 salariés", 
#   "6E75c-Artisans charcutiers"                                                                                                    = "215c-Artisans charcutiers, de 0 à 9 salariés", 
#   "6E75d-Autres artisans de l’alimentation"                                                                                       = "215d-Autres artisans de l’alimentation, de 0 à 9 salariés", 
#   "6E76a-Artisans mécaniciens réparateurs d’automobiles"                                                                          = "216a-Artisans mécaniciens réparateurs d’automobiles", 
#   "6E76b-Artisans tôliers carrossiers d’automobiles"                                                                              = "216b-Artisans tôliers carrossiers d’automobiles", 
#   "6E76c-Artisans réparateurs divers"                                                                                             = "216c-Artisans réparateurs divers", 
#   "6E77a-Conducteurs de taxis, ambulanciers et autres artisans du transport"                                                      = "217a-Conducteurs de taxis, ambulanciers et autres artisans du transport, de 0 à 9 salariés", 
#   "6E77b-Artisans déménageurs"                                                                                                    = "217b-Artisans déménageurs, de 0 à 9 salariés", 
#   "5H21a-Artisanes coiffeuses, manucures, esthéticiennes"                                                                         = "217c-Artisans coiffeurs, manucures, esthéticiens, de 0 à 9 salariés", 
#   "5H21b-Artisanes teinturieres, blanchisseuses"                                                                                  = "217d-Artisans teinturiers, blanchisseurs, de 0 à 9 salariés", 
#   "5H21c-Artisan·es des services divers"                                                                                          = "217e-Artisans des services divers, de 0 à 9 salariés", 
#   "6E77c-Transporteurs indépendants routiers et fluviaux"                                                                         = "218a-Transporteurs indépendants routiers et fluviaux, de 0 à 9 salariés", 
#   "5H21d-Aides familiales non salariées ou associées d’artisanes, effectuant un travail administratif ou commercial"              = "219a-Aides familiaux non salariés ou associés d’artisans, effectuant un travail administratif ou commercial", 
#   "NA"                                                                                                                            = "2200", 
#   "3B21a-Petits et moyens grossistes en alimentation"                                                                             = "221a-Petits et moyens grossistes en alimentation, de 0 à 9 salariés", 
#   "3B21b-Petits et moyens grossistes en produits non alimentaires"                                                                = "221b-Petits et moyens grossistes en produits non alimentaires, de 0 à 9 salariés", 
#   "3B21c-Petit·es et moyen·nes détaillant·es en alimentation spécialisée"                                                         = "222a-Petits et moyens détaillants en alimentation spécialisée, de 0 à 9 salariés", 
#   "5B22a-Petit·es et moyen·nes détaillant·es en alimentation générale"                                                            = "222b-Petits et moyens détaillants en alimentation générale, de 0 à 9 salariés", 
#   "5B22b-Détaillant·e·s en ameublement, décor, équipement du foyer"                                                               = "223a-Détaillants en ameublement, décor, équipement du foyer, de 0 à 9 salariés", 
#   "5B22c-Détaillants en droguerie, bazar, quincaillerie, bricolage"                                                               = "223b-Détaillants en droguerie, bazar, quincaillerie, bricolage, de 0 à 9 salariés", 
#   "5B22d-Fleuristes"                                                                                                              = "223c-Fleuristes, de 0 à 9 salariés", 
#   "5B22e-Détaillant·es en habillement et articles de sport"                                                                       = "223d-Détaillants en habillement et articles de sport, de 0 à 9 salariés", 
#   "5B22f-Détaillant·es en produits de beauté, de luxe "                                                                           = "223e-Détaillants en produits de beauté, de luxe (hors biens culturels), de 0 à 9 salariés", 
#   "5B22g-Détaillant·es en biens culturels "                                                                                       = "223f-Détaillants en biens culturels (livres, disques, multimédia, objets d’art), de 0 à 9 salariés", 
#   "5B22h-Détaillants·e en tabac, presse et articles divers"                                                                       = "223g-Détaillants en tabac, presse et articles divers, de 0 à 9 salariés", 
#   "5B22i-Exploitant·es et gérant·es libres de station-service"                                                                    = "223h-Exploitants et gérants libres de station-service, de 0 à 9 salariés", 
#   "5H22a-Exploitant·es de petit restaurant, café-restaurant, de 0 à 2 salariés"                                                   = "224a-Exploitants de petit restaurant, café-restaurant, de 0 à 2 salariés", 
#   "5H22b-Exploitant·es de petit café, débit de boisson, associé ou non à une autre activité hors restauration, de 0 à 2 salariés" = "224b-Exploitants de petit café, débit de boisson, associé ou non à une autre activité hors restauration, de 0 à 2 salariés", 
#   "5H22c-Exploitant·es de petit hôtel, hôtel-restaurant, de 0 à 2 salariés"                                                       = "224c-Exploitants de petit hôtel, hôtel-restaurant, de 0 à 2 salariés", 
#   "3B21d-Exploitants de café, restaurant, hôtel, de 3 à 9 salariés"                                                               = "224d-Exploitants de café, restaurant, hôtel, de 3 à 9 salariés", 
#   "3B21e-Intermédiaires indépendants du commerce"                                                                                 = "225a-Intermédiaires indépendants du commerce, de 0 à 9 salariés", 
#   "3B22a-Agents généraux et courtiers d’assurance indépendants"                                                                   = "226a-Agents généraux et courtiers d’assurance indépendants, de 0 à 9 salariés", 
#   "3B22b-Agent·es de voyage et auxiliaires de transports indépendant·es"                                                          = "226b-Agents de voyage et auxiliaires de transports indépendants, de 0 à 9 salariés", 
#   "3B22c-Agent·es immobilier·es indépendant·es"                                                                                   = "226c-Agents immobiliers indépendants, de 0 à 9 salariés", 
#   "3B22d-Indépendant·es gestionnaires de spectacle ou de service récréatif"                                                       = "227a-Indépendants gestionnaires de spectacle ou de service récréatif, de 0 à 9 salariés", 
#   "3B22e-Indépendant·es gestionnaires d’établissements privés "                                                                   = "227b-Indépendants gestionnaires d’établissements privés (enseignement, santé, social), de 0 à 9 salariés", 
#   "3B22f-Astrologues, professionnelles de la parapsychologie, guérisseuses"                                                       = "227c-Astrologues, professionnels de la parapsychologie, guérisseurs, de 0 à 9 salariés", 
#   "3B22g-Autres indépendants divers prestataires de services"                                                                     = "227d-Autres indépendants divers prestataires de services, de 0 à 9 salariés", 
#   "1A01a-Chefs de grande entreprise de 500 salariés et plus"                                                                      = "231a-Chefs de grande entreprise de 500 salariés et plus", 
#   "1A02a-Chefs de moyenne entreprise, de 50 à 499 salariés"                                                                       = "232a-Chefs de moyenne entreprise, de 50 à 499 salariés", 
#   "1A03a-Chefs d’entreprise du BTP, de 10 à 49 salariés"                                                                          = "233a-Chefs d’entreprise du bâtiment et des travaux publics, de 10 à 49 salariés", 
#   "1A03b-Chefs d’entreprise de l’industrie ou des transports, de 10 à 49 salariés"                                                = "233b-Chefs d’entreprise de l’industrie ou des transports, de 10 à 49 salariés", 
#   "1A03c-Chefs d’entreprise commerciale, de 10 à 49 salariés"                                                                     = "233c-Chefs d’entreprise commerciale, de 10 à 49 salariés", 
#   "1A03d-Chefs d’entreprise de services, de 10 à 49 salariés"                                                                     = "233d-Chefs d’entreprise de services, de 10 à 49 salariés", 
#  
#   "4F41a-Médecins libéra·les spécialistes"                                                                                        = "311a-Médecins libéraux spécialistes", 
#   "4F41b-Médecins libéra·les généralistes"                                                                                        = "311b-Médecins libéraux généralistes", 
#   "4F41c-Chirurgien·nes dentistes "                                                                                               = "311c-Chirurgiens dentistes (libéraux ou salariés)", 
#   "4F45a-Psychologues, psychanalystes, psychothérapeutes"                                                                         = "311d-Psychologues, psychanalystes, psychothérapeutes (non médecins)", 
#   "4F41d-Vétérinaires "                                                                                                           = "311e-Vétérinaires (libéraux ou salariés)", 
#   "4F44a-Pharmacien·nes libéra·les"                                                                                               = "311f-Pharmaciens libéraux", 
#   "4J21a-Avocat·es"                                                                                                               = "312a-Avocats", 
#   "4J21b-Notaires"                                                                                                                = "312b-Notaires", 
#   "2D23a-Experts comptables, comptables agréés, libéraux"                                                                         = "312c-Experts comptables, comptables agréés, libéraux", 
#   "2D23b-Consultant·es libéra·les en études économiques, organisation et recrutement, gestion et fiscalité"                       = "312d-Conseils et experts libéraux en études économiques, organisation et recrutement, gestion et fiscalité", 
#   "2E22a-Ingénieurs conseils libéraux en études techniques"                                                                       = "312e-Ingénieurs conseils libéraux en études techniques", 
#   "4J21c-Architectes libéraux"                                                                                                    = "312f-Architectes libéraux", 
#   "4J25a-Géomètres-experts, huissier·es de justice, officiers ministériel·les, professions libérales diverses"                    = "312g-Géomètres-experts, huissiers de justice, officiers ministériels, professions libérales diverses", 
#   "4J25b-Aides familiales non salariées de professions libérales effectuant un travail administratif"                             = "313a-Aides familiaux non salariés de professions libérales effectuant un travail administratif", 
#   
#   "2D21a-Personnel·les de direction de la fonction publique"                                                                      = "331a-Personnels de direction de la fonction publique (État, collectivités locales, hôpitaux)", 
#   "2D28b-Autres cadres d’entreprises classé·es fonction publique"                                                                 = "331a-Personnels de direction de la fonction publique (État, collectivités locales, hôpitaux)", 
#   "2E23a-Ingénieur·es publi·ques"                                                                                                 = "332a-Ingénieurs de l’État (y.c. ingénieurs militaires) et assimilés", 
#   "2D28b-Autres cadres d’entreprises classé·es fonction publique"                                                                 = "332a-Ingénieurs de l’État (y.c. ingénieurs militaires) et assimilés", 
#   "2E23a-Ingénieur·es publi·ques"                                                                                                 = "332b-Ingénieurs des collectivités locales et des hôpitaux", 
#   "2D28b-Autres cadres d’entreprises classé·es fonction publique"                                                                 = "332b-Ingénieurs des collectivités locales et des hôpitaux", 
#   "4J23a-Magistrat·es"                                                                                                            = "333a-Magistrats", 
#   "2C01a-Inspect·rices des Finances publiques et des Douanes"                                                                     = "333b-Inspecteurs et autres personnels de catégorie A des Impôts, du Trésor et des Douanes", 
#   "2D28b-Autres cadres d’entreprises classé·es fonction publique"                                                                 = "333b-Inspecteurs et autres personnels de catégorie A des Impôts, du Trésor et des Douanes", 
#   "2D27a-Cadres de la Poste/FT"                                                                                                   = "333c-Cadres de la Poste", 
#   "2D27a-Cadres de la Poste/FT"                                                                                                   = "333d-Cadres administratifs de France Télécom (statut public)", 
#   "2D24a-Autres cadres publi·ques administrati·ves de l’état"                                                                     = "333e-Autres personnels administratifs de catégorie A de État (hors Enseignement, Patrimoine, Impôts, Trésor, Douanes)", 
#   "2D28b-Autres cadres d’entreprises classé·es fonction publique"                                                                 = "333e-Autres personnels administratifs de catégorie A de État (hors Enseignement, Patrimoine, Impôts, Trésor, Douanes)", 
#   "2D24b-Cadres publi·ques administrati·ves des collectivités locales et hôpitaux publics "                                       = "333f-Personnels administratifs de catégorie A des collectivités locales et hôpitaux publics (hors Enseignement, Patrimoine)", 
#   "2D28b-Autres cadres d’entreprises classé·es fonction publique"                                                                 = "333f-Personnels administratifs de catégorie A des collectivités locales et hôpitaux publics (hors Enseignement, Patrimoine)", 
#   "2G00a-Officiers des Armées et de la Gendarmerie "                                                                              = "334a-Officiers des Armées et de la Gendarmerie (sauf officiers généraux)", 
#   "2D28b-Autres cadres d’entreprises classé·es fonction publique"                                                                 = "334a-Officiers des Armées et de la Gendarmerie (sauf officiers généraux)", 
#   "4J24a-Professionnels de la politique et permanents syndicaux"                                                                  = "335a-Personnes exerçant un mandat politique ou syndical", 
#   
#   "4I13a-Professeur·es agrégé·es et certifié·es de l’enseignement secondaire"                                                     = "341a-Professeurs agrégés et certifiés de l’enseignement secondaire", 
#   "2I11a-Proviseur·es et inspect·rices de l’EN"                                                                                   = "341b-Chefs d’établissement de l’enseignement secondaire et inspecteurs", 
#   "2I12a-Chef·fes d’établissement scolaire privé"                                                                                 = "341b-Chefs d’établissement de l’enseignement secondaire et inspecteurs", 
#   "4I11a-Enseignant·es de l’enseignement supérieur"                                                                               = "342a-Enseignants de l’enseignement supérieur", 
#   "4I12a-Chercheu·ses de la recherche publique"                                                                                   = "342e-Chercheurs de la recherche publique", 
#   "4F45b-Psychologues spécialistes de l’orientation scolaire et professionnelle"                                                  = "343a-Psychologues spécialistes de l’orientation scolaire et professionnelle", 
#   "4F10a-Médecins hospitalier·es sans activité libérale"                                                                          = "344a-Médecins hospitaliers sans activité libérale", 
#   "4F41e-Médecins salarié·es non hospitalier·es"                                                                                  = "344b-Médecins salariés non hospitaliers", 
#   "4F10b-Internes en médecine, odontologie et pharmacie"                                                                          = "344c-Internes en médecine, odontologie et pharmacie", 
#   "4F44b-Pharmaciennes salariées"                                                                                                 = "344d-Pharmaciens salariés", 
#  
#    "2J01a-Bibliothécaires, archivistes, conservatrices et autres cadres du patrimoine"                                             = "351a-Bibliothécaires, archivistes, conservateurs et autres cadres du patrimoine (fonction publique)", 
#   "4J22a-Journalistes "                                                                                                           = "352a-Journalistes (y. c. rédacteurs en chef)", 
#   "4J11a-Aut·rices littéraires, scénaristes, dialoguistes"                                                                        = "352b-Auteurs littéraires, scénaristes, dialoguistes", 
#   "2J03a-Cadres de la presse, de l’édition, de l’audiovisuel et des spectacles"                                                   = "353a-Directeurs de journaux, administrateurs de presse, directeurs d’éditions (littéraire, musicale, audiovisuelle et multimédia)", 
#   "2J02a-Cadres publi·ques de la presse et de l’audiovisuel"                                                                      = "353a-Directeurs de journaux, administrateurs de presse, directeurs d’éditions (littéraire, musicale, audiovisuelle et multimédia)", 
#   "2J03a-Cadres de la presse, de l’édition, de l’audiovisuel et des spectacles"                                                   = "353b-Directeurs, responsables de programmation et de production de l’audiovisuel et des spectacles", 
#   "2J02a-Cadres publi·ques de la presse et de l’audiovisuel"                                                                      = "353b-Directeurs, responsables de programmation et de production de l’audiovisuel et des spectacles", 
#   "4J12a-Cadres artistiques et technico-artistiques de la réalisation de l’audiovisuel et des spectacles"                         = "353c-Cadres artistiques et technico-artistiques de la réalisation de l’audiovisuel et des spectacles", 
#   "4J11b-Artistes plasticien·nes"                                                                                                 = "354a-Artistes plasticiens", 
#   "4J11c-Artistes de la musique et du chant"                                                                                      = "354b-Artistes+B493 de la musique et du chant", 
#   "4J11d-Artistes dramatiques, danseu·ses"                                                                                        = "354c-Artistes dramatiques", 
#   "4J11d-Artistes dramatiques, danseu·ses"                                                                                        = "354d-Artistes de la danse, du cirque et des spectacles divers", 
#   "4J13a-Professeur·es d’art "                                                                                                    = "354g-Professeurs d’art (hors établissements scolaires)", 
#   
#   "NA"                                                                                                                            = "3700", 
#   "2D22a-Cadres d’état-major administratifs, financiers, commerciaux des grandes entreprises"                                     = "371a-Cadres d’état-major administratifs, financiers, commerciaux des grandes entreprises", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "371a-Cadres d’état-major administratifs, financiers, commerciaux des grandes entreprises", 
#   "2E23c-Cadres chargé·es d’études économiques, financières, commerciales"                                                        = "372a-Cadres chargés d’études économiques, financières, commerciales", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "372a-Cadres chargés d’études économiques, financières, commerciales", 
#   "2D25a-Cadres de l’organisation ou du contrôle des services administratifs et financiers"                                       = "372b-Cadres de l’organisation ou du contrôle des services administratifs et financiers", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "372b-Cadres de l’organisation ou du contrôle des services administratifs et financiers", 
#   "2D25b-Cadres des ressources humaines "                                                                                         = "372c-Cadres spécialistes des ressources humaines et du recrutement", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "372c-Cadres spécialistes des ressources humaines et du recrutement", 
#   "2D25b-Cadres des ressources humaines "                                                                                         = "372d-Cadres spécialistes de la formation", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "372d-Cadres spécialistes de la formation", 
#   "2D25c-Juristes"                                                                                                                = "372e-Juristes", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "372e-Juristes", 
#   "2D28a-Cadres de la documentation, de l’archivage"                                                                              = "372f-Cadres de la documentation, de l’archivage (hors fonction publique)", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "372f-Cadres de la documentation, de l’archivage (hors fonction publique)", 
#   "2D25d-Cadres des services financiers ou comptables des grandes entreprises"                                                    = "373a-Cadres des services financiers ou comptables des grandes entreprises", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "373a-Cadres des services financiers ou comptables des grandes entreprises", 
#   "2D25e-Cadres des autres services administratifs des grandes entreprises"                                                       = "373b-Cadres des autres services administratifs des grandes entreprises", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "373b-Cadres des autres services administratifs des grandes entreprises", 
#   "2D25f-Cadres des services financiers ou comptables des PME"                                                                    = "373c-Cadres des services financiers ou comptables des petites et moyennes entreprises", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "373c-Cadres des services financiers ou comptables des petites et moyennes entreprises", 
#   "2D25g-Cadres des autres services administratifs des PME"                                                                       = "373d-Cadres des autres services administratifs des petites et moyennes entreprises", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "373d-Cadres des autres services administratifs des petites et moyennes entreprises", 
#   "2B02a-Cadres de l’exploitation des magasins de vente du commerce de détail"                                                    = "374a-Cadres de l’exploitation des magasins de vente du commerce de détail", 
#   "2D25h-Chef·fes de produits, achet·rices du commerce et autres cadres de la mercatique"                                         = "374b-Chefs de produits, acheteurs du commerce et autres cadres de la mercatique", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "374b-Chefs de produits, acheteurs du commerce et autres cadres de la mercatique", 
#   "2B01a-Cadres commerciaux des grandes entreprises "                                                                             = "374c-Cadres commerciaux des grandes entreprises (hors commerce de détail)", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "374c-Cadres commerciaux des grandes entreprises (hors commerce de détail)", 
#   "2B01b-Cadres commerciaux des PME "                                                                                             = "374d-Cadres commerciaux des petites et moyennes entreprises (hors commerce de détail)", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "374d-Cadres commerciaux des petites et moyennes entreprises (hors commerce de détail)", 
#   "2D25i-Cadres de la communication "                                                                                             = "375a-Cadres de la publicité", 
#   "2D25i-Cadres de la communication "                                                                                             = "375b-Cadres des relations publiques et de la communication", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "375b-Cadres des relations publiques et de la communication", 
#   "2C04a-Cadres des marchés financiers"                                                                                           = "376a-Cadres des marchés financiers", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "376a-Cadres des marchés financiers", 
#   "2C03a-Cadres des opérations bancaires"                                                                                         = "376b-Cadres des opérations bancaires", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "376b-Cadres des opérations bancaires", 
#   "2C02a-Cadres commercia·les de la banque"                                                                                       = "376c-Cadres commerciaux de la banque", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "376c-Cadres commerciaux de la banque", 
#   "2C04b-Chef·fes d’établissements et responsables de l’exploitation bancaire"                                                    = "376d-Chefs d’établissements et responsables de l’exploitation bancaire", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "376d-Chefs d’établissements et responsables de l’exploitation bancaire", 
#   "2C03b-Cadres des services techniques des assurances"                                                                           = "376e-Cadres des services techniques des assurances", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "376e-Cadres des services techniques des assurances", 
#   "2D26a-Cadres de la Sécurité sociale"                                                                                           = "376f-Cadres des services techniques des organismes de sécurité sociale et assimilés", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "376g-Cadres de l’immobilier", 
#   "2B03a-Cadres de l’immobilier"                                                                                                  = "376g-Cadres de l’immobilier", 
#   "2H00a-Cadres de l’hôtellerie et de la restauration"                                                                            = "377a-Cadres de l’hôtellerie et de la restauration", 
#   "2D24c-Cadres publi·ques administrati·ves classés entreprise"                                                                   = "377a-Cadres de l’hôtellerie et de la restauration", 
#   
#   "2E21a-Directeurs techniques des grandes entreprises"                                                                           = "380a-Directeurs techniques des grandes entreprises", 
#   "2E26a-Ingénieurs et cadres d’étude et d’exploitation de l’agriculture, la pêche, les eaux et forêts"                           = "381a-Ingénieurs et cadres d’étude et d’exploitation de l’agriculture, la pêche, les eaux et forêts", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "381a-Ingénieurs et cadres d’étude et d’exploitation de l’agriculture, la pêche, les eaux et forêts", 
#   "2E26b-Ingénieurs et cadres d’étude du BTP"                                                                                     = "382a-Ingénieurs et cadres d’étude du bâtiment et des travaux publics", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "382a-Ingénieurs et cadres d’étude du bâtiment et des travaux publics", 
#   "2E26c-Architectes salarié·es"                                                                                                  = "382b-Architectes salariés", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "382b-Architectes salariés", 
#   "2E25b-Ingénieurs, cadres de chantier et conducteurs de travaux  du BTP"                                                        = "382c-Ingénieurs, cadres de chantier et conducteurs de travaux (cadres) du bâtiment et des travaux publics", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "382c-Ingénieurs, cadres de chantier et conducteurs de travaux (cadres) du bâtiment et des travaux publics", 
#   "2B04a-Ingénieurs et cadres technico-commerciaux en BTP"                                                                        = "382d-Ingénieurs et cadres technico-commerciaux en bâtiment, travaux publics", 
#   "2E26d-Ingénieurs et cadres d’étude, recherche et développement en électricité, électronique"                                   = "383a-Ingénieurs et cadres d’étude, recherche et développement en électricité, électronique", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "383a-Ingénieurs et cadres d’étude, recherche et développement en électricité, électronique", 
#   "2E25c-Ingénieurs et cadres de fabrication en matériel électrique, électronique"                                                = "383b-Ingénieurs et cadres de fabrication en matériel électrique, électronique", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "383b-Ingénieurs et cadres de fabrication en matériel électrique, électronique", 
#   "2B04b-Ingénieurs et cadres technico-commerciaux en matériel électrique ou électronique professionnel"                          = "383c-Ingénieurs et cadres technico-commerciaux en matériel électrique ou électronique professionnel", 
#   "2E26e-Ingénieurs et cadres d’étude, recherche et développement en mécanique et travail des métaux"                             = "384a-Ingénieurs et cadres d’étude, recherche et développement en mécanique et travail des métaux", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "384a-Ingénieurs et cadres d’étude, recherche et développement en mécanique et travail des métaux", 
#   "2E25d-Ingénieurs et cadres de fabrication en mécanique et travail des métaux"                                                  = "384b-Ingénieurs et cadres de fabrication en mécanique et travail des métaux", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "384b-Ingénieurs et cadres de fabrication en mécanique et travail des métaux", 
#   "2B04c-Ingénieurs et cadres technico-commerciaux en matériel mécanique professionnel"                                           = "384c-Ingénieurs et cadres technico-commerciaux en matériel mécanique professionnel", 
#   "2E26f-Ingénieurs et cadres d’étude, recherche et développement des industries de transformation "                              = "385a-Ingénieurs et cadres d’étude, recherche et développement des industries de transformation (agroalimentaire, chimie, métallurgie, matériaux lourds)", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "385a-Ingénieurs et cadres d’étude, recherche et développement des industries de transformation (agroalimentaire, chimie, métallurgie, matériaux lourds)", 
#   "2E25e-Ingénieurs et cadres de fabrication des industries de transformation "                                                   = "385b-Ingénieurs et cadres de fabrication des industries de transformation (agroalimentaire, chimie, métallurgie, matériaux lourds)", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "385b-Ingénieurs et cadres de fabrication des industries de transformation (agroalimentaire, chimie, métallurgie, matériaux lourds)", 
#   "2B04d-Ingénieurs et cadres technico-commerciaux des industries de transformations "                                            = "385c-Ingénieurs et cadres technico-commerciaux des industries de transformations (biens intermédiaires)", 
#   "2E26g-Ingénieur·es et cadres d’étude, recherche et développement des autres industries "                                       = "386a-Ingénieurs et cadres d’étude, recherche et développement des autres industries (imprimerie, matériaux souples, ameublement et bois, énergie, eau)", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "386a-Ingénieurs et cadres d’étude, recherche et développement des autres industries (imprimerie, matériaux souples, ameublement et bois, énergie, eau)", 
#   "2E25f-Ingénieurs et cadres de la production et de la distribution d’énergie, eau"                                              = "386d-Ingénieurs et cadres de la production et de la distribution d’énergie, eau", 
#   "2E25g-Ingénieur·es et cadres de fabrication des autres industries "                                                            = "386e-Ingénieurs et cadres de fabrication des autres industries (imprimerie, matériaux souples, ameublement et bois)", 
#   "2E23d-Ingénieurs et cadres des achats et approvisionnements industriels"                                                       = "387a-Ingénieurs et cadres des achats et approvisionnements industriels", 
#   "2E23e-Ingénieurs et cadres de la logistique, du planning et de l’ordonnancement"                                               = "387b-Ingénieurs et cadres de la logistique, du planning et de l’ordonnancement", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "387b-Ingénieurs et cadres de la logistique, du planning et de l’ordonnancement", 
#   "2E23f-Ingénieurs et cadres des méthodes de production"                                                                         = "387c-Ingénieurs et cadres des méthodes de production", 
#   "2E23g-Ingénieur·es et cadres du contrôle-qualité"                                                                              = "387d-Ingénieurs et cadres du contrôle-qualité", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "387d-Ingénieurs et cadres du contrôle-qualité", 
#   "2E26h-Ingénieurs et cadres de la maintenance, de l’entretien et des travaux neufs"                                             = "387e-Ingénieurs et cadres de la maintenance, de l’entretien et des travaux neufs", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "387e-Ingénieurs et cadres de la maintenance, de l’entretien et des travaux neufs", 
#   "2E26i-Ingénieur·es et cadres techniques de l’environnement"                                                                    = "387f-Ingénieurs et cadres techniques de l’environnement", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "387f-Ingénieurs et cadres techniques de l’environnement", 
#   "2E27a-Ingénieurs et cadres d’étude, recherche et développement en informatique"                                                = "388a-Ingénieurs et cadres d’étude, recherche et développement en informatique", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "388a-Ingénieurs et cadres d’étude, recherche et développement en informatique", 
#   "2E27b-Ingénieurs et cadres d’administration, maintenance, support et services aux utilisateurs en informatique"                = "388b-Ingénieurs et cadres d’administration, maintenance, support et services aux utilisateurs en informatique", 
#   "2E27c-Chefs de projets informatiques, responsables informatiques"                                                              = "388c-Chefs de projets informatiques, responsables informatiques", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "388c-Chefs de projets informatiques, responsables informatiques", 
#   "2B04e-Ingénieurs et cadres technico-commerciaux en informatique et télécommunications"                                         = "388d-Ingénieurs et cadres technico-commerciaux en informatique et télécommunications", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "388d-Ingénieurs et cadres technico-commerciaux en informatique et télécommunications", 
#   "2E26j-Ingénieurs et cadres spécialistes des télécommunications"                                                                = "388e-Ingénieurs et cadres spécialistes des télécommunications", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "388e-Ingénieurs et cadres spécialistes des télécommunications", 
#   "2E25h-Ingénieurs et cadres techniques de l’exploitation des transports"                                                        = "389a-Ingénieurs et cadres techniques de l’exploitation des transports", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "389a-Ingénieurs et cadres techniques de l’exploitation des transports", 
#   "2E28a-Officiers et cadres navigants techniques et commerciaux de l’aviation civile"                                            = "389b-Officiers et cadres navigants techniques et commerciaux de l’aviation civile", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "389b-Officiers et cadres navigants techniques et commerciaux de l’aviation civile", 
#   "2E28b-Officiers et cadres navigants techniques de la marine marchande"                                                         = "389c-Officiers et cadres navigants techniques de la marine marchande", 
#   "2E23b-Ingénieur·es publi·ques classé·es entreprise"                                                                            = "389c-Officiers et cadres navigants techniques de la marine marchande", 
#   
#   "4I14a-Professeures des écoles"                                                                                                 = "421a-Instituteurs", 
#   "4I14a-Professeures des écoles"                                                                                                 = "421b-Professeurs des écoles", 
#   "4I13b-Professeur·es d’enseignement général des collèges"                                                                       = "422a-Professeurs d’enseignement général des collèges", 
#   "4I13c-Professeur·es de lycée professionnel"                                                                                    = "422b-Professeurs de lycée professionnel", 
#   "4I13d-Professeur·es contractuel·les de l’enseignement secondaire "                                                             = "422c-Maîtres auxiliaires et professeurs contractuels de l’enseignement secondaire", 
#   "4I13e-Conseillères principales d’Éducation"                                                                                    = "422d-Conseillers principaux d’éducation", 
#   "4I13e-Conseillères principales d’Éducation"                                                                                    = "422e-Surveillants et aides-éducateurs des établissements d’enseignement", 
#   "4I33a-Monit·rices d’école de conduite"                                                                                         = "423a-Moniteurs d’école de conduite", 
#   "4I33b-Format·rices et animat·rices de formation continue"                                                                      = "423b-Formateurs et animateurs de formation continue", 
#   "4I34a-Éducat·rices sporti·ves "                                                                                                = "424a-Moniteurs et éducateurs sportifs, sportifs professionnels", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "425a-Sous-bibliothécaires, cadres intermédiaires du patrimoine", 
#   "3D06a-Sous-bibliothécaires, cadres intermédiaires du patrimoine"                                                               = "425a-Sous-bibliothécaires, cadres intermédiaires du patrimoine", 
#   "2F02a-Cadres privées de santé"                                                                                                 = "431a-Cadres infirmiers et assimilés", 
#   "2F01a-Cadres publiques de santé"                                                                                               = "431a-Cadres infirmiers et assimilés", 
#   "4F20a-Infirmières psychiatriques"                                                                                              = "431b-Infirmiers psychiatriques", 
#   "4F20b-Puéricultrices"                                                                                                          = "431c-Puéricultrices", 
#   "4F20c-Infirmières spécialisées "                                                                                               = "431d-Infirmiers spécialisés (autres qu’infirmiers psychiatriques et puéricultrices)", 
#   "4F43a-Sages-femmes"                                                                                                            = "431e-Sages-femmes (libérales ou salariées)", 
#   "4F20d-Infirmières "                                                                                                            = "431f-Infirmiers en soins généraux, salariés", 
#   "4F20d-Infirmières "                                                                                                            = "431g-Infirmiers libéraux", 
#   "4F42a-Spécialistes de la réÉducation"                                                                                          = "432a-Masseurs-kinésithérapeutes rééducateurs, libéraux", 
#   "4F42a-Spécialistes de la réÉducation"                                                                                          = "432b-Masseurs-kinésithérapeutes rééducateurs, salariés", 
#   "4F42a-Spécialistes de la réÉducation"                                                                                          = "432c-Autres spécialistes de la rééducation, libéraux", 
#   "4F42a-Spécialistes de la réÉducation"                                                                                          = "432d-Autres spécialistes de la rééducation, salariés", 
#   "3F30a-Technicien·nes médica·les"                                                                                               = "433a-Techniciens médicaux", 
#   "3F30a-Technicien·nes médica·les"                                                                                               = "433b-Opticiens lunetiers et audioprothésistes (indépendants et salariés)", 
#   "3F30a-Technicien·nes médica·les"                                                                                               = "433c-Autres spécialistes de l’appareillage médical (indépendants et salariés)", 
#   "3F30b-Préparatrices en pharmacie"                                                                                              = "433d-Préparateurs en pharmacie", 
#   "2I24a-Cadres associati·ves  de l’intervention sociale"                                                                         = "434a-Cadres de l’intervention socio-éducative", 
#   "2I23a-Cadres publi·ques de l’intervention sociale"                                                                             = "434a-Cadres de l’intervention socio-éducative", 
#   "4I22a-Assistantes sociales"                                                                                                    = "434b-Assistants de service social", 
#   "4I23a-Conseillères en économie sociale familiale"                                                                              = "434c-Conseillers en économie sociale familiale", 
#   "4I21a-Éducatrices spécialisées"                                                                                                = "434d-Éducateurs spécialisés", 
#   "4I21b-Monit·rices Éducat·rices"                                                                                                = "434e-Moniteurs éducateurs", 
#   "4I21c-Éducat·rices techniques spécialisé·es, monit·rices d’atelier"                                                            = "434f-Éducateurs techniques spécialisés, moniteurs d’atelier", 
#   "4I21d-Éducatrices de jeunes enfants"                                                                                           = "434g-Éducateurs de jeunes enfants", 
#   "2I25a-Direct·rices de centres socioculturels et de loisirs"                                                                    = "435a-Directeurs de centres socioculturels et de loisirs", 
#   "4I32a-Animatrices socioculturels et de loisirs"                                                                                = "435b-Animateurs socioculturels et de loisirs", 
#   "4I35a-Clergé"                                                                                                                  = "441a-Clergé séculier", 
#   "4I35a-Clergé"                                                                                                                  = "441b-Clergé régulier", 
#   "3D08a-Cols blancs administrati·ves de la Poste et France Télécom "                                                             = "451a-Professions intermédiaires de la Poste", 
#   "3D08a-Cols blancs administrati·ves de la Poste et France Télécom "                                                             = "451b-Professions intermédiaires administratives de France Télécom (statut public)", 
#   "3C01a-Contrôleu·ses des Finances publiques "                                                                                   = "451c-Contrôleurs des Impôts, du Trésor, des Douanes et assimilés", 
#   "3D07b-Cols blancs subalternes d’entreprise classé·es fonction publique"                                                     = "451c-Contrôleurs des Impôts, du Trésor, des Douanes et assimilés", 
#   "2E23a-Ingénieur·es publi·ques"                                                                                                 = "451d-Ingénieurs du contrôle de la navigation aérienne", 
#   "3D01a-Cols blancs administratives de catégorie B"                                                                              = "451e-Autres personnels administratifs de catégorie B de État (hors Enseignement, Patrimoine, Impôts, Trésor, Douanes)", 
#   "3D07b-Cols blancs subalternes d’entreprise classé·es fonction publique"                                                     = "451e-Autres personnels administratifs de catégorie B de État (hors Enseignement, Patrimoine, Impôts, Trésor, Douanes)", 
#   "3D01a-Cols blancs administratives de catégorie B"                                                                              = "451f-Personnels administratifs de catégorie B des collectivités locales et des hôpitaux (hors Enseignement, Patrimoine)", 
#   "3D07b-Cols blancs subalternes d’entreprise classé·es fonction publique"                                                     = "451f-Personnels administratifs de catégorie B des collectivités locales et des hôpitaux (hors Enseignement, Patrimoine)", 
#   "2G00b-Inspecteurs et officiers de police"                                                                                      = "452a-Inspecteurs et officiers de police", 
#   "5G21a-Adjudants-chefs, adjudants et sous-officiers de rang supérieur de l’Armée et de la Gendarmerie"                          = "452b-Adjudants-chefs, adjudants et sous-officiers de rang supérieur de l’Armée et de la Gendarmerie", 
#   "3D07b-Cols blancs subalternes d’entreprise classé·es fonction publique"                                                     = "452b-Adjudants-chefs, adjudants et sous-officiers de rang supérieur de l’Armée et de la Gendarmerie", 
#   "NA"                                                                                                                            = "4600", 
#   "3D02a-Secrétaires de direction "                                                                                               = "461a-Personnel de secrétariat de niveau supérieur, secrétaires de direction (non cadres)", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "461a-Personnel de secrétariat de niveau supérieur, secrétaires de direction (non cadres)", 
#   "3D03a-Techniciennes  des services financiers ou comptables"                                                                    = "461d-Maîtrise et techniciens des services financiers ou comptables", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "461d-Maîtrise et techniciens des services financiers ou comptables", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "461e-Maîtrise et techniciens administratifs des services juridiques ou du personnel", 
#   "3D03b-Techniciennes administratives  (autres que financiers et comptables)"                                                    = "461e-Maîtrise et techniciens administratifs des services juridiques ou du personnel", 
#   "3D03b-Techniciennes administratives  (autres que financiers et comptables)"                                                    = "461f-Maîtrise et techniciens administratifs des autres services administratifs", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "461f-Maîtrise et techniciens administratifs des autres services administratifs", 
#   "3B12a-Chef·fes de petites surfaces de vente"                                                                                   = "462a-Chefs de petites surfaces de vente (salariés ou mandataires)", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "462a-Chefs de petites surfaces de vente (salariés ou mandataires)", 
#   "3B12b-Maîtrise de l’exploitation des magasins de vente"                                                                        = "462b-Maîtrise de l’exploitation des magasins de vente", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "462b-Maîtrise de l’exploitation des magasins de vente", 
#   "3B13a-Achet·rices non classé·es cadres, aides-achet·rices"                                                                     = "462c-Acheteurs non classés cadres, aides-acheteurs", 
#   "3B13d-Cols blancs subalternes du commerce Employé·es du public"                                                             = "462c-Acheteurs non classés cadres, aides-acheteurs", 
#   "3B13b-Animat·rices commercia·les des magasins de vente, marchandiseu·ses "                                                     = "462d-Animateurs commerciaux des magasins de vente, marchandiseurs (non cadres)", 
#   "3B13d-Cols blancs subalternes du commerce Employé·es du public"                                                             = "462d-Animateurs commerciaux des magasins de vente, marchandiseurs (non cadres)", 
#   "3B13c-Autres cols blancs subalternes du commerce "                                                                          = "462e-Autres professions intermédiaires commerciales (sauf techniciens des forces de vente)", 
#   "3B13d-Cols blancs subalternes du commerce Employé·es du public"                                                             = "462e-Autres professions intermédiaires commerciales (sauf techniciens des forces de vente)", 
#   "3B11a-Technicien·nes commercia·les "                                                                                           = "463a-Techniciens commerciaux et technico-commerciaux, représentants en informatique", 
#   "3B11a-Technicien·nes commercia·les "                                                                                           = "463b-Techniciens commerciaux et technico-commerciaux, représentants en biens d’équipement, en biens intermédiaires, commerce interindustriel (hors informatique)", 
#   "3B11a-Technicien·nes commercia·les "                                                                                           = "463c-Techniciens commerciaux et technico-commerciaux, représentants en biens de consommation auprès d’entreprises", 
#   "3B11a-Technicien·nes commercia·les "                                                                                           = "463d-Techniciens commerciaux et technico-commerciaux, représentants en services auprès d’entreprises ou de professionnels (hors banque, assurance, informatique)", 
#   "3B13d-Cols blancs subalternes du commerce Employé·es du public"                                                             = "463d-Techniciens commerciaux et technico-commerciaux, représentants en services auprès d’entreprises ou de professionnels (hors banque, assurance, informatique)", 
#   "3B11b-Technicien·nes commercia·les auprès de particuliers"                                                                     = "463e-Techniciens commerciaux et technico-commerciaux, représentants auprès de particuliers (hors banque, assurance, informatique)", 
#   "3B13d-Cols blancs subalternes du commerce Employé·es du public"                                                             = "463e-Techniciens commerciaux et technico-commerciaux, représentants auprès de particuliers (hors banque, assurance, informatique)", 
#   "3D03c-Assistantes de la publicité, des relations publiques "                                                                   = "464a-Assistants de la publicité, des relations publiques (indépendants ou salariés)", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "464a-Assistants de la publicité, des relations publiques (indépendants ou salariés)", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "464b-Interprètes, traducteurs (indépendants ou salariés)", 
#   "3D06b-Interprètes et traductrices "                                                                                            = "464b-Interprètes, traducteurs (indépendants ou salariés)", 
#   "3D06c-Concept·rices et assistant·es techniques des arts graphiques, de la mode et de la décoration "                           = "465a-Concepteurs et assistants techniques des arts graphiques, de la mode et de la décoration (indépendants et salariés)", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "465a-Concepteurs et assistants techniques des arts graphiques, de la mode et de la décoration (indépendants et salariés)", 
#   "3D06d-Assistants techniques de la réalisation des spectacles vivants et audiovisuels "                                         = "465b-Assistants techniques de la réalisation des spectacles vivants et audiovisuels (indépendants ou salariés)", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "465b-Assistants techniques de la réalisation des spectacles vivants et audiovisuels (indépendants ou salariés)", 
#   "3D06e-Photographes"                                                                                                            = "465c-Photographes (indépendants et salariés)", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "465c-Photographes (indépendants et salariés)", 
#   "3D07a-Responsables administrati·ves ou commercia·les des transports et du tourisme "                                           = "466a-Responsables commerciaux et administratifs des transports de voyageurs et du tourisme (non cadres)", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "466a-Responsables commerciaux et administratifs des transports de voyageurs et du tourisme (non cadres)", 
#   "3D07a-Responsables administrati·ves ou commercia·les des transports et du tourisme "                                           = "466b-Responsables commerciaux et administratifs des transports de marchandises (non cadres)", 
#   "3D05a-Responsables d’exploitation des transports de voyageurs et de marchandises "                                             = "466c-Responsables d’exploitation des transports de voyageurs et de marchandises (non cadres)", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "466c-Responsables d’exploitation des transports de voyageurs et de marchandises (non cadres)", 
#   "3C02a-Chargé·es de clientèle bancaire"                                                                                         = "467a-Chargés de clientèle bancaire", 
#   "3B13d-Cols blancs subalternes du commerce Employé·es du public"                                                             = "467a-Chargés de clientèle bancaire", 
#   "3C03a-Technicien·nes des opérations bancaires"                                                                                 = "467b-Techniciens des opérations bancaires", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "467b-Techniciens des opérations bancaires", 
#   "3C03b-Cols blancs  des assurances"                                                                                             = "467c-Professions intermédiaires techniques et commerciales des assurances", 
#   "3D01b-Cols blancs administrati·ves du public classées entreprise"                                                              = "467c-Professions intermédiaires techniques et commerciales des assurances", 
#   "3D07b-Cols blancs subalternes d’entreprise classé·es fonction publique"                                                     = "467d-Professions intermédiaires techniques des organismes de sécurité sociale", 
#   "3D04a-Cols blancs administratives de la Sécurité sociale"                                                                      = "467d-Professions intermédiaires techniques des organismes de sécurité sociale", 
#   "3H00a-Maîtrise de restauration : salle et service"                                                                             = "468a-Maîtrise de restauration : salle et service", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "468a-Maîtrise de restauration : salle et service", 
#   "3H00b-Maîtrise de l’hébergement : hall et étages"                                                                              = "468b-Maîtrise de l’hébergement : hall et étages", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "468b-Maîtrise de l’hébergement : hall et étages", 
#   "3E24a-Techniciens d’étude et de conseil en agriculture, eaux et forêt"                                                         = "471a-Techniciens d’étude et de conseil en agriculture, eaux et forêt", 
#   "3E21a-Techniciens employés du public "                                                                                         = "471a-Techniciens d’étude et de conseil en agriculture, eaux et forêt", 
#   "3E22a-Techniciens d’exploitation et de contrôle de la production en agriculture, eaux et forêt"                                = "471b-Techniciens d’exploitation et de contrôle de la production en agriculture, eaux et forêt", 
#   "3E21a-Techniciens employés du public "                                                                                         = "471b-Techniciens d’exploitation et de contrôle de la production en agriculture, eaux et forêt", 
#   "3E24b-Dessinateurs du BTP"                                                                                                     = "472a-Dessinateurs en bâtiment, travaux publics", 
#   "3E21a-Techniciens employés du public "                                                                                         = "472a-Dessinateurs en bâtiment, travaux publics", 
#   "3E26a-Géomètres, topographes"                                                                                                  = "472b-Géomètres, topographes", 
#   "3E21a-Techniciens employés du public "                                                                                         = "472b-Géomètres, topographes", 
#   "3E26b-Métreurs et techniciens divers du BTP"                                                                                   = "472c-Métreurs et techniciens divers du bâtiment et des travaux publics", 
#   "3E21a-Techniciens employés du public "                                                                                         = "472c-Métreurs et techniciens divers du bâtiment et des travaux publics", 
#   "3E21a-Techniciens employés du public "                                                                                         = "472d-Techniciens des travaux publics de État et des collectivités locales", 
#   "3E26c-Technicien·nes des travaux public "                                                                                      = "472d-Techniciens des travaux publics de État et des collectivités locales", 
#   "3E24c-Dessinateurs en électricité, électromécanique et électronique"                                                           = "473a-Dessinateurs en électricité, électromécanique et électronique", 
#   "3E22b-Techniciens de recherche-développement et des méthodes de fabrication en électricité, électromécanique et électronique"  = "473b-Techniciens de recherche-développement et des méthodes de fabrication en électricité, électromécanique et électronique", 
#   "3E21a-Techniciens employés du public "                                                                                         = "473b-Techniciens de recherche-développement et des méthodes de fabrication en électricité, électromécanique et électronique", 
#   "3E22c-Techniciens de fabrication et de contrôle-qualité en électricité, électromécanique et électronique"                      = "473c-Techniciens de fabrication et de contrôle-qualité en électricité, électromécanique et électronique", 
#   "3E21a-Techniciens employés du public "                                                                                         = "473c-Techniciens de fabrication et de contrôle-qualité en électricité, électromécanique et électronique", 
#   "3E24d-Dessinateurs en construction mécanique et travail des métaux"                                                            = "474a-Dessinateurs en construction mécanique et travail des métaux", 
#   "3E21a-Techniciens employés du public "                                                                                         = "474a-Dessinateurs en construction mécanique et travail des métaux", 
#   "3E22d-Techniciens de recherche-développement et des méthodes de fabrication en construction mécanique et travail des métaux"   = "474b-Techniciens de recherche-développement et des méthodes de fabrication en construction mécanique et travail des métaux", 
#   "3E21a-Techniciens employés du public "                                                                                         = "474b-Techniciens de recherche-développement et des méthodes de fabrication en construction mécanique et travail des métaux", 
#   "3E22e-Techniciens de fabrication et de contrôle-qualité en construction mécanique et travail des métaux"                       = "474c-Techniciens de fabrication et de contrôle-qualité en construction mécanique et travail des métaux", 
#   "3E21a-Techniciens employés du public "                                                                                         = "474c-Techniciens de fabrication et de contrôle-qualité en construction mécanique et travail des métaux", 
#   "3E24e-Technicien·nes de recherche-développement et des méthodes de production des industries de transformation"                = "475a-Techniciens de recherche-développement et des méthodes de production des industries de transformation", 
#   "3E21a-Techniciens employés du public "                                                                                         = "475a-Techniciens de recherche-développement et des méthodes de production des industries de transformation", 
#   "3E22f-Techniciens de production et de contrôle-qualité des industries de transformation"                                       = "475b-Techniciens de production et de contrôle-qualité des industries de transformation", 
#   "3E21a-Techniciens employés du public "                                                                                         = "475b-Techniciens de production et de contrôle-qualité des industries de transformation", 
#   "3E26d-Assistants techniques, techniciens de l’imprimerie et de l’édition"                                                      = "476a-Assistants techniques, techniciens de l’imprimerie et de l’édition", 
#   "3E21a-Techniciens employés du public "                                                                                         = "476a-Assistants techniques, techniciens de l’imprimerie et de l’édition", 
#   "3E26e-Technicien·nes de l’industrie des matériaux souples, de l’ameublement et du bois"                                        = "476b-Techniciens de l’industrie des matériaux souples, de l’ameublement et du bois", 
#   "3E21a-Techniciens employés du public "                                                                                         = "476b-Techniciens de l’industrie des matériaux souples, de l’ameublement et du bois", 
#   "3E22g-Techniciens de la logistique, du planning et de l’ordonnancement"                                                        = "477a-Techniciens de la logistique, du planning et de l’ordonnancement", 
#   "3E21a-Techniciens employés du public "                                                                                         = "477a-Techniciens de la logistique, du planning et de l’ordonnancement", 
#   "3E23a-Techniciens d’installation et de maintenance des équipements industriels "                                               = "477b-Techniciens d’installation et de maintenance des équipements industriels (électriques, électromécaniques, mécaniques, hors informatique)", 
#   "3E21a-Techniciens employés du public "                                                                                         = "477b-Techniciens d’installation et de maintenance des équipements industriels (électriques, électromécaniques, mécaniques, hors informatique)", 
#   "3E23b-Techniciens d’installation et de maintenance des équipements non industriels "                                           = "477c-Techniciens d’installation et de maintenance des équipements non industriels (hors informatique et télécommunications)", 
#   "3E21a-Techniciens employés du public "                                                                                         = "477c-Techniciens d’installation et de maintenance des équipements non industriels (hors informatique et télécommunications)", 
#   "3E26f-Techniciens de l’environnement et du traitement des pollutions"                                                          = "477d-Techniciens de l’environnement et du traitement des pollutions", 
#   "3E21a-Techniciens employés du public "                                                                                         = "477d-Techniciens de l’environnement et du traitement des pollutions", 
#   "3E25a-Techniciens d’étude et de développement en informatique"                                                                 = "478a-Techniciens d’étude et de développement en informatique", 
#   "3E21a-Techniciens employés du public "                                                                                         = "478a-Techniciens d’étude et de développement en informatique", 
#   "3E25b-Techniciens de production, d’exploitation en informatique"                                                               = "478b-Techniciens de production, d’exploitation en informatique", 
#   "3E21a-Techniciens employés du public "                                                                                         = "478b-Techniciens de production, d’exploitation en informatique", 
#   "3E25c-Techniciens d’installation, de maintenance, support et services aux utilisateurs en informatique"                        = "478c-Techniciens d’installation, de maintenance, support et services aux utilisateurs en informatique", 
#   "3E21a-Techniciens employés du public "                                                                                         = "478c-Techniciens d’installation, de maintenance, support et services aux utilisateurs en informatique", 
#   "3E25d-Techniciens des télécommunications et de l’informatique des réseaux"                                                     = "478d-Techniciens des télécommunications et de l’informatique des réseaux", 
#   "3E21a-Techniciens employés du public "                                                                                         = "478d-Techniciens des télécommunications et de l’informatique des réseaux", 
#   "3E21a-Techniciens employés du public "                                                                                         = "479a-Techniciens des laboratoires de recherche publique ou de l’enseignement", 
#   "3E24f-Technicien·nes des laboratoires "                                                                                        = "479a-Techniciens des laboratoires de recherche publique ou de l’enseignement", 
#   "3E21a-Techniciens employés du public "                                                                                         = "479b-Experts salariés ou indépendants de niveau technicien, techniciens divers", 
#   "3E26g-Experts salariés ou indépendants de niveau technicien, techniciens divers"                                               = "479b-Experts salariés ou indépendants de niveau technicien, techniciens divers", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "480a-Contremaîtres et agents d’encadrement (non cadres) en agriculture, sylviculture", 
#   "3E15a-Agents d’encadrement  de l’agriculture"                                                                                  = "480a-Contremaîtres et agents d’encadrement (non cadres) en agriculture, sylviculture", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "480b-Maîtres d’équipage de la marine marchande et de la pêche", 
#   "3E15b-Maîtres d’équipage de la marine marchande et de la pêche"                                                                = "480b-Maîtres d’équipage de la marine marchande et de la pêche", 
#   "3E12a-Conducteurs de travaux "                                                                                                 = "481a-Conducteurs de travaux (non cadres)", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "481a-Conducteurs de travaux (non cadres)", 
#   "3E12b-Chefs de chantier "                                                                                                      = "481b-Chefs de chantier (non cadres)", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "481b-Chefs de chantier (non cadres)", 
#   "3E13a-Agents de maîtrise en fabrication de matériel électrique, électronique"                                                  = "482a-Agents de maîtrise en fabrication de matériel électrique, électronique", 
#   "3E13b-Agents de maîtrise en construction mécanique, travail des métaux"                                                        = "483a-Agents de maîtrise en construction mécanique, travail des métaux", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "483a-Agents de maîtrise en construction mécanique, travail des métaux", 
#   "3E13c-Agents de maîtrise en fabrication : agroalimentaire, chimie, plasturgie, pharmacie"                                      = "484a-Agents de maîtrise en fabrication : agroalimentaire, chimie, plasturgie, pharmacie.", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "484a-Agents de maîtrise en fabrication : agroalimentaire, chimie, plasturgie, pharmacie.", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "484b-Agents de maîtrise en fabrication : métallurgie, matériaux lourds et autres industries de transformation", 
#   "3E13d-Agents de maîtrise en fabrication : métallurgie, matériaux lourds et autres industries de transformation"                = "484b-Agents de maîtrise en fabrication : métallurgie, matériaux lourds et autres industries de transformation", 
#   "3E13e-Agents de maîtrise et techniciens en production et distribution d’énergie, eau, chauffage"                               = "485a-Agents de maîtrise et techniciens en production et distribution d’énergie, eau, chauffage", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "485a-Agents de maîtrise et techniciens en production et distribution d’énergie, eau, chauffage", 
#   "3E13f-Agents de maîtrise en fabrication des autres industries "                                                                = "485b-Agents de maîtrise en fabrication des autres industries (imprimerie, matériaux souples, ameublement et bois)", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "485b-Agents de maîtrise en fabrication des autres industries (imprimerie, matériaux souples, ameublement et bois)", 
#   "3E13g-Agents de maîtrise en maintenance, installation en électricité, électromécanique et électronique"                        = "486a-Agents de maîtrise en maintenance, installation en électricité, électromécanique et électronique", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "486a-Agents de maîtrise en maintenance, installation en électricité, électromécanique et électronique", 
#   "3E13h-Agents de maîtrise en maintenance, installation en mécanique"                                                            = "486d-Agents de maîtrise en maintenance, installation en mécanique", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "486d-Agents de maîtrise en maintenance, installation en mécanique", 
#   "3E13i-Agents de maîtrise en entretien général, installation, travaux neufs "                                                   = "486e-Agents de maîtrise en entretien général, installation, travaux neufs (hors mécanique, électromécanique, électronique)", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "486e-Agents de maîtrise en entretien général, installation, travaux neufs (hors mécanique, électromécanique, électronique)", 
#   "3E14a-Responsables d’entrepôt, de magasinage"                                                                                  = "487a-Responsables d’entrepôt, de magasinage", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "487a-Responsables d’entrepôt, de magasinage", 
#   "3E14b-Responsables du tri, de l’emballage, de l’expédition et autres responsables de la manutention"                           = "487b-Responsables du tri, de l’emballage, de l’expédition et autres responsables de la manutention", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "487b-Responsables du tri, de l’emballage, de l’expédition et autres responsables de la manutention", 
#   "3H00c-Maîtrise de restauration et de cuisine"                                                                                  = "488a-Maîtrise de restauration : cuisine/production", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "488a-Maîtrise de restauration : cuisine/production", 
#   "3H00c-Maîtrise de restauration et de cuisine"                                                                                  = "488b-Maîtrise de restauration : gestion d’établissement", 
#   "3E11a-Agents de maîtrise employés du public"                                                                                   = "488b-Maîtrise de restauration : gestion d’établissement", 
#   "5D04a-Employé·es de la Poste et de France Télécom"                                                                             = "521a-Employés de la Poste", 
#   "5D04a-Employé·es de la Poste et de France Télécom"                                                                             = "521b-Employés de France Télécom (statut public)", 
#   "5C01a-Agentes des Finances publiques "                                                                                         = "522a-Agents de constatation ou de recouvrement des Impôts, du Trésor, des Douanes", 
#   "5D01a-Employées de bureau de la fonction publique"                                                                             = "523a-Adjoints administratifs de la fonction publique (y.c. enseignement)", 
#   "5D01a-Employées de bureau de la fonction publique"                                                                             = "524a-Agents administratifs de la fonction publique (y.c. enseignement)", 
#   "5H11a-Agentes de service des établissements scolaires"                                                                         = "525a-Agents de service des établissements primaires", 
#   "5H14a-Employées des services divers"                                                                                           = "525a-Agents de service des établissements primaires", 
#   "5H11a-Agentes de service des établissements scolaires"                                                                         = "525b-Agents de service des autres établissements d’enseignement", 
#   "5H14a-Employées des services divers"                                                                                           = "525b-Agents de service des autres établissements d’enseignement", 
#   "5H14a-Employées des services divers"                                                                                           = "525c-Agents de service de la fonction publique (sauf écoles, hôpitaux)", 
#   "5H11b-Autres agent·es de service de la fonction publique"                                                                      = "525c-Agents de service de la fonction publique (sauf écoles, hôpitaux)", 
#   "5H11c-Agentes de service hospitalieres"                                                                                        = "525d-Agents de service hospitaliers (de la fonction publique ou du secteur privé)", 
#   "5H14a-Employées des services divers"                                                                                           = "525d-Agents de service hospitaliers (de la fonction publique ou du secteur privé)", 
#   "5F00a-Aides-soignantes"                                                                                                        = "526a-Aides-soignants (de la fonction publique ou du secteur privé)", 
#   "5F00b-Assistantes dentaires, médicales et vétérinaires, aides de techniciennes médicales"                                      = "526b-Assistants dentaires, médicaux et vétérinaires, aides de techniciens médicaux", 
#   "5F00c-Auxiliaires de puériculture"                                                                                             = "526c-Auxiliaires de puériculture", 
#   "5F00d-Aides médico-psychologiques"                                                                                             = "526d-Aides médico-psychologiques", 
#   "5F00e-Ambulanciers"                                                                                                            = "526e-Ambulanciers salariés (du secteur public ou du secteur privé)", 
#   "5G10a-Agents de police"                                                                                                        = "531a-Agents de police de État", 
#   "5G10a-Agents de police"                                                                                                        = "531b-Agents des polices municipales", 
#   "5G32a-Surveillants pénitentiaires"                                                                                             = "531c-Surveillants de l’administration pénitentiaire", 
#   "5G22a-Gendarmes "                                                                                                              = "532a-Gendarmes (de grade inférieur à adjudant)", 
#   "5G23a-Sergents "                                                                                                               = "532b-Sergents et sous-officiers de grade équivalent des Armées (sauf pompiers militaires)", 
#   "5G23b-Militaires"                                                                                                              = "532c-Hommes du rang (sauf pompiers militaires)", 
#   "5G24a-Pompiers "                                                                                                               = "533a-Pompiers (y.c. pompiers militaires)", 
#   "5G32b-Agents techniques forestiers, gardes des espaces naturels"                                                               = "533b-Agents techniques forestiers, gardes des espaces naturels", 
#   "5G31a-Agents de sécurité"                                                                                                      = "533c-Agents de surveillance du patrimoine et des administrations", 
#   "5G31a-Agents de sécurité"                                                                                                      = "534a-Agents civils de sécurité et de surveillance", 
#   "5G31a-Agents de sécurité"                                                                                                      = "534b-Convoyeurs de fonds, gardes du corps, enquêteurs privés et métiers assimilés (salariés)", 
#   "NA"                                                                                                                            = "5400", 
#   "5D05a-Hôtesses d’accueil"                                                                                                      = "541a-Agents et hôtesses d’accueil et d’information (hors hôtellerie)", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "541a-Agents et hôtesses d’accueil et d’information (hors hôtellerie)", 
#   "5D02a-Standardistes et téléphonistes"                                                                                          = "541d-Standardistes, téléphonistes", 
#   "5D06a-Secrétaires"                                                                                                             = "542a-Secrétaires", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "542a-Secrétaires", 
#   "5D02b-Dactylos "                                                                                                               = "542b-Dactylos, sténodactylos (sans secrétariat), opérateurs de traitement de texte", 
#   "5D07a-Employées des services comptables ou financiers"                                                                         = "543a-Employés des services comptables ou financiers", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "543a-Employés des services comptables ou financiers", 
#   "5D08a-Employées administratives diverses d’entreprise"                                                                         = "543d-Employés administratifs divers d’entreprises", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "543d-Employés administratifs divers d’entreprises", 
#   "5D08b-Employé·es et opérat·rices d’exploitation en informatique"                                                               = "544a-Employés et opérateurs d’exploitation en informatique", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "544a-Employés et opérateurs d’exploitation en informatique", 
#   "5C03a-Employées des services techniques de la banque"                                                                          = "545a-Employés administratifs des services techniques de la banque", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "545a-Employés administratifs des services techniques de la banque", 
#   "5C02a-Employées des services commerciaux de la banque"                                                                         = "545b-Employés des services commerciaux de la banque", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "545b-Employés des services commerciaux de la banque", 
#   "5C03b-Employées d’assurance"                                                                                                   = "545c-Employés des services techniques des assurances", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "545c-Employés des services techniques des assurances", 
#   "5D03a-Employées de la Sécurité sociale"                                                                                        = "545d-Employés des services techniques des organismes de sécurité sociale et assimilés", 
#   "5D05b-Contrôleu·ses des transports"                                                                                            = "546a-Contrôleurs des transports (personnels roulants)", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "546a-Contrôleurs des transports (personnels roulants)", 
#   "5D05c-Agent·es des services commerciaux des transports de voyageurs et du tourisme"                                            = "546b-Agents des services commerciaux des transports de voyageurs et du tourisme", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "546b-Agents des services commerciaux des transports de voyageurs et du tourisme", 
#   "5D08c-Employé·es administrati·ves d’exploitation des transports de marchandises"                                               = "546c-Employés administratifs d’exploitation des transports de marchandises", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "546c-Employés administratifs d’exploitation des transports de marchandises", 
#   "5D05d-Agent·es d’accompagnement "                                                                                              = "546d-Hôtesses de l’air et stewards", 
#   "5D05d-Agent·es d’accompagnement "                                                                                              = "546e-Autres agents et hôtesses d’accompagnement (transports, tourisme)", 
#   "5D01b-Employées de bureau du public classées entreprise"                                                                       = "546e-Autres agents et hôtesses d’accompagnement (transports, tourisme)", 
#   "NA"                                                                                                                            = "5500", 
#   "5B13a-Employé·es de libre service du commerce et magasinier·es"                                                                = "551a-Employés de libre service du commerce et magasiniers", 
#   "5B13b-Caissières"                                                                                                              = "552a-Caissiers de magasin", 
#   "5B12a-Vendeuses non spécialisées"                                                                                              = "553a-Vendeurs non spécialisés", 
#   "5B12b-Vendeuses en alimentation"                                                                                               = "554a-Vendeurs en alimentation", 
#   "5B11a-Vendeu·ses en ameublement, décor, équipement du foyer"                                                                   = "554b-Vendeurs en ameublement, décor, équipement du foyer", 
#   "5B11b-Vendeurs en droguerie, bazar, quincaillerie, bricolage"                                                                  = "554c-Vendeurs en droguerie, bazar, quincaillerie, bricolage", 
#   "5B11c-Vendeuses du commerce de fleurs"                                                                                         = "554d-Vendeurs du commerce de fleurs", 
#   "5B11d-Vendeuses en habillement et articles de sport"                                                                           = "554e-Vendeurs en habillement et articles de sport", 
#   "5B11e-Vendeuses en produits de beauté, de luxe  et optique"                                                                    = "554f-Vendeurs en produits de beauté, de luxe (hors biens culturels) et optique", 
#   "5B11f-Vendeuses de biens culturels "                                                                                           = "554g-Vendeurs de biens culturels (livres, disques, multimédia, objets d’art)", 
#   "5B12c-Vendeu·ses de tabac, presse et articles divers"                                                                          = "554h-Vendeurs de tabac, presse et articles divers", 
#   "5B12d-Pompistes et gérant·es de station-service "                                                                              = "554j-Pompistes et gérants de station-service (salariés ou mandataires)", 
#   "5B12e-Vendeuses par correspondance"                                                                                            = "555a-Vendeurs par correspondance, télévendeurs", 
#   "5B11g-Vendeuses en gros de biens d’équipement, biens intermédiaires"                                                           = "556a-Vendeurs en gros de biens d’équipement, biens intermédiaires", 
#   "5H12a-Serveu·ses"                                                                                                              = "561a-Serveurs, commis de restaurant, garçons (bar, brasserie, café ou restaurant)", 
#   "5H11d-PSP de la FP classées privé "                                                                                            = "561a-Serveurs, commis de restaurant, garçons (bar, brasserie, café ou restaurant)", 
#   "5H12b-Aides-cuisinier·es"                                                                                                      = "561d-Aides de cuisine, apprentis de cuisine et employés polyvalents de la restauration", 
#   "5H11d-PSP de la FP classées privé "                                                                                            = "561d-Aides de cuisine, apprentis de cuisine et employés polyvalents de la restauration", 
#   "5H12c-Employées de l’hôtellerie"                                                                                               = "561e-Employés de l’hôtellerie : réception et hall", 
#   "5H11d-PSP de la FP classées privé "                                                                                            = "561e-Employés de l’hôtellerie : réception et hall", 
#   "5H12c-Employées de l’hôtellerie"                                                                                               = "561f-Employés d’étage et employés polyvalents de l’hôtellerie", 
#   "5H11d-PSP de la FP classées privé "                                                                                            = "561f-Employés d’étage et employés polyvalents de l’hôtellerie", 
#   "5H12d-Esthéticiennes "                                                                                                         = "562a-Manucures, esthéticiens (salariés)", 
#   "5H12e-Coiffeuses "                                                                                                             = "562b-Coiffeurs salariés", 
#   "5H13a-Assistantes maternelles"                                                                                                 = "563a-Assistantes maternelles, gardiennes d’enfants, familles d’accueil", 
#   "5H11d-PSP de la FP classées privé "                                                                                            = "563a-Assistantes maternelles, gardiennes d’enfants, familles d’accueil", 
#   "5H11d-PSP de la FP classées privé "                                                                                            = "563b-Aides à domicile, aides ménagères, travailleuses familiales", 
#   "5H13b-Aides à domicile"                                                                                                        = "563b-Aides à domicile, aides ménagères, travailleuses familiales", 
#   "5H13c-Employées de maison"                                                                                                     = "563c-Employés de maison et personnels de ménage chez des particuliers", 
#   "5H11d-PSP de la FP classées privé "                                                                                            = "563c-Employés de maison et personnels de ménage chez des particuliers", 
#   "5H13d-Concierges"                                                                                                              = "564a-Concierges, gardiens d’immeubles", 
#   "5H11d-PSP de la FP classées privé "                                                                                            = "564a-Concierges, gardiens d’immeubles", 
#   "5H14a-Employées des services divers"                                                                                           = "564b-Employés des services divers", 
#   "5H11d-PSP de la FP classées privé "                                                                                            = "564b-Employés des services divers", 
#   
#   "NA"                                                                                                                            = "6200", 
#   "6E11a-Chefs d’équipe du BTP"                                                                                                   = "621a-Chefs d’équipe du gros oeuvre et des travaux publics", 
#   "6E11b-Ouvriers qualifiés du travail du béton"                                                                                  = "621b-Ouvriers qualifiés du travail du béton", 
#   "6E11c-Conducteurs qualifiés d’engins de chantiers du BTP"                                                                      = "621c-Conducteurs qualifiés d’engins de chantiers du bâtiment et des travaux publics", 
#   "6E11d-Ouvriers des travaux publics en installations électriques et de télécommunications"                                      = "621d-Ouvriers des travaux publics en installations électriques et de télécommunications", 
#   "6E11e-Autres ouvriers qualifiés des travaux publics"                                                                           = "621e-Autres ouvriers qualifiés des travaux publics", 
#   "6E11f-Ouvriers qualifiés des travaux publics "                                                                                 = "621f-Ouvriers qualifiés des travaux publics (salariés de État et des collectivités locales)", 
#   "6E10a-Mineurs de fond qualifiés"                                                                                               = "621g-Mineurs de fond qualifiés et autres ouvriers qualifiés des industries d’extraction (carrières, pétrole, gaz...)", 
#   "6E12a-Opérat·rices qualifié·es sur machines automatiques en production électrique ou électronique"                             = "622a-Opérateurs qualifiés sur machines automatiques en production électrique ou électronique", 
#   "6E12b-Câbleurs et bobiniers"                                                                                                   = "622b-Câbleurs qualifiés, bobiniers qualifiés", 
#   "6E12c-Plateformistes, contrôleu·ses qualifié·es de matériel électrique ou électronique"                                        = "622g-Plateformistes, contrôleurs qualifiés de matériel électrique ou électronique", 
#   "6E13a-Chaudronniers, forgerons, traceurs"                                                                                      = "623a-Chaudronniers-tôliers industriels, opérateurs qualifiés du travail en forge, conducteurs qualifiés d’équipement de formage, traceurs qualifiés", 
#   "6E13b-Tuyauteurs industriels qualifiés"                                                                                        = "623b-Tuyauteurs industriels qualifiés", 
#   "6E13c-Soudeurs qualifiés sur métaux"                                                                                           = "623c-Soudeurs qualifiés sur métaux", 
#   "6E13d-Opérateurs qualifiés d’usinage des métaux travaillant à l’unité ou en petite série, moulistes qualifiés"                 = "623f-Opérateurs qualifiés d’usinage des métaux travaillant à l’unité ou en petite série, moulistes qualifiés", 
#   "6E13e-Opérateurs qualifiés d’usinage des métaux sur autres machines "                                                          = "623g-Opérateurs qualifiés d’usinage des métaux sur autres machines (sauf moulistes)", 
#   "6E13f-Monteurs qualifiés d’ensembles mécaniques"                                                                               = "624a-Monteurs qualifiés d’ensembles mécaniques", 
#   "6E13g-Monteurs qualifiés en structures métalliques"                                                                            = "624d-Monteurs qualifiés en structures métalliques", 
#   "6E13h-Ouvrier·es qualifié·es de contrôle et d’essais en mécanique"                                                             = "624e-Ouvriers qualifiés de contrôle et d’essais en mécanique", 
#   "6E13i-Ouvriers qualifiés des traitements thermiques et de surface sur métaux"                                                  = "624f-Ouvriers qualifiés des traitements thermiques et de surface sur métaux", 
#   "6E13j-Autres mécaniciens ou ajusteurs qualifiés "                                                                              = "624g-Autres mécaniciens ou ajusteurs qualifiés (ou spécialité non reconnue)", 
#   "6E15a-Pilotes d’installation lourde des industries de transformation : agroalimentaire, chimie, plasturgie, énergie"           = "625a-Pilotes d’installation lourde des industries de transformation : agroalimentaire, chimie, plasturgie, énergie", 
#   "6E15b-Ouvriers de laboratoire "                                                                                                = "625b-Ouvriers qualifiés et agents qualifiés de laboratoire : agroalimentaire, chimie, biologie, pharmacie", 
#   "6E15b-Ouvriers de laboratoire "                                                                                                = "625c-Autres opérateurs et ouvriers qualifiés de la chimie (y.c. pharmacie) et de la plasturgie", 
#   "6E15c-Ouvrier·es des abattoirs"                                                                                                = "625d-Opérateurs de la transformation des viandes", 
#   "6E15d-Autres ouvriers  de l’industrie agro-alimentaire"                                                                        = "625e-Autres opérateurs et ouvriers qualifiés de l’industrie agricole et alimentaire (hors transformation des viandes)", 
#   "6E19a-Ouvriers qualifiés des autres industries "                                                                               = "625h-Ouvriers qualifiés des autres industries (eau, gaz, énergie, chauffage)", 
#   "6E15e-Ouvriers des industries de transformation "                                                                              = "626a-Pilotes d’installation lourde des industries de transformation : métallurgie, production verrière, matériaux de construction", 
#   "6E15e-Ouvriers des industries de transformation "                                                                              = "626b-Autres opérateurs et ouvriers qualifiés : métallurgie, production verrière, matériaux de construction", 
#   "6E15f-Opérateurs et ouvriers qualifiés des industries lourdes du bois et de la fabrication du papier-carton"                   = "626c-Opérateurs et ouvriers qualifiés des industries lourdes du bois et de la fabrication du papier-carton", 
#   "6E16a-Opérat·rices qualifié·es du textile et de la mégisserie"                                                                 = "627a-Opérateurs qualifiés du textile et de la mégisserie", 
#   "6E16b-Ouvrier·es qualifié·es de la coupe des vêtements et de l’habillement, autres opérat·rices de confection qualifié·es"     = "627b-Ouvriers qualifiés de la coupe des vêtements et de l’habillement, autres opérateurs de confection qualifiés", 
#   "6E16c-Ouvrier·es qualifié·es du travail industriel du cuir"                                                                    = "627c-Ouvriers qualifiés du travail industriel du cuir", 
#   "6E17a-Ouvriers qualifiés de scierie, de la menuiserie industrielle et de l’ameublement"                                        = "627d-Ouvriers qualifiés de scierie, de la menuiserie industrielle et de l’ameublement", 
#   "6E14a-Ouvrier·es de la photogravure et des laboratoires photographiques et cinématographiques"                                 = "627e-Ouvriers de la photogravure et des laboratoires photographiques et cinématographiques", 
#   "6E14b-Ouvriers de l’impression"                                                                                                = "627f-Ouvriers de la composition et de l’impression, ouvriers qualifiés de la brochure, de la reliure et du façonnage du papier-carton", 
#   "6E18a-Mécaniciens qualifiés de maintenance, entretien : équipements industriels"                                               = "628a-Mécaniciens qualifiés de maintenance, entretien : équipements industriels", 
#   "6E18b-Electromécaniciens, électriciens qualifiés d’entretien : équipements industriels"                                        = "628b-Electromécaniciens, électriciens qualifiés d’entretien : équipements industriels", 
#   "6E18c-Régleurs qualifiés d’équipements de fabrication "                                                                        = "628c-Régleurs qualifiés d’équipements de fabrication (travail des métaux, mécanique)", 
#   "6E18d-Régleurs qualifiés d’équipements de fabrication "                                                                        = "628d-Régleurs qualifiés d’équipements de fabrication (hors travail des métaux et mécanique)", 
#   "6E19b-Ouvriers qualifiés de l’assainissement et du traitement des déchets"                                                     = "628e-Ouvriers qualifiés de l’assainissement et du traitement des déchets", 
#   "6E19c-Agent·es qualifié·es de laboratoire "                                                                                    = "628f-Agents qualifiés de laboratoire (sauf chimie, santé)", 
#   "6E19d-Ouvriers qualifiés divers de type industriel"                                                                            = "628g-Ouvriers qualifiés divers de type industriel", 
#   "6E21a-Jardiniers"                                                                                                              = "631a-Jardiniers", 
#   "6E23a-Maçons qualifiés"                                                                                                        = "632a-Maçons qualifiés", 
#   "6E23b-Ouvriers qualifiés du travail de la pierre"                                                                              = "632b-Ouvriers qualifiés du travail de la pierre", 
#   "6E22a-Charpentiers en bois qualifiés"                                                                                          = "632c-Charpentiers en bois qualifiés", 
#   "6E22b-Menuisiers qualifiés du bâtiment"                                                                                        = "632d-Menuisiers qualifiés du bâtiment", 
#   "6E23c-Couvreurs qualifiés"                                                                                                     = "632e-Couvreurs qualifiés", 
#   "6E23d-Plombiers et chauffagistes qualifiés"                                                                                    = "632f-Plombiers et chauffagistes qualifiés", 
#   "6E23e-Ouvriers qualifiés des finitions du BTP"                                                                                 = "632g-Peintres et ouvriers qualifiés de pose de revêtements sur supports verticaux", 
#   "6E23e-Ouvriers qualifiés des finitions du BTP"                                                                                 = "632h-Soliers moquetteurs et ouvriers qualifiés de pose de revêtements souples sur supports horizontaux", 
#   "6E23f-Monteurs qualifiés en agencement, isolation"                                                                             = "632j-Monteurs qualifiés en agencement, isolation", 
#   "6E23g-Ouvriers qualifiés d’entretien général des bâtiments"                                                                    = "632k-Ouvriers qualifiés d’entretien général des bâtiments", 
#   "6E24a-Électriciens qualifiés de type artisanal "                                                                               = "633a-Électriciens qualifiés de type artisanal (y.c. bâtiment)", 
#   "6E24b-Dépanneurs qualifiés en radiotélévision, électroménager, matériel électronique "                                         = "633b-Dépanneurs qualifiés en radiotélévision, électroménager, matériel électronique (salariés)", 
#   "6E24c-Électriciens, électroniciens qualifiés d’entretien d’équipements non industriels"                                        = "633c-Électriciens, électroniciens qualifiés en maintenance entretien, réparation : automobile", 
#   "6E24d-Électriciens, électroniciens qualifiés d’entretien d’équipements non industriels"                                        = "633d-Électriciens, électroniciens qualifiés en maintenance, entretien : équipements non industriels", 
#   "6E25a-Carrossiers d’automobiles qualifiés"                                                                                     = "634a-Carrossiers d’automobiles qualifiés", 
#   "6E25b-Métalliers, serruriers qualifiés"                                                                                        = "634b-Métalliers, serruriers qualifiés", 
#   "6E25c-Mécaniciens qualifiés en maintenance, entretien, réparation : automobile"                                                = "634c-Mécaniciens qualifiés en maintenance, entretien, réparation : automobile", 
#   "6E25d-Mécaniciens qualifiés en maintenance, entretien, réparation : automobile"                                                = "634d-Mécaniciens qualifiés de maintenance, entretien : équipements non industriels", 
#   "6E26a-Tailleuses et couturières qualifiées "                                                                                   = "635a-Tailleurs et couturières qualifiés, ouvriers qualifiés du travail des étoffes (sauf fabrication de vêtements), ouvriers qualifiés de type artisanal du travail du cuir", 
#   "6E27a-Bouchers "                                                                                                               = "636a-Bouchers (sauf industrie de la viande)", 
#   "6E27b-Charcutiers "                                                                                                            = "636b-Charcutiers (sauf industrie de la viande)", 
#   "6E27c-Boulangers, pâtissiers "                                                                                                 = "636c-Boulangers, pâtissiers (sauf activité industrielle)", 
#   "6E27d-Cuisiniers et commis de cuisine"                                                                                         = "636d-Cuisiniers et commis de cuisine", 
#   "6E28a-Modeleuses et mouleuses"                                                                                                 = "637a-Modeleurs (sauf modeleurs de métal), mouleurs-noyauteurs à la main, ouvriers qualifiés du travail du verre ou de la céramique à la main", 
#   "6E28b-Ouvrier·es d’art"                                                                                                        = "637b-Ouvriers d’art", 
#   "6E28c-Ouvriers et techniciens des spectacles vivants et audiovisuels"                                                          = "637c-Ouvriers et techniciens des spectacles vivants et audiovisuels", 
#   "6E28d-Ouvrier·es qualifié·es divers·es de type artisanal"                                                                      = "637d-Ouvriers qualifiés divers de type artisanal", 
#   "6E31a-Conducteurs routiers et grands routiers "                                                                                = "641a-Conducteurs routiers et grands routiers (salariés)", 
#   "6E32a-Conducteurs routiers de transport en commun "                                                                            = "641b-Conducteurs de véhicule routier de transport en commun (salariés)", 
#   "6E33a-Conducteurs de taxi "                                                                                                    = "642a-Conducteurs de taxi (salariés)", 
#   "6E33b-Conducteurs de voiture particulière "                                                                                    = "642b-Conducteurs de voiture particulière (salariés)", 
#   "6E52a-Coursiers et livreurs"                                                                                                   = "643a-Conducteurs livreurs, coursiers (salariés)", 
#   "6E34a-Conducteurs de véhicule de ramassage des ordures ménagères"                                                              = "644a-Conducteurs de véhicule de ramassage des ordures ménagères", 
#   "NA"                                                                                                                            = "6500", 
#   "6E34b-Conducteurs d’engin lourd"                                                                                               = "651a-Conducteurs d’engin lourd de levage", 
#   "6E34b-Conducteurs d’engin lourd"                                                                                               = "651b-Conducteurs d’engin lourd de manoeuvre", 
#   "6E51a-Manutentionnaires, magasiniers, caristes"                                                                                = "652a-Ouvriers qualifiés de la manutention, conducteurs de chariots élévateurs, caristes", 
#   "6E35a-Dockers"                                                                                                                 = "652b-Dockers", 
#   "6E51a-Manutentionnaires, magasiniers, caristes"                                                                                = "653a-Magasiniers qualifiés", 
#   "6E34c-Conducteurs de trains"                                                                                                   = "654a-Conducteurs qualifiés d’engins de transport guidés", # Mélange trains et remontées mécaniques !
#   "6E36a-Autres agents et ouvriers qualifiés  des services d’exploitation des transports"                                         = "655a-Autres agents et ouvriers qualifiés (sédentaires) des services d’exploitation des transports", 
#   "6E35b-Matelots de la marine marchande et de la navigation fluviale"                                                            = "656a-Matelots de la marine marchande, capitaines et matelots timoniers de la navigation fluviale (salariés)", 
#   "6E41a-Ouvriers non qualifiés des travaux publics "                                                                             = "671a-Ouvriers non qualifiés des travaux publics de État et des collectivités locales", 
#   "6E41b-Ouvriers non qualifiés des travaux publics, du travail du béton et de l’extraction "                                     = "671b-Ouvriers non qualifiés des travaux publics, du travail du béton et de l’extraction, hors État et collectivités locales", 
#   "6E42a-Ouvrier·es non qualifié·es de l’électricité et de l’électronique"                                                        = "672a-Ouvriers non qualifiés de l’électricité et de l’électronique", 
#   "6E43a-Ouvriers de production non qualifiés travaillant par enlèvement de métal"                                                = "673a-Ouvriers de production non qualifiés travaillant par enlèvement de métal", 
#   "6E43b-Ouvriers de production non qualifiés travaillant par formage de métal"                                                   = "673b-Ouvriers de production non qualifiés travaillant par formage de métal", 
#   "6E43c-Ouvriers non qualifiés de montage, contrôle en mécanique et travail des métaux"                                          = "673c-Ouvriers non qualifiés de montage, contrôle en mécanique et travail des métaux", 
#   "6E44a-Ouvrier·es de production non qualifié·es : chimie, pharmacie, plasturgie"                                                = "674a-Ouvriers de production non qualifiés : chimie, pharmacie, plasturgie", 
#   "6E44b-ONQ des abattoirs"                                                                                                       = "674b-Ouvriers de production non qualifiés de la transformation des viandes", 
#   "6E44c-Autres ONQ des industries agro-alimentaires"                                                                             = "674c-Autres ouvriers de production non qualifiés : industrie agro-alimentaire", 
#   "6E44d-Ouvriers de production non qualifiés : métallurgie, production verrière, céramique, matériaux de construction"           = "674d-Ouvriers de production non qualifiés : métallurgie, production verrière, céramique, matériaux de construction", 
#   "6E44e-Ouvriers de production non qualifiés : industrie lourde du bois, fabrication des papiers et cartons"                     = "674e-Ouvriers de production non qualifiés : industrie lourde du bois, fabrication des papiers et cartons", 
#   "6E45a-Ouvrier·es non qualifié·es du textile"                                                                                   = "675a-Ouvriers de production non qualifiés du textile et de la confection, de la tannerie-mégisserie et du travail du cuir", 
#   "6E46a-Ouvriers de production non qualifiés du travail du bois et de l’ameublement"                                             = "675b-Ouvriers de production non qualifiés du travail du bois et de l’ameublement", 
#   "6E46b-Ouvrier·es non qualifié·es de l’imprimerie, presse, édition"                                                             = "675c-Ouvriers de production non qualifiés de l’imprimerie, presse, édition", 
#   "6E51a-Manutentionnaires, magasiniers, caristes"                                                                                = "676a-Manutentionnaires non qualifiés", 
#   "6E53a-Déménageurs non qualifiés"                                                                                               = "676b-Déménageurs (hors chauffeurs-déménageurs), non qualifiés", 
#   "6E53b-ONQ du tri, de l’emballage, de l’expédition"                                                                             = "676c-Ouvriers du tri, de l’emballage, de l’expédition, non qualifiés", 
#   "6E46c-Agents non qualifiés des services d’exploitation des transports"                                                         = "676d-Agents non qualifiés des services d’exploitation des transports", 
#   "6E46d-Ouvrier·es non qualifié·es divers·es de type industriel"                                                                 = "676e-Ouvriers non qualifiés divers de type industriel", 
#   "6E61a-Ouvriers non qualifiés du gros oeuvre du bâtiment"                                                                       = "681a-Ouvriers non qualifiés du gros oeuvre du bâtiment", 
#   "6E61b-Ouvriers non qualifiés du second oeuvre du bâtiment"                                                                     = "681b-Ouvriers non qualifiés du second oeuvre du bâtiment", 
#   "6E62a-Métalliers, serruriers, réparateurs en mécanique non qualifiés"                                                          = "682a-Métalliers, serruriers, réparateurs en mécanique non qualifiés", 
#   "6E63a-Apprentis boulangers, bouchers, charcutiers"                                                                             = "683a-Apprentis boulangers, bouchers, charcutiers", 
#   "6E64a-Nettoyeuses"                                                                                                             = "684a-Nettoyeurs", 
#   "6E64b-Ouvriers non qualifiés de l’assainissement et du traitement des déchets"                                                 = "684b-Ouvriers non qualifiés de l’assainissement et du traitement des déchets", 
#   "6E65a-Ouvrier·es non qualifié·es divers·es de type artisanal"                                                                  = "685a-Ouvriers non qualifiés divers de type artisanal", 
#   "7K20a-Conducteurs d’engin agricole ou forestier"                                                                               = "691a-Conducteurs d’engin agricole ou forestier", 
#   "7K20b-Ouvrier·es de l’élevage"                                                                                                 = "691b-Ouvriers de l’élevage", 
#   "7K20c-Ouvrier·es du maraîchage ou de l’horticulture"                                                                           = "691c-Ouvriers du maraîchage ou de l’horticulture", 
#   "7K20d-Ouvriers de la viticulture ou de l’arboriculture fruitière"                                                              = "691d-Ouvriers de la viticulture ou de l’arboriculture fruitière", 
#   "7K20e-Ouvriers agricoles sans spécialisation particulière"                                                                     = "691e-Ouvriers agricoles sans spécialisation particulière", 
#   "7K20f-Ouvriers de l’exploitation forestière ou de la sylviculture"                                                             = "691f-Ouvriers de l’exploitation forestière ou de la sylviculture", 
#   "7K20g-Marins pêcheurs et ouvriers de l’aquaculture"                                                                            = "692a-Marins-pêcheurs et ouvriers de l’aquaculture", 
#   "NA"                                                                                                                            = "NA",
#  )










# source("~\\socio_public_services\\Demarrage.R")


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
               '311a' = '4F21a', '311b' = '4F21b', '311c' = '4F21c', '311e' = '4F21d', '344b' = '4F21e', 
               '344a' = '4F10a', '344c' = '4F10b', '431e' = '4F43a', '311f' = '4F44a', '344d' = '4F44b', 
               '311d' = '4F45a', '343a' = '4F45b', '342a' = '4I11a', '342e' = '4I12a', '421a' = '4I14a', 
               '421b' = '4I14a', '341a' = '4I13a', '422a' = '4I13b', '422b' = '4I13c', '422c' = '4I13d', 
               '422d' = '4I31a', '352b' = '4J11a', '354a' = '4J11b', '354b' = '4J11c', '354c' = '4J11d', 
               '354d' = '4J11d', '353c' = '4J12a', '354g' = '4J13a', '312a' = '4J21a', '312b' = '4J21b', 
               '312f' = '4J21c', '352a' = '4J22a', '335a' = '4J24a', '312g' = '4J25a', 
               '313a' = '4J25b', '451d' = '2E23a', '351a' = '2J01a', '376f' = '2D27a', 
               '333c' = '2D28a', '333d' = '2D28a', '431b' = '4F30a', '431c' = '4F30b', '431d' = '4F30c', 
               '431f' = '4F30d', '431g' = '4F30d', '432a' = '4F42a', '432b' = '4F42a', '432c' = '4F42a', 
               '432d' = '4F42a', '433a' = '3F00a', '433b' = '3F00a', '433c' = '3F00a', '433d' = '3F00b', 
               '434b' = '4I22a', '434c' = '4I23a', '434d' = '4I21a', '434e' = '4I21b', '434f' = '4I21c', 
               '434g' = '4I21d', '422e' = '4I32a', '423a' = '3I10a', '423b' = '3I10b', '424a' = '4I33a', 
               '435b' = '4I34a', '441a' = '4I35a', '441b' = '4I35a', '451a' = '3D08a', 
               '451b' = '3D08a', '531a' = '5G10a', '531b' = '5G10a', '532a' = '5G22a', '532b' = '5G23a', 
               '532c' = '5G23b', '533a' = '5G24a', '531c' = '5G32a', '533b' = '5G31b', '523a' = '5D01a', 
               '524a' = '5D01a', '522a' = '5C01a', '545d' = '5D03a', '521a' = '5D04a', '521b' = '5D04a', 
               '554b' = '5B11a', '554c' = '5B11b', '554d' = '5B11c', '554e' = '5B11d', '554f' = '5B11e', 
               '554g' = '5B11f', '556a' = '5B11g', '526a' = '5F01a', '526b' = '5F05a', '526c' = '5F02a', 
               '526d' = '5F03a', '526e' = '5F04a', '562a' = '5H12d', '562b' = '5H12e', '533c' = '5G31a', 
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
               '3111' = '4F21a', '3112' = '4F21b', '3113' = '4F21c', '3115' = '4F21d', '3432' = '4F21e', 
               '3431' = '4F10a', '3434' = '4F10b', '4321' = '4F43a', '3116' = '4F44a', '3435' = '4F44b', 
               '3114' = '4F45a', '3433' = '4F45b', '3415' = '4I11a', '3421' = '4I12a', '4211' = '4I14a', 
               '4215' = '4I14a', '4214' = '4I14a', '3411' = '4I13a', '4221' = '4I13b', '4224' = '4I13c', 
               '3512' = '4J11a', '3531' = '4J11b', '3532' = '4J11c', '3535' = '4J11c', '3533' = '4J11d', 
               '3523' = '4J12a', '3522' = '4J12a', '3534' = '4J13a', '3121' = '4J21a', '3122' = '4J21b', 
               '3127' = '4J21c', '3511' = '4J22a', '3318' = '4J24a', '3128' = '4J25a', 
               '3130' = '4J25b', '3513' = '2J01a', '3315' = '2D28a', '4312' = '4F30a', 
               '4313' = '4F30b', '4314' = '4F30c', '4315' = '4F30d', '4316' = '4F30d', '4322' = '4F42a', 
               '4323' = '4F42a', '4324' = '3F00a', '4325' = '3F00a', '4326' = '3F00a', '4327' = '3F00b', 
               '4331' = '4I22a', '4334' = '4I23a', '4332' = '4I21a', '4227' = '4I32a', '4232' = '3I10b', 
               '4233' = '4I33a', '4333' = '4I34a', '4411' = '4I35a', '4412' = '4I35a', '4511' = '3D08a', 
               '5311' = '5G10a', '5312' = '5G22a', '5313' = '5G23a', '5314' = '5G23b', '5315' = '5G24a', 
               '5316' = '5G31b', '5214' = '5D01a', '5215' = '5D01a', '5213' = '5C01a', '5211' = '5D04a', 
               '5212' = '5D04a', '5513' = '5B11a', '5515' = '5B11b', '5514' = '5B11d', '5516' = '5B11e', 
               '5517' = '5B11f', '5511' = '5B11g', '5221' = '5F01a', '5223' = '5F04a', '5621' = '5H12d', 
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
               '434a' = '2I21a', '353a' = '2J02a', '353b' = '2J02a', '451e' = '3D01a', '451f' = '3D01a', 
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
               '563a' = '5H11d', '563b' = '5H11d', '563c' = '5H11d', '564a' = '5H11d', '564b' = '5H11d',
               '333a' = '2D25a', '435a' = '2I21b', '452a' = '2G00b' #,
               ), 
             
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
               '5631' = '5H11d', '5632' = '5H11d', '5633' = '5H11d', '5634' = '5H11d', 
               '3313' = '2D25a', '4521' = '2G00b' #,
               )
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
               '372a' = '2D26j', '372b' = '2D26a', '372c' = '2D26b', '372d' = '2D26b', '372e' = '2D26c', 
               '373a' = '2D26d', '373b' = '2D26e', '373c' = '2D26f', '373d' = '2D26g', '374b' = '2D26h', 
               '375a' = '2D26i', '375b' = '2D26i', '387a' = '2E29a', '387b' = '2E29b', '387c' = '2E29c', 
               '387d' = '2E29d', '376a' = '2C04a', '376b' = '2C03a', '376c' = '2C02a', '376d' = '2C04b', 
               '376e' = '2C03b', '374a' = '2B02a', '374c' = '2B01a', '374d' = '2B01b', '376g' = '2B03a', 
               '382d' = '2B04a', '383c' = '2B04b', '384c' = '2B04c', '385c' = '2B04d', '388d' = '2B04e', 
               '381a' = '2E26a', '382a' = '2E26b', '382b' = '2E26c', '383a' = '2E26d', '384a' = '2E26e', 
               '385a' = '2E26f', '386a' = '2E26g', '387e' = '2E26h', '387f' = '2E26i', '388e' = '2E26j', 
               '388a' = '2E27a', '388b' = '2E27b', '388c' = '2E27c', '341b' = '2I12a', '353a' = '2J03a', 
               '353b' = '2J03a', '372f' = '2D29a', '389b' = '2E28a', '389c' = '2E28b', '331a' = '2D29b', 
               '332a' = '2D29b', '332b' = '2D29b', '333b' = '2D29b', '333e' = '2D29b', '333f' = '2D29b', 
               '334a' = '2D29b', '431a' = '2F02a', '434a' = '2I22a', '461a' = '3D02a', '461d' = '3D03a', 
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
               '525a' = '5H14a', '525b' = '5H14a', '525c' = '5H14a', '525d' = '5H14a', '564b' = '5H14a',
               '333a' = '2D29b', '435a' = '2I22a', '452a' = '2D29b' #,
             ), 
             
             "1982" = c(
               '3710' = '2D22a', '3810' = '2E21a', '3751' = '2H00a', '3833' = '2E25b', '3831' = '2E25c', 
               '3836' = '2E25d', '3832' = '2E25d', '3835' = '2E25e', '3837' = '2E25e', '3839' = '2E25f', 
               '3838' = '2E25g', '3861' = '2E25h', '3721' = '2D26j', '3723' = '2D26a', '3725' = '2D26b', 
               '3722' = '2D26b', '3724' = '2D26d', '3726' = '2D26e', '3727' = '2D26f', '3732' = '2D26h', 
               '3735' = '2D26i', '3842' = '2E29a', '3843' = '2E29b', '3741' = '2C03a', '3744' = '2C03b', 
               '3731' = '2B02a', '3733' = '2B01a', '3734' = '2B01b', '3853' = '2B04a', '3851' = '2B04b', 
               '3852' = '2B04c', '3854' = '2B04d', '3855' = '2B04e', '3820' = '2E26a', '3823' = '2E26b', 
               '3824' = '2E26c', '3821' = '2E26d', '3822' = '2E26e', '3825' = '2E26f', '3826' = '2E26f', 
               '3827' = '2E26f', '3829' = '2E26g', '3841' = '2E26h', '3828' = '2E27a', '3414' = '2I12a', 
               '3521' = '2J03a', '3728' = '2D29a', '3862' = '2E28a', '3863' = '2E28b', '3311' = '2D29b', 
               '3312' = '2D29b', '3314' = '2D29b', '3317' = '2D29b', '3316' = '2D29b', '3321' = '2D29b', 
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
               '5216' = '5H14a', '5217' = '5H14a', '5222' = '5H14a', '5634' = '5H14a',
               '3313' = '2D29b', '4521' = '2D29b' #,
               )
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
                      '2D26a' = paste0('2D26a-Cadres de l’organisation ou du contrôle des services administratifs et financiers ', b), 
                      '2D26b' = paste0('2D26b-Cadres des ressources humaines (dont recrutement et formation) ', b), 
                      '2D26c' = paste0('2D26c-Juristes ', f), 
                      '2D26d' = paste0('2D26d-Cadres des services financiers ou comptables des grandes entreprises ', b), 
                      '2D26e' = paste0('2D26e-Cadres des autres services administratifs des grandes entreprises ', b), 
                      '2D26f' = paste0('2D26f-Cadres des services financiers ou comptables des PME ', b), 
                      '2D26g' = paste0('2D26g-Cadres des autres services administratifs des PME ', b), 
                      '2D26h' = '2D26h-Chef\\u00b7fes de produits, achet\\u00b7rices du commerce et autres cadres de la mercatique', 
                      '2D26i' = paste0('2D26i-Cadres de la communication (publicité, relations publiques) ', f), 
                      '2D27a' = paste0('2D27a-Cadres de la Sécurité sociale ', f), 
                      '2D28a' = paste0('2D28a-Cadres de la Poste/FT ', b), 
                      '2D29a' = paste0('2D29a-Cadres de la documentation, de l’archivage ', f), 
                      '2D29b' = '2D29b-Autres cadres d’entreprises classé\\u00b7es fonction publique', 
                      '2E21a' = '2E21a-Directeurs techniques des grandes entreprises', 
                      '2E22a' = '2E22a-Ingénieurs conseils libéraux en études techniques', 
                      '2E23a' = '2E23a-Ingénieur\\u00b7es publi\\u00b7ques', 
                      '2E23b' = '2E23b-Ingénieur\\u00b7es publi\\u00b7ques classé\\u00b7es entreprise', 
                      '2D26j' = '2D26j-Cadres chargé\\u00b7es d’études économiques, financières, commerciales', 
                      '2E29a' = '2E29a-Ingénieurs et cadres des achats et approvisionnements industriels', 
                      '2E29b' = '2E29b-Ingénieurs et cadres de la logistique, du planning et de l’ordonnancement', 
                      '2E29c' = '2E29c-Ingénieurs et cadres des méthodes de production', 
                      '2E29d' = '2E29d-Ingénieur\\u00b7es et cadres du contrôle-qualité', 
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
                      '2I21a' = '2I21a-Cadres publi\\u00b7ques de l’intervention sociale', 
                      '2I22a' = '2I22a-Cadres associati\\u00b7ves (ou privé\\u00b7es lucrati\\u00b7ves) de l’intervention sociale', 
                      '2I21b' = '2I21b-Direct\\u00b7rices de centres socioculturels et de loisirs', 
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
                      '3F00a' = '3F00a-Technicien\\u00b7nes médica\\u00b7les', 
                      '3F00b' = '3F00b-Préparatrices en pharmacie', 
                      '3H00a' = paste0('3H00a-Maîtrise de restauration : salle et service ', b), 
                      '3H00b' = paste0('3H00b-Maîtrise de l’hébergement : hall et étages ', b), 
                      '3H00c' = paste0('3H00c-Maîtrise de restauration et de cuisine ', m), 
                      '4F10a' = '4F10a-Médecins hospitalier\\u00b7es sans activité libérale', 
                      '4F10b' = paste0('4F10b-Internes en médecine, odontologie et pharmacie ', b), 
                      '4F30a' = '4F30a-Infirmières psychiatriques', 
                      '4F30b' = '4F30b-Puéricultrices', 
                      '4F30c' = '4F30c-Infirmières spécialisées (autres)', 
                      '4F30d' = '4F30d-Infirmières (en soins généraux)', 
                      '4F21a' = '4F21a-Médecins libéra\\u00b7les spécialistes', 
                      '4F21b' = '4F21b-Médecins libéra\\u00b7les généralistes', 
                      '4F21c' = '4F21c-Chirurgien\\u00b7nes dentistes (libéra\\u00b7les ou salarié\\u00b7es)', 
                      '4F21d' = '4F21d-Vétérinaires (libéra\\u00b7les ou salarié\\u00b7es)', 
                      '4F21e' = '4F21e-Médecins salarié\\u00b7es non hospitalier\\u00b7es', 
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
                      '4I31a' = '4I31a-Conseillères principales d’éducation', 
                      '4I32a' = '4I32a-Assistantes d’éducation', 
                      '4I14a' = '4I14a-Professeures des écoles', 
                      '4I21a' = '4I21a-Éducatrices spécialisées', 
                      '4I21b' = '4I21b-Monit\\u00b7rices Éducat\\u00b7rices', 
                      '4I21c' = '4I21c-Éducat\\u00b7rices techniques spécialisé\\u00b7es, monit\\u00b7rices d’atelier', 
                      '4I21d' = '4I21d-Éducatrices de jeunes enfants', 
                      '4I22a' = '4I22a-Assistantes sociales', 
                      '4I23a' = '4I23a-Conseillères en économie sociale familiale', 
                      '4I34a' = '4I34a-Animatrices socioculturels et de loisirs', 
                      '3I10a' = '3I10a-Monit\\u00b7rices d’école de conduite', 
                      '3I10b' = '3I10b-Format\\u00b7rices et animat\\u00b7rices de formation continue', 
                      '4I33a' = '4I33a-Éducat\\u00b7rices sporti\\u00b7ves (et sporti\\u00b7ves professionnel\\u00b7les)', 
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
                      '2D25a' = '2D25a-Magistrat\\u00b7es', 
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
                      '5F01a' = '5F01a-Aides-soignantes', 
                      '5F05a' = '5F05a-Assistantes dentaires, médicales et vétérinaires, aides de techniciennes médicales', 
                      '5F02a' = paste0('5F02a-Auxiliaires de puériculture ', f), 
                      '5F03a' = paste0('5F03a-Aides médico-psychologiques ', f), 
                      '5F04a' = '5F04a-Ambulanciers', 
                      '5G10a' = '5G10a-Agents de police', 
                      '5G21a' = '5G21a-Adjudants-chefs, adjudants et sous-officiers de rang supérieur de l’Armée et de la Gendarmerie', 
                      '5G22a' = paste0('5G22a-Gendarmes (grade < adjudant) ', m), 
                      '5G23a' = '5G23a-Sergents (et autres sous-officiers)', 
                      '5G23b' = paste0('5G23b-Militaires ', m), 
                      '5G24a' = '5G24a-Pompiers (dont militaires)', 
                      '5G31a' = '5G31a-Agents de sécurité', 
                      '5G32a' = '5G32a-Surveillants pénitentiaires', 
                      '5G31b' = '5G31b-Agents techniques forestiers, gardes des espaces naturels', 
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
      '2H0', paste0('Cadres hôtellerie restauration ', f)       , paste0('Cadres hôtellerie restauration ', m)       , paste0('Cadres hôtellerie restauration ', b)                    ,
      '2I1', 'Proviseures et inspectrices EN'                   , 'Proviseurs et inspecteurs EN'                     , 'Proviseur\\u00b7es et inspecteurs/trices EN'                  ,
      '2I2', paste0('Cadres du social ', f)                     , paste0('Cadres du social ', m)                     , paste0('Cadres du social ', b)                                 ,
      '2J0', paste0('Cadres de la culture ', f)                 , paste0('Cadres de la culture ', m)                 , paste0('Cadres de la culture ', b)                              ,
      '3B1', paste0('CBS commerce ', f)                         , paste0('CBS commerce ', m)                         , paste0('CBS commerce ', b)                                ,
      '3B2', 'Moyennes commerçantes'                            , 'Moyens commerçants'                               , 'Moyen\\u00b7nes commerçant\\u00b7es'         ,
      '3C0', 'Contrôleuses FiP / CBS banque'                    , 'Contrôleurs FiP / CBS banque'                     , 'Contrôleurs/leuses FiP, CBS banque'                  ,
      '3D0', paste0('CBS de bureau ', f)                        , paste0('CBS de bureau ', m)                        , paste0('CBS de bureau ', b)                                 ,
      '3E1', paste0('Maîtrise ', f)                             , paste0('Maîtrise ', m)                             , paste0('Maîtrise ', b)                                      ,
      '3E2', 'Techniciennes'                                    , 'Techniciens'                                      , 'Technicien\\u00b7nes'                                      ,
      '3F0', 'Techniciennes médicales'                          , 'Techniciens médicaux'                             , 'Technicien\\u00b7nes médica\\u00b7les'                                    ,
      '3H0', paste0('Maitrise hotel-rest ', f)                  , paste0('Maitrise hotel-rest ', m)                  , paste0('Maitrise hotel-rest ', b)                         ,
      '3I1', 'Formatrices'                                      , 'Formateurs'                                       , 'Formateurs/trices'                           ,
      '4F1', 'Médecins hospitalières'                           , 'Médecins hospitaliers'                            , 'Médecins hospitalier\\u00b7es'                          ,
      '4F2', paste0('Médecins autres ', f)                      , paste0('Médecins autres ', m)                     , paste0('Médecins autres ', b)                            ,
      '4F3', 'Infirmières'                                      , 'Infirmiers'                                       , 'Infirmie\\u00b7res'                                      ,
      '4F4', "Rééducatrices, pharma, psy, sf"                   , "Rééducateurs, pharma, psy, sf"                    , "Rééducateurs/trices, pharma, psy, sf"                   ,
      '4I1', 'Enseignantes'                                     , 'Enseignants'                                      , 'Enseignant\\u00b7es'                                    ,
      '4I2', 'Travailleuses sociales'                           , 'Travailleurs sociaux'                             , 'Travailleu\\u00b7ses socia\\u00b7les'                           ,
      '4I3', "Animatrices, AED, CPE, sport"                     , "Animateurs, AED, CPE, sport"                      , "Animateurs/trices, AED, CPE, sport"                     ,
      '4J1', paste0('Professions artistiques ', f)              , paste0('Professions artistiques ', m)              , paste0('Professions artistiques ', b)                                    ,
      '4J2', paste0('Prof intel divers ', f)                    , paste0('Prof intel divers ', m)                    , paste0('Prof intel divers ', b)                           ,
      '5B1', 'Employées de commerce'                            , 'Employés de commerce'                             , 'Employé\\u00b7es de commerce'                               ,
      '5B2', 'Petites commerçantes'                             , 'Petits commerçants'                               , 'Petit\\u00b7es commerçant\\u00b7es'                           ,
      '5C0', 'Agentes adm. FiP / Employées banque'              , 'Agents adm. FiP / Employés banque'                , 'Agent\\u00b7es FiP, Employé\\u00b7es banque'             ,
      '5D0', 'Employées de bureau'                              , 'Employés de bureau'                               , 'Employé\\u00b7es de bureau'                                 ,
      '5F0', 'Employées de santé'                               , 'Employés de santé'                                , 'Employé\\u00b7es de santé'                                 ,
      '5G1', 'Policières'                                       , 'Policiers'                                        , 'Policier\\u00b7es'                                         ,
      '5G2', 'Militaires, gendarmes, pompières'                 , 'Militaires, gendarmes, pompiers'                  , 'Militaires, gendarmes, pompier\\u00b7es'                  ,
      '5G3', 'Agentes de surveillance'                          , 'Agents de surveillance'                           , 'Agent\\u00b7es de surveillance'                                     ,
      '5H1', 'Employées services à la personne'                 , 'Employés services à la personne'                  , 'Employé\\u00b7es services à la personne'                 ,
      '5H2', 'Artisanes des services'                           , 'Artisans des services'                            , 'Artisan\\u00b7es des services'                          ,
      '6E1', 'Ouvrières Q industrielles'                        , 'Ouvriers Q industriels'                           , 'Ouvrier\\u00b7es Q industriel\\u00b7les'                                 ,
      '6E2', 'Ouvrières Q artisanales'                          , 'Ouvriers Q artisanaux'                            , 'Ouvrier\\u00b7es Q artisana\\u00b7les'                                  ,
      '6E3', 'Ouvrières Q logistique'                           , 'Ouvriers Q logistique'                            , 'Ouvrier\\u00b7es Q logistique'                                  ,
      '6E4', 'Ouvrières NQ industrielles'                       , 'Ouvriers NQ industriels'                          , 'Ouvrier\\u00b7es NQ industriel\\u00b7les'                                ,
      '6E5', 'Ouvrières NQ logistique'                          , 'Ouvriers NQ logistique'                           , 'Ouvrier\\u00b7es NQ logistique'                                 ,
      '6E6', 'Ouvrières NQ artisanales'                         , 'Ouvriers NQ artisanaux'                           , 'Ouvrier\\u00b7es NQ artisana\\u00b7les'                                 ,
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
      '2B02', paste0('Cadres d’exploitation du commerce de détail ', f)       , paste0('Cadres d’exploitation du commerce de détail ', m)      , paste0('Cadres d’exploitation du commerce de détail ', b)               ,
      '2B03', paste0('Cadres de l’immobilier ', f)                            , paste0('Cadres de l’immobilier ', m)                           , paste0('Cadres de l’immobilier ', b)                                   ,
      '2B04', 'Ingénieures technico-commerciales'                             , 'Ingénieurs technico-commerciaux'                              , 'Ingénieur\\u00b7es technico-commerciaux'                                    ,
      '2C01', 'Inspectrices des Finances publiques (et Douanes)'              , 'Inspecteurs des Finances publiques (et Douanes)'              , 'Inspecteurs/trices des Finances publiques (et Douanes)'                    ,
      '2C02', 'Cadres commerciales de la banque'                              , 'Cadres commerciaux de la banque'                              , 'Cadres commercia\\u00b7les de la banque'                                    ,
      '2C03', paste0('Cadres des services techniques (bancassurance) ', f)    , paste0('Cadres des services techniques (bancassurance) ', m)   , paste0('Cadres des services techniques (bancassurance) ', b)            ,
      '2C04', paste0('Cadres de la banque autres ', f)                        , paste0('Cadres de la banque autres ', m)                       , paste0('Cadres de la banque autres ', b)                                ,
      '2D21', 'Cadres dirigeantes de la fonction publique'                    , 'Cadres dirigeants de la fonction publique'                    , 'Cadres dirigeant\\u00b7es de la fonction publique'                          ,
      '2D22', 'Cadres dirigeantes des entreprises'                            , 'Cadres dirigeants des entreprises'                            , 'Cadres dirigeant\\u00b7es des entreprises'                                  ,
      '2D23', 'Consultantes libérales'                                        , 'Consultants libéraux'                                         , 'Consultant\\u00b7es libéra\\u00b7les'                                             ,
      '2D24', 'Cadres publiques administratives'                              , 'Cadres publics administratifs'                                , 'Cadres publi\\u00b7ques administratifs/tives'                                   ,
      '2D25', 'Magistrates'                                                   , 'Magistrats'                                                   , 'Magistrat\\u00b7es'                                                          ,
      '2D26', paste0('Cadres gestionnaires ', f)                              , paste0('Cadres gestionnaires ', m)                             , paste0('Cadres gestionnaires ', b)                                     ,
      '2D27', paste0('Cadres de la Sécurité sociale ', f)                     , paste0('Cadres de la Sécurité sociale ', m)                    , paste0('Cadres de la Sécurité sociale ', b)                            ,
      '2D28', paste0('Cadres de la Poste ', f, ' (et France Telecom)')        , paste0('Cadres de la Poste ', m, ' (et France Telecom)')       , paste0('Cadres de la Poste ', b, ' (et France Telecom)')               ,
      '2D29', paste0('Cadres d’entreprise autres ', f)                        , paste0('Cadres d’entreprise autres ', m)                       , paste0('Cadres d’entreprise autres ', b)                               ,
      '2E21', 'Directrices techniques'                                        , 'Directeurs techniques'                                        , 'Direct\\u00b7rices techniques'                                              ,
      '2E22', 'Ingénieures libérales'                                         , 'Ingénieurs libéraux'                                          , 'Ingénieur\\u00b7es libéra\\u00b7les'                                              ,
      '2E23', 'Ingénieures publiques'                                         , 'Ingénieurs publics'                                           , 'Ingénieur\\u00b7es publi\\u00b7ques'                                              ,
      '2E25', paste0('Cadres de production ', f)                              , paste0('Cadres de production ', m)                             , paste0('Cadres de production ', b)                                     ,
      '2E26', paste0('Cadres techniques ', f)                                 , paste0('Cadres techniques ', m)                                , paste0('Cadres techniques ', b)                                        ,
      '2E27', 'Ingénieures en informatique'                                   , 'Ingénieurs en informatique'                                   , 'Ingénieur\\u00b7es en informatique'                                         ,
      '2E28', paste0('Cadres aviation et marine marchande ', f)               , paste0('Cadres aviation et marine marchande ', m)              , paste0('Cadres aviation et marine marchande ', b)                      ,
      '2E29', paste0('Cadres technico-gestionnaires ', f)                     , paste0('Cadres technico-gestionnaires ', m)                    , paste0('Cadres technico-gestionnaires ', b)                             ,
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
      '3D08', 'Cols blancs administratives de la Poste (et France Télécom)'   , 'Cols blancs administratifs de la Poste (et France Télécom)'   , 'Cols blancs administratifs/tives de la Poste (et France Télécom)'           ,
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
      '3F00', 'Techniciennes médicales'                                       , 'Techniciens médicaux'                                         , 'Technicien\\u00b7nes médica\\u00b7les'                                             ,
      '3H00', paste0('Maitrise de l’hotellerie-restauration ', f)             , paste0('Maitrise de l’hotellerie-restauration ', m)            , paste0('Maitrise de l’hotellerie-restauration ', b)                    ,
      '3I10', 'Formatrices formation continue (et conduite)'                  , 'Formateurs formation continue (et conduite)'                  , 'Formateurs/trices f. continue (et conduite)'                         ,
      
      '4F10', 'Médecins hospitalières (dont internes)'                        , 'Médecins hospitaliers (dont internes)'                        , 'Médecins hospitalier\\u00b7es (dont internes)'                              ,
      '4F21', paste0('Médecins autres ', f)                                   , paste0('Médecins autres ', m)                                  , paste0('Médecins autres ', b)                                                    ,
      '4F30', 'Infirmières'                                                   , 'Infirmiers'                                                   , 'Infirmie\\u00b7res'                                                         ,
      # '4F41', 'Médecins (hors hospitalières)'                                 , 'Médecins (hors hospitaliers)'                                 , 'Médecins (hors hospitalier\\u00b7es)'                                       ,
      '4F42', paste0('Spécialistes de la rééducation ', f)                    , paste0('Spécialistes de la rééducation ', m)                   , paste0('Spécialistes de la rééducation ', b)                           ,
      '4F43', 'Sages-femmes'                                                  , paste0('Sages-femmes ', m)                                     , paste0('Sages-femmes ', b)                                             ,
      '4F44', 'Pharmaciennes'                                                 , 'Pharmaciens'                                                  , 'Pharmacien\\u00b7nes'                                                       ,
      '4F45', paste0('Psychologues (non médecins) ', f)                       , paste0('Psychologues (non médecins) ', m)                      , paste0('Psychologues (non médecins) ', b)                              ,
      '4I11', 'Enseignantes du supérieur'                                     , 'Enseignants du supérieur'                                     , 'Enseignant\\u00b7es du supérieur'                                           ,
      '4I12', 'Chercheuses du public'                                         , 'Chercheurs du public'                                         , 'Chercheu\\u00b7ses du public'                                              ,
      '4I13', 'Enseignantes du secondaire'                                    , 'Enseignants du secondaire'                                    , 'Enseignant\\u00b7es du secondaire'                         ,
      '4I14', 'Enseignantes du primaire'                                      , 'Enseignants du primaire'                                      , 'Enseignant\\u00b7es du primaire'                                            ,
      '4I21', 'Éducatrices'                                                   , 'Éducateurs'                                                   , 'Éducat\\u00b7rices'                                                         ,
      '4I22', 'Assistantes sociales'                                          , 'Assistants sociaux'                                           , 'Assistant\\u00b7es socia\\u00b7les'                                               ,
      '4I23', 'Conseillères en économie sociale familiale'                    , 'Conseillers en économie sociale familiale'                    , 'Conseille\\u00b7res en économie sociale familiale'                          ,
      '4I31', 'Conseillères principales d’éducation'                          , 'Conseillers principaux d’éducation'                           , 'Conseiller\\u00b7es princ d’éducation'                          ,
      '4I32', 'Assistantes d’éducation'                                       , 'Assistants d’éducation'                                       , 'Assistant\\u00b7es d’éducation'                                                   ,
      '4I33', 'Éducatrices sportives (et sport pro)'                          , 'Éducateurs sportifs (et sport pro)'                           , 'Éducateurs/trices sporti\\u00b7ves (et sport pro)'            ,
      '4I34', 'Animatrices socioculturelles'                                  , 'Animateurs socioculturels'                                    , 'Animat\\u00b7rices socioculturel\\u00b7les'                               ,
      '4I35', paste0('Clergé ', f)                                            , paste0('Clergé ', m)                                           , paste0('Clergé ', b)                                                   ,
      '4J11', paste0('Artistes ', f)                                          , paste0('Artistes ', m)                                         , paste0('Artistes ', b)                                                 ,
      '4J12', paste0('Cadres technico-artistiques ', f)                       , paste0('Cadres technico-artistiques ', m)                      , paste0('Cadres technico-artistiques ', b)                              ,
      '4J13', 'Professeures d’art (hors étab scolaires)'                      , 'Professeurs d’art (hors étab scolaires)'                      , 'Professeur\\u00b7es d’art (hors étab scolaires)'                  ,
      '4J21', 'Avocates, notaires, architectes'                               , 'Avocats, notaires, architectes'                               , 'Avocat\\u00b7es, notaires, architectes'                                     ,
      '4J22', paste0('Journalistes ', f)                                      , paste0('Journalistes ', m)                                     , paste0('Journalistes ', b)                                             ,
      # '4J23', 'Magistrates'                                                   , 'Magistrats'                                                   , 'Magistrat\\u00b7es'                                                         ,
      '4J24', 'Personnel politique ou syndical'                               ,'Personnel politique ou syndical'                               , 'Personnel politique ou syndical'                                      ,
      '4J25', paste0('PIS autres ', f)                                        , paste0('PIS autres ', m)                                       , paste0('PIS autres ', b)                                               ,
      '5B11', 'Vendeuses qualifiées'                                          , 'Vendeurs qualifiés'                                           , 'Vendeu\\u00b7ses qualifié\\u00b7es'                                               ,
      '5B12', 'Vendeuses NQ'                                                  , 'Vendeurs NQ'                                                  , 'Vendeu\\u00b7ses NQ'                                                        ,
      '5B13', 'Caissières (et assimilées)'                                    , 'Caissiers (et assimilés)'                                     , 'Caissie\\u00b7res (et assimilé\\u00b7es)'                                         ,
      '5B22', 'Petites commerçantes (0-2)'                                    , 'Petits commerçants (0-2)'                                     , 'Petit\\u00b7es commerçant\\u00b7es (0-2)'                              ,
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
      '5F01', 'Aides-soignantes'                                              , 'Aides-soignants'                                              , 'Aides-soignant\\u00b7es'                                                   ,
      '5F02', 'Auxiliaires de puériculture'                                   , 'Auxiliaires de puériculture'                                  , 'Auxiliaires de puériculture'                                       ,
      '5F03', 'Aides médico-psychologiques'                                   , 'Aides médico-psychologiques'                                  , 'Aides médico-psychologiques'                                        ,
      '5F04', 'Ambulancières'                                                 , 'Ambulanciers'                                                 , 'Ambulancier\\u00b7es'                                                       ,
      '5F05', 'Assistantes et aides médicales'                                , 'Assistants et aides médicaux'                                 , 'Assistant\\u00b7es et aides médica\\u00b7les'                                     ,
      
      '5G10', 'Policières'                                                    , 'Policiers'                                                    , 'Policier\\u00b7es'                                                          ,
      '5G21', 'Sous-officières des Armées (et Gendarmerie)'                   , 'Sous-officiers des Armées (et Gendarmerie)'                   , 'Sous-officier\\u00b7es des Armées (et Gendarmerie)'                   ,
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
      '5H22', 'Petit hôtelieres/restauratrices (0-2)'                         , 'Petit hôteliers/restaurateurs (0-2)'                          , 'Petit\\u00b7es hôtelier\\u00b7es rest. (0-2)'                         ,
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
      '6E36', paste0('OQ logistique autres ' , f)                             , paste0('OQ logistique autres ' , m)                            , paste0('OQ logistique autres ' , b)                                     ,
      '6E41', paste0('ONQ-I du BTP '         , f)                             , paste0('ONQ-I du BTP '         , m)                            , paste0('ONQ-I du BTP '         , b)                                     ,
      '6E42', paste0('ONQ-I électricité ', f)                                 , paste0('ONQ-I électricité ', m)                                , paste0('ONQ-I électricité ', b)                                        ,
      '6E43', paste0('ONQ-I mécanique métaux ', f)                             , paste0('ONQ-I mécanique métaux ', m)                            , paste0('ONQ-I mécanique métaux ', b)                                    ,
      '6E44', paste0('ONQ-I transformation ', f)                              , paste0('ONQ-I transformation ', m)                             , paste0('ONQ-I transformation ', b)                                     ,
      '6E45', paste0('ONQ-I textile ', f)                                     , paste0('ONQ-I textile ', m)                                    , paste0('ONQ-I textile ', b)                                            ,
      '6E46', paste0('ONQ-I autres ', f)                                      , paste0('ONQ-I autres ', m)                                     , paste0('ONQ-I autres ', b)                                             ,
      '6E51', paste0('ONQ-manutention ', f)                                   , paste0('ONQ-manutention ', m)                                  , paste0('ONQ-manutention ', b)                                          ,
      '6E52', 'ONQ-coursières et livreuses'                                   , 'ONQ-coursiers et livreurs'                                    , 'ONQ-coursier\\u00b7es et livreurs/euses'                                        ,
      '6E53', paste0('ONQ-logistique autres ', f)                              , paste0('ONQ-logistique autres ', m)                             , paste0('ONQ-logistique autres ', b)                                     ,
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
      
      # # Générer les tableaux de féminisation pour tous les niveaux des CSP recodées : 
      # ##  ci-dessous à la fin du script : 
      # ##  charger base Enquête emploi : ee 
      # ##  passer pcspp avec masculiniser = TRUe 
      # ##  utiliser generate_fem_tribble() pour faire les tableaux format tribble
      # 
      # PPP1_fem <- generate_fem_tribble(ee, PPP1)
      # PPP2_fem <- generate_fem_tribble(ee, PPP2)
      # PPP3_fem <- generate_fem_tribble(ee, PPP3)
      # PPP4_fem <- generate_fem_tribble(ee, PPP4)
      # 
      # cat(PPP1_fem$trb, sep = ",\n")
      # cat(PPP2_fem$trb, sep = ",\n")
      # cat(PPP3_fem$trb, sep = ",\n")
      # cat(PPP4_fem$trb, sep = ",\n")
      # 
      # # sex_ratio <- c("PPP1", "PPP2", "PPP3", "PPP4") %>%
      # #   map_chr(~ generate_fem_tribble(ee, !!rlang::sym(.)))
      # # cat(sex_ratio)
      
      PPP1_fem <-tibble::tribble(
        ~`chiffre`, ~`1982`, ~`1983`, ~`1984`, ~`1985`, ~`1986`, ~`1987`, ~`1988`, ~`1989`, ~`1990`, ~`1991`, ~`1992`, ~`1993`, ~`1994`, ~`1995`, ~`1996`, ~`1997`, ~`1998`, ~`1999`, ~`2000`, ~`2001`, ~`2002`, ~`2003`, ~`2004`, ~`2005`, ~`2006`, ~`2007`, ~`2008`, ~`2009`, ~`2010`, ~`2011`, ~`2012`, ~`2013`, ~`2014`, ~`2015`, ~`2016`, ~`2017`, ~`2018`,
        '1'       , 15.6   , 18.3   , 21.8   , 23     , 17.9   , 19.1   , 17.2   , 16.4   , 14.3   , 15.7   , 12.4   , 15.3   , 14     , 18.8   , 15.5   , 18.5   , 20     , 20.2   , 14.4   , 15.5   , 14.5   , 13.9   , 11.7   , 17     , 17.4   , 18.9   , 15.2   , 9.3    , 12.9   , 16.8   , 16.4   , 19.4   , 15.5   , 17.5   , 19.5   , 18.8   , 16.1   ,
        '2'       , 19.2   , 18.8   , 19.8   , 19.9   , 22.2   , 22.2   , 22     , 23.1   , 23     , 24.1   , 24.3   , 24.6   , 24.3   , 26     , 27.6   , 26.2   , 28.1   , 27.4   , 27.5   , 27.8   , 29.6   , 29.8   , 30.9   , 32.1   , 32.9   , 33.1   , 34.4   , 35.1   , 35.2   , 36.2   , 36.1   , 36.3   , 36.5   , 36.3   , 36.7   , 37.4   , 38.1   ,
        '3'       , 28.3   , 28.3   , 29.3   , 29.7   , 30.6   , 32.1   , 32.3   , 32.5   , 33.3   , 33.6   , 34.8   , 35.1   , 35.5   , 35.4   , 35.1   , 35.7   , 36.2   , 36.3   , 37.3   , 37.4   , 37.5   , 38.8   , 39.7   , 40.2   , 40.5   , 41.3   , 41.1   , 41.2   , 41.7   , 41.7   , 42.2   , 42.1   , 41.8   , 43     , 43     , 43.1   , 44.2   ,
        '4'       , 58.6   , 58.9   , 58.5   , 57.8   , 57.5   , 57.2   , 57.7   , 57.7   , 57.5   , 58.7   , 58.3   , 59.6   , 59.7   , 59.7   , 60.1   , 60.4   , 60.6   , 61.4   , 62.3   , 62.7   , 62.6   , 62.7   , 63.4   , 63.7   , 63.7   , 63.6   , 64.4   , 65     , 63.7   , 62.8   , 63.9   , 64     , 65.4   , 65.6   , 65.9   , 65.1   , 64.8   ,
        '5'       , 72.7   , 72.8   , 72.8   , 73.3   , 73.4   , 73     , 73.3   , 73.2   , 73.9   , 75.1   , 74.9   , 74.1   , 74.3   , 74.4   , 74.9   , 74.9   , 74.4   , 74.3   , 74.6   , 74.1   , 74.3   , 75     , 74.7   , 74.5   , 75.1   , 75.3   , 74.7   , 74.9   , 74.6   , 74.6   , 74.7   , 74.9   , 75.1   , 74.6   , 74.9   , 74.7   , 74.5   ,
        '6'       , 18.6   , 18.6   , 18.6   , 19     , 18.9   , 18.3   , 18.2   , 18     , 18.7   , 18.7   , 18.5   , 18.1   , 18.7   , 18.4   , 17.7   , 17.9   , 18.3   , 18.3   , 18.3   , 18.8   , 18.5   , 18.3   , 18.3   , 17.9   , 17.8   , 17.6   , 17.4   , 17.2   , 17.6   , 18.2   , 17.8   , 18     , 18.4   , 18.8   , 18.7   , 19     , 18.6   ,
        '7'       , 36     , 36     , 35.6   , 35.8   , 35.3   , 35     , 34.3   , 34.2   , 33.9   , 35.4   , 35.2   , 35.6   , 34     , 33.7   , 33.1   , 32.7   , 31.4   , 31.7   , 30.7   , 30.7   , 30.8   , 29.8   , 32.4   , 29.8   , 29.1   , 30.1   , 29.4   , 29     , 27.7   , 29     , 28.9   , 27.5   , 27.3   , 27.7   , 26.6   , 27.1   , 25.9   
      ) %>% 
        dplyr::mutate(chiffre = stringr::str_to_upper(chiffre)) %>% 
        dplyr::select(chiffre, tidyselect::all_of(sexeEE)) %>% 
        dplyr::rowwise() %>% 
        dplyr::mutate(fem_pct = mean(dplyr::c_across(tidyselect::all_of(sexeEE)), na.rm = TRUE)) %>% 
        dplyr::select(chiffre, fem_pct)
      
      
      PPP2_fem <-tibble::tribble(
        ~`chiffre`, ~`1982`, ~`1983`, ~`1984`, ~`1985`, ~`1986`, ~`1987`, ~`1988`, ~`1989`, ~`1990`, ~`1991`, ~`1992`, ~`1993`, ~`1994`, ~`1995`, ~`1996`, ~`1997`, ~`1998`, ~`1999`, ~`2000`, ~`2001`, ~`2002`, ~`2003`, ~`2004`, ~`2005`, ~`2006`, ~`2007`, ~`2008`, ~`2009`, ~`2010`, ~`2011`, ~`2012`, ~`2013`, ~`2014`, ~`2015`, ~`2016`, ~`2017`, ~`2018`,
        '1A0'  , 15.6   , 18.3   , 21.8   , 23     , 17.9   , 19.1   , 17.2   , 16.4   , 14.3   , 15.7   , 12.4   , 15.3   , 14     , 18.8   , 15.5   , 18.5   , 20     , 20.2   , 14.4   , 15.5   , 14.5   , 13.9   , 11.7   , 17     , 17.4   , 18.9   , 15.2   , 9.3    , 12.9   , 16.8   , 16.4   , 19.4   , 15.5   , 17.5   , 19.5   , 18.8   , 16.1   ,
        '2B0'  , 7.1    , 10.3   , 9.8    , 11.7   , 11.3   , 11.1   , 12.2   , 12.1   , 11.3   , 12.6   , 12.3   , 15.1   , 13.7   , 16.6   , 14.8   , 12.6   , 17.7   , 18.4   , 15.4   , 17.4   , 20.9   , 16.6   , 19.3   , 19.6   , 21     , 22.5   , 22     , 21.9   , 24     , 26.3   , 27.8   , 25.2   , 24.7   , 27     , 27.5   , 26.1   , 26.7   ,
        '2C0'  , 15.5   , 17.8   , 18.9   , 22.3   , 21.7   , 25.3   , 22.5   , 21.7   , 27.3   , 27.6   , 29.6   , 30.9   , 29.3   , 31.9   , 32.9   , 28     , 29.9   , 29.7   , 31.5   , 34.5   , 34.4   , 30.6   , 30.8   , 33.4   , 42.5   , 43     , 37.4   , 40.9   , 42.4   , 41.9   , 41.4   , 42     , 45     , 44.9   , 44.3   , 48.7   , 48     ,
        '2D2'  , 27.5   , 25.5   , 26.1   , 25.5   , 29.5   , 29.3   , 27.9   , 30     , 32.8   , 35.4   , 36.1   , 34.7   , 34.2   , 37.8   , 40.9   , 39.3   , 39.9   , 38.9   , 40.7   , 41     , 43.1   , 43.6   , 46.5   , 47.1   , 47.6   , 46.8   , 51.4   , 49.2   , 49.4   , 50.3   , 49.8   , 52.3   , 53.5   , 53     , 52.4   , 53     , 54.7   ,
        '2E2'  , 6.9    , 6      , 5.9    , 6.3    , 8.9    , 8.5    , 9.6    , 10.2   , 10.6   , 11.3   , 11.9   , 11.6   , 13.1   , 12.8   , 13.1   , 12.8   , 15.6   , 15.4   , 14.5   , 14.9   , 16.3   , 18     , 16.8   , 18     , 17.9   , 17.7   , 20.1   , 22.5   , 21.3   , 21.8   , 22.1   , 22     , 20.9   , 20.1   , 20.2   , 22.1   , 23.2   ,
        '2F0'  , 87.6   , 88     , 85.4   , 85.1   , 87.8   , 86.3   , 89.6   , 92.9   , 92.2   , 86.7   , 87.7   , 88.6   , 86.5   , 78.5   , 78.5   , 79.6   , 84.6   , 86.6   , 80.4   , 81.6   , 83.4   , 83.6   , 83     , 82.7   , 92.2   , 85.1   , 79.9   , 81.7   , 79.4   , 85.1   , 80.5   , 83.4   , 79.6   , 90.8   , 90.3   , 86.8   , 87.2   ,
        '2G0'  , 5.2    , 3.8    , 4.3    , 5.9    , 4.6    , 4      , 7.7    , 8.3    , 3.1    , 8.5    , 7.3    , 8.3    , 3.8    , 5      , 7      , 9.8    , 8.8    , 7.3    , 3      , 7.3    , 6.1    , 12.3   , 6.4    , 8.2    , 19.2   , 22.6   , 11.2   , 8.9    , 11.3   , 13.7   , 15.5   , 19.4   , 13.8   , 14.9   , 13.1   , 12.2   , 14.7   ,
        '2H0'  , 17.3   , 15.5   , 39.8   , 28.5   , 24.3   , 26.5   , 34.1   , 28.1   , 29.8   , 20.8   , 30.1   , 25.8   , 19.3   , 21.4   , 23.5   , 22.4   , 9.7    , 21.3   , 47.6   , 33.2   , 27     , 29.8   , 28     , 19.4   , 27.1   , 29.8   , 24.1   , 31.3   , 30.8   , 27.3   , 33.9   , 32     , 40.1   , 31.6   , 37.6   , 37.7   , 30.9   ,
        '2I1'  , 26.2   , 29.3   , 34.4   , 37.6   , 32.5   , 13.2   , 19.3   , 27.2   , 32.2   , 32     , 31.6   , 21.8   , 26.6   , 33.8   , 35.7   , 30.2   , 33     , 29.2   , 30.9   , 37.7   , 35.4   , 35.2   , 43.8   , 47.4   , 42.9   , 48.6   , 45.3   , 36.9   , 40.5   , 49.9   , 51.5   , 58.3   , 46.3   , 37.8   , 39.4   , 46.2   , 35.7   ,
        '2I2'  , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 59     , 58.9   , 67.6   , 65.6   , 63.1   , 58     , 64.1   , 64.5   , 60.9   , 68.5   , 67.4   , 53.4   , 53     , 55.9   , 58.6   , 59.9   ,
        '2J0'  , 62.5   , 66.9   , 64.9   , 61.8   , 69.6   , 70.5   , 73.1   , 72.8   , 73.3   , 53.8   , 50.5   , 54.4   , 54.1   , 64.7   , 64.3   , 67.5   , 64.2   , 56.8   , 53.8   , 51.9   , 45.2   , 46.7   , 56.5   , 66.3   , 59.3   , 58.2   , 55.2   , 54.5   , 58.8   , 52.7   , 57.7   , 44.7   , 39.8   , 48.5   , 57.2   , 46.9   , 45.9   ,
        '3B1'  , 26     , 26.2   , 28.6   , 28     , 27.2   , 28.8   , 29.2   , 29.1   , 31.9   , 32.4   , 36     , 34.9   , 36.5   , 37.9   , 37.1   , 37.1   , 38.9   , 39.5   , 42.1   , 41.2   , 42.1   , 40.9   , 42.9   , 43.6   , 40.9   , 42.7   , 44.6   , 43     , 43.3   , 42.8   , 45.2   , 46.3   , 45.6   , 44.3   , 44.7   , 45.1   , 48.5   ,
        '3B2'  , 30.9   , 32.4   , 34.1   , 34     , 33.9   , 33.9   , 31     , 32.4   , 36.8   , 34.7   , 34.8   , 32.2   , 34.1   , 37.9   , 34.2   , 32.5   , 34.1   , 32.4   , 33.6   , 33.5   , 33     , 30.8   , 31.6   , 30     , 30.9   , 32     , 32.8   , 30.7   , 30.6   , 30.1   , 29.3   , 29.5   , 34.6   , 33.7   , 33     , 34.3   , 34.9   ,
        '3C0'  , 48.3   , 43.8   , 46.8   , 48.9   , 49.7   , 50.4   , 51.4   , 53.7   , 49.3   , 52.9   , 56.5   , 58.1   , 58.5   , 55     , 57.4   , 57.2   , 58.8   , 58.1   , 61.2   , 60.9   , 65.3   , 59.8   , 60.6   , 63.2   , 58     , 58.4   , 62.7   , 66     , 62.9   , 62.9   , 63.2   , 63.9   , 60.5   , 62.6   , 66.2   , 66.1   , 64.8   ,
        '3D0'  , 56.5   , 56.5   , 56.9   , 57.6   , 58.2   , 59.3   , 59.8   , 59.9   , 60.1   , 62.3   , 62     , 62.7   , 62.6   , 62.7   , 61.7   , 61.7   , 61.6   , 61.8   , 60.8   , 60.9   , 60.3   , 63.2   , 63.2   , 64.5   , 65.7   , 65.7   , 65.6   , 66.2   , 66.2   , 66.8   , 67.1   , 66.7   , 66.1   , 68.1   , 66.9   , 67.2   , 68.9   ,
        '3E1'  , 5.3    , 5.4    , 5.7    , 5.7    , 6.5    , 7      , 6.7    , 6.1    , 6.4    , 6.3    , 6      , 7.6    , 6.9    , 7.4    , 8.2    , 7.6    , 7.6    , 7.5    , 8.4    , 7.6    , 9.2    , 10.8   , 10.2   , 10.9   , 11.3   , 11.3   , 9.5    , 10.2   , 11.6   , 12.2   , 12.1   , 12.8   , 14.8   , 15.8   , 13.7   , 14.7   , 15     ,
        '3E2'  , 10     , 9.5    , 9.1    , 10.5   , 10.6   , 10.6   , 10.4   , 10.4   , 12.4   , 12.6   , 12.5   , 10.6   , 11.6   , 11.9   , 12.1   , 12.3   , 12.6   , 13.3   , 12.5   , 14.8   , 13.8   , 12.9   , 13.6   , 11.5   , 11.2   , 11.7   , 12.1   , 12.8   , 13.3   , 12.3   , 13.2   , 14.5   , 14.1   , 13.6   , 15.4   , 15.2   , 16.6   ,
        '3F0'  , 60.7   , 57.5   , 62.4   , 58.9   , 60.6   , 69.4   , 69.5   , 69.8   , 67.8   , 62.4   , 67.6   , 68.9   , 71.8   , 70.2   , 68.9   , 73.8   , 73     , 69.3   , 68.7   , 70.2   , 69.2   , 70.2   , 72.3   , 74.8   , 77.2   , 75.6   , 73.9   , 76.5   , 73.6   , 74.2   , 73     , 73.9   , 71     , 73.1   , 74.8   , 73.4   , 71.4   ,
        '3H0'  , 28     , 20.6   , 21     , 27     , 23.9   , 30.6   , 29.8   , 22.8   , 27.3   , 23.9   , 30.4   , 27.6   , 29.1   , 29.9   , 22.2   , 24.1   , 31.2   , 30.5   , 28.9   , 30.7   , 30.3   , 23.4   , 35.2   , 33.8   , 28.7   , 34.5   , 39.5   , 36     , 31.8   , 41     , 38.4   , 37.2   , 39.2   , 34.3   , 34.3   , 37     , 40.8   ,
        '3I1'  , 50.2   , 51.8   , 54.4   , 50     , 52.5   , 55.6   , 54.5   , 54.8   , 56.6   , 52.7   , 55.8   , 55.7   , 57.4   , 55.4   , 55.2   , 57.9   , 57.6   , 57.4   , 61.2   , 59.5   , 60     , 61.7   , 61     , 61.5   , 63.6   , 63.8   , 62.7   , 62.9   , 65.6   , 64.7   , 64     , 61.9   , 61.8   , 64.6   , 65.6   , 64.3   , 64.8   ,
        '4F1'  , 32.9   , 30     , 33.7   , 33.6   , 41.2   , 41.1   , 40.8   , 42.3   , 43.2   , 43.4   , 35.1   , 40.6   , 44.5   , 46.3   , 42.4   , 44.3   , 42     , 48.7   , 46.6   , 43.3   , 43.1   , 47.8   , 45.9   , 42.4   , 45     , 49.1   , 51.6   , 52.3   , 49.1   , 50.9   , 51.1   , 47     , 53.2   , 52.5   , 56.8   , 53.7   , 52.3   ,
        '4F2'  , 28.2   , 27.7   , 28.6   , 28.2   , 25.8   , 25.8   , 28.9   , 29.6   , 28.8   , 29.2   , 33.2   , 33.6   , 31.6   , 30.1   , 29.7   , 32.8   , 32     , 35.7   , 35     , 37.6   , 35.7   , 38.3   , 39.9   , 40.5   , 35     , 37.7   , 42.6   , 38.6   , 37.7   , 38.8   , 40     , 42.5   , 42.7   , 42     , 42.6   , 46.3   , 48.7   ,
        '4F3'  , 87.7   , 87.7   , 86.6   , 86.7   , 87.5   , 87.8   , 88.3   , 86.9   , 87.7   , 88     , 87.5   , 88.7   , 86.9   , 88.4   , 88.4   , 89.8   , 89.5   , 88.8   , 89.6   , 88.2   , 86.8   , 87.9   , 88.8   , 91.2   , 88.3   , 88.1   , 86.8   , 88.6   , 88.4   , 87.5   , 87.4   , 86.8   , 86.4   , 87     , 86     , 84.2   , 85.4   ,
        '4F4'  , 63.6   , 63.6   , 65.1   , 62     , 61.5   , 62.1   , 63.3   , 62.5   , 58.7   , 62.2   , 61     , 64     , 65.3   , 64.4   , 65.5   , 63.1   , 67.2   , 67.4   , 66.7   , 68.6   , 69.6   , 66.7   , 67.7   , 67.9   , 69.9   , 68.6   , 74.7   , 73.4   , 71.9   , 70.5   , 70.6   , 72.4   , 75.4   , 73     , 73.9   , 75.1   , 73.8   ,
        '4I1'  , 61.6   , 62.6   , 61.3   , 60.8   , 59.8   , 59.7   , 60.3   , 60.5   , 59.1   , 61.5   , 61.3   , 62     , 62.4   , 61.6   , 61.9   , 62.4   , 61.5   , 61.7   , 62.8   , 63.4   , 63.6   , 62.9   , 63.9   , 64     , 64.7   , 63.8   , 64.1   , 65     , 65     , 63.7   , 64.7   , 64.4   , 64.9   , 66.2   , 66     , 64.8   , 64.7   ,
        '4I2'  , 70.2   , 71.7   , 72.3   , 68     , 66.3   , 65.7   , 67.5   , 67.6   , 70     , 70.4   , 69.9   , 67     , 70.3   , 73.5   , 74.9   , 73.1   , 74.9   , 71.3   , 70.6   , 71.5   , 72.1   , 72.9   , 69.8   , 74.1   , 75.1   , 77.6   , 77.3   , 75.8   , 73.9   , 73.2   , 72.7   , 73.7   , 78.3   , 76.4   , 77.7   , 76.9   , 76.3   ,
        '4I3'  , 7.4    , 13.1   , 16.5   , 20.8   , 17.9   , 18.8   , 14.5   , 18.7   , 16     , 18.3   , 14.7   , 18.8   , 19.1   , 20.4   , 22.2   , 25.4   , 25.1   , 29.8   , 32.5   , 34.6   , 30.7   , 26.3   , 36.2   , 31.7   , 31.7   , 34.7   , 30.6   , 29.4   , 31.4   , 35.3   , 34.4   , 33.7   , 36     , 39.2   , 35.9   , 35.4   , 34.1   ,
        '4J1'  , 39.7   , 42.3   , 36.7   , 33.9   , 36.2   , 37.1   , 38.9   , 44.3   , 43.7   , 37.7   , 37.9   , 36.9   , 38.8   , 37.7   , 37.9   , 38.4   , 34     , 38.8   , 40.8   , 41.1   , 42.9   , 43.1   , 45.2   , 41.4   , 37     , 38.8   , 42     , 39.6   , 34.5   , 40     , 45.6   , 41.9   , 38.2   , 40.1   , 41.8   , 37.5   , 41     ,
        '4J2'  , 33.4   , 34     , 34.4   , 35.9   , 40     , 38.4   , 34     , 32.5   , 41.7   , 41.2   , 39.2   , 34.6   , 35.1   , 36.8   , 42.3   , 39.1   , 40.5   , 43.6   , 43.8   , 42.7   , 43.1   , 39.9   , 37.8   , 40.1   , 44.6   , 42.5   , 45.8   , 49.7   , 42.1   , 39.6   , 44.2   , 42.7   , 41.4   , 46.1   , 46.2   , 45.6   , 44.7   ,
        '5B1'  , 79.3   , 78.6   , 79.1   , 80.4   , 79.9   , 78.1   , 77.2   , 78.4   , 78.8   , 79.8   , 79.3   , 77.1   , 77.2   , 75.4   , 77.5   , 76.6   , 75.7   , 74.8   , 75     , 74.8   , 73.8   , 75.2   , 76.6   , 78.7   , 76.8   , 77.6   , 76.8   , 76.3   , 75.7   , 73.5   , 74.4   , 73.5   , 73.6   , 73.9   , 73.4   , 71.4   , 72.2   ,
        '5B2'  , 53.9   , 55.6   , 55.6   , 56.2   , 55     , 56.1   , 53.7   , 54.9   , 52.6   , 56.3   , 54.7   , 52     , 50.2   , 52.3   , 50.1   , 53.2   , 45.8   , 44.4   , 49.9   , 51.2   , 47.3   , 49.6   , 48.2   , 47     , 46     , 49.5   , 54.3   , 48.2   , 43.8   , 47.3   , 46     , 44.7   , 45.1   , 46.7   , 50.7   , 49.8   , 44.7   ,
        '5C0'  , 61.2   , 62.1   , 63.4   , 67.4   , 68.8   , 67.9   , 70.9   , 67.9   , 69.1   , 69     , 68.5   , 68     , 71.3   , 70.6   , 71.1   , 69.4   , 69.9   , 70.8   , 70.1   , 70.5   , 68.5   , 72.7   , 74     , 69.6   , 70.4   , 77.4   , 76.2   , 73.1   , 70.9   , 74.6   , 75.9   , 77.2   , 78     , 75.6   , 75.7   , 75.1   , 74     ,
        '5D0'  , 78.3   , 78.6   , 79.1   , 80.1   , 80.1   , 79.7   , 80.2   , 80.3   , 82     , 82.1   , 82     , 82.8   , 82.3   , 82.4   , 82     , 82     , 81.8   , 81     , 81     , 80     , 79.7   , 81.6   , 81.7   , 81.1   , 81.8   , 81.7   , 80.5   , 79.5   , 79.2   , 80.4   , 80.1   , 79.8   , 80.3   , 80.2   , 80.3   , 79.6   , 80.9   ,
        '5F0'  , 85.8   , 85.7   , 85.3   , 86.7   , 88.5   , 87.5   , 87.8   , 87.6   , 86.8   , 88.3   , 89.4   , 87.8   , 88.6   , 86     , 86.5   , 86.1   , 86.5   , 85.6   , 86.9   , 87.2   , 87.5   , 85.9   , 85.7   , 85.8   , 87.6   , 87.4   , 85.8   , 84.8   , 84.8   , 85.4   , 86.9   , 88.4   , 86.5   , 86.1   , 85.4   , 86.2   , 86.9   ,
        '5G1'  , 4.5    , 3.9    , 3.5    , 3      , 5.1    , 3.7    , 6.3    , 5.3    , 4.3    , 4.7    , 5      , 7.1    , 8.1    , 6.7    , 4.9    , 8.8    , 10.1   , 10.6   , 10.6   , 15.3   , 17.3   , 18.3   , 16.6   , 16.2   , 13.2   , 23     , 24.6   , 22.4   , 20.2   , 23.4   , 20.2   , 18.6   , 23.3   , 23.3   , 20.4   , 17.9   , 20.5   ,
        '5G2'  , 3.1    , 4.9    , 5.4    , 4.6    , 4.5    , 6.1    , 6.1    , 6      , 6.7    , 8      , 10     , 6.6    , 5.3    , 4.8    , 5.7    , 5.3    , 5.7    , 8.2    , 8.8    , 8.2    , 8.2    , 8.9    , 6.9    , 11     , 10.7   , 12.9   , 11     , 10.7   , 12.6   , 11.9   , 9      , 9.8    , 12.1   , 11.9   , 13.1   , 11.6   , 12.7   ,
        '5G3'  , 6.2    , 7.9    , 9.2    , 5.4    , 5.4    , 7.8    , 6.5    , 8      , 8.8    , 9.8    , 8.8    , 8.1    , 8.4    , 10.2   , 9.8    , 7.8    , 8.6    , 10.2   , 11     , 8.4    , 10.3   , 10.4   , 10.7   , 10.8   , 9      , 13.6   , 10.1   , 11.7   , 16.1   , 14.7   , 12.6   , 15.3   , 13.3   , 12.2   , 12.1   , 12     , 16.7   ,
        '5H1'  , 84.4   , 82.9   , 82.7   , 82.8   , 83.8   , 83.4   , 83.7   , 82.9   , 83.9   , 84.6   , 84.9   , 84.7   , 84.3   , 83.9   , 85.1   , 84.6   , 85.2   , 84.5   , 84.3   , 84.1   , 84.9   , 84.6   , 83.7   , 82.9   , 83.7   , 83.6   , 82.4   , 84     , 83.7   , 83.2   , 83.1   , 84.2   , 84.5   , 83.1   , 83.9   , 83.8   , 82.6   ,
        '5H2'  , 70.4   , 70.8   , 70.6   , 68.4   , 68     , 66.6   , 66.4   , 66.9   , 68.8   , 70     , 68.3   , 66     , 67.2   , 67.7   , 67.2   , 68.1   , 67.9   , 65.1   , 62.5   , 62.5   , 66     , 59.8   , 57.8   , 57.5   , 61.9   , 59.5   , 58.4   , 59.4   , 59.8   , 59.3   , 56.8   , 58     , 58.7   , 59.8   , 59.7   , 62.6   , 60.5   ,
        '6E1'  , 12.9   , 11.4   , 12.1   , 12     , 12.6   , 12.1   , 13.1   , 13.2   , 15.2   , 15     , 15.4   , 13.8   , 16.2   , 16.3   , 16.2   , 16.1   , 15.8   , 15.9   , 15.3   , 15.9   , 15.4   , 15.7   , 17.6   , 15.9   , 15.6   , 16     , 15.7   , 14.7   , 14.6   , 15.4   , 15.1   , 15.5   , 16.1   , 15.4   , 15.3   , 16.8   , 16.4   ,
        '6E2'  , 7.7    , 7.4    , 7.2    , 6.7    , 6.1    , 6.3    , 6.6    , 6.4    , 6.9    , 7      , 7.1    , 7.6    , 7.5    , 8.3    , 8.4    , 7.6    , 8.3    , 8.1    , 8.5    , 9.7    , 8.7    , 8.3    , 8.2    , 8.3    , 8.6    , 8.9    , 7.5    , 8.2    , 9.9    , 9.5    , 9.7    , 11.2   , 10.7   , 11.1   , 11.3   , 11.4   , 10.6   ,
        '6E3'  , 1.7    , 2      , 1.5    , 1.7    , 1.9    , 1.9    , 1.7    , 1.7    , 1.9    , 2.3    , 3      , 3.1    , 3.6    , 3      , 3.8    , 3.5    , 3.6    , 3.7    , 4.1    , 5.6    , 5.1    , 4.7    , 4.1    , 5.7    , 6      , 7.3    , 7.5    , 8      , 9.4    , 7.7    , 7.6    , 6.9    , 6.1    , 8.1    , 8.5    , 7      , 6.3    ,
        '6E4'  , 39.7   , 40     , 40     , 41.4   , 40.9   , 39.8   , 38.9   , 38.7   , 39.4   , 40.4   , 39.3   , 38.9   , 39.9   , 38.4   , 36.9   , 37.6   , 37.5   , 37.7   , 36.6   , 37.3   , 38     , 36.4   , 35.9   , 36.9   , 36.1   , 34.8   , 36     , 34     , 31     , 31.8   , 32.2   , 31.2   , 30.8   , 30.9   , 30.1   , 30.3   , 30.6   ,
        '6E5'  , 20.1   , 19.9   , 18.8   , 18.8   , 20     , 20.1   , 20.1   , 21     , 19.4   , 20.8   , 18.3   , 19.4   , 18.6   , 18.7   , 18.4   , 18.4   , 19.1   , 19.1   , 18.7   , 18.6   , 18.8   , 21.5   , 20.1   , 20.3   , 20.2   , 18.7   , 20.6   , 19.3   , 18.8   , 21.1   , 20.2   , 20     , 19.8   , 20.6   , 21.5   , 21.2   , 21     ,
        '6E6'  , 26.6   , 27.7   , 30.1   , 31.8   , 33.9   , 31     , 31     , 30.5   , 36.3   , 38.9   , 38.6   , 39.2   , 43.3   , 39.5   , 38.2   , 40.1   , 40.2   , 40     , 39.4   , 39.2   , 39.1   , 36.6   , 34.6   , 30.9   , 32.7   , 34.4   , 33.2   , 35.3   , 36.1   , 38.2   , 35.9   , 35.1   , 39.1   , 39.6   , 39     , 38.2   , 38.9   ,
        '6E7'  , 7.4    , 8.5    , 8.5    , 8.2    , 8.7    , 9.3    , 9.6    , 9.2    , 7.1    , 6.8    , 8.1    , 8.6    , 8.1    , 7.5    , 6.5    , 7.8    , 7.7    , 7.6    , 8.6    , 8.3    , 8.6    , 11.4   , 11.5   , 12     , 11.8   , 9      , 9      , 9.7    , 9.5    , 10.9   , 11     , 13.2   , 13.7   , 13.5   , 12.1   , 13     , 13     ,
        '7K1'  , 38.3   , 39     , 38.9   , 38.6   , 37.8   , 37     , 37     , 37     , 36.6   , 37.6   , 37.7   , 38.1   , 36.9   , 36.9   , 35.9   , 35.1   , 33.8   , 34.1   , 32.5   , 32.6   , 32.4   , 31.8   , 33.7   , 29.8   , 29.1   , 29.8   , 29.8   , 29.2   , 27.9   , 28     , 28.1   , 27.6   , 28.5   , 27.5   , 26.9   , 26.5   , 25.3   ,
        '7K2'  , 23.4   , 16.6   , 15.7   , 18.3   , 20.5   , 22.6   , 19.6   , 19.7   , 19.4   , 23.9   , 24     , 25.4   , 22.2   , 21.4   , 23.6   , 24.7   , 24.1   , 24.5   , 26.3   , 26.1   , 26.6   , 24     , 29.3   , 29.7   , 29.1   , 30.6   , 28.7   , 28.6   , 27.5   , 31.1   , 30.7   , 27.1   , 24.6   , 28.2   , 26.3   , 28.1   , 26.9   
      ) %>% 
        dplyr::mutate(chiffre = stringr::str_to_upper(chiffre)) %>% 
        dplyr::select(chiffre, tidyselect::all_of(sexeEE)) %>% 
        dplyr::rowwise() %>% 
        dplyr::mutate(fem_pct = mean(dplyr::c_across(tidyselect::all_of(sexeEE)), na.rm = TRUE)) %>% 
        dplyr::select(chiffre, fem_pct)
     
       PPP3_fem <-tibble::tribble(
        ~`chiffre`, ~`1982`, ~`1983`, ~`1984`, ~`1985`, ~`1986`, ~`1987`, ~`1988`, ~`1989`, ~`1990`, ~`1991`, ~`1992`, ~`1993`, ~`1994`, ~`1995`, ~`1996`, ~`1997`, ~`1998`, ~`1999`, ~`2000`, ~`2001`, ~`2002`, ~`2003`, ~`2004`, ~`2005`, ~`2006`, ~`2007`, ~`2008`, ~`2009`, ~`2010`, ~`2011`, ~`2012`, ~`2013`, ~`2014`, ~`2015`, ~`2016`, ~`2017`, ~`2018`,
        '1A01' , 0      , 13.4   , 21.3   , 18     , 11     , 18     , 14.7   , 15.5   , 5.3    , 10.9   , 16.4   , 10     , 11.1   , 33.7   , 5.1    , 0      , 13.2   , 31.5   , 21.2   , 7.7    , 0      , 24.7   , 11     , 0      , 10.8   , 8.4    , 0      , 12.1   , 17.3   , 15.2   , 22.7   , 18     , 22.9   , 30.8   , 23.8   , 21     , 24.1   ,
        '1A02' , 16.8   , 16.6   , 15.9   , 16.7   , 14.4   , 16.7   , 15     , 16.4   , 13.1   , 14.1   , 8.3    , 16.9   , 12.6   , 14.1   , 14.5   , 11.2   , 11.1   , 12.6   , 12.6   , 7.8    , 13.1   , 15.5   , 3.3    , 6.5    , 14.3   , 23.2   , 14     , 2.7    , 10.1   , 10.7   , 9.8    , 18     , 11.8   , 13.6   , 14.8   , 17.1   , 14.4   ,
        '1A03' , 15.2   , 21.2   , 25.3   , 26.4   , 20.8   , 20     , 18.3   , 16.7   , 15.2   , 16.7   , 13.3   , 15.2   , 14.6   , 18.9   , 16.5   , 21.4   , 22     , 20.5   , 14.4   , 16.9   , 15.1   , 13     , 14.2   , 20.3   , 18.6   , 18.4   , 16.4   , 10.8   , 13.4   , 18.4   , 17.4   , 19.8   , 15.6   , 16.8   , 20.4   , 19     , 15.6   ,
        '2B01' , 8.9    , 10.7   , 9.3    , 10.6   , 12     , 12.5   , 14.1   , 13.5   , 11.1   , 14.5   , 13.3   , 17.9   , 14     , 17     , 15.8   , 13.9   , 19.2   , 21.5   , 16.1   , 18.4   , 24     , 14.9   , 20.9   , 20.2   , 23.7   , 24.8   , 23.9   , 20.8   , 22.5   , 22.4   , 27.1   , 23.4   , 24.3   , 25.9   , 26     , 26.7   , 28     ,
        '2B02' , 7.9    , 16.7   , 13.9   , 20.2   , 16.5   , 14.3   , 17.2   , 16.5   , 19.9   , 17     , 18     , 18.4   , 19.2   , 25.6   , 20.5   , 20.1   , 25     , 22.2   , 22.2   , 24.7   , 26.9   , 21.4   , 20.8   , 26.9   , 22.9   , 26.1   , 18.1   , 24.3   , 28.5   , 29.1   , 31.2   , 27     , 26.7   , 26.2   , 24.9   , 21.5   , 24.9   ,
        '2B03' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 47.9   , 53     , 47.8   , 40.8   , 31.3   , 45.7   , 48.5   , 52.1   , 56.5   , 53.1   , 51.8   , 41.6   , 52.3   , 52.6   , 35     , 41     ,
        '2B04' , 4.2    , 3.5    , 6.7    , 6.9    , 6.5    , 6.3    , 5.5    , 6.7    , 8.2    , 5.3    , 7.4    , 8.5    , 10.1   , 11     , 9.9    , 6.1    , 10.3   , 11     , 10.6   , 12.2   , 12.1   , 12.7   , 12.3   , 12.9   , 13.6   , 16.8   , 15.5   , 16.7   , 17.4   , 22.5   , 20.7   , 21     , 21.1   , 21     , 22.5   , 24.9   , 21.5   ,
        '2C01' , 18.3   , 16.1   , 21     , 36.1   , 32.9   , 30.9   , 30.3   , 26.8   , 29.3   , 36.1   , 33.1   , 40.8   , 41.1   , 47     , 42.9   , 42     , 37.2   , 35.3   , 38.1   , 37.1   , 32.6   , 43.1   , 39     , 36.6   , 40.6   , 44.6   , 34.8   , 43.3   , 43.4   , 42.2   , 46     , 52.1   , 45.4   , 46.7   , 45.8   , 51.9   , 54.4   ,
        '2C02' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 27.1   , 23.7   , 29.7   , 40.1   , 42.6   , 37.4   , 40.8   , 37.5   , 35.2   , 39.7   , 40.2   , 46.2   , 36.1   , 38.3   , 49.4   , 48.1   ,
        '2C03' , 14.6   , 18.3   , 18.3   , 18.6   , 19.6   , 24.3   , 21.1   , 20.4   , 26.8   , 25.7   , 28.9   , 28.4   , 26.2   , 28.1   , 30.5   , 24.9   , 28     , 28.4   , 29.4   , 33.9   , 34.8   , 27.5   , 37     , 38.2   , 50.3   , 49.6   , 47.6   , 45.1   , 49.7   , 48.5   , 46.4   , 48.2   , 48.4   , 52.9   , 47.4   , 52.8   , 52.3   ,
        '2C04' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 30.9   , 22.8   , 28.2   , 34.6   , 30.8   , 24.4   , 34.2   , 34.5   , 38.1   , 33.9   , 31     , 38.2   , 42.5   , 44.8   , 42.3   , 39.9   ,
        '2D21' , 13     , 19     , 21.3   , 12     , 9      , 6.9    , 13.2   , 21     , 14.8   , 32.1   , 19.6   , 18.3   , 20.9   , 19.4   , 23.2   , 27.3   , 24.6   , 20.2   , 31.2   , 22.7   , 27.6   , 40.4   , 32.1   , 44.2   , 17.1   , 24.4   , 55.2   , 35.2   , 24.2   , 49.2   , 48.7   , 46     , 38.1   , 28.4   , 43.5   , 38     , 44.7   ,
        '2D22' , 3.9    , 7.2    , 11.3   , 11.4   , 11.2   , 15.1   , 11.9   , 10.7   , 3.2    , 7.1    , 5.8    , 10.3   , 8.8    , 10.1   , 12.2   , 11.7   , 10.8   , 10.9   , 11.9   , 11.7   , 6.4    , 22     , 12.1   , 22.7   , 22.2   , 20.1   , 14.5   , 12     , 24.2   , 27.1   , 13.3   , 25.1   , 14     , 30.6   , 26.2   , 18     , 21.9   ,
        '2D23' , 8.7    , 15.5   , 10.8   , 8.4    , 10.7   , 10.9   , 8.5    , 9.4    , 17.2   , 17.7   , 19.1   , 11.7   , 13.9   , 16.8   , 23.2   , 24.8   , 24.7   , 26.7   , 17     , 18     , 21.6   , 20.6   , 19.8   , 26     , 25.8   , 20.5   , 35.5   , 30.4   , 25.8   , 27.6   , 27.5   , 34.5   , 28.1   , 28.7   , 34.9   , 35     , 33.8   ,
        '2D24' , 39.3   , 35.5   , 34.6   , 31.6   , 32.3   , 34.1   , 37.1   , 34     , 39.1   , 37     , 40.9   , 43.8   , 42.8   , 43.4   , 44.7   , 41.8   , 43.4   , 44.2   , 45.2   , 47     , 49.5   , 49.3   , 49.1   , 49.4   , 56.1   , 56.8   , 58     , 52.9   , 49.3   , 52.5   , 55.1   , 54.2   , 57.9   , 57.5   , 57.4   , 57.1   , 57.7   ,
        '2D25' , 30.8   , 25     , 20     , 27.5   , 46.2   , 45     , 42.9   , 53     , 49.8   , 53.9   , 43.6   , 40     , 29.5   , 38.1   , 45.4   , 45.1   , 53.5   , 60.3   , 50.3   , 41.5   , 41.9   , 61.8   , 47.3   , 63     , 54.4   , 52.9   , 52.5   , 47.5   , 59.6   , 73.6   , 68.6   , 53.1   , 57.9   , 52.1   , 43.8   , 66.8   , 68.7   ,
        '2D26' , 27.4   , 24.6   , 27     , 27.4   , 32.8   , 31.2   , 28.8   , 32.1   , 36.4   , 39.1   , 38.6   , 36.2   , 36.1   , 40.8   , 44.6   , 42.2   , 42.7   , 40.6   , 43.3   , 42.8   , 44.6   , 43.7   , 48     , 47.9   , 47.8   , 47.2   , 50.6   , 49.7   , 52.1   , 51.6   , 50.1   , 53.4   , 55.6   , 54.5   , 53     , 54.1   , 55.9   ,
        '2D27' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 51.3   , 59.5   , 65.8   , 55.6   , 51.4   , 67.2   , 67.9   , 54.6   , 60.5   , 63.6   , 72.3   , 73.9   , 68.8   , 69.7   , 62.8   , 68.9   ,
        '2D28' , 19.8   , 15     , 12.4   , 18.3   , 26.4   , 30.8   , 29.4   , 30.9   , 22.5   , 23.4   , 31.1   , 27.9   , 24.7   , 21     , 20.6   , 27.6   , 30.2   , 26.4   , 29.1   , 39.3   , 40.1   , 31.6   , 25.5   , 30.3   , 40.8   , 38.9   , 45.9   , 44.3   , 40.7   , 42.1   , 36.4   , 43.8   , 36.3   , 36.1   , 31.5   , 32.4   , 38.4   ,
        '2D29' , 27.7   , 36     , 21     , 25.4   , 34.1   , 37.7   , 26.6   , 30.9   , 21     , 19.8   , 27.5   , 24.9   , 23.7   , 32.3   , 35.5   , 34.4   , 35     , 38     , 32.1   , 30.4   , 36.4   , 47.4   , 60.8   , 45.8   , 39.4   , 39.2   , 41.9   , 40.8   , 49.1   , 42     , 45.1   , 41.4   , 41.2   , 43.2   , 49.9   , 44.6   , 47.8   ,
        '2E21' , 2.5    , 10.1   , 0      , 6.7    , 15.3   , 13.1   , 5.2    , 4.8    , 0      , 0      , 0      , 0      , 6.7    , 12.7   , 5.6    , 7.9    , 3.7    , 16.5   , 0      , 0      , 13.8   , 0      , 4.6    , 25.2   , 43.6   , 0      , 8.7    , 24.6   , 22.9   , 20     , 11     , 0      , 4.3    , 0      , 56.3   , 10.4   , 14.2   ,
        '2E22' , 12     , 0      , 21.6   , 0      , 0      , 3      , 6.6    , 13.5   , 15.6   , 7.8    , 11.8   , 0      , 0      , 13.8   , 8.1    , 14.4   , 16.7   , 13.3   , 13.1   , 11.3   , 12.2   , 8.7    , 5.4    , 3.1    , 5.3    , 5.6    , 6.6    , 5.4    , 8.9    , 8.6    , 9.9    , 9.3    , 8.3    , 8.3    , 10.3   , 7.6    , 9.7    ,
        '2E23' , 6.9    , 5.5    , 6.3    , 4.7    , 8.7    , 12.1   , 9.9    , 13.4   , 10.3   , 16.2   , 15.4   , 16.4   , 13.2   , 18.4   , 22.4   , 25     , 24.4   , 23.6   , 20.4   , 21.8   , 23.3   , 31.9   , 25.3   , 24.6   , 31.5   , 30.5   , 34.5   , 31.4   , 40.2   , 37.7   , 34.2   , 37.2   , 31.8   , 35.7   , 34.4   , 39.6   , 45.1   ,
        '2E25' , 5      , 3.4    , 3.2    , 5.3    , 4.8    , 5.6    , 6      , 7.1    , 6      , 5.8    , 8      , 6.9    , 7.2    , 8.4    , 7.5    , 8.7    , 9.8    , 8.4    , 9.6    , 10.2   , 10.5   , 6.1    , 6.1    , 11.7   , 9.4    , 10.5   , 15.6   , 15.7   , 14.2   , 15.1   , 16.1   , 12.6   , 12.7   , 11.7   , 13.2   , 13.1   , 15.9   ,
        '2E26' , 5      , 5.2    , 5.1    , 5.5    , 8.4    , 6.5    , 8.8    , 8.5    , 9.7    , 10.3   , 9.6    , 10.7   , 11.8   , 10     , 12     , 10.3   , 15.7   , 15.5   , 13.4   , 15.6   , 14.7   , 17.6   , 16     , 17.1   , 18.5   , 19.2   , 18.1   , 21.4   , 19.3   , 20.5   , 22.3   , 21.5   , 20.3   , 22.2   , 21.1   , 24.2   , 23.3   ,
        '2E27' , 15.8   , 14.4   , 13     , 11.3   , 19.1   , 14.8   , 16.7   , 15.4   , 18.2   , 18.5   , 18.9   , 16.3   , 20.3   , 18.4   , 16.3   , 16     , 19     , 19.5   , 18.5   , 16.7   , 20.4   , 20.4   , 19.8   , 19.3   , 16.2   , 14.7   , 20.3   , 21.5   , 19.1   , 20.7   , 20.6   , 21.7   , 18.3   , 14.5   , 17.2   , 17.9   , 18.7   ,
        '2E28' , 0      , 0      , 0      , 3      , 0      , 7.2    , 6      , 3.1    , 3.6    , 0      , 0      , 0      , 6.6    , 5.1    , 7.3    , 2.3    , 5.1    , 10.4   , 6.6    , 0      , 3.2    , 12.5   , 12.6   , 23.2   , 13.6   , 12.8   , 8.9    , 10     , 15.4   , 8.3    , 13.1   , 8.1    , 11.7   , 15.6   , 17.3   , 26.7   , 26     ,
        '2E29' , 13.2   , 9.2    , 14     , 14.8   , 13.6   , 11     , 11.7   , 14.6   , 7.6    , 18.5   , 9.2    , 14.6   , 21.3   , 13.4   , 28.6   , 20.4   , 11.2   , 7.2    , 13.7   , 22.4   , 32.7   , 23.1   , 24.7   , 24.7   , 26.1   , 27.1   , 30.3   , 39.2   , 36.1   , 34.1   , 32.1   , 34.7   , 37.4   , 33.2   , 29.7   , 32.2   , 37     ,
        '2F01' , 87.3   , 87     , 83.4   , 83.2   , 85.9   , 84.1   , 89     , 95.2   , 91.6   , 90.4   , 87.2   , 90.7   , 87.1   , 78.2   , 78.2   , 80.8   , 83.3   , 84.8   , 80.6   , 81.3   , 84.9   , 84.8   , 81.1   , 79.1   , 90.8   , 80.6   , 78.6   , 80.6   , 71.3   , 79.8   , 78.3   , 83.5   , 78.1   , 91.7   , 92.6   , 86.7   , 86.3   ,
        '2F02' , 88.6   , 92.5   , 94.4   , 91.4   , 95     , 95.1   , 91.8   , 85     , 94.7   , 76.6   , 91.4   , 81.2   , 84.3   , 79.7   , 79.6   , 74.8   , 90.5   , 94.6   , 79.8   , 82.6   , 78.5   , 80.9   , 90.8   , 93.8   , 95.6   , 95.2   , 82.5   , 84.8   , 96.2   , 93.7   , 84.4   , 82.8   , 83.8   , 89.2   , 85.5   , 87     , 88.8   ,
        '2G00' , 5.2    , 3.8    , 4.3    , 5.9    , 4.6    , 4      , 7.7    , 8.3    , 3.1    , 8.5    , 7.3    , 8.3    , 3.8    , 5      , 7      , 9.8    , 8.8    , 7.3    , 3      , 7.3    , 6.1    , 12.3   , 6.4    , 8.2    , 19.2   , 22.6   , 11.2   , 8.9    , 11.3   , 13.7   , 15.5   , 19.4   , 13.8   , 14.9   , 13.1   , 12.2   , 14.7   ,
        '2H00' , 17.3   , 15.5   , 39.8   , 28.5   , 24.3   , 26.5   , 34.1   , 28.1   , 29.8   , 20.8   , 30.1   , 25.8   , 19.3   , 21.4   , 23.5   , 22.4   , 9.7    , 21.3   , 47.6   , 33.2   , 27     , 29.8   , 28     , 19.4   , 27.1   , 29.8   , 24.1   , 31.3   , 30.8   , 27.3   , 33.9   , 32     , 40.1   , 31.6   , 37.6   , 37.7   , 30.9   ,
        '2I11' , 27.4   , 29.6   , 33.9   , 37.6   , 32.6   , 14.5   , 20.8   , 27.7   , 30.2   , 32.4   , 30.7   , 23.6   , 31.7   , 39.3   , 38.7   , 28.7   , 37     , 27     , 29.1   , 34.7   , 35.4   , 44.7   , 47.8   , 46     , 47.4   , 48.9   , 45.4   , 31     , 41     , 56.1   , 59.6   , 62     , 47.8   , 38     , 43.6   , 45.8   , 34.7   ,
        '2I12' , 0      , 0      , 48.9   , NA, 31.4   , 0      , 0      , 0      , 100    , 24.1   , 100    , 11.5   , 5.9    , 20.6   , 25.4   , 35.1   , 16.2   , 41.7   , 47.9   , 54.8   , 35.6   , 13.9   , 33.3   , 50.4   , 25.3   , 47.4   , 44.7   , 52.2   , 39     , 32.3   , 24.4   , 43.5   , 42.8   , 37.5   , 30.5   , 48.6   , 41.4   ,
        '2I21' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 68.3   , 65.3   , 74.4   , 63.1   , 63.2   , 53.9   , 56.9   , 67     , 58.9   , 69.5   , 68.8   , 57.8   , 49.4   , 61.9   , 61.3   , 64.1   ,
        '2I22' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 50     , 55.4   , 65     , 67     , 63     , 61.3   , 71.7   , 62.5   , 62.4   , 67.9   , 66.3   , 50.2   , 55.6   , 52.2   , 56.7   , 57.2   ,
        '2J01' , 73.3   , 76.3   , 73.2   , 74.6   , 81.5   , 80.7   , 80.8   , 83.7   , 87.3   , 74.4   , 68.8   , 69.8   , 71.8   , 85.1   , 81.5   , 80.2   , 77.5   , 81.6   , 86.4   , 77.6   , 73.4   , 80.2   , 83     , 91.8   , 74.1   , 78.5   , 76.3   , 68.4   , 83     , 77.1   , 75.6   , 63.6   , 58.1   , 73.7   , 73.5   , 67.5   , 73.4   ,
        '2J02' , 0      , NA, NA, NA, NA, 0      , 29.2   , 0      , NA, 0      , NA, 0      , 0      , 0      , 0      , 100    , 100    , NA, 48.4   , 34.5   , 41.9   , 0      , 0      , 0      , 9.8    , 8      , 0      , NA, 100    , 100    , 100    , 100    , 0      , 100    , 100    , 66.2   , 20.1   ,
        '2J03' , 26.9   , 32.9   , 12     , 28.3   , 33.2   , 39.4   , 54.9   , 36.3   , 30.3   , 29.1   , 23.3   , 31.6   , 34.8   , 39     , 42     , 48.9   , 44.2   , 28.9   , 26.5   , 26.5   , 25     , 28.6   , 32.5   , 44.4   , 50.8   , 42.1   , 42.9   , 43.3   , 41.8   , 38     , 50.3   , 36.7   , 28.6   , 40.3   , 49.8   , 36.6   , 36.9   ,
        '3B11' , 21.9   , 20.4   , 23.3   , 22.4   , 21.2   , 20.8   , 23.4   , 23.9   , 28.5   , 27.5   , 30.9   , 31.4   , 34.9   , 35.5   , 34.5   , 34.9   , 35.5   , 38.3   , 41.3   , 39.5   , 40.3   , 36.1   , 37.3   , 36.6   , 34.3   , 38.9   , 39.1   , 39.1   , 38.7   , 38.1   , 38.3   , 40.6   , 40.4   , 39.6   , 36.4   , 38.3   , 44.1   ,
        '3B12' , 40.5   , 44.3   , 47.1   , 43.5   , 40.2   , 44.1   , 41.1   , 39.7   , 41.4   , 47.7   , 53.6   , 44.1   , 38.1   , 42.3   , 44.6   , 41.7   , 44.6   , 36.9   , 39.5   , 40.6   , 48.3   , 49.9   , 53.9   , 51     , 48.5   , 43.9   , 54.2   , 53.8   , 52.8   , 50     , 56.5   , 57.1   , 55.7   , 52.2   , 57.6   , 56.6   , 55.6   ,
        '3B13' , 21.9   , 24.4   , 27.9   , 32.7   , 36     , 40.7   , 38.9   , 37.3   , 41.6   , 44.3   , 47.8   , 41     , 43.9   , 45.7   , 42.7   , 41.9   , 47.1   , 46.5   , 47.9   , 47.7   , 44.9   , 52.7   , 54.8   , 60.2   , 57.7   , 55.8   , 56.2   , 45.7   , 50     , 51.4   , 58.1   , 54.6   , 52.6   , 53.3   , 59     , 56.2   , 55.4   ,
        '3B21' , 33.4   , 36.8   , 37.4   , 36.9   , 35.7   , 34.7   , 33.1   , 34.3   , 32.7   , 33.1   , 31.4   , 33     , 37     , 40     , 37.1   , 33.6   , 34.1   , 33.3   , 36.6   , 34.5   , 36     , 30.7   , 33.2   , 31.1   , 30.7   , 32.6   , 35.7   , 31.6   , 31.8   , 30.5   , 29     , 30.2   , 31.3   , 33.9   , 34.1   , 32.9   , 30.6   ,
        '3B22' , 27     , 24.5   , 28.6   , 29.4   , 31.1   , 32.8   , 27.6   , 29.4   , 39.9   , 36     , 37.3   , 31     , 30.7   , 35     , 30.5   , 31.2   , 34     , 31.1   , 29.8   , 32.3   , 30.1   , 31     , 29.8   , 28.8   , 31.1   , 31.6   , 30.7   , 30     , 29.6   , 29.7   , 29.5   , 28.9   , 37.3   , 33.5   , 32.2   , 35.4   , 38     ,
        '3C01' , 51.2   , 49.1   , 56.2   , 59.3   , 53.9   , 56.1   , 57.7   , 57.6   , 57.6   , 58.4   , 57.7   , 61.2   , 58.9   , 60.8   , 58.9   , 60.5   , 62.7   , 67.4   , 68     , 68.7   , 68.6   , 73.1   , 71.8   , 64.7   , 54.1   , 57.8   , 61.7   , 69.7   , 72.1   , 64.4   , 64.7   , 58.6   , 58.9   , 60.2   , 58.4   , 61.5   , 63.4   ,
        '3C02' , 41.8   , 34.8   , 37.2   , 39.5   , 41.5   , 39     , 43.6   , 48.4   , 36.5   , 46.9   , 51.1   , 51.8   , 51     , 48.9   , 51.6   , 46.8   , 49.8   , 48     , 54.5   , 50.8   , 57.9   , 55.5   , 62.1   , 70.1   , 59.5   , 57     , 63.8   , 64.8   , 55.9   , 58.2   , 57.3   , 57.2   , 59     , 58.7   , 62.8   , 62.5   , 58.2   ,
        '3C03' , 51.9   , 49.1   , 50.6   , 52.8   , 56.9   , 63     , 57.1   , 58.4   , 61.8   , 57.9   , 64.8   , 66.7   , 69.8   , 58.5   , 65.5   , 71.3   , 68.3   , 68.1   , 66.6   , 69.7   , 74.4   , 55.9   , 52.9   , 55.7   , 58.9   , 59.8   , 62.6   , 65.3   , 63.8   , 65.6   , 66.6   , 71.5   , 62.6   , 66.4   , 72.4   , 70.9   , 69.1   ,
        '3D01' , 64.4   , 65.4   , 62.4   , 65.5   , 67.2   , 68.6   , 67.9   , 64.8   , 62.6   , 69.1   , 69.2   , 69.2   , 71.5   , 73.6   , 71.4   , 72.4   , 70.4   , 69.9   , 69.7   , 67.7   , 65.6   , 65.7   , 64.3   , 64.9   , 69.4   , 71     , 65.4   , 67.8   , 70.5   , 67.9   , 67.8   , 69     , 70.1   , 71.2   , 69.2   , 70     , 70.8   ,
        '3D02' , 96.4   , 97.2   , 97.8   , 95.6   , 96.5   , 97.4   , 97.6   , 99.2   , 99     , 99     , 99.2   , 98.6   , 99     , 97.7   , 99.2   , 96.6   , 97     , 98     , 96.6   , 97.4   , 96.9   , 94.3   , 94.2   , 94.8   , 97.1   , 96.8   , 95     , 95.9   , 96.9   , 94.9   , 95.2   , 95.1   , 95.6   , 93.9   , 94.1   , 94.3   , 96.3   ,
        '3D03' , 44.7   , 44.7   , 46.5   , 47     , 48.8   , 51.9   , 56.2   , 55.8   , 59.5   , 56.9   , 58.3   , 58.9   , 56.7   , 58.6   , 59.1   , 58.3   , 58.8   , 61.8   , 59.6   , 64.9   , 63.3   , 63.6   , 67.2   , 65.1   , 68.6   , 68.1   , 68.6   , 67.5   , 67.3   , 72.6   , 71.1   , 69.4   , 66.9   , 71.1   , 70.9   , 71.5   , 73.6   ,
        '3D04' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0      , 0      , 100    , NA, NA, NA, NA, NA, 100    ,
        '3D05' , 17.4   , 10.4   , 12.6   , 11.7   , 13.7   , 9      , 9.5    , 12.8   , 8      , 15.7   , 11.4   , 4.8    , 15.5   , 15.9   , 11     , 17.6   , 19     , 13.5   , 12     , 12.3   , 17.4   , 10.7   , 12.3   , 13.7   , 19.9   , 16.8   , 19.8   , 20     , 18     , 20.5   , 23.4   , 27.6   , 19.9   , 13.2   , 23.8   , 19.8   , 15.7   ,
        '3D06' , 40.4   , 35.8   , 38.8   , 36.8   , 38.6   , 43.6   , 44.2   , 47.6   , 44.4   , 44.4   , 43.7   , 45.6   , 49.3   , 45.6   , 49     , 43.6   , 50.2   , 45.6   , 48.6   , 44.6   , 47.4   , 35.8   , 35.7   , 43.9   , 45.9   , 41     , 43.1   , 44.1   , 42.1   , 46.1   , 47.1   , 47.2   , 44.1   , 44.2   , 42.3   , 45.2   , 50.9   ,
        '3D07' , 32.7   , 40.2   , 38.8   , 37.7   , 29.3   , 28     , 28     , 32.9   , 35.1   , 48.3   , 51.6   , 55.9   , 47.2   , 50.4   , 47     , 46.8   , 42.4   , 46.8   , 43.8   , 42.8   , 41.9   , 66.6   , 65.8   , 64     , 59     , 57.4   , 62.5   , 64.2   , 60     , 62.1   , 64.7   , 60.3   , 65.8   , 69.5   , 70     , 67.2   , 62.7   ,
        '3D08' , 55.9   , 59.6   , 55.6   , 59.1   , 55.8   , 53.6   , 49.1   , 51.4   , 55.4   , 53.3   , 51.1   , 51.5   , 51.2   , 49     , 48.1   , 49.3   , 46.1   , 45     , 46.1   , 46.7   , 47.1   , 60.7   , 53.5   , 55.6   , 46.5   , 60.5   , 63.4   , 64.8   , 72.5   , 53.9   , 49.7   , 47.6   , 73.1   , 58     , 52     , 44.8   , 51.5   ,
        '3E11' , 5.4    , 3.4    , 5.2    , 5.5    , 5.8    , 2.9    , 3.9    , 3.2    , 5.9    , 9.5    , 9.9    , 8.1    , 6.2    , 7.1    , 4.7    , 5      , 6.6    , 3.9    , 6.9    , 4.7    , 12.1   , 11.7   , 5      , 7.5    , 11.6   , 17     , 8.5    , 19.8   , 17     , 10.2   , 12.6   , 19.3   , 16.9   , 24.8   , 24.3   , 21.9   , 26.7   ,
        '3E12' , 0.3    , 0      , 0      , 0.7    , 0.4    , 0.4    , 0.8    , 0.7    , 0.7    , 1.5    , 0.9    , 1.7    , 1.3    , 1.4    , 1.5    , 1.3    , 1.5    , 0.5    , 1.3    , 1.2    , 1      , 2.9    , 5.5    , 5      , 2.7    , 1.7    , 2.5    , 3.1    , 1.5    , 2.7    , 3.9    , 4.9    , 4.4    , 5.4    , 8.3    , 3.4    , 6.3    ,
        '3E13' , 6.3    , 6.9    , 6.9    , 6.8    , 8.3    , 8.9    , 8.7    , 8.1    , 7.4    , 6.1    , 6      , 8.4    , 7.2    , 7.6    , 9.6    , 8.2    , 7.2    , 7.3    , 8.5    , 7.3    , 9.1    , 10.5   , 9.9    , 10.8   , 12.6   , 10.7   , 8.7    , 8.8    , 10.4   , 10.9   , 11.1   , 10.8   , 13.3   , 14.8   , 12.4   , 14.2   , 13.9   ,
        '3E14' , 8.5    , 8      , 9.1    , 7.3    , 6      , 12.3   , 10.1   , 8.2    , 10.1   , 10.3   , 9      , 13.5   , 15.1   , 13.8   , 14.6   , 15     , 16.8   , 18.3   , 17.6   , 19.3   , 18.6   , 16.5   , 16.4   , 21.8   , 14.4   , 18.9   , 15.5   , 18     , 21.1   , 25.3   , 21.2   , 21.9   , 25.6   , 20.5   , 17.3   , 21.9   , 20.2   ,
        '3E15' , 2.6    , 0      , 2      , 0      , 2.8    , 3.1    , 0      , 2.5    , 8.1    , 13.8   , 11.2   , 0      , 3.2    , 10.1   , 4.7    , 7.9    , 7.4    , 4.3    , 8.8    , 2.8    , 5.7    , 27.9   , 24.8   , 13.6   , 9.3    , 15.9   , 33     , 13     , 16     , 22.4   , 20.7   , 24     , 23.8   , 24.2   , 12.9   , 15.5   , 19.6   ,
        '3E21' , 13.4   , 13.7   , 14     , 13.8   , 12.9   , 13.9   , 13.1   , 11.4   , 17.9   , 25.2   , 20.3   , 15.4   , 18.8   , 20.4   , 19.6   , 17.7   , 18     , 22.1   , 19.1   , 25.4   , 22.6   , 23.1   , 25.5   , 21.9   , 18.2   , 22.4   , 20.3   , 18.4   , 26.4   , 24     , 23.2   , 26.8   , 23.9   , 23.3   , 23.9   , 23.1   , 32.6   ,
        '3E22' , 7.5    , 5.9    , 6.2    , 7.7    , 10.3   , 8.3    , 8      , 9      , 11.3   , 9.4    , 10.2   , 9.8    , 10.2   , 10.3   , 9.1    , 10.2   , 12.1   , 11.8   , 11.4   , 14.4   , 13.8   , 9.3    , 11.1   , 10     , 7.1    , 8.5    , 9.4    , 10.9   , 10.2   , 10.7   , 11.3   , 11.5   , 11.9   , 11.4   , 13.3   , 13.3   , 12.9   ,
        '3E23' , 0.5    , 1.7    , 2      , 2.9    , 1.3    , 2.7    , 2.8    , 1.8    , 1.1    , 1.6    , 1.9    , 1.5    , 1.6    , 1.9    , 2.1    , 1      , 1.2    , 1.6    , 3      , 3      , 2.9    , 1.6    , 1      , 1.3    , 0.6    , 1.4    , 0.8    , 1.8    , 2.4    , 1.4    , 2.8    , 2.8    , 1.1    , 1.2    , 2.2    , 1.9    , 1.6    ,
        '3E24' , 7.2    , 9      , 6.9    , 6.7    , 6.9    , 7.9    , 9.6    , 10.1   , 7.9    , 9      , 10.4   , 10.3   , 9      , 13.6   , 10.7   , 9.4    , 10.9   , 10.9   , 12.5   , 13.4   , 13.5   , 21.2   , 20.6   , 19.3   , 20.1   , 19.1   , 19.7   , 25.4   , 25.7   , 22.3   , 26.1   , 24.3   , 23.5   , 23.5   , 27     , 31.3   , 24.1   ,
        '3E25' , 24.8   , 25     , 20.1   , 26.5   , 23.6   , 26.5   , 22.9   , 23.7   , 22.4   , 22.5   , 20.6   , 17.7   , 17.8   , 18.4   , 18.7   , 21.7   , 18.2   , 17.1   , 16.4   , 16.5   , 15.3   , 16.9   , 19.8   , 11.5   , 16.4   , 14.6   , 13.6   , 12.5   , 11.2   , 10.1   , 14.7   , 17.4   , 15.3   , 13.8   , 15.4   , 14.9   , 17.3   ,
        '3E26' , 8.8    , 6.4    , 7.9    , 6.7    , 6.3    , 4.9    , 7      , 6.6    , 11.3   , 11.1   , 11.9   , 8      , 12     , 9.3    , 14.4   , 14.3   , 14.9   , 16.8   , 13.7   , 17.1   , 15.7   , 13.1   , 12.2   , 11.8   , 13.7   , 12.8   , 13.9   , 13.2   , 13.8   , 12.5   , 11.6   , 13.9   , 14.4   , 14.7   , 16.6   , 15.8   , 18.7   ,
        '3F00' , 60.7   , 57.5   , 62.4   , 58.9   , 60.6   , 69.4   , 69.5   , 69.8   , 67.8   , 62.4   , 67.6   , 68.9   , 71.8   , 70.2   , 68.9   , 73.8   , 73     , 69.3   , 68.7   , 70.2   , 69.2   , 70.2   , 72.3   , 74.8   , 77.2   , 75.6   , 73.9   , 76.5   , 73.6   , 74.2   , 73     , 73.9   , 71     , 73.1   , 74.8   , 73.4   , 71.4   ,
        '3H00' , 28     , 20.6   , 21     , 27     , 23.9   , 30.6   , 29.8   , 22.8   , 27.3   , 23.9   , 30.4   , 27.6   , 29.1   , 29.9   , 22.2   , 24.1   , 31.2   , 30.5   , 28.9   , 30.7   , 30.3   , 23.4   , 35.2   , 33.8   , 28.7   , 34.5   , 39.5   , 36     , 31.8   , 41     , 38.4   , 37.2   , 39.2   , 34.3   , 34.3   , 37     , 40.8   ,
        '3I11' , 57.2   , 61.2   , 60.7   , 55.3   , 50.1   , 65.2   , 60.4   , 62.7   , 60.5   , 57.5   , 61.4   , 61.8   , 61.5   , 58.5   , 58.7   , 65     , 61.8   , 64.1   , 65.7   , 63.1   , 64.1   , 65     , 68.2   , 68.5   , 65.6   , 68.2   , 70.1   , 74.3   , 72     , 71.7   , 68.3   , 64     , 61.6   , 72.2   , 73.7   , 68.3   , 68.4   ,
        '3I12' , 55.5   , 58.4   , 57.8   , 59.7   , 62.7   , 57.7   , 57.9   , 56.8   , 60.1   , 59.4   , 60.5   , 59.4   , 67     , 64.4   , 65.8   , 66     , 68.6   , 64.5   , 66.7   , 67.9   , 71.7   , 72.7   , 65     , 63     , 73     , 72.7   , 69.4   , 67.4   , 70.9   , 69     , 70.5   , 68     , 69     , 68.8   , 74.5   , 75.6   , 75.5   ,
        '3I10' , 31.8   , 28.1   , 38.4   , 29.7   , 40.9   , 38.7   , 42.6   , 42.5   , 48.5   , 41     , 46.2   , 48     , 47.2   , 45.8   , 44.5   , 46.9   , 45     , 45.1   , 53.5   , 49.8   , 48.7   , 48.4   , 50.5   , 53.9   , 55.1   , 53.2   , 52.6   , 50.5   , 54.1   , 54.9   , 55.2   , 53.9   , 54.9   , 53.2   , 48.2   , 49.5   , 50.6   ,
        '4F10' , 32.9   , 30     , 33.7   , 33.6   , 41.2   , 41.1   , 40.8   , 42.3   , 43.2   , 43.4   , 35.1   , 40.6   , 44.5   , 46.3   , 42.4   , 44.3   , 42     , 48.7   , 46.6   , 43.3   , 43.1   , 47.8   , 45.9   , 42.4   , 45     , 49.1   , 51.6   , 52.3   , 49.1   , 50.9   , 51.1   , 47     , 53.2   , 52.5   , 56.8   , 53.7   , 52.3   ,
        '4F21' , 28.2   , 27.7   , 28.6   , 28.2   , 25.8   , 25.8   , 28.9   , 29.6   , 28.8   , 29.2   , 33.2   , 33.6   , 31.6   , 30.1   , 29.7   , 32.8   , 32     , 35.7   , 35     , 37.6   , 35.7   , 38.3   , 39.9   , 40.5   , 35     , 37.7   , 42.6   , 38.6   , 37.7   , 38.8   , 40     , 42.5   , 42.7   , 42     , 42.6   , 46.3   , 48.7   ,
        '4F30' , 87.7   , 87.7   , 86.6   , 86.7   , 87.5   , 87.8   , 88.3   , 86.9   , 87.7   , 88     , 87.5   , 88.7   , 86.9   , 88.4   , 88.4   , 89.8   , 89.5   , 88.8   , 89.6   , 88.2   , 86.8   , 87.9   , 88.8   , 91.2   , 88.3   , 88.1   , 86.8   , 88.6   , 88.4   , 87.5   , 87.4   , 86.8   , 86.4   , 87     , 86     , 84.2   , 85.4   ,
        '4F42' , 60.6   , 59.1   , 57.2   , 56.9   , 55.5   , 56.2   , 58.3   , 57.2   , 53.7   , 53.3   , 55.8   , 58.2   , 57.6   , 59.1   , 62.2   , 58.5   , 65     , 63     , 64.7   , 65.3   , 64.2   , 62.2   , 62.5   , 57.7   , 57.9   , 59.7   , 71.6   , 69.1   , 66.3   , 63.1   , 64.2   , 63.3   , 69.6   , 68.7   , 69.2   , 69.9   , 64.3   ,
        '4F43' , 100    , 96.8   , 97.3   , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 99.5   , 99.5   , 100    , 100    , 100    , 100    , 97.6   , 92.7   , 96.5   , 99.2   , 98.3   , 100    , 98.1   , 96     , 99.5   , 100    ,
        '4F44' , 57.4   , 59.7   , 61.5   , 60.8   , 59.8   , 62.1   , 63.4   , 60.2   , 57.6   , 65     , 58.9   , 59.5   , 65.9   , 60.4   , 59.2   , 57.1   , 60.6   , 64.4   , 58.9   , 60.2   , 60.5   , 64.2   , 63.5   , 66.2   , 69.5   , 70.3   , 70.5   , 65.6   , 66.2   , 69.3   , 65.6   , 69.1   , 71.5   , 66.9   , 69.3   , 67.3   , 73.3   ,
        '4F45' , 67     , 70.6   , 75.7   , 60.5   , 63.8   , 62.2   , 61.6   , 64.6   , 56.9   , 65.4   , 62.2   , 69.9   , 72.4   , 69.6   , 73.4   , 73.6   , 74.2   , 74.2   , 75     , 77.2   , 82.5   , 72.5   , 77     , 81.6   , 88.7   , 82.1   , 81.1   , 85.7   , 84     , 80.5   , 80.5   , 88.6   , 86.4   , 85     , 88.1   , 88.9   , 84.9   ,
        '4I11' , 26.6   , 34.5   , 27.1   , 32.1   , 28.7   , 30.2   , 24.3   , 26     , 27.4   , 31.1   , 30.8   , 30     , 31.6   , 25.6   , 27     , 39.5   , 35.1   , 36.4   , 42.3   , 37.4   , 41.2   , 35.3   , 35.9   , 37     , 39.3   , 40.2   , 38     , 44.8   , 42.7   , 40.6   , 42.4   , 40.6   , 44.4   , 49.6   , 47.9   , 47.6   , 52.9   ,
        '4I12' , 21.8   , 27.8   , 21.6   , 29.9   , 27.7   , 35.5   , 28.8   , 27.7   , 30.9   , 37.5   , 39.8   , 35.4   , 37.4   , 37.7   , 34.4   , 41     , 38.1   , 37     , 31.7   , 35.1   , 42.5   , 32.7   , 35.6   , 43.6   , 36.1   , 31     , 34.5   , 43.1   , 39.1   , 42.4   , 40     , 41     , 42.2   , 42.6   , 36.5   , 34.1   , 29     ,
        '4I13' , 57.8   , 56.7   , 56.6   , 55.6   , 55.3   , 54     , 56.9   , 56.5   , 53.9   , 55.6   , 56.9   , 58.1   , 58.7   , 58.2   , 57.7   , 56.1   , 56.3   , 55.5   , 57.4   , 57.8   , 58.8   , 59.1   , 60.7   , 59.2   , 60.3   , 61     , 61     , 60.7   , 59.8   , 58.1   , 61.1   , 61.7   , 60.4   , 59.7   , 60.5   , 59.8   , 58.8   ,
        '4I14' , 72.9   , 76.3   , 75.4   , 74.5   , 72.5   , 73.3   , 73.2   , 74.8   , 74.7   , 75.8   , 75.3   , 76.5   , 77.3   , 77.6   , 78.4   , 79     , 77.1   , 79.1   , 79.4   , 79.9   , 78.5   , 80.2   , 80.7   , 80.2   , 82.5   , 78.9   , 79.1   , 79.9   , 80.9   , 80.8   , 80.9   , 82.2   , 83.4   , 84.8   , 84.1   , 82.3   , 84     ,
        '4I21' , 59.4   , 59.1   , 62.2   , 57.1   , 54.1   , 54.3   , 56.2   , 56.2   , 58.4   , 58.5   , 58.9   , 57.7   , 59.3   , 63.5   , 64.5   , 63.4   , 67.1   , 64.5   , 63     , 65.3   , 66.6   , 61.6   , 60.9   , 66.8   , 65.9   , 70.2   , 70.5   , 68.8   , 65.1   , 65     , 65.5   , 66.4   , 71.7   , 70.3   , 69.5   , 68.4   , 69.7   ,
        '4I22' , 97.4   , 98.1   , 95.2   , 94.9   , 97.2   , 97.3   , 95.9   , 96.2   , 95.6   , 95.7   , 94.7   , 92.7   , 96.1   , 94.5   , 96.3   , 94.3   , 93.9   , 95.1   , 95.6   , 92.5   , 92.6   , 95.9   , 91.2   , 90.8   , 93.2   , 93.5   , 94.4   , 91.4   , 93.4   , 89     , 87.4   , 84.4   , 89.9   , 90     , 94.4   , 94.2   , 93.4   ,
        '4I23' , 76.8   , 100    , 94.8   , 82.2   , 81.5   , 86     , 85.2   , 80.7   , 89.4   , 90.1   , 90.3   , 74.3   , 90     , 95.3   , 87.6   , 91.3   , 95.4   , 88.4   , 81.7   , 81.7   , 79.1   , 82.8   , 84.1   , 89.2   , 94.1   , 95.6   , 87.1   , 87.2   , 91.1   , 96.3   , 92.2   , 88.7   , 94.2   , 95.3   , 90.8   , 95     , 85.7   ,
        '4I32' , 14.7   , 18.9   , 27.2   , 32.6   , 27.8   , 26.9   , 20.9   , 24.2   , 24.9   , 26.2   , 19     , 23.5   , 24.1   , 25     , 28.3   , 29.9   , 30.5   , 33.4   , 35.3   , 37.4   , 34     , 28.8   , 38.7   , 34     , 34.4   , 38     , 33.4   , 32.1   , 33.1   , 36.8   , 35.9   , 36     , 38.3   , 40.9   , 37.6   , 37.2   , 35.3   ,
        '4I33' , 3.3    , 7.4    , 6.4    , 7.9    , 2.5    , 6.3    , 3.3    , 10.3   , 1.3    , 1.8    , 4.5    , 8.8    , 9.2    , 7.4    , 5.1    , 10.9   , 6.4    , 15.1   , 18.9   , 20     , 11.5   , 11.4   , 18     , 13.3   , 14.5   , 9.8    , 0      , 4.6    , 16     , 11.2   , 8      , 12.8   , 12.3   , 16.1   , 20.4   , 17.9   , 25     ,
        '4J11' , 33     , 34.8   , 31.8   , 26.5   , 29.6   , 29.9   , 35.2   , 40.7   , 36.9   , 32.3   , 31.5   , 25.9   , 35     , 24.5   , 34.1   , 33.7   , 28.6   , 32.8   , 35.4   , 34.5   , 38.4   , 38.4   , 39.7   , 33.6   , 30.6   , 31.9   , 34.7   , 32.1   , 34.6   , 39.4   , 43.2   , 36.8   , 34.6   , 39.6   , 39.8   , 35.9   , 39.9   ,
        '4J12' , 41.7   , 30     , 19.6   , 13.1   , 20.7   , 13.9   , 12.7   , 29.4   , 23.3   , 22.4   , 25.8   , 36.7   , 17.1   , 33.3   , 26.9   , 23.6   , 19.8   , 20     , 30.9   , 38.9   , 29.8   , 28.7   , 47.8   , 34.3   , 34.7   , 26.8   , 36.3   , 48     , 22     , 19.7   , 27.1   , 30.3   , 23.7   , 21.9   , 26     , 20.2   , 21.7   ,
        '4J13' , 54.9   , 65.5   , 58.7   , 58.5   , 59.6   , 60.9   , 63.5   , 61.7   , 67.9   , 61.9   , 65     , 59.9   , 58.2   , 63.8   , 55.5   , 60.1   , 55.1   , 60.6   , 60.7   , 57.2   , 59.3   , 59.6   , 54.8   , 57.6   , 51.9   , 60.5   , 60.7   , 51.5   , 40.2   , 51.8   , 60.7   , 59     , 56.4   , 54.3   , 56.1   , 53.6   , 59     ,
        '4J21' , 17.2   , 17.3   , 18.8   , 16.9   , 14.1   , 14.9   , 15.4   , 18     , 14.7   , 23.2   , 27     , 21.6   , 19.8   , 22.1   , 25.9   , 27.5   , 29.7   , 35.9   , 33.8   , 32.8   , 32.2   , 33.7   , 30.3   , 32.9   , 40.6   , 41.4   , 39.7   , 40.5   , 37     , 39.2   , 45.1   , 42.8   , 40     , 44.4   , 45.4   , 45.7   , 44.4   ,
        '4J22' , 35.5   , 32.5   , 38.6   , 36.4   , 47.6   , 39.5   , 37.8   , 36.9   , 44.4   , 43.8   , 36.5   , 32.9   , 36.9   , 41.3   , 46.4   , 36.1   , 42.5   , 45     , 46.7   , 44.6   , 48.9   , 41     , 49.6   , 54     , 56.6   , 51.9   , 54.2   , 64.2   , 51.4   , 42.3   , 45     , 48.5   , 46.4   , 53.6   , 58     , 49.8   , 48.3   ,
        '4J24' , 5.6    , 7.6    , 12.9   , 17.6   , 17.7   , 31.9   , 33.1   , 5.7    , 31.1   , 18.5   , 6.8    , 27.8   , 24.9   , 21.6   , 29.3   , 18.6   , 18.2   , 17.7   , 29.8   , 26.9   , 19.4   , 41.5   , 8.7    , 9.2    , 19     , 18.8   , 27.3   , 45.3   , 29.1   , 28.2   , 24.6   , 21.8   , 28.8   , 35.1   , 32.5   , 32.5   , 24.9   ,
        '4J25' , 75.1   , 78.4   , 73.6   , 79.5   , 81.8   , 77.4   , 65.8   , 69.5   , 82.8   , 76.2   , 76.2   , 77.4   , 77.7   , 76     , 88.3   , 83.9   , 74.8   , 72.6   , 73.4   , 83.7   , 80.5   , 66.6   , 50.4   , 51.7   , 56.6   , 55.1   , 70.4   , 69.4   , 59.9   , 52.4   , 62     , 56.5   , 61.3   , 57.2   , 55.8   , 65.8   , 68.1   ,
        '5B11' , 75.2   , 75.4   , 75.2   , 75     , 75.5   , 74.1   , 71.4   , 73.6   , 73.9   , 75.1   , 73.2   , 70.1   , 69.2   , 66.6   , 69.8   , 66.9   , 65.4   , 68.1   , 67.1   , 64.8   , 63     , 69     , 70.2   , 71.4   , 70.1   , 73.3   , 71.9   , 71     , 72.1   , 69.1   , 70.1   , 71.3   , 70.6   , 69.5   , 72.2   , 70.8   , 69.6   ,
        '5B12' , 74.6   , 74.3   , 74.6   , 80.1   , 76.5   , 75.3   , 76.4   , 76.2   , 79.7   , 79.5   , 81.2   , 77.3   , 78.3   , 75.8   , 76.8   , 77.4   , 77.1   , 76     , 76.2   , 76.6   , 75.7   , 75.6   , 75.7   , 81.6   , 78.5   , 76.7   , 78     , 77.7   , 74.3   , 74.3   , 75.2   , 72.2   , 71.4   , 72.4   , 71.5   , 69.6   , 71.2   ,
        '5B13' , 90     , 87.5   , 89.6   , 89.2   , 89.3   , 86     , 86     , 87.4   , 85.7   , 87.6   , 87.3   , 85.1   , 84.9   , 84.2   , 86.3   , 85.3   , 84     , 79.9   , 81.8   , 83.3   , 84     , 83.2   , 85.3   , 84.4   , 83.5   , 84.3   , 82.2   , 82.2   , 82.6   , 78.5   , 79.2   , 78.4   , 81.3   , 82.2   , 77.9   , 75     , 77.4   ,
        '5B22' , 53.9   , 55.6   , 55.6   , 56.2   , 55     , 56.1   , 53.7   , 54.9   , 52.6   , 56.3   , 54.7   , 52     , 50.2   , 52.3   , 50.1   , 53.2   , 45.8   , 44.4   , 49.9   , 51.2   , 47.3   , 49.6   , 48.2   , 47     , 46     , 49.5   , 54.3   , 48.2   , 43.8   , 47.3   , 46     , 44.7   , 45.1   , 46.7   , 50.7   , 49.8   , 44.7   ,
        '5C01' , 68.2   , 68.8   , 71.6   , 79     , 82.3   , 80.3   , 82     , 75.1   , 71     , 72.4   , 73.3   , 73.6   , 74.6   , 74.2   , 74.2   , 74.5   , 72.6   , 70.9   , 64.8   , 66.3   , 63.5   , 77.9   , 76.8   , 71.1   , 68     , 73.5   , 68.8   , 70.4   , 64.9   , 70.1   , 64.1   , 61.3   , 65.8   , 72.6   , 78.6   , 64.8   , 76.9   ,
        '5C02' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 67.8   , 65.9   , 65.6   , 62     , 69.6   , 73.4   , 71.3   , 70.1   , 74.3   , 72.8   , 75.8   , 73.9   , 68.6   , 71.1   , 72.2   , 67.4   ,
        '5C03' , 59     , 60.4   , 61.4   , 64.8   , 65.6   , 65.1   , 68.3   , 66.1   , 68.6   , 68.2   , 67.3   , 66.6   , 70.4   , 69.7   , 70.3   , 68.3   , 69.3   , 70.8   , 71.5   , 71.6   , 69.6   , 74.2   , 79.1   , 72.8   , 79     , 84.3   , 82.1   , 75.5   , 73.7   , 76.3   , 82.4   , 81.5   , 84     , 83     , 79.4   , 79.9   , 79     ,
        '5D01' , 82.9   , 82.7   , 82.9   , 84.1   , 84     , 82.9   , 84.1   , 82.7   , 85.8   , 84.3   , 82.7   , 84.6   , 83.6   , 84.3   , 83.6   , 82.5   , 82.7   , 82.8   , 81.6   , 81.1   , 82.3   , 82.9   , 80     , 80.7   , 81.9   , 82.2   , 81.1   , 79.8   , 77.9   , 79.6   , 80.1   , 81.6   , 81.7   , 82.9   , 82.1   , 81.6   , 82     ,
        '5D02' , 91.4   , 93     , 93.4   , 92.4   , 94.3   , 92.1   , 92.5   , 90.7   , 93.7   , 91.1   , 87.6   , 89.4   , 84.5   , 87.4   , 92.3   , 89.1   , 89.3   , 85.1   , 85.9   , 87.1   , 86.7   , 84.3   , 83.6   , 83.3   , 87.4   , 80.1   , 71.1   , 75.4   , 73.9   , 76.9   , 77.7   , 63.1   , 67.7   , 79.9   , 64.6   , 61.3   , 54.4   ,
        '5D03' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 79.2   , 75.7   , 71.7   , 83.3   , 79.3   , 74     , 83.1   , 85.9   , 82.4   , 81.9   , 83     , 85.9   , 87.3   , 85.5   , 88.6   , 87.7   ,
        '5D04' , 40.6   , 38.1   , 39     , 41.4   , 42.3   , 43.4   , 42.4   , 39.8   , 38.5   , 38.2   , 43.1   , 46.2   , 45.7   , 48.3   , 45.3   , 46.7   , 48.4   , 46     , 47.1   , 45.4   , 45.1   , 54     , 59.2   , 58.8   , 53.5   , 56.4   , 57.9   , 50.7   , 54.7   , 51.4   , 53.5   , 52.3   , 54.2   , 53.2   , 52.8   , 54.4   , 58.1   ,
        '5D05' , 42.5   , 49.2   , 54     , 57.4   , 60.8   , 56.7   , 56.1   , 66.4   , 62.9   , 70.6   , 75.4   , 70     , 69.2   , 72.8   , 75     , 75.3   , 73.4   , 68.2   , 67.9   , 69.8   , 70.5   , 74.6   , 80.7   , 77.1   , 79.7   , 77.8   , 79.3   , 75.8   , 77.4   , 75     , 70.8   , 71.6   , 73.1   , 72.4   , 74.4   , 75.1   , 75     ,
        '5D06' , 96.3   , 96.4   , 96.3   , 96.9   , 97.3   , 96.7   , 96.8   , 95.7   , 97.5   , 98.1   , 97.9   , 98.1   , 97.5   , 97.1   , 97.2   , 98     , 97.6   , 97.1   , 97.5   , 97.5   , 97.2   , 98.7   , 98.6   , 98.9   , 99.1   , 98.8   , 99     , 98.9   , 98.6   , 98.4   , 98.4   , 98.3   , 99.1   , 98.6   , 98.4   , 98     , 98     ,
        '5D07' , 75.7   , 78.8   , 79.3   , 81.8   , 83     , 81.5   , 82     , 81     , 81.4   , 82.2   , 82.9   , 83.7   , 84.1   , 83.6   , 82.9   , 82.2   , 82.3   , 81.6   , 82.2   , 80.9   , 80.2   , 85.5   , 87.5   , 87.3   , 86     , 85.8   , 85.4   , 84     , 83.7   , 85.8   , 85.3   , 83.3   , 82.7   , 83.9   , 85.9   , 83.8   , 83.2   ,
        '5D08' , 68.5   , 67.9   , 68.2   , 69.2   , 67.8   , 68.3   , 68.1   , 69.3   , 69.1   , 69.9   , 69.5   , 69.4   , 67.9   , 66     , 63.9   , 64.5   , 66     , 67.1   , 70.8   , 69.4   , 67.9   , 71.3   , 71.9   , 69.4   , 73.3   , 70.1   , 65.8   , 67.1   , 67     , 70.6   , 70.3   , 68.3   , 69.1   , 67.1   , 68.2   , 67     , 70.7   ,
        '5F01' , 90.1   , 89.5   , 90.3   , 90.7   , 92.4   , 91.9   , 92.5   , 92.5   , 91.7   , 92.8   , 93.3   , 91.9   , 93.6   , 92     , 92.5   , 90.8   , 90.8   , 90.9   , 91.2   , 92.3   , 91.3   , 88.7   , 90.5   , 90.6   , 91.8   , 90.5   , 89.9   , 88.3   , 88.9   , 89.1   , 89.7   , 92.1   , 89.6   , 89.8   , 88.4   , 89     , 89.1   ,
        '5F02' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 99.9   , 99.7   , 100    , 100    , 100    , 100    , 99.1   , 98.1   , 98.8   , 98.6   , 96.9   , 98.3   , 99.7   , 99.2   , 99.6   , 99.4   ,
        '5F03' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 76     , 74.4   , 86     , 89.5   , 84.8   , 78.3   , 83.9   , 83.6   , 85.5   , 86.1   , 89.5   , 82.4   , 85.3   , 86.6   , 85.2   , 89.5   ,
        '5F04' , 17.5   , 25.2   , 20     , 25.9   , 28.2   , 31.2   , 33.4   , 25.5   , 23.4   , 35.4   , 46.1   , 45.9   , 38.6   , 21.3   , 23.6   , 27.3   , 27.9   , 27.9   , 31.3   , 31     , 35.5   , 36.7   , 25.4   , 27     , 27.8   , 30.9   , 31.1   , 34.8   , 32.8   , 24     , 36.1   , 37.6   , 29.8   , 21.3   , 32.6   , 29.9   , 25.6   ,
        '5F05' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 95.4   , 92.9   , 87.5   , 89.4   , 97.7   , 93.2   , 93     , 94.4   , 92.9   , 88.6   , 86.2   , 93     , 98.3   , 94     , 92     , 94     ,
        '5G10' , 4.5    , 3.9    , 3.5    , 3      , 5.1    , 3.7    , 6.3    , 5.3    , 4.3    , 4.7    , 5      , 7.1    , 8.1    , 6.7    , 4.9    , 8.8    , 10.1   , 10.6   , 10.6   , 15.3   , 17.3   , 18.3   , 16.6   , 16.2   , 13.2   , 23     , 24.6   , 22.4   , 20.2   , 23.4   , 20.2   , 18.6   , 23.3   , 23.3   , 20.4   , 17.9   , 20.5   ,
        '5G21' , 4.4    , 2.7    , 2.1    , 4.1    , 4.7    , 5.4    , 5.5    , 5.5    , 10.4   , 10.9   , 16.1   , 7.8    , 6.2    , 7.4    , 5.5    , 4.7    , 4.1    , 7.4    , 10     , 10.5   , 9.5    , 7.1    , 5.6    , 8.2    , 7.9    , 6.8    , 8      , 6.4    , 6      , 8.4    , 6.9    , 7.1    , 8.8    , 7.1    , 14.4   , 12.7   , 6.2    ,
        '5G22' , 0      , 0      , 0      , 0      , 0      , 2.3    , 2.8    , 3.5    , 2.9    , 2.8    , 2      , 2.2    , 3.1    , 1.7    , 2.6    , 2.4    , 1.9    , 5.6    , 4.4    , 4.4    , 6.4    , 8.7    , 7.6    , 14.5   , 12.9   , 15.2   , 12.7   , 5.5    , 20.4   , 20.3   , 15.5   , 17.9   , 16     , 15.9   , 18.2   , 17.9   , 22.2   ,
        '5G23' , 5.6    , 10.9   , 13.2   , 12     , 11     , 13     , 13.5   , 13.2   , 12.7   , 13.9   , 16.8   , 13.6   , 10     , 9.8    , 11.6   , 10     , 12.4   , 14.2   , 16.1   , 14.1   , 11     , 14.1   , 9.3    , 15.9   , 17.8   , 20.2   , 17     , 20.9   , 16.1   , 12.3   , 9.2    , 8.5    , 14.1   , 18.1   , 18.5   , 11.1   , 13.6   ,
        '5G24' , 0      , 0      , 1.5    , 0      , 0      , 4.2    , 2      , 0      , 0      , 0      , 0      , 1.3    , 0.8    , 0.8    , 2.3    , 2.5    , 3.1    , 2      , 1.7    , 3.1    , 5.1    , 3.2    , 2.9    , 0.5    , 0.2    , 2.8    , 2.4    , 2.8    , 2.7    , 1.6    , 3.4    , 6      , 8.1    , 4.3    , 1.8    , 3.4    , 4.3    ,
        '5G31' , 6.2    , 7.9    , 9.2    , 5.4    , 5.4    , 7.8    , 6.5    , 8      , 8.8    , 9.8    , 8.8    , 8.1    , 8.4    , 10.2   , 9.8    , 7.8    , 8.6    , 10.2   , 11     , 8.4    , 10.3   , 10.3   , 10.6   , 9.6    , 9.3    , 14.6   , 9.8    , 10.8   , 13.7   , 12.2   , 12.3   , 15.4   , 12.2   , 10.5   , 11.8   , 12.1   , 17.1   ,
        '5G32' , NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 10.8   , 11.2   , 16.3   , 7.2    , 2.7    , 13.2   , 22.6   , 36.7   , 30.5   , 14.8   , 14.4   , 20.6   , 25.1   , 14.8   , 11.2   , 13.5   ,
        '5H11' , 84.7   , 82.6   , 83.8   , 83.6   , 84.3   , 84.3   , 84.1   , 83.7   , 85.5   , 85.6   , 85.8   , 84.6   , 83.3   , 82.9   , 83.9   , 83.5   , 84.4   , 82.6   , 81.6   , 80.7   , 81.6   , 77.8   , 75.9   , 76.8   , 77.7   , 76.4   , 75.1   , 76.7   , 76.8   , 75     , 74.8   , 76.4   , 77.9   , 77.7   , 79.1   , 80.8   , 79.4   ,
        '5H12' , 66.7   , 64.2   , 64     , 67.3   , 70.2   , 69.8   , 70.6   , 67.5   , 67.8   , 69.2   , 69.9   , 70.6   , 70.2   , 67.4   , 69.2   , 68.8   , 66.6   , 66.8   , 67.5   , 68.7   , 72.2   , 73.5   , 71.8   , 69.2   , 72.4   , 72.1   , 68.4   , 72.9   , 71.4   , 71.1   , 71.1   , 71.9   , 71.7   , 68.5   , 70.4   , 67.8   , 66.4   ,
        '5H13' , 95.3   , 95.2   , 94.9   , 94.2   , 94.4   , 93.1   , 94.4   , 94.3   , 94.3   , 95.5   , 94.9   , 95.2   , 95.3   , 96.1   , 96.3   , 95     , 95.4   , 95.3   , 95.4   , 95.3   , 95.4   , 97.4   , 97.1   , 96.1   , 96.6   , 96.7   , 95.7   , 96.2   , 95.1   , 95.5   , 96.1   , 96.2   , 95.9   , 95.7   , 95.7   , 95.3   , 94.4   ,
        '5H14' , 85.9   , 84.8   , 78     , 79     , 82.2   , 83.1   , 81.9   , 85.3   , 84.4   , 85     , 87.9   , 87     , 85.2   , 84.3   , 83.5   , 81.7   , 85.4   , 85     , 83.4   , 81.3   , 79.3   , 80.5   , 77     , 76.4   , 74.3   , 75.6   , 78.1   , 77.8   , 78.6   , 78.4   , 74.8   , 79.8   , 80     , 75.1   , 78.1   , 78     , 76.1   ,
        '5H21' , 79.7   , 80.9   , 82.1   , 81.7   , 80.5   , 79.8   , 79.3   , 78.6   , 81.7   , 82.9   , 83.2   , 82.7   , 82.2   , 82.5   , 82.9   , 84.9   , 84.3   , 82.5   , 77.7   , 78.6   , 79.8   , 79.3   , 78.4   , 74.1   , 78     , 76.7   , 81.1   , 81.5   , 82.4   , 78.4   , 77.4   , 80.1   , 80.9   , 79.4   , 78.1   , 80.6   , 77.3   ,
        '5H22' , 58.7   , 59.1   , 58.2   , 53.3   , 55.4   , 53.8   , 53.4   , 55.1   , 52.8   , 54     , 48.3   , 47.4   , 50     , 51.9   , 49.3   , 49.3   , 49.8   , 45.7   , 45.5   , 46.1   , 51.1   , 41.8   , 40.9   , 43.7   , 46.5   , 42.9   , 38.8   , 38.2   , 37.9   , 40.5   , 37.7   , 39.6   , 38.6   , 41.3   , 38.5   , 41.6   , 39.9   ,
        '6E10' , 0      , 1.9    , 0      , 0      , 0      , 0      , 1.7    , 1.8    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 9.7    , 12.1   , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      ,
        '6E11' , 0.8    , 0.2    , 0      , 0      , 0.2    , 0.2    , 0.4    , 0.8    , 0      , 0.2    , 0.3    , 1.4    , 0.5    , 0.6    , 1      , 0.6    , 0      , 0.6    , 1.5    , 1.1    , 1.1    , 1      , 1.5    , 2      , 2      , 0.5    , 0.7    , 0.9    , 2.1    , 3.3    , 2.3    , 1.4    , 1.3    , 2.4    , 2.2    , 0.6    , 1.5    ,
        '6E12' , 20.8   , 23.2   , 27.6   , 35.5   , 31.2   , 36     , 33.7   , 28.7   , 28.1   , 31     , 33.7   , 28.6   , 37.1   , 33.3   , 34.6   , 34.7   , 35.3   , 34.7   , 35.3   , 35.3   , 34.3   , 38.8   , 40     , 37.2   , 41.2   , 37.8   , 28.3   , 35.8   , 34.5   , 36.8   , 34.6   , 36.9   , 30.1   , 27.4   , 25.7   , 28.4   , 23.8   ,
        '6E13' , 2.6    , 2.8    , 3.8    , 3.4    , 3.6    , 4.1    , 4.1    , 4.8    , 5.3    , 5.5    , 6.3    , 6.2    , 6.6    , 6.5    , 6.4    , 6.4    , 6.1    , 7.1    , 7.4    , 8.2    , 6.6    , 8.8    , 11.1   , 9.7    , 10.5   , 10.1   , 10.8   , 10.3   , 10.1   , 11.8   , 11.1   , 11     , 11.1   , 12.2   , 11.6   , 13.5   , 11.5   ,
        '6E14' , 19     , 19.8   , 19.3   , 18.1   , 23.6   , 21.5   , 22.4   , 22     , 23.9   , 26     , 24.4   , 23.3   , 24.4   , 23.3   , 23.3   , 21.9   , 22.6   , 19     , 19.8   , 20.6   , 23.8   , 18.5   , 30.6   , 27.7   , 32.3   , 38.3   , 31.9   , 26.1   , 17.7   , 21.1   , 24.6   , 25.2   , 19.6   , 17.1   , 18.8   , 20.9   , 24.2   ,
        '6E15' , 18.4   , 14.8   , 15     , 15.4   , 16.8   , 15.3   , 18.6   , 19.2   , 16.7   , 16.2   , 16.8   , 14     , 17     , 19.1   , 19.1   , 20     , 18.6   , 18.9   , 17.6   , 19.9   , 19.7   , 23.3   , 27.5   , 24.9   , 20.1   , 23.6   , 22     , 19.5   , 22.4   , 24.1   , 24.1   , 25.9   , 29.7   , 26.7   , 24.5   , 27.6   , 30.7   ,
        '6E16' , 72.9   , 70.9   , 71.5   , 71     , 66.8   , 60.4   , 65.4   , 65.6   , 70.5   , 71.8   , 71.4   , 67.6   , 67.6   , 69.2   , 69.8   , 64.7   , 66.6   , 63.4   , 63.7   , 65.1   , 68.7   , 67.3   , 69.9   , 70.3   , 62.4   , 61.1   , 65.1   , 61.8   , 55     , 58.4   , 65.6   , 67.3   , 54.2   , 52.9   , 61.1   , 68.1   , 54.1   ,
        '6E17' , 7.4    , 4.6    , 6.6    , 3.8    , 3.1    , 4.1    , 2.5    , 2.4    , 5.6    , 7.6    , 11     , 7.2    , 5.7    , 6.6    , 8.3    , 7      , 4.9    , 2.4    , 4.6    , 3.5    , 5.6    , 12     , 14.7   , 10.6   , 14.4   , 7.7    , 8.6    , 7.4    , 6.2    , 7.5    , 5.4    , 4.4    , 6.7    , 7.2    , 5.5    , 4.8    , 6.9    ,
        '6E18' , 1.9    , 1      , 1.5    , 0.8    , 1.1    , 1.4    , 2.2    , 1.9    , 1.8    , 2.4    , 1.1    , 1.2    , 1.6    , 1.8    , 2.2    , 1.6    , 1.1    , 2      , 1.9    , 1.7    , 2.2    , 1.8    , 1.1    , 1      , 1.4    , 3.2    , 3.6    , 3.3    , 3.5    , 1.3    , 1.7    , 3.3    , 2.7    , 1.8    , 3.4    , 4.3    , 3.7    ,
        '6E19' , 33.6   , 21.5   , 19.9   , 23.2   , 20.7   , 16.3   , 20.9   , 20.5   , 31     , 25.1   , 21.8   , 25     , 26.3   , 24.6   , 24.2   , 29.3   , 27.2   , 28.4   , 22.9   , 24.5   , 26.1   , 23.8   , 19.8   , 15.3   , 19.1   , 22.9   , 28.2   , 25.5   , 22.8   , 21.2   , 22.4   , 26.9   , 23.9   , 21.3   , 25.1   , 23.2   , 24.7   ,
        '6E21' , 1.6    , 1      , 1      , 1.4    , 2.8    , 2.3    , 2.2    , 0      , 1.1    , 1.8    , 2.2    , 2.4    , 3.8    , 4.8    , 2.6    , 3.8    , 2.9    , 3.9    , 3.8    , 5.4    , 5.5    , 7.9    , 7.6    , 5      , 4.1    , 11     , 7.6    , 4.7    , 5.3    , 6.7    , 6.4    , 6.4    , 4.4    , 6.9    , 5.9    , 4.7    , 4.9    ,
        '6E22' , 0      , 0      , 0.4    , 0      , 0      , 0      , 0      , 0.4    , 0.4    , 0.6    , 0      , 0      , 0.2    , 0      , 0.8    , 0.4    , 0.3    , 0.4    , 0.9    , 1.2    , 0.4    , 0      , 0      , 0.6    , 0.4    , 0.3    , 1.4    , 0.9    , 1.1    , 0.1    , 0.2    , 0.3    , 0      , 0.6    , 1.3    , 2.8    , 0.5    ,
        '6E23' , 0.8    , 0.4    , 0.7    , 0.5    , 0.4    , 0.8    , 0.6    , 0.6    , 0.9    , 1.8    , 1.5    , 1.9    , 2.6    , 3.2    , 4.3    , 3.6    , 3.9    , 3.4    , 4.2    , 4.6    , 4.8    , 2.2    , 2.5    , 1.8    , 2.2    , 2.7    , 1.8    , 1.7    , 1.9    , 2.3    , 3.5    , 3.1    , 3.1    , 3.8    , 4.2    , 4.4    , 3.3    ,
        '6E24' , 0.8    , 1.3    , 0.6    , 0.5    , 0.4    , 0.3    , 0.5    , 0.3    , 0.5    , 0.5    , 0.5    , 1.3    , 1      , 1.2    , 0.8    , 0.6    , 2      , 2.1    , 0.7    , 1.2    , 0.3    , 1.9    , 1.1    , 0.2    , 0.6    , 2.4    , 0.9    , 0.6    , 2      , 0.4    , 0.6    , 1.5    , 1.5    , 0.7    , 3      , 6      , 1      ,
        '6E25' , 0      , 0.4    , 0.1    , 0.4    , 0.4    , 0.4    , 0.3    , 0.5    , 0.4    , 0.7    , 0.5    , 1.1    , 1      , 1.2    , 1.2    , 1.3    , 1.1    , 1.4    , 2      , 1.7    , 1.6    , 0.3    , 0.6    , 0.7    , 1.5    , 1.5    , 1.5    , 0.7    , 1.2    , 1.1    , 0.3    , 1      , 1.9    , 1.2    , 2.2    , 0.9    , 0.8    ,
        '6E26' , 74.2   , 70.9   , 67.4   , 68.1   , 64.8   , 66.1   , 66.4   , 67.2   , 62.3   , 58.9   , 65.4   , 64.5   , 69.4   , 64.4   , 70.1   , 63.7   , 67.7   , 59.6   , 66     , 69     , 79.5   , 64.8   , 57.9   , 70     , 69.7   , 59.4   , 57.8   , 64.9   , 75.3   , 71.6   , 86.7   , 86.4   , 75.5   , 68.7   , 73.8   , 67     , 77.4   ,
        '6E27' , 16.5   , 17     , 17.2   , 13.9   , 12.8   , 14.7   , 15.1   , 15.5   , 17.1   , 17     , 16.6   , 16.8   , 16.2   , 18     , 17.9   , 16.9   , 17.9   , 16.4   , 15.2   , 18.2   , 16.6   , 17.8   , 18.3   , 21.4   , 21.3   , 18.4   , 18.6   , 20.1   , 23.4   , 23.7   , 22.8   , 23.7   , 22.7   , 24.4   , 24.5   , 23     , 21.9   ,
        '6E28' , 32.3   , 34     , 29.4   , 31.7   , 30.4   , 28.3   , 36     , 28.4   , 31.7   , 31.7   , 28.6   , 31.8   , 25.6   , 38.8   , 36.6   , 28.8   , 33.7   , 34.5   , 38.2   , 43.9   , 38.2   , 38.4   , 30.2   , 33.5   , 50.3   , 46.9   , 37.2   , 34     , 37.2   , 33.5   , 29.3   , 49.4   , 42.9   , 36.5   , 37.5   , 43.7   , 47.4   ,
        '6E31' , 0.3    , 0.4    , 0.1    , 0.6    , 0.4    , 0.4    , 0.1    , 0.1    , 0.3    , 0.2    , 0.7    , 0.3    , 0.6    , 0.7    , 0.5    , 0.5    , 0.9    , 0.8    , 0.9    , 1.4    , 0.6    , 0.9    , 0.8    , 1.5    , 1.9    , 2      , 1.6    , 1.8    , 1.7    , 1.9    , 2.3    , 2.7    , 1.7    , 2.8    , 3.2    , 2.5    , 2.5    ,
        '6E32' , 5.1    , 3.4    , 5.3    , 5.8    , 6.6    , 6.8    , 7      , 6.1    , 5.5    , 8.6    , 10.4   , 11.3   , 10.9   , 9      , 12     , 12.7   , 13.9   , 12.3   , 15.1   , 17.6   , 20     , 19.2   , 17.8   , 21.4   , 23.8   , 29.1   , 22.3   , 23.6   , 27.4   , 21.9   , 21     , 17.9   , 18     , 22     , 23     , 17.6   , 13.6   ,
        '6E33' , 5.1    , 8      , 5.9    , 3.8    , 2.8    , 5.5    , 4.4    , 3.2    , 5.1    , 6.3    , 5.3    , 10.9   , 11.7   , 12.5   , 11     , 9.7    , 8.2    , 13.4   , 11.2   , 22.5   , 17.3   , 7.2    , 4.7    , 8.2    , 13.1   , 19.8   , 24.4   , 21.2   , 25.5   , 22.6   , 23.5   , 19.1   , 15.2   , 21.1   , 16.7   , 17.1   , 16.8   ,
        '6E34' , 3.1    , 2.5    , 0.9    , 1      , 1.8    , 1.5    , 1.7    , 1.5    , 1.9    , 1.7    , 2.4    , 1.5    , 2.6    , 0.9    , 3.5    , 2.4    , 1      , 0.4    , 0      , 2      , 1.9    , 1      , 2      , 2.1    , 1.4    , 1.7    , 3.7    , 2.8    , 4.2    , 5.3    , 2.3    , 1.9    , 2.9    , 2.2    , 0.6    , 1.9    , 2.7    ,
        '6E35' , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 1.4    , 1.6    , 0      , 0      , 1.2    , 1.6    , 2.2    , 2.5    , 2.5    , 0      , 0      , 0      , 3      , 2.9    , 0      , 0      , 0      , 2.4    , 0      , 0      , 0      , 6.1    , 2.3    , 1.4    , 1.6    , 0      , 0      , 5.8    , 0      , 2.5    ,
        '6E36' , 3.6    , 7.6    , 5.8    , 3.9    , 6.2    , 4.1    , 4.7    , 6.6    , 4.7    , 5.5    , 6.2    , 4.4    , 4      , 2.1    , 3.9    , 3.9    , 3.3    , 6.1    , 4.6    , 2.8    , 5.4    , 11.8   , 2.9    , 6.2    , 3.4    , 6      , 11.8   , 14.4   , 13.6   , 13.2   , 16.2   , 8.1    , 6.4    , 3.9    , 7.3    , 15.6   , 9.9    ,
        '6E41' , 0.4    , 0.4    , 0.4    , 0.5    , 0.5    , 1.4    , 1.5    , 1      , 0.6    , 1      , 1.1    , 3.8    , 1.5    , 1.1    , 0.8    , 2.1    , 1.5    , 3.1    , 2.1    , 1.9    , 1.1    , 3      , 4.4    , 4.6    , 7.8    , 4.5    , 6.2    , 7.7    , 5.3    , 4.9    , 3.4    , 9.5    , 8.3    , 10.5   , 10.4   , 9      , 13     ,
        '6E42' , 50.1   , 51     , 58.7   , 60.4   , 53.7   , 53.2   , 53.2   , 55.9   , 52.1   , 60     , 56.9   , 51.7   , 62.8   , 53.5   , 52.7   , 57     , 57.5   , 53.5   , 57.1   , 53.1   , 60.2   , 52.5   , 52.1   , 50.8   , 53.3   , 49.5   , 49.8   , 43.4   , 42.3   , 44     , 40.3   , 40.4   , 47     , 41.5   , 46.1   , 50.9   , 34.1   ,
        '6E43' , 27.9   , 28.2   , 27.2   , 27.3   , 27.6   , 24.2   , 26.2   , 25.5   , 31.8   , 33.9   , 29.5   , 27.8   , 31.1   , 31.3   , 29.8   , 27.6   , 27     , 28     , 27.3   , 27.7   , 31.4   , 28.9   , 27.9   , 25     , 28.9   , 27.1   , 24.8   , 26.2   , 22.5   , 28.5   , 28.5   , 25.9   , 28.3   , 24.7   , 27.3   , 27.4   , 25.9   ,
        '6E44' , 33     , 32     , 32     , 34.4   , 35.6   , 37.1   , 35     , 36.5   , 36.3   , 40.1   , 36.8   , 36.9   , 40.6   , 41.2   , 39.8   , 43.2   , 41.4   , 41.8   , 42.1   , 45.2   , 41.8   , 43.9   , 44.2   , 48.9   , 46.6   , 47     , 50.8   , 48     , 43.7   , 42.5   , 47.5   , 45.8   , 43.6   , 43.8   , 40.3   , 41.7   , 43.4   ,
        '6E45' , 81.6   , 82.9   , 79     , 76.9   , 77.6   , 79.6   , 79.8   , 78.5   , 79.5   , 78.6   , 77.5   , 77.2   , 76.3   , 76.7   , 70.6   , 72.9   , 73     , 74.3   , 71.2   , 68.9   , 73.8   , 68.6   , 73.5   , 77.8   , 78.1   , 76.3   , 59.4   , 73.9   , 73.2   , 70.7   , 68     , 68.4   , 67.7   , 65.9   , 59.1   , 58.8   , 67.6   ,
        '6E46' , 36.1   , 35.7   , 35.6   , 39.8   , 36.5   , 30.6   , 33.8   , 33.5   , 34.9   , 34.9   , 37     , 35.6   , 33.8   , 32     , 34.6   , 30.5   , 30.3   , 31.7   , 33.2   , 33.4   , 32     , 34.8   , 32     , 32.6   , 30.3   , 26.4   , 32.3   , 27.1   , 30.1   , 24.6   , 22.5   , 22.3   , 19.8   , 19     , 22.2   , 19.8   , 25.7   ,
        '6E51' , 16     , 15.9   , 15.1   , 13.1   , 12.8   , 13.6   , 14.1   , 14.5   , 17     , 17.8   , 15.4   , 16.5   , 15.4   , 15.3   , 15.3   , 14.4   , 17.1   , 16.6   , 15.5   , 14.7   , 16.1   , 19.5   , 19.6   , 18     , 18.2   , 18.5   , 19.6   , 18.5   , 17.6   , 18.8   , 18     , 18.4   , 18.2   , 18.7   , 20.7   , 19.1   , 19.2   ,
        '6E52' , 6      , 6      , 5.8    , 5.9    , 7.3    , 7.2    , 5.9    , 8.9    , 4.3    , 5      , 5.4    , 5.8    , 6.3    , 6.8    , 7.3    , 6.9    , 6.6    , 7.3    , 5.5    , 5.7    , 4.7    , 9.5    , 9.9    , 9.9    , 10     , 8.2    , 10.8   , 9.4    , 9.4    , 12.4   , 11.1   , 9.8    , 9      , 10.6   , 9      , 11.9   , 10.6   ,
        '6E53' , 54     , 44.7   , 38.6   , 42.6   , 46.4   , 45     , 47.1   , 47.5   , 42.6   , 46.4   , 43.1   , 42.6   , 40.9   , 43.8   , 43.1   , 44.9   , 41.3   , 40.3   , 43.3   , 43.4   , 41.3   , 40.2   , 33.7   , 38.6   , 36.9   , 33.5   , 35.9   , 34.7   , 34.9   , 36.7   , 36     , 36.5   , 35.8   , 35     , 37.2   , 35.9   , 35.6   ,
        '6E61' , 1.3    , 1      , 0.9    , 0.7    , 1.3    , 1.5    , 1.6    , 1.1    , 1      , 1.3    , 1      , 1.8    , 2.8    , 4.1    , 4.3    , 4.4    , 3.6    , 3.7    , 3.5    , 3.9    , 3.5    , 5.5    , 3.8    , 4.7    , 4.1    , 3.7    , 3.6    , 2.2    , 2.3    , 5.2    , 4.2    , 4.2    , 5.1    , 4.9    , 6.6    , 5.6    , 6.5    ,
        '6E62' , 2.5    , 2.2    , 2      , 0.7    , 1.2    , 0.3    , 0      , 1.4    , 2.5    , 2.9    , 2      , 2.3    , 2.5    , 3.2    , 2      , 3.6    , 2.6    , 2.7    , 4.2    , 2.3    , 1.5    , 6.6    , 3.8    , 2      , 0.3    , 2.9    , 1.8    , 1.7    , 4.8    , 4.9    , 1.5    , 4.6    , 4.5    , 4      , 2.9    , 3.5    , 2      ,
        '6E63' , 2.1    , 1.6    , 6.7    , 6.1    , 6.2    , 0.9    , 6      , 9.7    , 1.9    , 0.9    , 11.1   , 10.7   , 9.7    , 3.6    , 11.5   , 8.3    , 5.1    , 8.6    , 8.4    , 5.1    , 5.8    , 9.5    , 17.3   , 10.1   , 3.8    , 12.2   , 13.1   , 17.3   , 14.6   , 15.3   , 18.1   , 14.6   , 15.9   , 16     , 16.2   , 20.9   , 19.3   ,
        '6E64' , 66.4   , 69.3   , 69.7   , 69.1   , 69.7   , 68.1   , 69     , 65.4   , 73.4   , 74.9   , 75     , 69.4   , 73.1   , 70.3   , 68.7   , 69.5   , 70.1   , 71.7   , 71.2   , 67.9   , 67.6   , 64.8   , 62     , 57.7   , 61.9   , 63.4   , 62     , 64.2   , 67.3   , 68     , 65.2   , 61.2   , 62.2   , 63.3   , 64.5   , 60.4   , 59.4   ,
        '6E65' , 52.7   , 53.3   , 48.6   , 53     , 53.8   , 48.9   , 47     , 54.9   , 53.7   , 49.2   , 52.4   , 60.1   , 65     , 66.6   , 58.2   , 60.6   , 58.2   , 60.1   , 49.2   , 52.9   , 52.2   , 49.3   , 53.7   , 56.9   , 47.8   , 46.7   , 53.5   , 48.3   , 40.7   , 50.3   , 44.6   , 45     , 51.8   , 52.1   , 43.6   , 49.1   , 52.5   ,
        '6E71' , 1.3    , 1.5    , 1.7    , 1.9    , 2.7    , 3.2    , 2.7    , 2      , 2.2    , 1.3    , 2.8    , 2.5    , 2.8    , 2.3    , 1.2    , 2.1    , 2.3    , 2.3    , 2.3    , 1.5    , 1.5    , 4      , 3.5    , 3.1    , 4.5    , 4      , 4      , 3.6    , 3.9    , 3.3    , 3.3    , 5.1    , 6.3    , 5.5    , 5.4    , 5.2    , 6      ,
        '6E72' , 3.8    , 1.5    , 3      , 4.3    , 5.4    , 5.8    , 6.7    , 8.1    , 7.8    , 7.8    , 2.9    , 7      , 7.2    , 12.3   , 7.3    , 8.3    , 8.7    , 8.3    , 15.2   , 9.8    , 5.5    , 3.2    , 1.3    , 14.4   , 13     , 3.7    , 7.1    , 8.9    , 3.8    , 3      , 2.4    , 2.7    , 6.7    , 10.8   , 8.3    , 6.1    , 11.1   ,
        '6E73' , 39.1   , 48.2   , 48.1   , 54.1   , 43.9   , 42.2   , 35.8   , 46.2   , 46.7   , 47.2   , 40.3   , 44     , 39.6   , 38.8   , 45.6   , 43.8   , 58.4   , 61.4   , 48.2   , 48.7   , 52     , 69.6   , 55.2   , 54.2   , 64.9   , 60.5   , 53.6   , 60.1   , 69     , 80.4   , 82.8   , 74.2   , 78.9   , 81.1   , 70.8   , 76.5   , 90.5   ,
        '6E74' , 0      , 2.8    , 2.7    , 4.7    , 1.5    , 2.4    , 0      , 3.1    , 4.4    , 3.3    , 7      , 5.3    , 4.6    , 4.7    , 4.1    , 4.9    , 3.4    , 4.9    , 1.1    , 0      , 8.8    , 20     , 18.3   , 26.4   , 12.3   , 8.9    , 10     , 6      , 9.9    , 17.3   , 20.9   , 32.8   , 25.8   , 21     , 26     , 28.7   , 22.5   ,
        '6E75' , 17.7   , 15.6   , 14.2   , 13.6   , 15.4   , 17     , 18.7   , 18.8   , 11.6   , 11.2   , 10.1   , 13     , 13.8   , 11.7   , 10.8   , 11.5   , 11.9   , 10     , 15.9   , 15.7   , 17.8   , 27.1   , 26.9   , 26.3   , 27.7   , 20.9   , 19.6   , 17.9   , 20.9   , 28.1   , 26.5   , 33.7   , 31     , 30.7   , 29.7   , 29.9   , 26.6   ,
        '6E76' , 2.2    , 3.5    , 3.4    , 3.2    , 4.6    , 6.4    , 8.2    , 7      , 3      , 5      , 7      , 5.3    , 2      , 1.6    , 3      , 4.4    , 3.5    , 3.4    , 3.5    , 2.8    , 4      , 4      , 13.1   , 11.9   , 8.6    , 6.3    , 8      , 5.7    , 4.4    , 6.4    , 8.6    , 8.7    , 8      , 11.7   , 9.9    , 6.2    , 6.2    ,
        '6E77' , 6.4    , 11.9   , 13.2   , 8.4    , 10.9   , 10.5   , 10.6   , 10.4   , 8.8    , 9.8    , 11.3   , 10.5   , 10.8   , 10.4   , 10.4   , 12.7   , 7.8    , 12.8   , 12.8   , 13.1   , 13.8   , 12.7   , 11.6   , 13.6   , 12.3   , 5      , 10     , 12.2   , 11.7   , 6.6    , 10     , 10.1   , 13.5   , 16.5   , 9.5    , 10.7   , 9.2    ,
        '6E78' , 19.5   , 20.7   , 21.5   , 20.2   , 22.3   , 19     , 21.8   , 18.9   , 19.1   , 17     , 22.2   , 21.1   , 21.5   , 22.2   , 20.9   , 22.8   , 21     , 19.1   , 15.2   , 23.5   , 24.5   , 31.9   , 28.2   , 25.1   , 29.1   , 29.1   , 26.6   , 44.2   , 34.5   , 41.5   , 40.1   , 37.3   , 39.3   , 34.6   , 39.1   , 47     , 39.7   ,
        '7K11' , 34.1   , 36.1   , 36.7   , 36.1   , 34.2   , 35.3   , 35.5   , 35     , 34.4   , 35     , 34     , 34.1   , 33.3   , 33     , 32.8   , 32     , 31.4   , 31.4   , 29.2   , 30.5   , 30.7   , 20.7   , 21.6   , 22     , 21.2   , 23.1   , 21.7   , 22.2   , 19.6   , 18.9   , 22.6   , 23.1   , 25.3   , 26.8   , 24.4   , 25.1   , 25     ,
        '7K12' , 37.2   , 37.3   , 37.1   , 37.1   , 36.7   , 36     , 35.5   , 34.4   , 35.9   , 35.8   , 36.9   , 36.3   , 35.4   , 35     , 33.9   , 33     , 33.7   , 33.2   , 33.9   , 32.8   , 30     , 28.6   , 32.4   , 27.2   , 24.7   , 25.1   , 28     , 23.6   , 22.8   , 26     , 22     , 18.9   , 23.6   , 22.6   , 21.8   , 19.1   , 20.5   ,
        '7K13' , 41.1   , 42     , 41.9   , 41.4   , 41.8   , 39.3   , 39.6   , 41.5   , 40.5   , 43.8   , 44.8   , 47.8   , 46.8   , 49.3   , 47.6   , 48.6   , 41.7   , 45.4   , 42.6   , 40.9   , 42.4   , 45.1   , 46.9   , 40     , 38.4   , 38.3   , 39.3   , 38.2   , 37.9   , 37.1   , 35.9   , 35     , 33.7   , 30.7   , 32.4   , 31.7   , 27.9   ,
        '7K20' , 23.4   , 16.6   , 15.7   , 18.3   , 20.5   , 22.6   , 19.6   , 19.7   , 19.4   , 23.9   , 24     , 25.4   , 22.2   , 21.4   , 23.6   , 24.7   , 24.1   , 24.5   , 26.3   , 26.1   , 26.6   , 24     , 29.3   , 29.7   , 29.1   , 30.6   , 28.7   , 28.6   , 27.5   , 31.1   , 30.7   , 27.1   , 24.6   , 28.2   , 26.3   , 28.1   , 26.9   
      ) %>% 
        dplyr::mutate(chiffre = stringr::str_to_upper(chiffre)) %>% 
        dplyr::select(chiffre, tidyselect::all_of(sexeEE)) %>% 
        dplyr::rowwise() %>% 
        dplyr::mutate(fem_pct = mean(dplyr::c_across(tidyselect::all_of(sexeEE)), na.rm = TRUE)) %>% 
        dplyr::select(chiffre, fem_pct)
      
        PPP4_fem <-tibble::tribble(
         ~`chiffre`, ~`1982`, ~`1983`, ~`1984`, ~`1985`, ~`1986`, ~`1987`, ~`1988`, ~`1989`, ~`1990`, ~`1991`, ~`1992`, ~`1993`, ~`1994`, ~`1995`, ~`1996`, ~`1997`, ~`1998`, ~`1999`, ~`2000`, ~`2001`, ~`2002`, ~`2003`, ~`2004`, ~`2005`, ~`2006`, ~`2007`, ~`2008`, ~`2009`, ~`2010`, ~`2011`, ~`2012`, ~`2013`, ~`2014`, ~`2015`, ~`2016`, ~`2017`, ~`2018`,
         '1A01a', 0      , 13.4   , 21.3   , 18     , 11     , 18     , 14.7   , 15.5   , 5.3    , 10.9   , 16.4   , 10     , 11.1   , 33.7   , 5.1    , 0      , 13.2   , 31.5   , 21.2   , 7.7    , 0      , 24.7   , 11     , 0      , 10.8   , 8.4    , 0      , 12.1   , 17.3   , 15.2   , 22.7   , 18     , 22.9   , 30.8   , 23.8   , 21     , 24.1   ,
         '1A02a', 16.8   , 16.6   , 15.9   , 16.7   , 14.4   , 16.7   , 15     , 16.4   , 13.1   , 14.1   , 8.3    , 16.9   , 12.6   , 14.1   , 14.5   , 11.2   , 11.1   , 12.6   , 12.6   , 7.8    , 13.1   , 15.5   , 3.3    , 6.5    , 14.3   , 23.2   , 14     , 2.7    , 10.1   , 10.7   , 9.8    , 18     , 11.8   , 13.6   , 14.8   , 17.1   , 14.4   ,
         '1A03a', 12     , 10.1   , 10.3   , 20.7   , 18.7   , 15.9   , 9.2    , 16.8   , 9.6    , 8.9    , 1.5    , 3.8    , 9.9    , 6.4    , 8.7    , 9.1    , 15     , 13.4   , 14.3   , 11.8   , 11     , 3.8    , 3.3    , 1.9    , 3      , 8.1    , 9.6    , 6.2    , 4.7    , 5      , 5.4    , 2.6    , 2.8    , 3.1    , 9.6    , 6.6    , 0.3    ,
         '1A03b', 17.2   , 24.8   , 19.8   , 20.1   , 14.5   , 16.7   , 18.1   , 13.2   , 10.1   , 14.2   , 15.8   , 16.4   , 16.1   , 17.5   , 18.8   , 14.3   , 17.3   , 18.4   , 10.7   , 17.3   , 14.9   , 14.6   , 14.9   , 21.2   , 13.8   , 21.3   , 18.4   , 16.8   , 18.1   , 16.2   , 12.6   , 15.8   , 14.9   , 16.8   , 14.1   , 18.9   , 16.7   ,
         '1A03c', 17.4   , 24.8   , 38.6   , 32.2   , 23.7   , 22.9   , 23.4   , 19.4   , 21     , 25.6   , 19.6   , 14.6   , 8.6    , 16.1   , 14.4   , 28.9   , 30.1   , 24.1   , 22.3   , 19.4   , 17.7   , 18.2   , 21.4   , 28.6   , 22.8   , 15.9   , 13.5   , 12     , 19.8   , 32.3   , 23.7   , 26.3   , 21.2   , 19.8   , 28.7   , 33.7   , 22.9   ,
         '1A03d', 13     , 20.8   , 37.6   , 38.6   , 33.4   , 32.3   , 27.6   , 23.3   , 27.3   , 19.9   , 10.7   , 23.5   , 22.6   , 28.6   , 20.1   , 29.9   , 24.5   , 24.9   , 13     , 18.1   , 16     , 10.1   , 11.4   , 15     , 29.9   , 27.5   , 23.2   , 6.1    , 9.5    , 16.5   , 24.1   , 28.2   , 16.2   , 21.4   , 22.8   , 9.9    , 15.5   ,
         '2B01a', 5.3    , 16.7   , 9.6    , 7.6    , 9.5    , 11.9   , 12.3   , 16.6   , 9.6    , 19.8   , 14.4   , 19.1   , 13.7   , 18.4   , 17.7   , 23.6   , 26.6   , 22.6   , 20.9   , 29.5   , 35.2   , 21.8   , 33.2   , 21.3   , 30.9   , 23.5   , 16.4   , 16.8   , 30.4   , 22.1   , 30.3   , 28     , 31.7   , 27.5   , 32.2   , 31.7   , 26.2   ,
         '2B01b', 11.7   , 7.1    , 9.2    , 11.9   , 13     , 12.7   , 15     , 12     , 11.4   , 13.4   , 13.1   , 17.6   , 14.1   , 16.7   , 15.4   , 11.5   , 17.4   , 21.2   , 15     , 16     , 21.4   , 13.3   , 17.9   , 19.9   , 22.5   , 25     , 25.2   , 21.4   , 20.9   , 22.4   , 26.6   , 22.3   , 21.2   , 25     , 23.2   , 24.7   , 28.6   ,
         '2B02a', 7.9    , 16.7   , 13.9   , 20.2   , 16.5   , 14.3   , 17.2   , 16.5   , 19.9   , 17     , 18     , 18.4   , 19.2   , 25.6   , 20.5   , 20.1   , 25     , 22.2   , 22.2   , 24.7   , 26.9   , 21.4   , 20.8   , 26.9   , 22.9   , 26.1   , 18.1   , 24.3   , 28.5   , 29.1   , 31.2   , 27     , 26.7   , 26.2   , 24.9   , 21.5   , 24.9   ,
         '2B03a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 47.9   , 53     , 47.8   , 40.8   , 31.3   , 45.7   , 48.5   , 52.1   , 56.5   , 53.1   , 51.8   , 41.6   , 52.3   , 52.6   , 35     , 41     ,
         '2B04a', 0      , 7.1    , 4.6    , 0      , 0      , 4.9    , 0      , 0      , 5.1    , 0      , 0      , 2.5    , 9.8    , 5      , 4.8    , 6.7    , 5.1    , 0      , 0      , 5.4    , 6.8    , 0      , 5      , 8.5    , 1.8    , 4.1    , 5      , 9.4    , 6.4    , 3.6    , 9.1    , 17.9   , 4.9    , 0      , 4.8    , 5.3    , 2.1    ,
         '2B04b', 3.6    , 2.3    , 0      , 2.8    , 3.2    , 5      , 6.2    , 2.2    , 8.5    , 0      , 6.1    , 10.2   , 5.4    , 6.3    , 8.2    , 7.9    , 4.7    , 7.3    , 8.1    , 14.9   , 0      , 0.6    , 1.6    , 3.5    , 7.9    , 3      , 4.7    , 10.2   , 4.8    , 17.7   , 11.6   , 16.7   , 15.5   , 16.2   , 22.7   , 27.2   , 10.6   ,
         '2B04c', 0      , 0      , 0      , 3.5    , 0      , 3.5    , 3      , 2.4    , 6.9    , 3.8    , 0.8    , 8.1    , 8      , 10     , 6.4    , 4.7    , 2.7    , 2.8    , 4.5    , 5.5    , 11.7   , 13.2   , 10.1   , 7.9    , 11     , 16     , 13.2   , 10     , 14     , 16.6   , 16.4   , 16.9   , 15.2   , 14.1   , 12.4   , 20.4   , 11.2   ,
         '2B04d', 2.4    , 4.6    , 7      , 7.2    , 5      , 2.9    , 2.8    , 6.6    , 5.9    , 5.6    , 10.7   , 9.3    , 6.5    , 9.1    , 11.2   , 6.7    , 19.5   , 18.4   , 14.3   , 14.2   , 13.1   , 6.9    , 7.9    , 11.7   , 13.2   , 23.1   , 22.2   , 21.5   , 20.1   , 31.2   , 29.6   , 27.5   , 33.1   , 39.6   , 31.9   , 26.3   , 31.4   ,
         '2B04e', 13.8   , 5      , 18.7   , 13.2   , 14.1   , 11.2   , 10.9   , 15.9   , 13.5   , 12.2   , 15.6   , 8.3    , 24.3   , 21.6   , 16.3   , 5      , 17.3   , 17.3   , 18     , 17.3   , 22.6   , 26.8   , 28.1   , 25.5   , 27     , 25.8   , 22.9   , 27.4   , 32.7   , 32.7   , 28     , 23.3   , 25.3   , 21.5   , 28.2   , 33.9   , 34.8   ,
         '2C01a', 18.3   , 16.1   , 21     , 36.1   , 32.9   , 30.9   , 30.3   , 26.8   , 29.3   , 36.1   , 33.1   , 40.8   , 41.1   , 47     , 42.9   , 42     , 37.2   , 35.3   , 38.1   , 37.1   , 32.6   , 43.1   , 39     , 36.6   , 40.6   , 44.6   , 34.8   , 43.3   , 43.4   , 42.2   , 46     , 52.1   , 45.4   , 46.7   , 45.8   , 51.9   , 54.4   ,
         '2C02a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 27.1   , 23.7   , 29.7   , 40.1   , 42.6   , 37.4   , 40.8   , 37.5   , 35.2   , 39.7   , 40.2   , 46.2   , 36.1   , 38.3   , 49.4   , 48.1   ,
         '2C03a', 12.5   , 13.3   , 13.8   , 14.2   , 16.2   , 20     , 17.7   , 18.4   , 23.4   , 24.3   , 26     , 24.1   , 21.6   , 25.4   , 28.8   , 22.5   , 22     , 22.3   , 25.8   , 32.6   , 30.5   , 31.8   , 47.7   , 30.1   , 38     , 47.3   , 51.4   , 36.8   , 41.7   , 47.9   , 49     , 48.7   , 50.8   , 50.4   , 41.8   , 52.7   , 54     ,
         '2C03b', 19.7   , 27.8   , 28.9   , 27.3   , 26.5   , 32.8   , 29.2   , 25.9   , 34.6   , 28.9   , 36.2   , 38.2   , 36     , 33.7   , 33.5   , 30     , 41.3   , 39.5   , 36.1   , 37     , 43.9   , 24.7   , 32.2   , 43     , 59     , 51.3   , 44.9   , 52     , 55.9   , 49.2   , 44.3   , 47.7   , 46.1   , 54.7   , 51.5   , 52.9   , 51.1   ,
         '2C04a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 39.9   , 57.8   , 55.4   , 63.6   , 54.4   , 28.4   , 16.4   , 35.1   , 37.4   , 17.7   , 15.9   , 48.6   , 59.4   , 67     , 42.5   , 36.5   ,
         '2C04b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 28.9   , 20.8   , 25.5   , 30.6   , 26.7   , 23.4   , 38.1   , 34.4   , 38.3   , 40.8   , 34.8   , 36.9   , 38.9   , 38.3   , 42.3   , 40.7   ,
         '2D21a', 13     , 19     , 21.3   , 12     , 9      , 6.9    , 13.2   , 21     , 14.8   , 32.1   , 19.6   , 18.3   , 20.9   , 19.4   , 23.2   , 27.3   , 24.6   , 20.2   , 31.2   , 22.7   , 27.6   , 40.4   , 32.1   , 44.2   , 17.1   , 24.4   , 55.2   , 35.2   , 24.2   , 49.2   , 48.7   , 46     , 38.1   , 28.4   , 43.5   , 38     , 44.7   ,
         '2D22a', 3.9    , 7.2    , 11.3   , 11.4   , 11.2   , 15.1   , 11.9   , 10.7   , 3.2    , 7.1    , 5.8    , 10.3   , 8.8    , 10.1   , 12.2   , 11.7   , 10.8   , 10.9   , 11.9   , 11.7   , 6.4    , 22     , 12.1   , 22.7   , 22.2   , 20.1   , 14.5   , 12     , 24.2   , 27.1   , 13.3   , 25.1   , 14     , 30.6   , 26.2   , 18     , 21.9   ,
         '2D23a', 6.8    , 18.2   , 10     , 10.2   , 4.1    , 9.9    , 4.6    , 9      , 14.9   , 2.9    , 7.4    , 3      , 14.8   , 7.6    , 26.6   , 17.1   , 29.4   , 32.4   , 22.4   , 12.7   , 22.5   , 20.7   , 10.2   , 22.5   , 25.7   , 19     , 32.5   , 21.7   , 5.2    , 9.6    , 21.6   , 28.2   , 24.1   , 14     , 20.3   , 31.6   , 23.6   ,
         '2D23b', 10.3   , 11.9   , 11.6   , 6.7    , 16.8   , 12     , 12.8   , 9.9    , 18.9   , 27.3   , 32.8   , 25.4   , 12.2   , 30.3   , 14.3   , 34.9   , 19.8   , 20.8   , 11.7   , 22     , 20.4   , 20.5   , 25.2   , 29.6   , 25.9   , 21     , 36.2   , 36     , 36.3   , 37.9   , 30     , 36.1   , 29.6   , 32.7   , 40.4   , 36.2   , 37.8   ,
         '2D24a', 40.2   , 34.4   , 34.4   , 32.4   , 37.2   , 38.2   , 41.9   , 33     , 39.8   , 34.3   , 39.8   , 44     , 44.4   , 40.7   , 42.8   , 36.3   , 38.6   , 43.3   , 40.4   , 48     , 54.4   , 43.7   , 48.3   , 46.3   , 54.1   , 56.4   , 56.3   , 48.8   , 46.3   , 50.5   , 50.6   , 46.8   , 50.7   , 53.4   , 51.7   , 50.3   , 50.5   ,
         '2D24b', 37.7   , 36.2   , 32     , 26.4   , 23.1   , 25.6   , 22.2   , 30.2   , 34     , 39     , 45.1   , 39.8   , 37.5   , 42.9   , 44.3   , 46.1   , 48.5   , 48.2   , 45.2   , 44.5   , 42.2   , 52.6   , 47.8   , 48.7   , 56.6   , 57.5   , 61.2   , 54.7   , 50.6   , 54     , 58.8   , 61.3   , 63.6   , 60.4   , 61.2   , 62     , 63.5   ,
         '2D24c', 28.8   , 43.4   , 45.3   , 41.2   , 34.7   , 37.6   , 40.5   , 48.1   , 44.6   , 42.4   , 37.5   , 50.3   , 47.5   , 53.1   , 50.9   , 49.5   , 48.3   , 38.2   , 58     , 48.2   , 49.5   , 69.3   , 61.4   , 73.2   , 65.3   , 51.7   , 48.9   , 65.7   , 59.8   , 55.1   , 53.2   , 43.2   , 52.7   , 63.4   , 62.5   , 65.8   , 63.6   ,
         '2D25a', 30.8   , 25     , 20     , 27.5   , 46.2   , 45     , 42.9   , 53     , 49.8   , 53.9   , 43.6   , 40     , 29.5   , 38.1   , 45.4   , 45.1   , 53.5   , 60.3   , 50.3   , 41.5   , 41.9   , 61.8   , 47.3   , 63     , 54.4   , 52.9   , 52.5   , 47.5   , 59.6   , 73.6   , 68.6   , 53.1   , 57.9   , 52.1   , 43.8   , 66.8   , 68.7   ,
         '2D26a', 17     , 12.2   , 15.6   , 18     , 28.8   , 24     , 19.2   , 24.3   , 25.4   , 26.3   , 25.5   , 31.1   , 25     , 33.4   , 38     , 33.9   , 34.5   , 37.9   , 28.2   , 32.4   , 34.5   , 35.8   , 38.8   , 41.8   , 34.4   , 41.7   , 44.4   , 40.3   , 48.2   , 49.2   , 46     , 40.8   , 43.1   , 45.9   , 43.8   , 47.4   , 47.5   ,
         '2D26b', 31.2   , 34     , 24.6   , 23.7   , 30.9   , 32.4   , 26.9   , 33     , 33.1   , 48.8   , 56.4   , 42     , 37.8   , 44.2   , 39.3   , 39.4   , 41.8   , 44.6   , 47.3   , 48.5   , 45.7   , 57.5   , 64.2   , 55.8   , 59.3   , 59.8   , 56.4   , 57.6   , 57.9   , 57.6   , 61.8   , 64.6   , 66.5   , 65.2   , 62     , 66.3   , 67.2   ,
         '2D26c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 51.2   , 52.6   , 57.4   , 72.8   , 64.9   , 74.2   , 61.2   , 73.8   , 68.3   , 67.1   , 71.2   , 75.2   , 69.5   , 70.1   , 68.5   , 62.5   ,
         '2D26d', 19     , 24.9   , 23.9   , 21.1   , 31.1   , 30.7   , 29.7   , 25.5   , 21.5   , 40.2   , 40.2   , 23.7   , 20.6   , 34.5   , 34.1   , 36.4   , 38.2   , 32.6   , 38.1   , 32.9   , 42.9   , 36.4   , 51.2   , 43.1   , 36.1   , 37.7   , 32     , 47.5   , 49.4   , 42.5   , 46.2   , 50.1   , 47.2   , 47.7   , 53.6   , 57.5   , 58.5   ,
         '2D26e', 34.6   , 37.1   , 37.3   , 24.6   , 40.7   , 42.9   , 38.4   , 44.2   , 33.1   , 34.2   , 35.8   , 41.1   , 39.4   , 40.4   , 46.3   , 41.1   , 33.6   , 42.8   , 53.5   , 44.4   , 33.1   , 39.7   , 46.4   , 40.9   , 33.9   , 51.5   , 48.1   , 42.8   , 35.6   , 46.6   , 40.3   , 33.7   , 33.8   , 40.8   , 42     , 41.8   , 41.8   ,
         '2D26f', 28.7   , 25.1   , 30.6   , 30.6   , 36.5   , 33.1   , 35     , 37.5   , 42.4   , 41.5   , 39.3   , 36.9   , 39.3   , 43.3   , 47.9   , 44     , 46.6   , 42.3   , 44.1   , 46.9   , 48.6   , 49.2   , 49.2   , 46.5   , 51.5   , 50.7   , 54.3   , 49.9   , 57.2   , 48.3   , 51.5   , 59.7   , 66.5   , 61.7   , 57.3   , 50.7   , 59     ,
         '2D26g', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 39.4   , 43.5   , 45.2   , 45.5   , 44.1   , 52.3   , 50.1   , 50.4   , 51.7   , 46.3   , 53.7   , 57.6   , 53     , 49     , 53.2   , 54     ,
         '2D26h', 20     , 19.7   , 16.8   , 11.4   , 13.2   , 11.5   , 13     , 21.1   , 31.4   , 31.4   , 35.2   , 27.3   , 27     , 31.7   , 41.5   , 36.6   , 38.3   , 35.1   , 44.2   , 44.2   , 43.8   , 39.8   , 53.8   , 51     , 42.5   , 37.3   , 35.5   , 44.5   , 49.9   , 43.9   , 48.4   , 58.1   , 51.8   , 53.8   , 54.4   , 56.2   , 57.9   ,
         '2D26i', 45.2   , 39.5   , 38.7   , 48.8   , 47.1   , 47     , 37.6   , 38.5   , 44.2   , 51     , 50     , 54.6   , 50.3   , 57.7   , 46.1   , 51.2   , 49     , 47.3   , 62.1   , 52.3   , 59.1   , 53.9   , 52.5   , 59.1   , 68.3   , 51.4   , 52.6   , 60     , 59.4   , 68.6   , 61.3   , 60.3   , 74.1   , 65.6   , 70.1   , 66.7   , 64.7   ,
         '2D26j', 16     , 9.6    , 17.1   , 27     , 17.3   , 22.3   , 12.5   , 19.1   , 23.5   , 30     , 26.2   , 32.9   , 34.1   , 33.3   , 44.8   , 47.1   , 44.1   , 34.1   , 37.2   , 29.3   , 37.4   , 36.7   , 31.8   , 34.1   , 24     , 31.3   , 50.1   , 45.3   , 35.4   , 35.5   , 31.1   , 38.4   , 36.7   , 41.5   , 34.1   , 32.2   , 49.3   ,
         '2D27a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 51.3   , 59.5   , 65.8   , 55.6   , 51.4   , 67.2   , 67.9   , 54.6   , 60.5   , 63.6   , 72.3   , 73.9   , 68.8   , 69.7   , 62.8   , 68.9   ,
         '2D28a', 19.8   , 15     , 12.4   , 18.3   , 26.4   , 30.8   , 29.4   , 30.9   , 22.5   , 23.4   , 31.1   , 27.9   , 24.7   , 21     , 20.6   , 27.6   , 30.2   , 26.4   , 29.1   , 39.3   , 40.1   , 31.6   , 25.5   , 30.3   , 40.8   , 38.9   , 45.9   , 44.3   , 40.7   , 42.1   , 36.4   , 43.8   , 36.3   , 36.1   , 31.5   , 32.4   , 38.4   ,
         '2D29a', 32.4   , 64.1   , 100    , 70.1   , 86.1   , 76     , 49.9   , 62.6   , 35.7   , 70.1   , 63.5   , 56     , 76.2   , 69.8   , 56.1   , 73.7   , 69.1   , 90.6   , 66.5   , 56.5   , 66     , 72.2   , 100    , 100    , 59.4   , 85     , 100    , 100    , 69.3   , 75.1   , 61.4   , 68.5   , 79.6   , 72.4   , 75.5   , 85.8   , 70.6   ,
         '2D29b', 24.1   , 28     , 7.3    , 6.3    , 15.6   , 26.1   , 20.5   , 16     , 18.6   , 11.8   , 22.6   , 19     , 17.8   , 26.1   , 31.8   , 29.4   , 30.6   , 29.7   , 26.7   , 28.2   , 31.5   , 44.2   , 57.4   , 38.9   , 37.3   , 34     , 33.8   , 36.3   , 45.2   , 38.2   , 43.8   , 37.6   , 27.7   , 35.7   , 45.3   , 34.8   , 44.2   ,
         '2E21a', 2.5    , 10.1   , 0      , 6.7    , 15.3   , 13.1   , 5.2    , 4.8    , 0      , 0      , 0      , 0      , 6.7    , 12.7   , 5.6    , 7.9    , 3.7    , 16.5   , 0      , 0      , 13.8   , 0      , 4.6    , 25.2   , 43.6   , 0      , 8.7    , 24.6   , 22.9   , 20     , 11     , 0      , 4.3    , 0      , 56.3   , 10.4   , 14.2   ,
         '2E22a', 12     , 0      , 21.6   , 0      , 0      , 3      , 6.6    , 13.5   , 15.6   , 7.8    , 11.8   , 0      , 0      , 13.8   , 8.1    , 14.4   , 16.7   , 13.3   , 13.1   , 11.3   , 12.2   , 8.7    , 5.4    , 3.1    , 5.3    , 5.6    , 6.6    , 5.4    , 8.9    , 8.6    , 9.9    , 9.3    , 8.3    , 8.3    , 10.3   , 7.6    , 9.7    ,
         '2E23a', 6.1    , 6.5    , 6.8    , 5.1    , 9.8    , 9.9    , 10     , 8.2    , 7.5    , 16.6   , 17.4   , 14.2   , 12.1   , 14.3   , 22.2   , 22.5   , 24.6   , 20.9   , 18.8   , 24.3   , 24.7   , 29.3   , 25.6   , 26.4   , 32.1   , 30.3   , 35     , 32.6   , 39.1   , 36.9   , 34.4   , 36.9   , 32     , 33.9   , 31.7   , 38.4   , 44.7   ,
         '2E23b', 32.5   , 0      , 5.3    , 3.3    , 4.5    , 19.6   , 9.6    , 21.1   , 19.5   , 15.1   , 10.3   , 21.6   , 15.2   , 26.7   , 22.9   , 31.5   , 23.8   , 30.6   , 23.4   , 16.9   , 20     , 43.5   , 23.8   , 14.6   , 29.4   , 32.2   , 31.9   , 21.2   , 47     , 42.6   , 33     , 39.7   , 30.5   , 42.3   , 47.4   , 46.3   , 46.3   ,
         '2E25b', 2.5    , 0      , 0      , 1.4    , 0      , 2.3    , 2.7    , 1.4    , 1.5    , 0      , 1.6    , 1.7    , 1.5    , 0      , 0      , 2.5    , 4.5    , 4.6    , 3.4    , 0      , 0      , 1      , 0.8    , 0.6    , 1.2    , 1.9    , 7.8    , 9.1    , 5.5    , 6      , 6.5    , 3.9    , 5.2    , 7      , 6      , 5.8    , 12.7   ,
         '2E25c', 3.8    , 0      , 0      , 4.4    , 3.6    , 1.8    , 1.6    , 4.2    , 7.5    , 5.5    , 0      , 5.4    , 3.7    , 1.2    , 7.5    , 11.6   , 7.2    , 2.5    , 1.3    , 5.2    , 5.3    , 4      , 11.8   , 9.3    , 6.2    , 4.8    , 11.9   , 15.8   , 14.4   , 17.8   , 23.3   , 12.2   , 12     , 8.5    , 9.3    , 4.7    , 9.5    ,
         '2E25d', 3.7    , 0.9    , 3.3    , 4.3    , 2.4    , 0      , 1.2    , 0      , 0      , 2.9    , 7.5    , 2.5    , 4      , 6.6    , 5.8    , 3.4    , 5.7    , 8.1    , 8.1    , 5      , 6.8    , 7      , 7.2    , 9      , 6.4    , 7.8    , 6.9    , 10.6   , 12     , 7.8    , 13.5   , 13.6   , 15.6   , 9.7    , 7.3    , 13.9   , 17.6   ,
         '2E25e', 4.7    , 5.3    , 5.9    , 7      , 8.7    , 7.7    , 7.7    , 8.5    , 13.8   , 11.8   , 11.3   , 8.4    , 10.3   , 12     , 6.5    , 12.8   , 18.4   , 17.6   , 9.1    , 9.2    , 12.6   , 5.5    , 6.2    , 17.9   , 7.5    , 25     , 28.6   , 18.9   , 13.7   , 17.3   , 14.6   , 9.9    , 9.8    , 14.7   , 19.3   , 24.3   , 16.7   ,
         '2E25f', 4.9    , 0      , 0      , 0      , 1.9    , 5      , 5.7    , 6.9    , 4      , 5.5    , 5.6    , 6.4    , 3.9    , 9.7    , 6.4    , 9.2    , 3.9    , 9.3    , 4.6    , 9.8    , 12.8   , 3.5    , 3      , 13.3   , 7.9    , 12     , 26.6   , 16.4   , 16.1   , 20.7   , 23.4   , 18.3   , 2.9    , 34     , 35.2   , 15.2   , 8.2    ,
         '2E25g', 18.5   , 17.6   , 5.9    , 28.7   , 13.5   , 56.5   , 35.9   , 32.6   , 15.7   , 23     , 20.5   , 22.6   , 21     , 22.1   , 24.8   , 15.9   , 15     , 11     , 30     , 21.1   , 11.8   , 30.2   , 0      , 26     , 47     , 21     , 30.7   , 32     , 10.8   , 24.7   , 27.2   , 21.3   , 39.8   , 22.9   , 25.5   , 39.3   , 42.3   ,
         '2E25h', 7      , 10.6   , 8.6    , 8.5    , 10.7   , 12.2   , 9.3    , 15.3   , 9.1    , 6.2    , 11.7   , 12.5   , 13.2   , 15.9   , 14.5   , 13.2   , 14.9   , 7.1    , 20.7   , 22.8   , 23.6   , 15.9   , 13.3   , 21.6   , 35.1   , 21.2   , 23.6   , 25.2   , 31.7   , 28.6   , 25.7   , 27.2   , 21.3   , 13.8   , 22.2   , 21.6   , 26.8   ,
         '2E26a', 0      , 4.6    , 10.2   , 5.6    , 9.1    , 0      , 5.6    , 14.1   , 11.3   , 6.6    , 7.5    , 13.7   , 17     , 14.5   , 11.8   , 12.1   , 24     , 30.6   , 15     , 19.8   , 21.3   , 10     , 8      , 10.4   , 21.5   , 26.3   , 9.9    , 28.6   , 12.1   , 27.5   , 31     , 17.9   , 34.4   , 19.5   , 19.2   , 21.2   , 15.9   ,
         '2E26b', 4.1    , 2.4    , 0      , 4.6    , 6.7    , 4.1    , 5.9    , 3.8    , 6.2    , 10.8   , 6.3    , 5.5    , 4.1    , 0      , 7.3    , 7      , 7.3    , 8.7    , 6.6    , 13.9   , 8.8    , 14.2   , 15.1   , 17.8   , 12.6   , 13.8   , 13.1   , 16.1   , 23.2   , 19.3   , 19.2   , 18.6   , 21.6   , 22.1   , 20.9   , 27.7   , 24.7   ,
         '2E26c', 21     , 23.3   , 15.9   , 10.4   , 25.5   , 14     , 22.8   , 19.7   , 26     , 41.9   , 11.6   , 13     , 26.1   , 27.3   , 30.8   , 21.5   , 38.5   , 34.4   , 30.6   , 31.7   , 23.9   , 33.2   , 27     , 50.9   , 37     , 35.8   , 32.7   , 58.8   , 49     , 52.6   , 50.7   , 46.2   , 43.7   , 53.2   , 52.1   , 45.9   , 36.5   ,
         '2E26d', 2.3    , 3.4    , 3.5    , 3.8    , 5.2    , 4.5    , 4.4    , 6.6    , 5.9    , 4.5    , 5      , 8.3    , 6.2    , 6.3    , 7.7    , 6.5    , 13.7   , 10     , 10.5   , 12     , 14.3   , 6.2    , 8.3    , 10.3   , 11.9   , 12     , 16.5   , 14.9   , 9.6    , 10.1   , 16.2   , 12.9   , 10.1   , 17.2   , 15.9   , 19.8   , 17.8   ,
         '2E26e', 2.4    , 2.9    , 0      , 1.6    , 4.7    , 3.6    , 4.6    , 0      , 4.9    , 1.8    , 7.3    , 9.1    , 9.5    , 3.9    , 3.5    , 5.9    , 9.3    , 10.5   , 7.2    , 10     , 7.6    , 10     , 11.8   , 14.5   , 14.2   , 11.7   , 12.2   , 10.8   , 14.6   , 9.1    , 12.8   , 14.6   , 14.3   , 16     , 10.5   , 12.3   , 12.4   ,
         '2E26f', 9      , 9      , 11.4   , 9      , 13.6   , 11     , 13     , 10.7   , 15.5   , 17.5   , 23.8   , 18.6   , 24.4   , 22.1   , 27.4   , 18.2   , 26.3   , 28.6   , 26.7   , 23.2   , 24.5   , 34.2   , 23.2   , 19.5   , 29.1   , 33.4   , 30.9   , 42.8   , 30.3   , 36.1   , 36.7   , 34.5   , 25.8   , 26.2   , 32     , 39     , 39.1   ,
         '2E26g', 7.3    , 0      , 0      , 4.1    , 0      , 13.4   , 26.5   , 12.9   , 7.4    , 3.2    , 12.7   , 11.3   , 9.1    , 10.5   , 12.2   , 14.8   , 16.6   , 20.7   , 11.8   , 19.3   , 9.9    , 21.8   , 15.5   , 19.7   , 19     , 29.4   , 20.5   , 23.2   , 17.6   , 20     , 28.9   , 33.1   , 36.5   , 37.4   , 30.4   , 33.4   , 39.9   ,
         '2E26h', 0      , 2.6    , 4      , 7.5    , 6.6    , 3.9    , 5.1    , 8.8    , 2.7    , 4.1    , 0      , 0      , 0      , 3.7    , 0      , 6.3    , 0      , 0      , 5.1    , 6.9    , 8.6    , 6.7    , 15.1   , 12.6   , 3.5    , 1.1    , 3      , 2.5    , 3.8    , 5.8    , 4.7    , 4.9    , 9.1    , 6.2    , 11.9   , 8.9    , 7.5    ,
         '2E26i', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 32.4   , 26.7   , 26.5   , 40.4   , 71.5   , 36.9   , 38     , 21.3   , 23.8   , 37.1   , 49.4   , 40.8   , 35.1   , 45.7   , 41.6   , 38.1   ,
         '2E26j', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 28.7   , 27.3   , 23.8   , 24.3   , 16.7   , 18.4   , 16.4   , 20.8   , 24.4   , 22.6   , 14.4   , 10.2   , 15.3   , 10.9   , 14     , 14.6   ,
         '2E27a', 15.8   , 14.4   , 13     , 11.3   , 19.1   , 14.8   , 16.7   , 15.4   , 18.2   , 18.5   , 18.9   , 16.3   , 20.3   , 18.4   , 16.3   , 16     , 19     , 19.5   , 18.5   , 16.7   , 20.4   , 20.4   , 19.7   , 19.6   , 16.3   , 14.6   , 20.5   , 21.7   , 19.3   , 20.2   , 20.3   , 22.3   , 18.9   , 15.3   , 18     , 18.1   , 18.7   ,
         '2E27b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 18.6   , 14.2   , 2      , 4.6    , 7.8    , 7.7    , 10.4   , 18.6   , 22.9   , 7.5    , 10.7   , 10.9   , 3.9    , 7      , 13     , 15.3   ,
         '2E27c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 35.8   , 42.2   , 52.9   , 37.1   , 33.2   , 29.3   , 34.4   , 16.2   , 26.2   , 43.7   , 29.6   , 5.5    , 0      , 8.4    , 33.6   , 28.4   ,
         '2E28a', 0      , 0      , 0      , 6.5    , 0      , 11.5   , 10.1   , 5.4    , 6.6    , 0      , 0      , 0      , 9      , 6.1    , 9.9    , 3.4    , 7.6    , 13     , 9.1    , 0      , 4.5    , 13.9   , 7.1    , 25     , 17.9   , 15.2   , 9.7    , 10.9   , 17.3   , 10.8   , 18.3   , 10.2   , 14.5   , 19.7   , 21.2   , 31.3   , 32.8   ,
         '2E28b', 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 40.7   , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      ,
         '2E29a', 19.7   , 9.1    , 15.4   , 16.6   , 16.1   , 13.8   , 18.6   , 18     , 10.2   , 25.5   , 11.4   , 19.1   , 24.2   , 17.9   , 30.8   , 29.8   , 15     , 3.4    , 9.2    , 22.5   , 31.2   , 7.4    , 31     , 40.3   , 33.3   , 20.1   , 31.3   , 40.8   , 45.6   , 38.5   , 35.7   , 30.4   , 24.2   , 22.1   , 32.2   , 25.6   , 28     ,
         '2E29b', 0      , 9.3    , 10.1   , 0      , 0      , 0      , 0      , 7.7    , 0      , 0      , 0      , 0      , 0      , 0      , 25.3   , 0      , 0      , 15.3   , 33     , 22.1   , 40.7   , 17.5   , 20.4   , 17.2   , 21.2   , 15.6   , 20.7   , 26.3   , 21.1   , 21.3   , 20.5   , 17.8   , 27.2   , 30.5   , 21.9   , 21.5   , 27.6   ,
         '2E29c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 13.5   , 27.9   , 21.4   , 44.5   , 26.4   , 20.3   , 19     , 20.6   , 30.2   , 10     , 9      , 10.3   , 9.4    , 11.9   , 16     , 16.3   ,
         '2E29d', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 30     , 24.2   , 25     , 26.1   , 34.3   , 34.9   , 48.6   , 45.5   , 42.5   , 39.8   , 46.6   , 49.6   , 39.7   , 35.6   , 42.9   , 45.7   ,
         '2F01a', 87.3   , 87     , 83.4   , 83.2   , 85.9   , 84.1   , 89     , 95.2   , 91.6   , 90.4   , 87.2   , 90.7   , 87.1   , 78.2   , 78.2   , 80.8   , 83.3   , 84.8   , 80.6   , 81.3   , 84.9   , 84.8   , 81.1   , 79.1   , 90.8   , 80.6   , 78.6   , 80.6   , 71.3   , 79.8   , 78.3   , 83.5   , 78.1   , 91.7   , 92.6   , 86.7   , 86.3   ,
         '2F02a', 88.6   , 92.5   , 94.4   , 91.4   , 95     , 95.1   , 91.8   , 85     , 94.7   , 76.6   , 91.4   , 81.2   , 84.3   , 79.7   , 79.6   , 74.8   , 90.5   , 94.6   , 79.8   , 82.6   , 78.5   , 80.9   , 90.8   , 93.8   , 95.6   , 95.2   , 82.5   , 84.8   , 96.2   , 93.7   , 84.4   , 82.8   , 83.8   , 89.2   , 85.5   , 87     , 88.8   ,
         '2G00a', 6      , 1.4    , 2.9    , 3.1    , 2.6    , 2.6    , 4.7    , 4.8    , 0      , 7      , 4.7    , 5.1    , 1.6    , 5.1    , 7.7    , 10.5   , 8.2    , 7.4    , 2.6    , 5.4    , 6.6    , 10.3   , 5.2    , 4.4    , 16.9   , 20.5   , 7.1    , 6.6    , 7.9    , 12.5   , 13.7   , 15.1   , 8.4    , 7.6    , 7.2    , 11.6   , 16.6   ,
         '2G00b', 3.1    , 8      , 6.8    , 11.5   , 8.3    , 6.7    , 16.2   , 15.4   , 9.1    , 12.7   , 14     , 17.7   , 9.5    , 4.7    , 5      , 8.2    , 9.9    , 7      , 5.3    , 14.1   , 4.5    , 15.6   , 8.9    , 18.9   , 26.1   , 26.6   , 18.3   , 16.4   , 21.2   , 16.9   , 18.4   , 27.2   , 32.3   , 39.9   , 22.9   , 13.2   , 7.1    ,
         '2H00a', 17.3   , 15.5   , 39.8   , 28.5   , 24.3   , 26.5   , 34.1   , 28.1   , 29.8   , 20.8   , 30.1   , 25.8   , 19.3   , 21.4   , 23.5   , 22.4   , 9.7    , 21.3   , 47.6   , 33.2   , 27     , 29.8   , 28     , 19.4   , 27.1   , 29.8   , 24.1   , 31.3   , 30.8   , 27.3   , 33.9   , 32     , 40.1   , 31.6   , 37.6   , 37.7   , 30.9   ,
         '2I11a', 27.4   , 29.6   , 33.9   , 37.6   , 32.6   , 14.5   , 20.8   , 27.7   , 30.2   , 32.4   , 30.7   , 23.6   , 31.7   , 39.3   , 38.7   , 28.7   , 37     , 27     , 29.1   , 34.7   , 35.4   , 44.7   , 47.8   , 46     , 47.4   , 48.9   , 45.4   , 31     , 41     , 56.1   , 59.6   , 62     , 47.8   , 38     , 43.6   , 45.8   , 34.7   ,
         '2I12a', 0      , 0      , 48.9   , NA, 31.4   , 0      , 0      , 0      , 100    , 24.1   , 100    , 11.5   , 5.9    , 20.6   , 25.4   , 35.1   , 16.2   , 41.7   , 47.9   , 54.8   , 35.6   , 13.9   , 33.3   , 50.4   , 25.3   , 47.4   , 44.7   , 52.2   , 39     , 32.3   , 24.4   , 43.5   , 42.8   , 37.5   , 30.5   , 48.6   , 41.4   ,
         '2I21a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 74.5   , 79.5   , 78.9   , 82.2   , 66.1   , 62.5   , 54.4   , 74     , 81.2   , 75.1   , 68.7   , 51.3   , 44.9   , 39.3   , 64.8   , 69.5   ,
         '2I21b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 60.6   , 56.2   , 73.4   , 50.8   , 59.4   , 49.8   , 58.4   , 59.7   , 49     , 66.2   , 68.8   , 60.5   , 51.7   , 71.4   , 60     , 61.8   ,
         '2I22a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 50     , 55.4   , 65     , 67     , 63     , 61.3   , 71.7   , 62.5   , 62.4   , 67.9   , 66.3   , 50.2   , 55.6   , 52.2   , 56.7   , 57.2   ,
         '2J01a', 73.3   , 76.3   , 73.2   , 74.6   , 81.5   , 80.7   , 80.8   , 83.7   , 87.3   , 74.4   , 68.8   , 69.8   , 71.8   , 85.1   , 81.5   , 80.2   , 77.5   , 81.6   , 86.4   , 77.6   , 73.4   , 80.2   , 83     , 91.8   , 74.1   , 78.5   , 76.3   , 68.4   , 83     , 77.1   , 75.6   , 63.6   , 58.1   , 73.7   , 73.5   , 67.5   , 73.4   ,
         '2J02a', 0      , NA, NA, NA, NA, 0      , 29.2   , 0      , NA, 0      , NA, 0      , 0      , 0      , 0      , 100    , 100    , NA, 48.4   , 34.5   , 41.9   , 0      , 0      , 0      , 9.8    , 8      , 0      , NA, 100    , 100    , 100    , 100    , 0      , 100    , 100    , 66.2   , 20.1   ,
         '2J03a', 26.9   , 32.9   , 12     , 28.3   , 33.2   , 39.4   , 54.9   , 36.3   , 30.3   , 29.1   , 23.3   , 31.6   , 34.8   , 39     , 42     , 48.9   , 44.2   , 28.9   , 26.5   , 26.5   , 25     , 28.6   , 32.5   , 44.4   , 50.8   , 42.1   , 42.9   , 43.3   , 41.8   , 38     , 50.3   , 36.7   , 28.6   , 40.3   , 49.8   , 36.6   , 36.9   ,
         '3B11a', 16     , 15.7   , 16.6   , 17.5   , 16.7   , 17.7   , 19.4   , 19.1   , 25.4   , 25     , 25.4   , 28.6   , 31.5   , 33.4   , 32.7   , 32.1   , 30.6   , 33.9   , 38.9   , 38.2   , 36.4   , 35.5   , 37.6   , 36.1   , 32.8   , 35.5   , 37.5   , 38.1   , 36.7   , 35.2   , 35.3   , 36.6   , 37.8   , 37.9   , 33.4   , 35.2   , 41.8   ,
         '3B11b', 36     , 33.4   , 39.6   , 35.4   , 35.7   , 30.7   , 34.7   , 38     , 33.2   , 30.9   , 38     , 39.8   , 40.9   , 39.4   , 37.9   , 39.2   , 43.1   , 45.2   , 44.8   , 41.3   , 46.3   , 39.7   , 35.9   , 38.6   , 41.2   , 51.5   , 44     , 42.9   , 47.6   , 49.7   , 49.8   , 56     , 51     , 46.9   , 50.9   , 53.1   , 53.9   ,
         '3B12a', 41.2   , 49.3   , 54.8   , 54.4   , 50     , 53.1   , 47.6   , 44.7   , 54     , 52.1   , 62.2   , 52.4   , 45.5   , 53.8   , 56.3   , 44.3   , 52.9   , 48.3   , 44.6   , 55     , 55.5   , 55.7   , 57.4   , 53.8   , 49.3   , 46.2   , 57.4   , 55.3   , 56     , 54.3   , 61.6   , 57.4   , 51     , 49.5   , 58.2   , 60.7   , 56.5   ,
         '3B12b', 39.7   , 37.5   , 37.2   , 29.9   , 30.4   , 34.3   , 34.8   , 35.5   , 32     , 43.1   , 46.4   , 35.9   , 32.4   , 35     , 38.9   , 40.4   , 39.4   , 30.6   , 36.9   , 31.7   , 44.9   , 44.8   , 51.2   , 48.5   , 47.8   , 41.8   , 51.4   , 52.3   , 48.9   , 44.9   , 51.1   , 56.8   , 61.1   , 55.6   , 56.8   , 52     , 54.6   ,
         '3B13a', 22.8   , 29.4   , 25.1   , 29     , 24.5   , 42.3   , 29.9   , 41.8   , 47.4   , 43.3   , 44.5   , 35.8   , 41.1   , 40.1   , 45     , 32.5   , 43.9   , 44.3   , 37.2   , 44.8   , 36.8   , 53.7   , 50.4   , 44.2   , 51.7   , 56.4   , 51.6   , 35.5   , 44.4   , 49.8   , 56.1   , 49.4   , 48.6   , 47.2   , 53.4   , 56.6   , 54.8   ,
         '3B13b', 48     , 29.3   , 36     , 41.6   , 56.9   , 57.6   , 57     , 34.7   , 37.2   , 40.6   , 69.6   , 47.8   , 60.1   , 56.4   , 53.1   , 54.4   , 53.9   , 62.1   , 50.5   , 56.4   , 41.4   , 53.7   , 58.4   , 70.8   , 68.4   , 66.9   , 70.1   , 55.9   , 65.3   , 59.2   , 60.8   , 54.1   , 59.4   , 58.4   , 68     , 59.9   , 59.7   ,
         '3B13c', 11     , 21.2   , 27.6   , 32     , 35.2   , 34.1   , 39.5   , 36.3   , 41.2   , 45.6   , 45.9   , 42.4   , 40.5   , 45.9   , 36.6   , 41.5   , 45.2   , 42.5   , 50     , 46.5   , 49.3   , 51.6   , 55.5   , 64     , 53.7   , 44     , 52.8   , 47.8   , 41.8   , 46.1   , 58.1   , 56.6   , 48.2   , 52.2   , 52.5   , 53.9   , 51.8   ,
         '3B13d', 32.9   , 0      , 0      , 26     , 17.2   , 67.9   , 27     , 21.8   , 26.4   , 43.7   , 35.4   , 45.4   , 29.9   , 28.5   , 61.1   , 23     , 64.1   , 56     , 68.7   , 47.6   , 41.4   , 47.6   , 46.3   , 67.4   , 57.7   , 60.1   , 39.4   , 56.2   , 63.8   , 58.3   , 55     , 76.1   , 52     , 62.4   , 56.5   , 39.6   , 42     ,
         '3B21a', 21.9   , 31.2   , 31.2   , 11.6   , 29     , 27.4   , 26.8   , 26.5   , 27.8   , 26.4   , 19.6   , 23.8   , 29.6   , 27.5   , 25.3   , 14     , 11.8   , 18.4   , 24.9   , 25.7   , 20.9   , 24.9   , 11.7   , 7      , 17.5   , 21.2   , 14.4   , 12.9   , 11.2   , 20     , 8.5    , 4.3    , 11.6   , 17.6   , 14.4   , 20     , 35.6   ,
         '3B21b', 19.6   , 26.7   , 30.1   , 26.3   , 25.1   , 27.9   , 23.1   , 24.3   , 23.6   , 25.9   , 26.6   , 21.4   , 18.3   , 22.1   , 23.1   , 28.7   , 28.5   , 19.6   , 21.7   , 23     , 18.4   , 17.2   , 21     , 23.6   , 14.6   , 16     , 25.7   , 15.2   , 20     , 16.4   , 15.9   , 12.1   , 20.8   , 21.5   , 17.5   , 20.7   , 26.7   ,
         '3B21c', 41.6   , 43.3   , 44.5   , 49.1   , 46.8   , 43.9   , 41.6   , 42.4   , 43.3   , 44     , 41.8   , 46     , 49     , 53.2   , 49.4   , 45.6   , 46.8   , 47     , 47.1   , 47.6   , 47.9   , 45.3   , 40.5   , 38.2   , 42.6   , 48.5   , 46.2   , 42.3   , 45.1   , 43.4   , 40.5   , 42.8   , 43.4   , 50     , 50.9   , 44.2   , 35.2   ,
         '3B21d', 45.5   , 43.6   , 49.5   , 53     , 44     , 45.4   , 44.8   , 45.8   , 40.9   , 37.6   , 38.5   , 41.9   , 40.5   , 34.6   , 33.8   , 31.4   , 38.1   , 37.1   , 36.9   , 30     , 39.6   , 17.9   , 34.5   , 35.7   , 35.9   , 45.5   , 32.6   , 31.9   , 43.6   , 41.3   , 25     , 28.7   , 28     , 32.8   , 33.6   , 32.5   , 23.6   ,
         '3B21e', 34.2   , 30.4   , 18.6   , 9.3    , 7.2    , 15.4   , 15.6   , 24.1   , 20     , 22.7   , 17.2   , 14.6   , 20.1   , 27.9   , 18.1   , 18.6   , 16.4   , 13.3   , 24.7   , 14.6   , 23.8   , 14.6   , 33.1   , 28.9   , 32.5   , 23.5   , 34.1   , 34.3   , 25.4   , 24.1   , 28.4   , 32     , 26.9   , 24.1   , 28.8   , 30.4   , 31.2   ,
         '3B22a', 18.3   , 18.7   , 23.8   , 23.1   , 22.3   , 20.6   , 22.6   , 21.9   , 28.8   , 26.2   , 30.2   , 28.2   , 24.6   , 31.7   , 29.7   , 31.9   , 38.1   , 34.7   , 28.1   , 19.6   , 17.8   , 45.2   , 4.4    , 18.3   , 41.2   , 29.5   , 18.8   , 19.5   , 28.2   , 20.7   , 6.4    , 15.8   , 21.9   , 15.3   , 12     , 13.3   , 24     ,
         '3B22b', 9.7    , 0      , 22     , 30.3   , 50.3   , 26.4   , 24.9   , 24.3   , 16.5   , 38.6   , 37.3   , 11.8   , 0      , 17.2   , 14.6   , 0      , 16.2   , 33.2   , 18.2   , 20.5   , 35.3   , 47.1   , 38.1   , 18.8   , 24.5   , 44.4   , 19     , 43.6   , 66.7   , 68.2   , 59.2   , 28.9   , 42.8   , 44     , 54.7   , 31.1   , 29.4   ,
         '3B22c', 11.8   , 16     , 26.3   , 35.6   , 27     , 33.3   , 18     , 21.5   , 26.7   , 29.3   , 30.9   , 26.7   , 22.2   , 31.3   , 22.9   , 25.5   , 25.4   , 20.7   , 16.5   , 32.2   , 27     , 24.8   , 17.2   , 26.6   , 33.3   , 36     , 32.3   , 29.9   , 30.2   , 25.5   , 28.7   , 25.9   , 47.6   , 48.2   , 31.3   , 38.1   , 41.5   ,
         '3B22d', 33     , 22.2   , 37.6   , 33.7   , 37.3   , 40     , 22.1   , 34.7   , 35.5   , 59.8   , 22.3   , 20.8   , 15.3   , 23     , 16.7   , 28.9   , 29.4   , 33     , 24.8   , 26.3   , 31.5   , 25.9   , 25.2   , 53.5   , 41.9   , 34.1   , 41     , 40     , 52.1   , 42.4   , 35.2   , 41.4   , 49.8   , 21.8   , 30.1   , 29.2   , 40.3   ,
         '3B22e', 44.5   , 34.2   , 30.8   , 26     , 33.1   , 34.1   , 22     , 19.6   , 43.9   , 29.8   , 30.8   , 29.5   , 20.7   , 35.3   , 16     , 28.9   , 32     , 30.8   , 17.9   , 42     , 38.7   , 23.1   , 39.8   , 46.7   , 39.7   , 15.5   , 23.5   , 44.5   , 40.6   , 33.5   , 33     , 40.8   , 48.4   , 35.8   , 51.8   , 41.2   , 29.1   ,
         '3B22f', 69.8   , 66.9   , 33.7   , 40.6   , 36.6   , 50.3   , 34.4   , 45.8   , 59.9   , 52.2   , 62.3   , 65.5   , 70.2   , 60.2   , 62.5   , 90.9   , 73.8   , 69.9   , 63.4   , 74.2   , 73.2   , 51.5   , 77.6   , 60.9   , 67.9   , 73.6   , 63     , 67.3   , 51.4   , 62.3   , 59.2   , 75.5   , 75.5   , 66.4   , 64.6   , 70.4   , 71     ,
         '3B22g', 35     , 41.7   , 34     , 31.2   , 40.1   , 38.2   , 41.4   , 39.5   , 45.4   , 38.5   , 41.4   , 36.1   , 36.1   , 38.1   , 35.7   , 32.8   , 34.9   , 30.7   , 33.2   , 34     , 30.6   , 30.3   , 32.5   , 27.6   , 24.6   , 29.6   , 30.1   , 26.1   , 23.3   , 28.1   , 28.5   , 26.3   , 29.3   , 28.5   , 28.9   , 32.6   , 34.3   ,
         '3C01a', 51.2   , 49.1   , 56.2   , 59.3   , 53.9   , 56.1   , 57.7   , 57.6   , 57.6   , 58.4   , 57.7   , 61.2   , 58.9   , 60.8   , 58.9   , 60.5   , 62.7   , 67.4   , 68     , 68.7   , 68.6   , 73.1   , 71.8   , 64.7   , 54.1   , 57.8   , 61.7   , 69.7   , 72.1   , 64.4   , 64.7   , 58.6   , 58.9   , 60.2   , 58.4   , 61.5   , 63.4   ,
         '3C02a', 41.8   , 34.8   , 37.2   , 39.5   , 41.5   , 39     , 43.6   , 48.4   , 36.5   , 46.9   , 51.1   , 51.8   , 51     , 48.9   , 51.6   , 46.8   , 49.8   , 48     , 54.5   , 50.8   , 57.9   , 55.5   , 62.1   , 70.1   , 59.5   , 57     , 63.8   , 64.8   , 55.9   , 58.2   , 57.3   , 57.2   , 59     , 58.7   , 62.8   , 62.5   , 58.2   ,
         '3C03a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 61.2   , 57.3   , 44     , 48.9   , 52.9   , 52.3   , 59.3   , 55.3   , 65.4   , 61.9   , 66.2   , 44     , 53.1   , 75.4   , 68.7   , 74.6   ,
         '3C03b', 51.9   , 49.1   , 50.6   , 52.8   , 56.9   , 63     , 57.1   , 58.4   , 61.8   , 57.9   , 64.8   , 66.7   , 69.8   , 58.5   , 65.5   , 71.3   , 68.3   , 68.1   , 66.6   , 69.7   , 74.4   , 53.7   , 51.3   , 59.5   , 63.5   , 63.2   , 66.1   , 67.2   , 66.9   , 65.7   , 68     , 73.2   , 66.4   , 69.4   , 71.8   , 71.4   , 67.9   ,
         '3D01a', 64.9   , 66.1   , 63.5   , 66.2   , 67.4   , 70     , 68.9   , 65.5   , 62.1   , 69.7   , 68.8   , 69     , 70.4   , 74.6   , 75.2   , 72.7   , 70.6   , 69.2   , 69.5   , 68.8   , 64.9   , 65.9   , 64.4   , 65.3   , 69.3   , 71.2   , 65.8   , 67.9   , 71.6   , 67.8   , 68.6   , 70.8   , 70.4   , 71.1   , 69.8   , 70.5   , 72.2   ,
         '3D01b', 50.4   , 59.5   , 54.6   , 59.2   , 65.4   , 58     , 60.1   , 59.1   , 66     , 67     , 70.8   , 70     , 75.5   , 70     , 56.5   , 70.5   , 69.3   , 72.9   , 70.4   , 62.8   , 68.6   , 63.1   , 63     , 59.2   , 70.6   , 68.7   , 62.4   , 66.5   , 56.7   , 68.8   , 58.1   , 45.5   , 65.9   , 72.8   , 62.1   , 63.7   , 56.7   ,
         '3D02a', 96.4   , 97.2   , 97.8   , 95.6   , 96.5   , 97.4   , 97.6   , 99.2   , 99     , 99     , 99.2   , 98.6   , 99     , 97.7   , 99.2   , 96.6   , 97     , 98     , 96.6   , 97.4   , 96.9   , 94.3   , 94.2   , 94.8   , 97.1   , 96.8   , 95     , 95.9   , 96.9   , 94.9   , 95.2   , 95.1   , 95.6   , 93.9   , 94.1   , 94.3   , 96.3   ,
         '3D03a', 41.8   , 39.7   , 45.2   , 48.3   , 49.8   , 51.1   , 57.6   , 55     , 63.5   , 55.5   , 55.9   , 55.8   , 60.1   , 57.1   , 60.4   , 58.9   , 60.6   , 59.6   , 56.4   , 59.1   , 56.7   , 69.6   , 67.9   , 62.3   , 67.1   , 67.9   , 62.6   , 63.3   , 65.3   , 70.3   , 69     , 66.8   , 65     , 64.8   , 69.2   , 68     , 67.6   ,
         '3D03b', 47.9   , 47.4   , 48.3   , 46.1   , 47.9   , 53     , 54.4   , 55.7   , 57     , 58.2   , 59.2   , 59.6   , 54.7   , 60.5   , 57.2   , 58.1   , 58.8   , 63.1   , 61.3   , 68.1   , 67     , 59.7   , 65.2   , 65.5   , 67.9   , 67.8   , 72.1   , 69.4   , 67.6   , 74     , 73.4   , 71.6   , 68.1   , 73.2   , 70.7   , 73.1   , 76.9   ,
         '3D03c', 39.9   , 56.1   , 41.6   , 44.6   , 48.2   , 50     , 59     , 61.3   , 55.7   , 53.3   , 62.1   , 66.8   , 56.1   , 53.4   , 66.2   , 57.5   , 52.5   , 61.8   , 59.7   , 62.8   , 59.3   , 62.6   , 77.7   , 77.5   , 80.5   , 70.6   , 65.8   , 70.1   , 74.1   , 71.3   , 63.5   , 64.8   , 65.7   , 75.1   , 77.3   , 73.7   , 72.7   ,
         '3D04a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0      , 0      , 100    , NA, NA, NA, NA, NA, 100    ,
         '3D05a', 17.4   , 10.4   , 12.6   , 11.7   , 13.7   , 9      , 9.5    , 12.8   , 8      , 15.7   , 11.4   , 4.8    , 15.5   , 15.9   , 11     , 17.6   , 19     , 13.5   , 12     , 12.3   , 17.4   , 10.7   , 12.3   , 13.7   , 19.9   , 16.8   , 19.8   , 20     , 18     , 20.5   , 23.4   , 27.6   , 19.9   , 13.2   , 23.8   , 19.8   , 15.7   ,
         '3D06a', 57     , 58.7   , 82.8   , 69.5   , 70.7   , 68.6   , 58     , 78.6   , 73     , 69.3   , 83.7   , 73.9   , 78.3   , 79.9   , 80.1   , 69.2   , 87     , 83.4   , 85.2   , 71.7   , 70.6   , 25.1   , 34.6   , 62.5   , 72.4   , 41.3   , 75.3   , 85.1   , 92     , 57.8   , 53     , 57     , 63.9   , 42.2   , 9.4    , 46.4   , 79.7   ,
         '3D06b', 47.1   , 38.2   , 56.6   , 47.3   , 38.8   , 56.3   , 72.2   , 77.3   , 66.8   , 65.3   , 69.5   , 75.1   , 76.4   , 69.8   , 62.7   , 71     , 70.9   , 64     , 84.4   , 67.2   , 73.8   , 60.6   , 57.2   , 95.4   , 73     , 67.4   , 69.4   , 60.5   , 53.2   , 65.6   , 75.9   , 74.4   , 69.7   , 71.6   , 62.5   , 61     , 75.3   ,
         '3D06c', 39.8   , 39.8   , 36.7   , 36.1   , 39.9   , 45.5   , 43.8   , 47.3   , 47.1   , 49.4   , 49.6   , 53     , 50.7   , 46.2   , 46.5   , 47.2   , 49.8   , 44.5   , 49.3   , 46.5   , 53.2   , 39.1   , 38     , 50.2   , 48.5   , 45.5   , 48.9   , 50     , 49.3   , 51.4   , 54     , 55     , 48.1   , 46.3   , 45.1   , 50.8   , 52.2   ,
         '3D06d', 24.3   , 22.1   , 22.4   , 23.9   , 26.7   , 32.7   , 27     , 23.8   , 24.3   , 28.3   , 24.4   , 18.6   , 30     , 21.2   , 27.7   , 26.8   , 36.4   , 41.4   , 38.6   , 36.5   , 35.2   , 26     , 27.4   , 20.1   , 34.1   , 27.5   , 24.6   , 26.7   , 21.9   , 32.1   , 23.3   , 26.2   , 25.3   , 22.5   , 34     , 30     , 37.8   ,
         '3D06e', 21.1   , 14.3   , 18.9   , 24.1   , 24.4   , 22.4   , 35.3   , 24     , 17.5   , 15.7   , 11     , 10.7   , 19.6   , 25.1   , 39.1   , 19.1   , 17     , 16.5   , 16     , 22.7   , 22.3   , 27.6   , 23.4   , 16.8   , 24.9   , 24.7   , 30.6   , 32.6   , 29.6   , 21.5   , 26.5   , 31.9   , 33.1   , 44.2   , 34.7   , 25     , 37.7   ,
         '3D07a', 26.6   , 26.9   , 32.4   , 29.3   , 24.6   , 22.7   , 21.7   , 29     , 29.9   , 39     , 42.7   , 42.2   , 37.2   , 40.2   , 33.1   , 41.6   , 40.3   , 39.4   , 33     , 34     , 38.2   , 64.5   , 63.5   , 56.1   , 53.6   , 51.5   , 50.9   , 51.9   , 44.5   , 51.3   , 57.8   , 52.2   , 55.2   , 63.2   , 64.5   , 61.6   , 56.6   ,
         '3D07b', 100    , 84.9   , 63.6   , 78.6   , 50     , 54.1   , 72.1   , 64     , 47.1   , 70.4   , 72.2   , 74.5   , 61.3   , 61.9   , 62.9   , 53.8   , 45.3   , 54.8   , 61.9   , 56.9   , 50.1   , 69.2   , 68.6   , 73.9   , 66     , 67.9   , 74.7   , 77.6   , 78.5   , 77.6   , 73.4   , 74.3   , 84.3   , 78.2   , 78.4   , 79.8   , 73.9   ,
         '3D08a', 55.9   , 59.6   , 55.6   , 59.1   , 55.8   , 53.6   , 49.1   , 51.4   , 55.4   , 53.3   , 51.1   , 51.5   , 51.2   , 49     , 48.1   , 49.3   , 46.1   , 45     , 46.1   , 46.7   , 47.1   , 60.7   , 53.5   , 55.6   , 46.5   , 60.5   , 63.4   , 64.8   , 72.5   , 53.9   , 49.7   , 47.6   , 73.1   , 58     , 52     , 44.8   , 51.5   ,
         '3E11a', 5.4    , 3.4    , 5.2    , 5.5    , 5.8    , 2.9    , 3.9    , 3.2    , 5.9    , 9.5    , 9.9    , 8.1    , 6.2    , 7.1    , 4.7    , 5      , 6.6    , 3.9    , 6.9    , 4.7    , 12.1   , 11.7   , 5      , 7.5    , 11.6   , 17     , 8.5    , 19.8   , 17     , 10.2   , 12.6   , 19.3   , 16.9   , 24.8   , 24.3   , 21.9   , 26.7   ,
         '3E12a', 0      , 0      , 0      , 0      , 0      , 0      , 2.9    , 1      , 0      , 3.7    , 2.6    , 4      , 3.1    , 5.4    , 3.9    , 0      , 3.4    , 0      , 2.1    , 1.6    , 0      , 4.6    , 10.4   , 8.8    , 4.2    , 3.1    , 2.6    , 4.3    , 1.3    , 2.9    , 3.8    , 8.8    , 10.1   , 8      , 8.2    , 2.9    , 7.5    ,
         '3E12b', 0.4    , 0      , 0      , 1      , 0.6    , 0.5    , 0      , 0.5    , 0.9    , 1      , 0.5    , 1      , 0.9    , 0.6    , 0.8    , 1.7    , 1      , 0.7    , 1      , 1.1    , 1.4    , 1.9    , 2.1    , 1.6    , 1.2    , 0.8    , 2.5    , 2.5    , 1.6    , 2.6    , 4      , 2.5    , 1      , 3.8    , 8.4    , 3.6    , 5.6    ,
         '3E13a', 1.9    , 12     , 12     , 15.2   , 14.6   , 10.5   , 11.6   , 11.3   , 16.8   , 12.6   , 9.7    , 15.1   , 10.6   , 9.5    , 16.1   , 13.3   , 10.7   , 9.6    , 9.4    , 10     , 16.7   , 38.7   , 23.2   , 26.9   , 13.4   , 17.1   , 6.1    , 6      , 14.1   , 15.2   , 26.3   , 33.4   , 29.5   , 39.9   , 29.3   , 29.8   , 13.3   ,
         '3E13b', 1.4    , 2.4    , 2.1    , 2.5    , 2.7    , 2.2    , 1.9    , 1.3    , 4.7    , 4.4    , 4      , 5      , 5.9    , 7.1    , 6.7    , 4.7    , 5.9    , 4.5    , 9.1    , 4.2    , 5.3    , 8.3    , 6.8    , 10.5   , 13     , 13.6   , 8.8    , 9.1    , 10.6   , 14.5   , 14.4   , 8.8    , 8.5    , 11.7   , 10.3   , 14.8   , 14.5   ,
         '3E13c', 8.6    , 8      , 12.2   , 10.1   , 14.6   , 12.7   , 11.8   , 10.6   , 10.4   , 12.5   , 10.3   , 14     , 15.4   , 14.7   , 13.4   , 13.5   , 10     , 13.5   , 17.8   , 15.2   , 12.8   , 17     , 25.1   , 23.4   , 20.6   , 14.3   , 16.1   , 13.4   , 15.8   , 13     , 14.2   , 15.1   , 17.5   , 17     , 21.8   , 28.2   , 22.2   ,
         '3E13d', 4.8    , 6      , 5.1    , 4.7    , 4.2    , 2.4    , 1.3    , 1      , 1.6    , 2      , 2.4    , 4.1    , 2.9    , 0.6    , 2.6    , 0      , 4      , 4.9    , 3.8    , 1.6    , 8.1    , 0      , 0      , 3.8    , 7.6    , 6.7    , 5.6    , 14.7   , 13.8   , 13     , 4.5    , 8.4    , 7.1    , 13.5   , 7.8    , 12.7   , 12.4   ,
         '3E13e', 4.2    , 8.2    , 7      , 7.2    , 7      , 8.4    , 9.3    , 6.6    , 3.1    , 0      , 1      , 3.3    , 2.9    , 6.1    , 6.3    , 5.3    , 9.6    , 9.7    , 9      , 3.4    , 9.7    , 14.1   , 14.9   , 13.1   , 18.5   , 17.4   , 12.8   , 15.2   , 18.1   , 20.1   , 20.8   , 22     , 33.5   , 35.4   , 33.7   , 22.9   , 27.9   ,
         '3E13f', 23.5   , 17.6   , 15.1   , 13.5   , 16.8   , 27.3   , 26.3   , 21.4   , 21.8   , 21.1   , 17.2   , 21.3   , 15.5   , 18.1   , 24.9   , 20     , 15.4   , 10.7   , 8.3    , 17.6   , 17.7   , 16.7   , 12.4   , 18.2   , 30.4   , 22.7   , 11.8   , 12.8   , 13.9   , 14.4   , 9.1    , 13     , 16.9   , 25     , 17.5   , 16.8   , 18.4   ,
         '3E13g', 2.7    , 0      , 0      , 0      , 0      , 1.8    , 4.7    , 7.3    , 2      , 1.3    , 2      , 7.1    , 5.2    , 1.1    , 2.5    , 0      , 0      , 5.1    , 5.1    , 2.3    , 4.1    , 0      , 0      , 2.7    , 3.7    , 0.6    , 0.7    , 0      , 1.5    , 3.5    , 0.8    , 1.1    , 2.5    , 1.2    , 0.8    , 1.2    , 2.8    ,
         '3E13h', 1.2    , 1.3    , 1.3    , 0.7    , 1.5    , 1.2    , 0.6    , 1.4    , 0      , 0      , 1.5    , 2.2    , 2.3    , 1.2    , 2.6    , 2.8    , 2.7    , 1.9    , 1.7    , 0      , 2      , 2.3    , 0.3    , 0.2    , 3      , 1.9    , 3.5    , 3      , 4.1    , 2.3    , 2.4    , 0.5    , 2.7    , 4.3    , 2.6    , 5.3    , 2      ,
         '3E13i', 3.7    , 6.5    , 2.8    , 8.3    , 17     , 16.8   , 5.2    , 19.4   , 5.1    , 3.2    , 9.3    , 8.6    , 4.4    , 12.9   , 15.3   , 22.1   , 8.3    , 7.7    , 6.5    , 13.6   , 9.6    , 18.1   , 11.1   , 2.3    , 1.4    , 2.2    , 14.7   , 3.1    , 5.9    , 12.5   , 12.4   , 6.2    , 15.2   , 18.6   , 9.4    , 3.9    , 4.5    ,
         '3E14a', 8.6    , 8.7    , 10.1   , 7.1    , 7.9    , 11.5   , 9.7    , 7.7    , 10.6   , 11     , 8.7    , 14.1   , 17.4   , 13.9   , 15.3   , 18.1   , 20.7   , 22.6   , 21.8   , 22.4   , 20.1   , 18.8   , 17.2   , 22.5   , 14.7   , 20.4   , 16.5   , 16.9   , 22     , 25.1   , 24.6   , 26.2   , 33.4   , 23.1   , 18.3   , 26.3   , 21.2   ,
         '3E14b', 8.1    , 5.4    , 6.4    , 7.9    , 1.5    , 15.7   , 11.4   , 10.5   , 8.5    , 8.5    , 9.5    , 11.8   , 9.9    , 13.7   , 12.4   , 8.8    , 7.3    , 11.7   , 10.5   , 14.7   , 15.9   , 12.1   , 15.3   , 20.8   , 14.1   , 17     , 13.5   , 19.4   , 19.8   , 25.7   , 15     , 13.5   , 14.9   , 16.6   , 16     , 15.3   , 17.8   ,
         '3E15a', 3.4    , 0      , 2.4    , 0      , 3.3    , 4      , 0      , 3      , 9.3    , 15.3   , 14.5   , 0      , 3.5    , 10.5   , 5      , 9      , 8.4    , 4.8    , 10.2   , 3      , 6.8    , 34.5   , 35.7   , 17.8   , 10.2   , 16.9   , 37.7   , 14.2   , 17.8   , 22.5   , 23.3   , 24.9   , 25.3   , 28.2   , 13.5   , 18.7   , 20.4   ,
         '3E15b', 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 18     , 19.2   , 7.4    , 0      , 0      , 0      ,
         '3E21a', 13.4   , 13.7   , 14     , 13.8   , 12.9   , 13.9   , 13.1   , 11.4   , 17.9   , 25.2   , 20.3   , 15.4   , 18.8   , 20.4   , 19.6   , 17.7   , 18     , 22.1   , 19.1   , 25.4   , 22.6   , 23.1   , 25.5   , 21.9   , 18.2   , 22.4   , 20.3   , 18.4   , 26.4   , 24     , 23.2   , 26.8   , 23.9   , 23.3   , 23.9   , 23.1   , 32.6   ,
         '3E22a', 3.8    , 9      , 4.6    , 9.2    , 14.4   , 24.7   , 17.4   , 19     , 24.5   , 5.7    , 0      , 4.8    , 12.3   , 5.2    , 10.1   , 6.4    , 21.5   , 23.5   , 16.9   , 21.3   , 14.1   , 26     , 14.4   , 22.4   , 24.4   , 15.9   , 23.7   , 35.8   , 27     , 20.8   , 14.6   , 19.8   , 15.3   , 14.9   , 13.6   , 17.7   , 25.7   ,
         '3E22b', 4.7    , 3.6    , 2.8    , 4.7    , 6.2    , 6.7    , 5.8    , 5.8    , 7.7    , 8.1    , 6.8    , 7      , 7.8    , 5.9    , 3.5    , 7.5    , 6.1    , 9.7    , 5.5    , 11     , 7.3    , 3.7    , 10.5   , 7.7    , 2.2    , 2      , 3.3    , 1.8    , 3      , 4      , 6.5    , 3.4    , 2.7    , 2.6    , 4.9    , 7      , 5.1    ,
         '3E22c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 8      , 7.6    , 6.3    , 6.9    , 6.6    , 15.3   , 19.8   , 16.3   , 11.7   , 11.3   , 9.4    , 4.8    , 11.5   , 11.6   , 8.6    , 6.4    ,
         '3E22d', 5.1    , 4.3    , 6.1    , 5      , 6.4    , 4.4    , 3.9    , 2.7    , 7.6    , 3.4    , 1      , 3.1    , 6.3    , 4.7    , 3.1    , 4.7    , 7.5    , 11.2   , 11     , 6.2    , 6.9    , 9.4    , 7.5    , 10.2   , 5      , 10.8   , 13.2   , 12.6   , 10.5   , 11.6   , 12.2   , 10.2   , 10.5   , 20.9   , 12.1   , 6.3    , 8      ,
         '3E22e', 4.1    , 2.1    , 1.5    , 0.6    , 2.3    , 0.9    , 1.3    , 1.9    , 2.8    , 2.4    , 3.8    , 4.8    , 3.8    , 3.9    , 3.2    , 3      , 3.3    , 2.8    , 3.9    , 4.4    , 5.1    , 5.7    , 3      , 2.3    , 5.1    , 6.2    , 3.1    , 6.9    , 8.5    , 7.2    , 6      , 12.5   , 8.7    , 8.8    , 10.8   , 9.3    , 12.6   ,
         '3E22f', 26.1   , 22     , 23.8   , 28.3   , 34.9   , 26     , 26.4   , 30.1   , 32.9   , 27.1   , 32.1   , 31.9   , 24.4   , 29     , 24.7   , 26.6   , 32     , 27.7   , 28.8   , 34     , 34.2   , 19.7   , 21.4   , 16.6   , 15.8   , 17.3   , 11.7   , 15.6   , 15.1   , 18.3   , 19.3   , 15.1   , 22     , 13.8   , 16.2   , 21.4   , 17.9   ,
         '3E22g', 4.4    , 6.9    , 8.6    , 16.6   , 12.1   , 16.1   , 15.9   , 15.9   , 16.3   , 17     , 23.4   , 2      , 24.2   , 14.2   , 19.6   , 24.3   , 25.8   , 21.6   , 12.3   , 25.3   , 33.2   , 12.5   , 22     , 23.7   , 5.2    , 8.6    , 28.6   , 22.7   , 12.7   , 20     , 19.2   , 23.1   , 29.1   , 21.5   , 33     , 33.8   , 27     ,
         '3E23a', 0.5    , 1.7    , 2      , 2.9    , 1.3    , 2.7    , 2.8    , 1.8    , 1.1    , 1.6    , 1.9    , 1.5    , 1.6    , 1.9    , 2.1    , 1      , 1.2    , 1.6    , 3      , 3      , 2.9    , 1.6    , 1.2    , 0.5    , 0.3    , 2.8    , 1.2    , 0.6    , 1.5    , 0.9    , 2.5    , 1.7    , 1.1    , 2.5    , 3.1    , 2.7    , 0.9    ,
         '3E23b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 1.6    , 0.8    , 2      , 0.9    , 0.4    , 0.6    , 2.3    , 2.9    , 1.6    , 3      , 3.3    , 1.1    , 0.6    , 1.7    , 1.5    , 2      ,
         '3E24a', 2.7    , 0      , 6      , 5      , 8      , 11.4   , 4.2    , 3.1    , 5.2    , 21.8   , 23     , 15.4   , 12.6   , 14.5   , 10.5   , 8.9    , 13.1   , 13.2   , 16.2   , 9.8    , 14.7   , 27.4   , 33.7   , 47     , 38.3   , 22.5   , 20.4   , 22.6   , 23.4   , 25.7   , 38.3   , 32     , 19     , 28.7   , 30.4   , 42.4   , 34.5   ,
         '3E24b', 14.8   , 15.8   , 11.4   , 12.1   , 8.4    , 11.2   , 17     , 13.7   , 6.9    , 9.2    , 8.4    , 10.7   , 8.1    , 21.8   , 17.2   , 13.2   , 15     , 11.7   , 18.4   , 18.7   , 13.7   , 16.2   , 13.4   , 11.1   , 20.1   , 20.2   , 19.6   , 29.8   , 33.1   , 19.6   , 19.2   , 27.3   , 22.2   , 18.1   , 16.8   , 37.7   , 34.7   ,
         '3E24c', 6.1    , 7.8    , 5.1    , 3.9    , 7.2    , 6.7    , 6.7    , 9.4    , 10     , 4      , 8      , 8.2    , 5.8    , 6.7    , 7.7    , 6.1    , 2.1    , 2.4    , 0      , 5.3    , 6.6    , 0      , 5.3    , 2      , 0      , 5.7    , 2.4    , 7.7    , 5.2    , 14     , 12.9   , 4.1    , 11     , 11.9   , 2.6    , 9.8    , 12.8   ,
         '3E24d', 4.8    , 10.9   , 9.3    , 0      , 2.8    , 0      , 3.7    , 7.5    , 4.2    , 5.8    , 0      , 2.8    , 2.8    , 3.3    , 4.7    , 0      , 3.9    , 0      , 0      , 3.5    , 4.1    , 2.3    , 6.1    , 6.7    , 2.5    , 3.2    , 6.4    , 15.6   , 12.3   , 7.9    , 8.5    , 7.2    , 9.9    , 2.2    , 8.9    , 13.2   , 10.6   ,
         '3E24e', 3      , 5      , 4.6    , 3.6    , 5.6    , 5.6    , 4      , 5.6    , 7.6    , 4      , 10.9   , 6.9    , 4.1    , 2.4    , 2.1    , 3.4    , 12.5   , 12.8   , 2.5    , 14.9   , 15.9   , 42.9   , 32.7   , 19.7   , 29.2   , 33.6   , 40.4   , 43.2   , 36.8   , 35.6   , 41.3   , 43.2   , 38.2   , 36.5   , 43.7   , 40     , 30.6   ,
         '3E24f', 0      , 17.9   , 0      , 18.6   , 9.5    , 9.3    , 27.9   , 43.2   , 25     , 9.4    , 33.8   , 41.8   , 36.6   , 42.2   , 21.5   , 40.2   , 21.1   , 26.2   , 34     , 26.4   , 45     , 100    , 66.8   , 62     , 51.7   , 36.4   , 31.1   , 12.9   , 34.5   , 52.4   , 26.5   , 19.4   , 51.7   , 80.8   , 83.1   , 61.1   , 37.1   ,
         '3E25a', 28.3   , 28.5   , 22.2   , 29.2   , 25.1   , 28.8   , 23.8   , 25.5   , 27.4   , 28.6   , 25.3   , 20.1   , 21.2   , 23.2   , 22     , 25.6   , 21.3   , 20.8   , 18.2   , 19.5   , 18.4   , 23.1   , 25.9   , 15.8   , 26     , 22.6   , 17     , 19.6   , 17.5   , 13.6   , 21.9   , 28.2   , 20.5   , 21.2   , 24.6   , 18.9   , 21.5   ,
         '3E25b', 7.8    , 15.9   , 20.2   , 26.1   , 20.5   , 22.2   , 23     , 20.8   , 32.4   , 26.7   , 32.7   , 23.8   , 20.8   , 22.7   , 30.7   , 32.8   , 32.7   , 29.8   , 28.8   , 17.3   , 5.4    , 11.9   , 21.4   , 17.7   , 15     , 12.9   , 22.2   , 26.7   , 9.8    , 15.9   , 24.5   , 16.1   , 16     , 11.7   , 13.1   , 24.2   , 14.4   ,
         '3E25c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 13.1   , 12.1   , 1.9    , 7.5    , 4.4    , 4.4    , 4.7    , 6.1    , 4.8    , 5.5    , 4.4    , 7.5    , 2.5    , 5.5    , 11.5   , 14.3   ,
         '3E25d', 9.1    , 11     , 6.8    , 6.9    , 11.1   , 10     , 13.2   , 9.2    , 5      , 3      , 4.5    , 9.9    , 7.2    , 6.2    , 6.1    , 8.5    , 7.3    , 6.7    , 8.9    , 7.1    , 8.1    , 4.5    , 13.1   , 12.5   , 6.2    , 10.4   , 17.3   , 8.2    , 8.4    , 5.6    , 6.8    , 10.4   , 13     , 13.1   , 9.6    , 5.2    , 12.5   ,
         '3E26a', 5.4    , 7.6    , 3.3    , 0      , 0      , 4.1    , 3.1    , 2.9    , 3.1    , 2.4    , 3      , 0      , 3.9    , 0      , 3.8    , 8.1    , 7.4    , 13.2   , 3.1    , 3.6    , 4.7    , 0      , 1.8    , 9.4    , 4      , 7.7    , 15     , 21.7   , 14.4   , 9.7    , 1.8    , 9.9    , 14.3   , 8.3    , 5.7    , 8.3    , 11.9   ,
         '3E26b', 1.8    , 2.1    , 3      , 0      , 2.6    , 2      , 3.7    , 4.1    , 6.2    , 3.8    , 5.7    , 1.8    , 3.5    , 4.4    , 2.6    , 6.4    , 7.2    , 6.6    , 5.9    , 7.7    , 6.2    , 5.6    , 6.1    , 4.1    , 6      , 3.3    , 5.4    , 4.7    , 3.1    , 3.8    , 3.7    , 3.1    , 7      , 7.1    , 7.7    , 7.7    , 8.1    ,
         '3E26c', NA, 0      , 78.6   , 0      , 16     , 20.3   , 17.1   , 0      , 0      , 0      , 0      , 7.1    , 0      , 10.7   , 5.9    , 11.6   , 3.3    , 19.6   , 20.3   , 20.3   , 0      , 0      , 0      , 0      , 0      , 1.9    , 23.4   , 38     , 0      , 10.7   , 10     , 23.8   , 65.8   , 37.1   , 44.1   , 49.4   , 14.1   ,
         '3E26d', 12.2   , 14.9   , 15.8   , 8.1    , 2.3    , 5.2    , 3.5    , 9.1    , 14.1   , 20.1   , 16     , 18.7   , 24     , 13.1   , 26.8   , 24.6   , 24.1   , 31.6   , 27.9   , 29.4   , 37     , 19.4   , 27.4   , 16.4   , 14.7   , 22.7   , 2.2    , 17.2   , 34.3   , 17.9   , 10.2   , 15.4   , 12.2   , 38.5   , 33.3   , 35.3   , 29.5   ,
         '3E26e', 14.8   , 6      , 11.5   , 24.6   , 23.6   , 10.6   , 20.9   , 23.6   , 13.4   , 33.2   , 29.7   , 7.7    , 9.2    , 18.4   , 10.3   , 11.8   , 10.5   , 24.6   , 26     , 31.7   , 14.7   , 50.5   , 27.3   , 19.1   , 56     , 41.1   , 43.2   , 31.6   , 38     , 42.6   , 24.8   , 39.6   , 29.6   , 36.8   , 48.7   , 36.9   , 40.5   ,
         '3E26f', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 18.6   , 26.1   , 13.5   , 22.1   , 30     , 13.9   , 7.7    , 22.8   , 13.9   , 9.4    , 21.3   , 17.6   , 20.9   , 32.8   , 19.8   , 19.2   ,
         '3E26g', 17.2   , 7.1    , 8.1    , 10.9   , 9.4    , 6.6    , 9.2    , 5.1    , 14.7   , 11.8   , 13.1   , 10.1   , 14.7   , 11.1   , 19     , 16.6   , 17.8   , 16.3   , 14     , 17.8   , 16.6   , 17.6   , 14.5   , 16.1   , 17.7   , 16.5   , 17.6   , 18.3   , 19.8   , 17.7   , 18.2   , 20.1   , 17.9   , 17     , 19.1   , 18.7   , 24.1   ,
         '3F00a', 59.4   , 51.4   , 58.9   , 55.1   , 55.4   , 66.3   , 66.8   , 67.4   , 63.9   , 58.1   , 62.9   , 64.9   , 66.1   , 61.6   , 61.2   , 68.2   , 67.8   , 63.1   , 61     , 62.8   , 59.9   , 63.2   , 63.5   , 65.5   , 67.4   , 64     , 62.6   , 65     , 59.5   , 63.4   , 62.6   , 65.4   , 60.6   , 61.9   , 60.9   , 61.3   , 61     ,
         '3F00b', 63.4   , 69.9   , 71.1   , 69.3   , 74.1   , 77.2   , 76.2   , 74.7   , 74.4   , 69.5   , 75.9   , 77     , 81.8   , 86.6   , 83.1   , 84     , 82.6   , 79.6   , 80.5   , 80.6   , 83.3   , 86.4   , 90.9   , 93.2   , 95     , 95.2   , 95.9   , 96.4   , 95.5   , 92     , 91.7   , 89.3   , 92.2   , 95.1   , 95.8   , 91.9   , 88.5   ,
         '3H00a', 11.3   , 15.7   , 9.7    , 13.6   , 12.6   , 19.4   , 18.7   , 17.5   , 20.9   , 21.6   , 20.4   , 20.4   , 20     , 28.4   , 17.2   , 22.6   , 30.8   , 27.9   , 19.9   , 16.9   , 25.2   , 29.8   , 32.9   , 28.8   , 27.7   , 31.4   , 41     , 44.8   , 40     , 41.5   , 38.1   , 38.4   , 39.9   , 34.4   , 39     , 39.1   , 42.8   ,
         '3H00b', 57.2   , 50     , 54.3   , 61.4   , 53.1   , 63.8   , 52.6   , 38.9   , 58.3   , 57.8   , 65.9   , 53.5   , 53.4   , 63.8   , 60     , 58.1   , 61.2   , 55.4   , 68.8   , 72.1   , 59.5   , 33.1   , 61.9   , 53.4   , 41.5   , 75.5   , 62.1   , 59.8   , 53.6   , 64.9   , 65.1   , 70.3   , 65.6   , 62.8   , 69.3   , 67.4   , 62.4   ,
         '3H00c', 35.9   , 14.7   , 16.9   , 19.2   , 18.3   , 8.8    , 25.7   , 22.4   , 25.6   , 14.7   , 27.6   , 24.7   , 25.7   , 18     , 21.2   , 14.6   , 18.1   , 24.4   , 14.4   , 25.1   , 21.5   , 12.3   , 23.6   , 26.5   , 18.6   , 14.8   , 22.1   , 19.2   , 14.3   , 30     , 24.7   , 22.2   , 28.6   , 22.1   , 13.5   , 14.8   , 24.8   ,
         '3I11a', 57.2   , 61.2   , 60.7   , 55.3   , 50.1   , 65.2   , 60.4   , 62.7   , 60.5   , 57.5   , 61.4   , 61.8   , 61.5   , 58.5   , 58.7   , 65     , 61.8   , 64.1   , 65.7   , 63.1   , 64.1   , 65     , 68.2   , 68.5   , 65.6   , 68.2   , 70.1   , 74.3   , 72     , 71.7   , 68.3   , 64     , 61.6   , 72.2   , 73.7   , 68.3   , 68.4   ,
         '3I12a', 55.5   , 58.4   , 57.8   , 59.7   , 62.7   , 57.7   , 57.9   , 56.8   , 60.1   , 59.4   , 60.5   , 59.4   , 67     , 64.4   , 65.8   , 66     , 68.6   , 64.5   , 66.7   , 67.9   , 71.7   , 72.7   , 65     , 63     , 73     , 72.7   , 69.4   , 67.4   , 70.9   , 69     , 70.5   , 68     , 69     , 68.8   , 74.5   , 75.6   , 75.5   ,
         '3I10a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 39.8   , 12.2   , 26.5   , 54.6   , 62.1   , 47.6   , 43.2   , 49.1   , 37.8   , 42.4   , 47     , 51     , 47.7   , 32.8   , 37.7   , 32.5   ,
         '3I10b', 31.8   , 28.1   , 38.4   , 29.7   , 40.9   , 38.7   , 42.6   , 42.5   , 48.5   , 41     , 46.2   , 48     , 47.2   , 45.8   , 44.5   , 46.9   , 45     , 45.1   , 53.5   , 49.8   , 48.7   , 50     , 55     , 57.8   , 55.1   , 51.9   , 53.4   , 51.3   , 54.8   , 57.8   , 57.6   , 55.2   , 55.6   , 54.1   , 51     , 51.4   , 53.5   ,
         '4F10a', 33.4   , 28.8   , 33.4   , 33.1   , 40.1   , 41     , 39.6   , 40.6   , 41.5   , 42.4   , 35.6   , 39.8   , 44.4   , 45.6   , 41.2   , 42.9   , 41.9   , 49.7   , 46.7   , 42.9   , 42.5   , 44.6   , 42.1   , 36.9   , 41.1   , 49.2   , 50.1   , 46.4   , 45     , 48     , 49.1   , 46.4   , 51.3   , 51.8   , 54.6   , 51.3   , 52.5   ,
         '4F10b', 28.5   , 44.4   , 38.3   , 43.5   , 55.9   , 43.6   , 60.4   , 71.2   , 77.1   , 58.7   , 29.9   , 60.4   , 46.9   , 66     , 67.8   , 67.8   , 45     , 41.9   , 40.6   , 48.6   , 53.2   , 56.7   , 57.8   , 57.9   , 56.7   , 48.2   , 55.9   , 69.1   , 61.7   , 59.4   , 57.5   , 48.6   , 57.5   , 53.9   , 62.7   , 61.4   , 51.9   ,
         '4F21a', 38.4   , 29.4   , 34.1   , 28.5   , 26     , 31.3   , 31.9   , 29.4   , 23.6   , 26     , 34.8   , 39     , 40.7   , 36.4   , 33.1   , 35.9   , 36.6   , 38.1   , 34.8   , 39.1   , 34     , 39.6   , 31.8   , 30.7   , 32.8   , 37.8   , 37.7   , 25.6   , 41     , 33.8   , 29.5   , 31.3   , 36.2   , 38.4   , 26.9   , 35.5   , 36.9   ,
         '4F21b', 11.3   , 13.8   , 15.5   , 16.2   , 16     , 14.6   , 18.1   , 22.8   , 20.8   , 21.5   , 24.7   , 22.2   , 24.4   , 20.9   , 25.2   , 26.9   , 23     , 22.6   , 24.8   , 27     , 24.6   , 29.9   , 33.2   , 33.7   , 31     , 33     , 38.2   , 37.3   , 30.3   , 37     , 39.7   , 43.8   , 41.6   , 39     , 52.8   , 53.1   , 53.9   ,
         '4F21c', 32.9   , 36.3   , 32.6   , 36.8   , 31.5   , 24.3   , 29.5   , 29.3   , 24     , 28     , 30.1   , 30.7   , 23.2   , 24.7   , 20.1   , 27.1   , 28     , 33.2   , 33.2   , 32.7   , 33.1   , 32.5   , 47.3   , 41.3   , 31.6   , 33     , 35.6   , 39.3   , 32.6   , 38.2   , 38.6   , 39.4   , 49.7   , 52.2   , 39.4   , 45     , 48     ,
         '4F21d', 30.7   , 23.1   , 28.1   , 16.5   , 16.9   , 20.5   , 22.5   , 25.1   , 33.9   , 24.2   , 36.3   , 37.2   , 17     , 17.1   , 21.7   , 27.1   , 31.9   , 49.1   , 45.3   , 45     , 40.5   , 48.4   , 50.2   , 56.6   , 32.8   , 33.8   , 68.2   , 32.5   , 36.3   , 38.2   , 44.4   , 43.6   , 38.7   , 46.5   , 32.4   , 35.6   , 51.1   ,
         '4F21e', 52.1   , 46.8   , 49.5   , 49     , 46.2   , 48.9   , 48.7   , 52.8   , 57.7   , 56.3   , 60.9   , 68.7   , 56.8   , 64.6   , 65.4   , 59.9   , 64.2   , 63.9   , 62.8   , 65.4   , 61.5   , 75.5   , 64     , 66.8   , 66.7   , 68.2   , 70     , 71.5   , 71.2   , 57.8   , 68.4   , 73.9   , 58.3   , 39.9   , 62.4   , 60.6   , 60.1   ,
         '4F30a', 70.5   , 67.1   , 62.3   , 66.3   , 67     , 69.2   , 61.8   , 58.5   , 66.8   , 67.8   , 71.8   , 71     , 67.8   , 70.6   , 66.1   , 74.3   , 64.1   , 76.7   , 77.9   , 72.3   , 71.8   , 59     , 56.6   , 77.4   , 63.5   , 66.2   , 65.5   , 58.2   , 68     , 77.8   , 54.1   , 66.4   , 72.4   , 81.2   , 70.1   , 73.6   , 83.8   ,
         '4F30b', 100    , 100    , 95.4   , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 97.5   , 97.7   , 97.8   , 100    , 97.3   , 97.5   , 100    , 100    , 100    , 98.2   , 100    , 100    , 100    , 100    , 100    , 90.1   , 95.7   , 100    , 100    , 100    , 100    , 100    , 99.1   , 99.4   , 100    ,
         '4F30c', 87.9   , 89.5   , 88.6   , 84.7   , 84.1   , 86.5   , 87.4   , 90.1   , 89.5   , 88.2   , 93     , 79.3   , 84.6   , 87.9   , 76.7   , 84.4   , 88.1   , 92.2   , 86.9   , 86.3   , 85     , 85.1   , 88.6   , 84.3   , 78.1   , 74.8   , 77.5   , 81.7   , 79.9   , 74.1   , 74.2   , 71.8   , 71.3   , 76.5   , 76.4   , 66.7   , 70.4   ,
         '4F30d', 90.8   , 93     , 92.1   , 92.3   , 92.9   , 91.6   , 93.9   , 91.7   , 89.3   , 89.8   , 88.6   , 90.9   , 88.4   , 89.6   , 90.5   , 91     , 91.3   , 89.1   , 90     , 88.5   , 86.9   , 88.7   , 89.8   , 91.9   , 89.2   , 88.9   , 87.4   , 89.3   , 88.8   , 87.8   , 88     , 87.1   , 86.7   , 86.8   , 85.7   , 84     , 85.2   ,
         '4F42a', 60.6   , 59.1   , 57.2   , 56.9   , 55.5   , 56.2   , 58.3   , 57.2   , 53.7   , 53.3   , 55.8   , 58.2   , 57.6   , 59.1   , 62.2   , 58.5   , 65     , 63     , 64.7   , 65.3   , 64.2   , 62.2   , 62.5   , 57.7   , 57.9   , 59.7   , 71.6   , 69.1   , 66.3   , 63.1   , 64.2   , 63.3   , 69.6   , 68.7   , 69.2   , 69.9   , 64.3   ,
         '4F43a', 100    , 96.8   , 97.3   , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 99.5   , 99.5   , 100    , 100    , 100    , 100    , 97.6   , 92.7   , 96.5   , 99.2   , 98.3   , 100    , 98.1   , 96     , 99.5   , 100    ,
         '4F44a', 52.6   , 52.2   , 52.8   , 52.7   , 51.5   , 60     , 51.3   , 50.4   , 47.2   , 53.4   , 42.5   , 44     , 48.5   , 44.7   , 40.8   , 38.1   , 46.5   , 48.6   , 50     , 49.5   , 50     , 36     , 42     , 54.9   , 50.6   , 51.5   , 56.4   , 49.5   , 48.6   , 47.7   , 49.7   , 51.6   , 55.7   , 50.4   , 61.9   , 56.5   , 64.4   ,
         '4F44b', 61.8   , 68     , 68.4   , 68.6   , 65.7   , 63.5   , 71.9   , 66.5   , 64.9   , 73.1   , 74.5   , 76.7   , 82.1   , 76.4   , 76.1   , 70.7   , 73.2   , 76.6   , 69.4   , 71.6   , 68.4   , 82     , 79     , 76.1   , 81.7   , 82.5   , 81.4   , 74.6   , 76.8   , 83.1   , 75.9   , 80     , 80.8   , 76.3   , 74     , 75.6   , 78.3   ,
         '4F45a', 72     , 75.3   , 72.2   , 69.3   , 84.2   , 74.2   , 75.6   , 71.9   , 66.1   , 75.2   , 75.9   , 78.1   , 81.4   , 79.3   , 81.1   , 80.8   , 76.6   , 77.4   , 80.3   , 80.9   , 81.4   , 71.4   , 76.4   , 86.4   , 93.3   , 86.2   , 85.8   , 85.6   , 83.8   , 81.7   , 81.4   , 89.9   , 87.3   , 85.2   , 87.9   , 87.9   , 85.3   ,
         '4F45b', 63.2   , 65.4   , 79.6   , 53.3   , 49.4   , 50.2   , 52.3   , 58.6   , 47.5   , 55.3   , 48.2   , 63.8   , 63.7   , 58.5   , 65.7   , 66.6   , 70.3   , 67.6   , 65.9   , 71.2   , 84     , 76.7   , 78.4   , 71.3   , 77.8   , 70.8   , 68     , 85.8   , 84.8   , 76.7   , 77.2   , 83     , 82.1   , 84.6   , 89     , 100    , 81     ,
         '4I11a', 26.6   , 34.5   , 27.1   , 32.1   , 28.7   , 30.2   , 24.3   , 26     , 27.4   , 31.1   , 30.8   , 30     , 31.6   , 25.6   , 27     , 39.5   , 35.1   , 36.4   , 42.3   , 37.4   , 41.2   , 35.3   , 35.9   , 37     , 39.3   , 40.2   , 38     , 44.8   , 42.7   , 40.6   , 42.4   , 40.6   , 44.4   , 49.6   , 47.9   , 47.6   , 52.9   ,
         '4I12a', 21.8   , 27.8   , 21.6   , 29.9   , 27.7   , 35.5   , 28.8   , 27.7   , 30.9   , 37.5   , 39.8   , 35.4   , 37.4   , 37.7   , 34.4   , 41     , 38.1   , 37     , 31.7   , 35.1   , 42.5   , 32.7   , 35.6   , 43.6   , 36.1   , 31     , 34.5   , 43.1   , 39.1   , 42.4   , 40     , 41     , 42.2   , 42.6   , 36.5   , 34.1   , 29     ,
         '4I13a', 50.4   , 54.9   , 57.6   , 56.1   , 55.4   , 55.8   , 58.1   , 59.7   , 53.5   , 55.9   , 57     , 59.1   , 58.9   , 58.2   , 56.8   , 54.6   , 54.7   , 55.7   , 57.4   , 58.1   , 59.4   , 58.7   , 60     , 59     , 59.9   , 59.6   , 59.6   , 61.2   , 59.3   , 56.4   , 59.5   , 60.8   , 60.3   , 60.8   , 60.3   , 59.6   , 58.5   ,
         '4I13b', 67.7   , 62.9   , 62.3   , 59.2   , 59.4   , 59     , 61.2   , 58.3   , 58.2   , 58     , 61.5   , 61     , 63.7   , 65.3   , 66     , 65     , 65.5   , 59.6   , 64.3   , 62.4   , 61.4   , 60.6   , 62.7   , 67.2   , 65.2   , 70.2   , 70.8   , 64.4   , 64.8   , 65.2   , 68.7   , 65     , 63.6   , 62.8   , 63.7   , 59.1   , 60.2   ,
         '4I13c', 50.5   , 47.7   , 46.2   , 47.8   , 47     , 40.1   , 44.6   , 46.9   , 47     , 49.4   , 46.7   , 45.9   , 46     , 45.5   , 50.1   , 51.8   , 53.9   , 46.5   , 43.9   , 46.9   , 49.2   , 53.7   , 55.5   , 51.5   , 53.7   , 60.4   , 54     , 48.3   , 50.1   , 53.9   , 49.3   , 49.8   , 46.5   , 47.4   , 50.3   , 49.9   , 54.2   ,
         '4I13d', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 65.9   , 70.6   , 59.2   , 65     , 61.4   , 63.8   , 60.8   , 63     , 62.2   , 73.4   , 74.4   , 69.3   , 59.4   , 65.5   , 73     , 63.9   ,
         '4I14a', 72.9   , 76.3   , 75.4   , 74.5   , 72.5   , 73.3   , 73.2   , 74.8   , 74.7   , 75.8   , 75.3   , 76.5   , 77.3   , 77.6   , 78.4   , 79     , 77.1   , 79.1   , 79.4   , 79.9   , 78.5   , 80.2   , 80.7   , 80.2   , 82.5   , 78.9   , 79.1   , 79.9   , 80.9   , 80.8   , 80.9   , 82.2   , 83.4   , 84.8   , 84.1   , 82.3   , 84     ,
         '4I21a', 59.4   , 59.1   , 62.2   , 57.1   , 54.1   , 54.3   , 56.2   , 56.2   , 58.4   , 58.5   , 58.9   , 57.7   , 59.3   , 63.5   , 64.5   , 63.4   , 67.1   , 64.5   , 63     , 65.3   , 66.6   , 59.4   , 64.5   , 71.4   , 65.6   , 71.1   , 68.6   , 73.4   , 66.1   , 66.1   , 69     , 65.7   , 73.7   , 71     , 71.5   , 68.9   , 70.7   ,
         '4I21b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 82.7   , 63.8   , 63.8   , 73.2   , 70.6   , 80.2   , 70.5   , 67.9   , 62.5   , 58.9   , 70.1   , 67     , 66.7   , 67.4   , 68.4   , 63.9   ,
         '4I21c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 37.5   , 31.1   , 31     , 24.8   , 27.7   , 44.4   , 19.1   , 25.3   , 35.9   , 30.9   , 31.1   , 34.7   , 45.1   , 30.4   , 27.8   , 47.5   ,
         '4I21d', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 89.3   , 92.5   , 94.4   , 100    , 100    , 99.2   , 93.7   , 86.2   , 90.9   , 89.8   , 91     , 86.5   , 90.5   , 96.5   , 97.3   , 95     ,
         '4I22a', 97.4   , 98.1   , 95.2   , 94.9   , 97.2   , 97.3   , 95.9   , 96.2   , 95.6   , 95.7   , 94.7   , 92.7   , 96.1   , 94.5   , 96.3   , 94.3   , 93.9   , 95.1   , 95.6   , 92.5   , 92.6   , 95.9   , 91.2   , 90.8   , 93.2   , 93.5   , 94.4   , 91.4   , 93.4   , 89     , 87.4   , 84.4   , 89.9   , 90     , 94.4   , 94.2   , 93.4   ,
         '4I23a', 76.8   , 100    , 94.8   , 82.2   , 81.5   , 86     , 85.2   , 80.7   , 89.4   , 90.1   , 90.3   , 74.3   , 90     , 95.3   , 87.6   , 91.3   , 95.4   , 88.4   , 81.7   , 81.7   , 79.1   , 82.8   , 84.1   , 89.2   , 94.1   , 95.6   , 87.1   , 87.2   , 91.1   , 96.3   , 92.2   , 88.7   , 94.2   , 95.3   , 90.8   , 95     , 85.7   ,
         '4I32a', 14.7   , 18.9   , 27.2   , 32.6   , 27.8   , 26.9   , 20.9   , 24.2   , 24.9   , 26.2   , 19     , 23.5   , 24.1   , 25     , 28.3   , 29.9   , 30.5   , 33.4   , 35.3   , 37.4   , 34     , 28.8   , 38.7   , 34     , 34.4   , 38     , 33.4   , 32.1   , 33.1   , 36.8   , 35.9   , 36     , 38.3   , 40.9   , 37.6   , 37.2   , 35.3   ,
         '4I33a', 3.3    , 7.4    , 6.4    , 7.9    , 2.5    , 6.3    , 3.3    , 10.3   , 1.3    , 1.8    , 4.5    , 8.8    , 9.2    , 7.4    , 5.1    , 10.9   , 6.4    , 15.1   , 18.9   , 20     , 11.5   , 11.4   , 18     , 13.3   , 14.5   , 9.8    , 0      , 4.6    , 16     , 11.2   , 8      , 12.8   , 12.3   , 16.1   , 20.4   , 17.9   , 25     ,
         '4J11a', 32.2   , 46.1   , 51     , 35.6   , 38.1   , 38     , 42.1   , 39.4   , 49.9   , 32.8   , 55.5   , 38     , 37.4   , 38.8   , 31.1   , 33.4   , 26.4   , 28.5   , 41.6   , 46.1   , 41.5   , 38.9   , 38.8   , 39.2   , 30.4   , 18.9   , 30.5   , 30.2   , 31.3   , 35.2   , 41.4   , 37.1   , 35.6   , 40.1   , 47.6   , 37.2   , 27.6   ,
         '4J11b', 26.9   , 27.5   , 33.3   , 14     , 29.5   , 35.2   , 44.5   , 43.8   , 37.7   , 33     , 29.4   , 19.3   , 34.1   , 23.3   , 40.3   , 35.2   , 27.1   , 29.6   , 38.8   , 34.2   , 43     , 34.1   , 41.2   , 39.3   , 43.6   , 44.4   , 40.4   , 34.5   , 47     , 44.9   , 47.2   , 40.4   , 42.6   , 43.9   , 42.6   , 40.9   , 42     ,
         '4J11c', 35     , 34.3   , 27.7   , 27.8   , 23.9   , 23.3   , 24.7   , 33.4   , 27.5   , 27.9   , 22.6   , 17.2   , 19.1   , 14.6   , 25.8   , 26.6   , 23     , 26.1   , 30.4   , 22.8   , 25.7   , 25.1   , 28.1   , 18.3   , 17.5   , 19.6   , 22.7   , 16.6   , 13.6   , 24.2   , 26     , 21.4   , 27.7   , 30     , 28.4   , 21.2   , 26.6   ,
         '4J11d', 37.6   , 49.4   , 33.4   , 41     , 43.5   , 24     , 38.4   , 50.3   , 48     , 39.8   , 40.6   , 59.2   , 58.1   , 37     , 48.8   , 53.1   , 43.1   , 55.3   , 36.6   , 55.6   , 52.8   , 53.7   , 56     , 44.4   , 34.5   , 34     , 40.9   , 49.4   , 43.7   , 49.1   , 54.3   , 45.8   , 33.4   , 44.8   , 47     , 42.2   , 54.7   ,
         '4J12a', 41.7   , 30     , 19.6   , 13.1   , 20.7   , 13.9   , 12.7   , 29.4   , 23.3   , 22.4   , 25.8   , 36.7   , 17.1   , 33.3   , 26.9   , 23.6   , 19.8   , 20     , 30.9   , 38.9   , 29.8   , 28.7   , 47.8   , 34.3   , 34.7   , 26.8   , 36.3   , 48     , 22     , 19.7   , 27.1   , 30.3   , 23.7   , 21.9   , 26     , 20.2   , 21.7   ,
         '4J13a', 54.9   , 65.5   , 58.7   , 58.5   , 59.6   , 60.9   , 63.5   , 61.7   , 67.9   , 61.9   , 65     , 59.9   , 58.2   , 63.8   , 55.5   , 60.1   , 55.1   , 60.6   , 60.7   , 57.2   , 59.3   , 59.6   , 54.8   , 57.6   , 51.9   , 60.5   , 60.7   , 51.5   , 40.2   , 51.8   , 60.7   , 59     , 56.4   , 54.3   , 56.1   , 53.6   , 59     ,
         '4J21a', 39     , 35.9   , 39.6   , 36.1   , 33.7   , 36.1   , 38.6   , 40.7   , 31.5   , 47.2   , 43.8   , 34     , 30     , 30.4   , 36.8   , 42.4   , 44.7   , 51.6   , 48.7   , 54.2   , 52.2   , 44.4   , 40.1   , 45.3   , 49.3   , 52.6   , 52.2   , 51.9   , 49.9   , 47.3   , 50.9   , 52.5   , 53.1   , 54     , 55.2   , 58.3   , 50.7   ,
         '4J21b', 13.3   , 5.6    , 4.5    , 0      , 9.9    , 0      , 3.8    , 5.5    , 8.7    , 18.1   , 20.5   , 7.9    , 9.8    , 18.1   , 18.9   , 17.5   , 20.8   , 35.9   , 47.5   , 29.1   , 22.9   , 30     , 30.7   , 45.1   , 54.2   , 57.4   , 42.6   , 33.6   , 40     , 49.5   , 62.5   , 40.8   , 42.5   , 54.5   , 59.7   , 50.6   , 48.5   ,
         '4J21c', 0      , 4      , 6.5    , 7.9    , 3.5    , 7.2    , 5.1    , 7.1    , 8.3    , 7.2    , 13.4   , 10.1   , 10.7   , 9.6    , 10.7   , 9.4    , 6.4    , 5      , 3.6    , 3.4    , 8.3    , 22.9   , 19     , 15     , 16.5   , 14.7   , 14.2   , 27.6   , 20     , 12.6   , 23.7   , 27.8   , 23.5   , 23.2   , 20.1   , 21.8   , 30.9   ,
         '4J22a', 35.5   , 32.5   , 38.6   , 36.4   , 47.6   , 39.5   , 37.8   , 36.9   , 44.4   , 43.8   , 36.5   , 32.9   , 36.9   , 41.3   , 46.4   , 36.1   , 42.5   , 45     , 46.7   , 44.6   , 48.9   , 41     , 49.6   , 54     , 56.6   , 51.9   , 54.2   , 64.2   , 51.4   , 42.3   , 45     , 48.5   , 46.4   , 53.6   , 58     , 49.8   , 48.3   ,
         '4J24a', 5.6    , 7.6    , 12.9   , 17.6   , 17.7   , 31.9   , 33.1   , 5.7    , 31.1   , 18.5   , 6.8    , 27.8   , 24.9   , 21.6   , 29.3   , 18.6   , 18.2   , 17.7   , 29.8   , 26.9   , 19.4   , 41.5   , 8.7    , 9.2    , 19     , 18.8   , 27.3   , 45.3   , 29.1   , 28.2   , 24.6   , 21.8   , 28.8   , 35.1   , 32.5   , 32.5   , 24.9   ,
         '4J25a', 15     , 15.3   , 26.3   , 24.1   , 43.8   , 26.7   , 14.8   , 22.3   , 29.4   , 21.7   , 26.3   , 12.3   , 9.6    , 15.4   , 35.7   , 52.3   , 48.2   , 30.1   , 24.5   , 34.4   , 40.4   , 26.6   , 7.2    , 4.5    , 29.3   , 20.9   , 51.9   , 58     , 51.3   , 46.6   , 57.9   , 55.3   , 61.3   , 57.2   , 50.8   , 62.2   , 67.2   ,
         '4J25b', 90     , 95.3   , 95.1   , 97.8   , 98.2   , 98     , 92.4   , 100    , 98.4   , 92.8   , 91.7   , 98     , 97     , 100    , 100    , 95.5   , 90.5   , 89.9   , 93.4   , 95.9   , 93.6   , 95.3   , 97.4   , 100    , 97.9   , 92.2   , 100    , 100    , 100    , 100    , 100    , 100    , NA, NA, 100    , 100    , 100    ,
         '5B11a', 56.1   , 61     , 68.8   , 65     , 62.2   , 58.8   , 53.9   , 56.3   , 51.8   , 55.8   , 49.9   , 40.6   , 44.2   , 41.2   , 49     , 43.6   , 50.4   , 55.8   , 42.5   , 45.4   , 41.8   , 59.3   , 59.8   , 60.4   , 60     , 60.9   , 57.5   , 51.6   , 58.2   , 52.7   , 56.3   , 60.7   , 53.3   , 65.3   , 68.2   , 61.1   , 57.3   ,
         '5B11b', 55.9   , 43.5   , 44     , 44.7   , 44.6   , 37     , 31.8   , 35.1   , 31.3   , 33.6   , 36.1   , 36.3   , 39.1   , 39     , 27.7   , 25.1   , 21.1   , 18     , 32.6   , 27.7   , 30.1   , 36.4   , 37.9   , 34.7   , 36.2   , 33.9   , 31.5   , 35.7   , 35.5   , 31.5   , 27.4   , 32.1   , 29.4   , 31     , 37.4   , 35     , 33.2   ,
         '5B11c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 73     , 73.6   , 82.3   , 86     , 84.2   , 82.4   , 79.2   , 71.1   , 72.1   , 77.4   , 68     , 84.2   , 74     , 72.4   , 77.8   , 77.7   ,
         '5B11d', 86     , 88.2   , 85.7   , 87     , 88     , 87.5   , 86.9   , 87.4   , 89.9   , 89.1   , 85.8   , 83     , 84.7   , 81     , 83.5   , 84.5   , 83.4   , 80.8   , 81.8   , 78.7   , 82.9   , 80.5   , 83.8   , 82.6   , 78.8   , 83.4   , 84.5   , 83     , 85.1   , 80.7   , 83.8   , 82.5   , 82.5   , 83.1   , 83.1   , 81.4   , 80.7   ,
         '5B11e', 88.6   , 85.7   , 83.4   , 86.3   , 87.8   , 87.9   , 81.8   , 89.5   , 88.5   , 91.9   , 88.8   , 87.8   , 85.8   , 84.6   , 84.5   , 82.4   , 77.5   , 84.8   , 83.7   , 83.1   , 81     , 89     , 83.5   , 79.6   , 80.7   , 88.5   , 88.6   , 92.1   , 90.3   , 85.2   , 85.2   , 88.2   , 82.7   , 63.5   , 78.6   , 81     , 81.7   ,
         '5B11f', 74.6   , 75.8   , 77     , 72.5   , 66.9   , 71     , 73.3   , 69.6   , 69.2   , 75.7   , 82.3   , 73.5   , 62.8   , 61.3   , 74.5   , 69     , 66.6   , 70.2   , 66.5   , 63.8   , 56.9   , 63.1   , 60.5   , 68.5   , 68.2   , 64     , 68.1   , 70.1   , 74.1   , 73.8   , 66.7   , 71.1   , 76.8   , 66.6   , 61.9   , 64.1   , 76.9   ,
         '5B11g', 32     , 42.8   , 35.1   , 34.3   , 36.8   , 35.3   , 37.6   , 42.9   , 42.8   , 42.1   , 44.4   , 37.2   , 46.7   , 46.7   , 50.9   , 49.1   , 48.1   , 45.3   , 46.8   , 46.2   , 42.4   , 56.5   , 56.8   , 63.2   , 69.2   , 73.3   , 67.4   , 69.8   , 74.7   , 67.9   , 64.3   , 67.4   , 71.7   , 74.1   , 72     , 66     , 67.8   ,
         '5B12a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 74.9   , 71.8   , 79.4   , 80.1   , 77.4   , 75.7   , 75.8   , 72.9   , 70.6   , 71.7   , 69.8   , 67.8   , 68.5   , 69.8   , 63.6   , 68.6   ,
         '5B12b', 82.2   , 81.4   , 82.3   , 84.8   , 82.8   , 83     , 83.2   , 81.4   , 84.2   , 83.5   , 85.4   , 80     , 81.2   , 79     , 80.4   , 79.9   , 79.1   , 77.2   , 77.8   , 78.5   , 77.5   , 80.9   , 78     , 87.2   , 79.6   , 79.5   , 85     , 84.3   , 80.3   , 79.6   , 80.8   , 77.5   , 77.9   , 79.8   , 80.1   , 76.8   , 74.7   ,
         '5B12c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 72     , 83.1   , 78.9   , 73.9   , 73.3   , 67     , 67.5   , 73.2   , 75.2   , 67     , 63.9   , 61.8   , 63.7   , 48.3   , 71.4   , 69.6   ,
         '5B12d', 27.7   , 29.9   , 23.8   , 40.2   , 28.4   , 19     , 19.4   , 29.7   , 34.7   , 41     , 36.1   , 43.1   , 34.8   , 33.3   , 34.6   , 36.5   , 41.4   , 52.2   , 42.1   , 41.8   , 46.2   , 47.9   , 69.7   , 53.2   , 43     , 47.4   , 66.1   , 59.6   , 46     , 41.7   , 51     , 55.9   , 48     , 38.3   , 33.1   , 34.9   , 60.8   ,
         '5B12e', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 72.6   , 79.2   , 79.3   , 81.8   , 75     , 74.9   , 77.8   , 70.8   , 78.8   , 79.7   , 73.9   , 78.6   , 78.8   , 76.5   , 70.2   , 69.6   ,
         '5B13a', 82.7   , 78.3   , 80.7   , 80.3   , 80.7   , 72.9   , 73.5   , 78.4   , 73.6   , 77.5   , 73.4   , 69.8   , 70.4   , 72.1   , 72.9   , 71.6   , 69.7   , 60.9   , 66.8   , 69.7   , 70.3   , 59.3   , 64.4   , 65.1   , 62.5   , 70.5   , 62.6   , 60     , 59.8   , 57.8   , 53.2   , 51.7   , 61.6   , 66.2   , 59.2   , 52.9   , 55.9   ,
         '5B13b', 94.9   , 93.7   , 95.8   , 95.4   , 95.2   , 95.4   , 95.5   , 94.4   , 93     , 92.5   , 94.2   , 95.5   , 93.6   , 93.2   , 96.2   , 94.7   , 93     , 93.2   , 92.2   , 92.4   , 93.4   , 93.6   , 94.8   , 94.8   , 94.3   , 92     , 93.1   , 92.9   , 92.3   , 89.1   , 92.3   , 94     , 91.7   , 89.2   , 86.3   , 87.9   , 90     ,
         '5B22a', 53.1   , 57.8   , 56.4   , 53.4   , 57.8   , 56.8   , 52.5   , 53     , 53.5   , 53.6   , 56.1   , 53.8   , 52.7   , 53.4   , 46.1   , 46.8   , 43.2   , 45     , 44.7   , 37.4   , 42.1   , 47.1   , 40.1   , 42.4   , 43.2   , 58.9   , 61.4   , 48     , 36.1   , 43.9   , 39.1   , 41.6   , 38.8   , 41.3   , 45.6   , 47.6   , 40.5   ,
         '5B22b', 42.6   , 42.2   , 48.2   , 45.8   , 43     , 48.9   , 41.9   , 46     , 42.9   , 47.5   , 35.1   , 34.8   , 36.1   , 40.4   , 33.1   , 46.8   , 32     , 35.4   , 35.7   , 38.9   , 27.4   , 30.9   , 29     , 30.7   , 35.8   , 33.6   , 43     , 48     , 32.7   , 34.8   , 43.9   , 42.5   , 37.4   , 33.5   , 45     , 54.8   , 31.9   ,
         '5B22c', 46.1   , 50     , 50.4   , 45.3   , 43.8   , 44.7   , 44.9   , 47.5   , 44.6   , 46.3   , 46.5   , 35.2   , 38     , 38.6   , 46.2   , 44.6   , 29.8   , 27.6   , 33.5   , 26.4   , 37     , 29.6   , 46.3   , 41.8   , 13     , 10.7   , 29.4   , 18.9   , 24.9   , 31.1   , 18.3   , 21.6   , 29.2   , 24.6   , 27.7   , 20.7   , 28.2   ,
         '5B22d', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 82.4   , 81.5   , 63     , 49.6   , 60.9   , 51.6   , 62.5   , 71.8   , 74     , 65.7   , 63.8   , 79.7   , 78.2   , 62.8   , 66.7   , 72.8   ,
         '5B22e', 63.5   , 62.6   , 61.8   , 64.8   , 63.6   , 64.7   , 62.9   , 61.1   , 61.2   , 62.6   , 62.6   , 60.5   , 54.7   , 58.5   , 56.8   , 65.9   , 61.4   , 50.5   , 62     , 65.1   , 70.2   , 56.4   , 54.5   , 51.9   , 51.9   , 51.2   , 59.3   , 58.1   , 50.6   , 54.5   , 51.8   , 53.4   , 50.4   , 54.7   , 50.4   , 44.2   , 50.7   ,
         '5B22f', 51.7   , 57     , 57.3   , 64     , 56.8   , 62.4   , 56.1   , 55.8   , 51.4   , 63.6   , 57.5   , 54.9   , 54.5   , 56.2   , 57.4   , 60.2   , 52.6   , 51.7   , 57.9   , 62.5   , 56.4   , 65.6   , 42.5   , 41.3   , 55.5   , 55.3   , 61.1   , 45.4   , 46.2   , 66.4   , 68.7   , 49.7   , 58.6   , 62.7   , 71.6   , 67.4   , 52     ,
         '5B22g', 50     , 54     , 52.5   , 46.9   , 50.6   , 46.6   , 40.5   , 52.4   , 48.9   , 57.3   , 54.6   , 52.3   , 51.7   , 52.1   , 47.1   , 37.9   , 38.6   , 39.9   , 42.2   , 48.3   , 36.2   , 43.4   , 47.2   , 55.2   , 45.4   , 41.2   , 53.7   , 45.6   , 51.7   , 45.1   , 28.2   , 32     , 32.3   , 20.3   , 32.5   , 50.1   , 33     ,
         '5B22h', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 52.4   , 54.9   , 51.1   , 53.3   , 58.2   , 54.1   , 40.9   , 35.9   , 39.3   , 42.2   , 30.5   , 40.4   , 45.1   , 60.7   , 44.3   , 26.6   ,
         '5B22i', 39.5   , 39.4   , 42.9   , 44.5   , 42.2   , 34.4   , 46     , 42.5   , 36.8   , 37.1   , 48.1   , 42.9   , 43.7   , 16.4   , 0      , 50     , 41.2   , 47.3   , 63.4   , 58.2   , 41.2   , 43.1   , 19.2   , 0      , 30.5   , 50.8   , 69.9   , 49.4   , 70.1   , 24.3   , 21     , 29.8   , 31.2   , 53.3   , 77.7   , 68.7   , 19.7   ,
         '5C01a', 68.2   , 68.8   , 71.6   , 79     , 82.3   , 80.3   , 82     , 75.1   , 71     , 72.4   , 73.3   , 73.6   , 74.6   , 74.2   , 74.2   , 74.5   , 72.6   , 70.9   , 64.8   , 66.3   , 63.5   , 77.9   , 76.8   , 71.1   , 68     , 73.5   , 68.8   , 70.4   , 64.9   , 70.1   , 64.1   , 61.3   , 65.8   , 72.6   , 78.6   , 64.8   , 76.9   ,
         '5C02a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 67.8   , 65.9   , 65.6   , 62     , 69.6   , 73.4   , 71.3   , 70.1   , 74.3   , 72.8   , 75.8   , 73.9   , 68.6   , 71.1   , 72.2   , 67.4   ,
         '5C03a', 52.5   , 53.1   , 54     , 56.6   , 57.6   , 57     , 60.4   , 59     , 60.6   , 60.8   , 58.8   , 58.3   , 63.5   , 60.9   , 62.4   , 59.8   , 61.9   , 64.6   , 65.1   , 65.3   , 63.7   , 71.8   , 77.1   , 65.9   , 74.3   , 78.8   , 76.2   , 67     , 68.8   , 73.3   , 80.7   , 73.7   , 82.2   , 80.6   , 76.6   , 71.9   , 70.6   ,
         '5C03b', 73     , 73.1   , 74.1   , 77.4   , 77.4   , 76.8   , 80.2   , 77.4   , 81.2   , 80.4   , 80.7   , 78.7   , 80.7   , 82.1   , 80.1   , 78.8   , 78.3   , 77.6   , 79.7   , 79.3   , 77.1   , 77.4   , 81.7   , 79.7   , 83.4   , 89.8   , 86.8   , 82.2   , 79     , 79.2   , 83.9   , 87.4   , 85.5   , 85.4   , 81.6   , 84.7   , 84.3   ,
         '5D01a', 82.8   , 82.7   , 82.5   , 84.2   , 84.5   , 83     , 84.2   , 82     , 85.3   , 83.1   , 82.2   , 84     , 83     , 84.3   , 83.6   , 82.7   , 82.5   , 82.4   , 81.2   , 80.8   , 81.6   , 82.8   , 80.4   , 80.7   , 82.1   , 82.5   , 81.3   , 80.2   , 77.9   , 79.8   , 80.9   , 82.7   , 82.3   , 82.9   , 82.7   , 82.6   , 82.8   ,
         '5D01b', 86.4   , 81.8   , 85.6   , 83.1   , 80.7   , 82.2   , 83.9   , 88.2   , 89.6   , 90.2   , 85.3   , 88.7   , 86.9   , 84.3   , 83.6   , 81.2   , 84.1   , 85.9   , 84.3   , 82.7   , 86.5   , 83.6   , 75.1   , 80.5   , 75.7   , 73.9   , 74.7   , 68.1   , 79.5   , 74.1   , 59     , 57.5   , 65.5   , 82.6   , 69.6   , 61.3   , 66.1   ,
         '5D02a', 91     , 94.4   , 93     , 92.3   , 95.9   , 91.2   , 92.4   , 92.1   , 95.4   , 90.3   , 90.7   , 92.8   , 87.5   , 91.7   , 90     , 91.2   , 88.3   , 87.4   , 86.3   , 89.5   , 87.8   , 89.4   , 91.9   , 93.6   , 92.9   , 88.7   , 86.5   , 89.2   , 77.9   , 89.1   , 93.5   , 84.5   , 79.5   , 92.3   , 82.3   , 75.4   , 72.7   ,
         '5D02b', 91.5   , 92.6   , 93.5   , 92.4   , 93.8   , 92.3   , 92.6   , 90.3   , 93.1   , 91.4   , 86.3   , 87.8   , 83     , 84.7   , 93.8   , 87.5   , 90     , 83.6   , 85.7   , 85     , 85.8   , 69.3   , 63.8   , 59.6   , 70.7   , 56.8   , 40.6   , 45.7   , 63.7   , 50.9   , 44.1   , 36.1   , 44.3   , 58.8   , 45.5   , 46.3   , 40.1   ,
         '5D03a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 79.2   , 75.7   , 71.7   , 83.3   , 79.3   , 74     , 83.1   , 85.9   , 82.4   , 81.9   , 83     , 85.9   , 87.3   , 85.5   , 88.6   , 87.7   ,
         '5D04a', 40.6   , 38.1   , 39     , 41.4   , 42.3   , 43.4   , 42.4   , 39.8   , 38.5   , 38.2   , 43.1   , 46.2   , 45.7   , 48.3   , 45.3   , 46.7   , 48.4   , 46     , 47.1   , 45.4   , 45.1   , 54     , 59.2   , 58.8   , 53.5   , 56.4   , 57.9   , 50.7   , 54.7   , 51.4   , 53.5   , 52.3   , 54.2   , 53.2   , 52.8   , 54.4   , 58.1   ,
         '5D05a', 72.4   , 80     , 79.9   , 85.9   , 85.2   , 81.1   , 80     , 90.8   , 85.3   , 90.8   , 92.8   , 87.7   , 88.1   , 90.3   , 91.3   , 93.3   , 92     , 85.7   , 85.6   , 84.8   , 86     , 88.7   , 94.5   , 90.7   , 91.5   , 91.3   , 91.3   , 88     , 88.5   , 84.2   , 86.3   , 83.7   , 84.4   , 86.9   , 89.2   , 89.7   , 88.5   ,
         '5D05b', 0      , 0      , 0      , 4.3    , 8.4    , 6.5    , 6.1    , 11.4   , 19.1   , 13.7   , 0      , 16.4   , 4.7    , 3.4    , 4.5    , 3.6    , 12.7   , 16.3   , 21     , 15.8   , 25.6   , 39     , 37.7   , 6.2    , 21.7   , 35.5   , 32.4   , 39.1   , 31.4   , 41.3   , 32.5   , 12.5   , 9      , 35     , 34.8   , 49.2   , 35.6   ,
         '5D05c', 27.8   , 34.8   , 45.3   , 48.3   , 45.6   , 43.1   , 44.6   , 47.5   , 45.2   , 55.9   , 62.5   , 67     , 63     , 62.2   , 62.7   , 67.6   , 59.1   , 52.2   , 53.8   , 58.6   , 57.7   , 59.8   , 69.5   , 69.7   , 69.4   , 79     , 77.4   , 67.7   , 66.6   , 67.2   , 66.5   , 68.1   , 69.7   , 66.1   , 64.4   , 59.7   , 68.5   ,
         '5D05d', 60.1   , 54     , 51.8   , 58.1   , 67.9   , 72     , 62.5   , 69.2   , 62.7   , 82.1   , 74.4   , 55.3   , 59.8   , 63.5   , 68     , 64.1   , 78.3   , 68     , 58.6   , 68.8   , 63.6   , 73.9   , 69.3   , 68.3   , 79.7   , 58.4   , 57.4   , 63.1   , 72.9   , 75.5   , 54.1   , 52.8   , 70     , 76.9   , 63.5   , 57.6   , 60.5   ,
         '5D06a', 96.3   , 96.4   , 96.3   , 96.9   , 97.3   , 96.7   , 96.8   , 95.7   , 97.5   , 98.1   , 97.9   , 98.1   , 97.5   , 97.1   , 97.2   , 98     , 97.6   , 97.1   , 97.5   , 97.5   , 97.2   , 98.7   , 98.6   , 98.9   , 99.1   , 98.8   , 99     , 98.9   , 98.6   , 98.4   , 98.4   , 98.3   , 99.1   , 98.6   , 98.4   , 98     , 98     ,
         '5D07a', 75.7   , 78.8   , 79.3   , 81.8   , 83     , 81.5   , 82     , 81     , 81.4   , 82.2   , 82.9   , 83.7   , 84.1   , 83.6   , 82.9   , 82.2   , 82.3   , 81.6   , 82.2   , 80.9   , 80.2   , 85.5   , 87.5   , 87.3   , 86     , 85.8   , 85.4   , 84     , 83.7   , 85.8   , 85.3   , 83.3   , 82.7   , 83.9   , 85.9   , 83.8   , 83.2   ,
         '5D08a', 69.3   , 69.3   , 69.7   , 70.6   , 71.3   , 70.9   , 69.8   , 72.3   , 71.5   , 72.7   , 73.6   , 73.9   , 71.4   , 68.3   , 66     , 66.4   , 69.7   , 71.4   , 73.9   , 72.1   , 70.5   , 73.5   , 76.5   , 73.7   , 77.4   , 74.6   , 70.7   , 72.7   , 72     , 75.6   , 76.3   , 75.3   , 75.7   , 73.4   , 75.3   , 73.6   , 79.3   ,
         '5D08b', 71.9   , 69.7   , 67.5   , 76.6   , 58     , 59.2   , 67.2   , 59.5   , 53.3   , 53     , 43.2   , 43.2   , 34.9   , 38.3   , 32.1   , 38.1   , 36.7   , 39.6   , 39     , 37.5   , 27.1   , 64.5   , 63.3   , 59.8   , 67.3   , 65.9   , 50.7   , 53.3   , 58     , 55.3   , 52.9   , 48.7   , 39.2   , 38.5   , 41.3   , 43.3   , 38     ,
         '5D08c', 38.1   , 35.4   , 33.3   , 34.6   , 27.7   , 40.1   , 41     , 30.4   , 57.3   , 53.8   , 41.4   , 45.1   , 54.3   , 60.5   , 64.2   , 58.9   , 50.5   , 42.4   , 49.1   , 56     , 64.7   , 60.8   , 48.7   , 46.3   , 44     , 44.3   , 48.3   , 42.8   , 41.3   , 54.7   , 50.8   , 48.3   , 54.2   , 55.9   , 54.2   , 50     , 53.4   ,
         '5F01a', 90.1   , 89.5   , 90.3   , 90.7   , 92.4   , 91.9   , 92.5   , 92.5   , 91.7   , 92.8   , 93.3   , 91.9   , 93.6   , 92     , 92.5   , 90.8   , 90.8   , 90.9   , 91.2   , 92.3   , 91.3   , 88.7   , 90.5   , 90.6   , 91.8   , 90.5   , 89.9   , 88.3   , 88.9   , 89.1   , 89.7   , 92.1   , 89.6   , 89.8   , 88.4   , 89     , 89.1   ,
         '5F02a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 99.9   , 99.7   , 100    , 100    , 100    , 100    , 99.1   , 98.1   , 98.8   , 98.6   , 96.9   , 98.3   , 99.7   , 99.2   , 99.6   , 99.4   ,
         '5F03a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 76     , 74.4   , 86     , 89.5   , 84.8   , 78.3   , 83.9   , 83.6   , 85.5   , 86.1   , 89.5   , 82.4   , 85.3   , 86.6   , 85.2   , 89.5   ,
         '5F04a', 17.5   , 25.2   , 20     , 25.9   , 28.2   , 31.2   , 33.4   , 25.5   , 23.4   , 35.4   , 46.1   , 45.9   , 38.6   , 21.3   , 23.6   , 27.3   , 27.9   , 27.9   , 31.3   , 31     , 35.5   , 36.7   , 25.4   , 27     , 27.8   , 30.9   , 31.1   , 34.8   , 32.8   , 24     , 36.1   , 37.6   , 29.8   , 21.3   , 32.6   , 29.9   , 25.6   ,
         '5F05a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 95.4   , 92.9   , 87.5   , 89.4   , 97.7   , 93.2   , 93     , 94.4   , 92.9   , 88.6   , 86.2   , 93     , 98.3   , 94     , 92     , 94     ,
         '5G10a', 4.5    , 3.9    , 3.5    , 3      , 5.1    , 3.7    , 6.3    , 5.3    , 4.3    , 4.7    , 5      , 7.1    , 8.1    , 6.7    , 4.9    , 8.8    , 10.1   , 10.6   , 10.6   , 15.3   , 17.3   , 18.3   , 16.6   , 16.2   , 13.2   , 23     , 24.6   , 22.4   , 20.2   , 23.4   , 20.2   , 18.6   , 23.3   , 23.3   , 20.4   , 17.9   , 20.5   ,
         '5G21a', 4.4    , 2.7    , 2.1    , 4.1    , 4.7    , 5.4    , 5.5    , 5.5    , 10.4   , 10.9   , 16.1   , 7.8    , 6.2    , 7.4    , 5.5    , 4.7    , 4.1    , 7.4    , 10     , 10.5   , 9.5    , 7.1    , 5.6    , 8.2    , 7.9    , 6.8    , 8      , 6.4    , 6      , 8.4    , 6.9    , 7.1    , 8.8    , 7.1    , 14.4   , 12.7   , 6.2    ,
         '5G22a', 0      , 0      , 0      , 0      , 0      , 2.3    , 2.8    , 3.5    , 2.9    , 2.8    , 2      , 2.2    , 3.1    , 1.7    , 2.6    , 2.4    , 1.9    , 5.6    , 4.4    , 4.4    , 6.4    , 8.7    , 7.6    , 14.5   , 12.9   , 15.2   , 12.7   , 5.5    , 20.4   , 20.3   , 15.5   , 17.9   , 16     , 15.9   , 18.2   , 17.9   , 22.2   ,
         '5G23a', 5.6    , 10.2   , 14.2   , 11.8   , 12.8   , 14.9   , 14.7   , 15.6   , 16.5   , 15     , 14.7   , 12.4   , 8      , 8.6    , 13.8   , 10.3   , 11.4   , 13.7   , 15.9   , 16.4   , 10     , 14.1   , 11.8   , 16.8   , 16.5   , 17.7   , 22.8   , 24.5   , 17.4   , 12.2   , 10.4   , 8.8    , 20.5   , 15.1   , 7.3    , 4.4    , 7.3    ,
         '5G23b', 5.7    , 12.6   , 10.9   , 12.3   , 6.6    , 8.9    , 11     , 7.2    , 4.1    , 11.8   , 22.3   , 16.6   , 14.3   , 12.8   , 6.9    , 9.5    , 14.1   , 15     , 16.5   , 11.4   , 12     , 14.1   , 7.6    , 15.3   , 18.8   , 22.4   , 11     , 17.8   , 14.7   , 12.5   , 8.3    , 8.3    , 10.4   , 19.8   , 26.5   , 16.1   , 18.1   ,
         '5G24a', 0      , 0      , 1.5    , 0      , 0      , 4.2    , 2      , 0      , 0      , 0      , 0      , 1.3    , 0.8    , 0.8    , 2.3    , 2.5    , 3.1    , 2      , 1.7    , 3.1    , 5.1    , 3.2    , 2.9    , 0.5    , 0.2    , 2.8    , 2.4    , 2.8    , 2.7    , 1.6    , 3.4    , 6      , 8.1    , 4.3    , 1.8    , 3.4    , 4.3    ,
         '5G31a', 6.5    , 8.3    , 9.5    , 5.6    , 5.5    , 8.1    , 6.7    , 8.2    , 9.2    , 10     , 8.9    , 8.4    , 8.7    , 10.4   , 10.1   , 8      , 8.9    , 10.4   , 11.4   , 8.6    , 10.5   , 10.1   , 9.8    , 8.8    , 9.8    , 14.5   , 8.6    , 10.4   , 13.1   , 12     , 12.1   , 12.1   , 10.6   , 10.5   , 11.6   , 12.1   , 16.6   ,
         '5G31b', 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 5.9    , 7      , 0      , 0      , 6.1    , 0      , 0      , 0      , 3.6    , 0      , 0      , 0      , 13.2   , 23.4   , 25.3   , 1.7    , 17.7   , 29.4   , 16.7   , 29.7   , 17.3   , 16.2   , 64.7   , 47.9   , 12.2   , 26.7   , 13.2   , 30.3   ,
         '5G32a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 10.8   , 11.2   , 16.3   , 7.2    , 2.7    , 13.2   , 22.6   , 36.7   , 30.5   , 14.8   , 14.4   , 20.6   , 25.1   , 14.8   , 11.2   , 13.5   ,
         '5H11a', 86.7   , 84.3   , 87.3   , 88.2   , 89.3   , 87.6   , 87     , 86.7   , 86.8   , 87.9   , 87.6   , 86.3   , 86.6   , 86.6   , 89.7   , 87.2   , 90.9   , 88.8   , 85.6   , 86.9   , 87.6   , 88.8   , 87.8   , 87.7   , 86.7   , 86.3   , 85.4   , 87     , 88.6   , 87.2   , 87.1   , 87.5   , 91.9   , 91.1   , 88.7   , 92.5   , 93     ,
         '5H11b', 72.8   , 71.6   , 72.3   , 74.6   , 76.5   , 75.4   , 76     , 75.7   , 77     , 76.8   , 77.5   , 75     , 70.5   , 71.9   , 69.8   , 69.4   , 72.3   , 68.6   , 65     , 62.5   , 63.2   , 59.7   , 55     , 58.2   , 60.3   , 60.2   , 58.8   , 61.2   , 61.2   , 57.3   , 55.3   , 58.5   , 60.6   , 60.7   , 65.1   , 66.2   , 64.7   ,
         '5H11c', 84     , 81.7   , 83.5   , 79.3   , 77.2   , 79.2   , 80     , 78.8   , 80.5   , 80.1   , 81.5   , 80.6   , 79     , 77.3   , 80.2   , 81.9   , 76.9   , 77.2   , 80.8   , 79.3   , 79     , 78.2   , 77.2   , 77.2   , 79.2   , 77.3   , 77.9   , 77.1   , 75.6   , 74.3   , 74.7   , 77.8   , 78.3   , 78.6   , 78.9   , 77.5   , 77.8   ,
         '5H11d', 98.4   , 92.6   , 91.6   , 90.4   , 92.4   , 92.2   , 92.1   , 91.5   , 96.1   , 94.8   , 95.6   , 95.3   , 95.4   , 94.6   , 95.7   , 95.5   , 95.1   , 94.5   , 95.5   , 94.7   , 96.3   , 96.2   , 98.7   , 96.9   , 94.6   , 96.3   , 94.4   , 93.9   , 95.2   , 96.1   , 95.9   , 93.3   , 93.6   , 94.4   , 92.5   , 92.6   , 90.8   ,
         '5H12a', 54.5   , 52.2   , 53.7   , 58     , 58.3   , 59.3   , 58.4   , 56.6   , 59.7   , 59.8   , 60.7   , 62.9   , 62.4   , 57     , 59.7   , 59.5   , 56.7   , 58.9   , 59     , 58.9   , 63.1   , 64.4   , 64.3   , 56.9   , 66.9   , 66.8   , 61.3   , 62.5   , 61.7   , 60.8   , 62.2   , 60.3   , 62.7   , 61.3   , 62     , 60     , 61.6   ,
         '5H12b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 60.9   , 59.5   , 56.9   , 55.7   , 56.9   , 55.9   , 65.5   , 58.4   , 57.9   , 54.2   , 59.7   , 63.9   , 57.9   , 63.5   , 51.6   , 48.1   ,
         '5H12c', 87.3   , 81.7   , 80.4   , 81.7   , 83.4   , 81     , 85.3   , 78     , 76.4   , 75.2   , 76.6   , 70.6   , 71.7   , 78.7   , 81.3   , 77     , 79.1   , 72.2   , 65.2   , 73.6   , 74.2   , 79.5   , 69.5   , 74.7   , 75.2   , 76.3   , 68.3   , 79.9   , 80.6   , 83.5   , 83.3   , 83.6   , 77.9   , 75.6   , 75.2   , 77.1   , 75.4   ,
         '5H12d', 100    , 95.6   , 91.4   , 95.7   , 100    , 100    , 100    , 100    , 96.7   , 100    , 100    , 100    , 100    , 100    , 100    , 100    , 96.1   , 100    , 96     , 97.7   , 97.7   , 99.5   , 96.4   , 99.1   , 100    , 100    , 100    , 100    , 99.1   , 97.7   , 98.8   , 98.9   , 98.7   , 98     , 99.8   , 99.5   , 97.5   ,
         '5H12e', 81.7   , 80.1   , 78     , 79.5   , 88.5   , 86.4   , 88.3   , 83.5   , 79.7   , 84.7   , 86.8   , 86.6   , 85.4   , 85     , 87.2   , 87.5   , 84.3   , 81.8   , 86.9   , 87     , 88.6   , 92.4   , 93     , 91.7   , 92     , 88.2   , 86.2   , 88     , 89     , 88.7   , 90.6   , 94.3   , 89.3   , 85.4   , 87.5   , 87.4   , 84.5   ,
         '5H13a', 98.6   , 99.7   , 100    , 100    , 100    , 98.5   , 99.8   , 100    , 99.6   , 99.4   , 100    , 99.3   , 99.6   , 99.2   , 99.5   , 98.8   , 98.8   , 98.6   , 98.8   , 99.3   , 98.8   , 99.5   , 99.4   , 99.3   , 99.7   , 99.6   , 99.1   , 99.2   , 98.7   , 98.5   , 99.1   , 99.6   , 99.5   , 98.9   , 98.3   , 98     , 98     ,
         '5H13b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 97.8   , 98.7   , 98.3   , 98.3   , 98.3   , 98.2   , 97.8   , 96.2   , 96.8   , 97.2   , 97.3   , 97.4   , 96.6   , 96.1   , 96.5   , 95     ,
         '5H13c', 98.3   , 98     , 97.6   , 97.9   , 98.5   , 97.6   , 98.5   , 98.7   , 98.1   , 98.4   , 98.9   , 98.1   , 97.3   , 97.5   , 97.9   , 97.4   , 97.8   , 97.9   , 97.7   , 96.8   , 97.6   , 98.5   , 98.1   , 96.4   , 96.7   , 98     , 96.7   , 95.3   , 94     , 94.9   , 95.8   , 97.1   , 97     , 95.8   , 96.9   , 95.7   , 94.3   ,
         '5H13d', 79.2   , 78.4   , 78.9   , 73.7   , 72.4   , 72.2   , 74.4   , 69.3   , 71.1   , 75.1   , 70.3   , 70.9   , 71.8   , 75     , 72.3   , 67.2   , 68.8   , 66.1   , 64.3   , 62.7   , 61.4   , 76.9   , 69.6   , 66.4   , 67.1   , 65.2   , 59.8   , 63.9   , 65.2   , 68.1   , 66.1   , 66.2   , 58.9   , 63.2   , 65.5   , 55.5   , 60.1   ,
         '5H14a', 85.9   , 84.8   , 78     , 79     , 82.2   , 83.1   , 81.9   , 85.3   , 84.4   , 85     , 87.9   , 87     , 85.2   , 84.3   , 83.5   , 81.7   , 85.4   , 85     , 83.4   , 81.3   , 79.3   , 80.5   , 77     , 76.4   , 74.3   , 75.6   , 78.1   , 77.8   , 78.6   , 78.4   , 74.8   , 79.8   , 80     , 75.1   , 78.1   , 78     , 76.1   ,
         '5H21a', 56.8   , 58.1   , 61.1   , 62.4   , 63.3   , 64     , 66.4   , 69.2   , 67.3   , 73.5   , 75     , 68.3   , 68.7   , 68.2   , 70.8   , 71.7   , 74.1   , 73     , 67.3   , 70     , 74.4   , 76.1   , 74.9   , 65.6   , 70.1   , 73.4   , 79.9   , 81.2   , 85.7   , 81     , 81.1   , 86.9   , 87     , 83.8   , 82.9   , 83.8   , 81.7   ,
         '5H21b', 51.8   , 52.9   , 53.3   , 52.9   , 51.8   , 40.7   , 52.5   , 51.2   , 55.7   , 49.7   , 50.2   , 57.8   , 56     , 64.7   , 60.6   , 75.9   , 66.6   , 56.2   , 50.3   , 53.2   , 55.8   , 81.2   , 72.2   , 83.7   , 63.7   , 58     , 65.5   , 77.6   , 62.9   , 53.8   , 48.2   , 65     , 71.8   , 68.4   , 63.5   , 66.7   , 67.3   ,
         '5H21c', 18     , 20.8   , 15.5   , 12.4   , 23.5   , 20.8   , 23.2   , 18.8   , 12.8   , 15.1   , 19.7   , 24.5   , 17.2   , 24.7   , 26.1   , 31.9   , 24.9   , 17.1   , 20.4   , 14.8   , 21.8   , 21.4   , 37.6   , 44.5   , 36.4   , 30.4   , 36.9   , 36.6   , 41.3   , 36.8   , 38.3   , 34.6   , 35.5   , 47.9   , 51.4   , 57.8   , 47.5   ,
         '5H21d', 96.8   , 98.9   , 98.7   , 97.7   , 98.1   , 98.5   , 97.6   , 96     , 98.4   , 98.4   , 98.2   , 99.5   , 98.9   , 98.6   , 98.5   , 98.9   , 99.2   , 99.3   , 99.4   , 98.6   , 97.5   , 93.2   , 93.8   , 97     , 100    , 99.5   , 97.7   , 93.6   , 98.2   , 98.8   , 94.5   , 93.2   , 87.4   , 84.7   , 84.2   , 88.5   , 80.9   ,
         '5H22a', 56.5   , 55     , 52.7   , 48.4   , 54.3   , 51.4   , 48.5   , 51.9   , 49.5   , 50.7   , 46.9   , 44.1   , 50     , 51.9   , 46.5   , 49.2   , 47.5   , 45.7   , 44.2   , 46.2   , 50     , 36.1   , 40.2   , 40.4   , 42.6   , 39.3   , 36.1   , 35.5   , 36.3   , 38.5   , 33.5   , 35.6   , 35.9   , 32.9   , 34     , 37.8   , 35.1   ,
         '5H22b', 61.9   , 61.9   , 62     , 57     , 57.8   , 56.6   , 58     , 58.6   , 56.9   , 56.7   , 49.2   , 49.6   , 49     , 49.8   , 52.7   , 47.6   , 50.5   , 46.2   , 45.4   , 46.2   , 52.5   , 49.8   , 33.6   , 40.9   , 43.8   , 39.8   , 38.7   , 49.4   , 39.9   , 52.4   , 56.9   , 49.4   , 36.2   , 52     , 53.7   , 47.2   , 48.6   ,
         '5H22c', 56.1   , 59.6   , 59.1   , 55.6   , 53.5   , 53.9   , 55.4   , 56.4   , 53.9   , 58.1   , 50.2   , 52.7   , 52.1   , 56.8   , 49.8   , 53.2   , 58.5   , 44     , 50.9   , 45.8   , 51.9   , 50.2   , 53     , 55.9   , 67     , 63.1   , 49.9   , 40.8   , 44.4   , 46.9   , 57.7   , 55.5   , 50.2   , 62.9   , 46.2   , 51.2   , 53     ,
         '6E10a', 0      , 1.9    , 0      , 0      , 0      , 0      , 1.7    , 1.8    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 9.7    , 12.1   , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      ,
         '6E11a', 0      , 0      , 0      , 0      , 0      , 1.7    , 1.4    , 1.8    , 0      , 0      , 2.5    , 3.5    , 0      , 0      , 2.7    , 1.9    , 0      , 0      , 3.1    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 18.7   ,
         '6E11b', 0.8    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 2.6    , 1.2    , 0      , 0      , 0      , 0      , 0      , 1.4    , 2.8    , 2.3    , 0      , 1.2    , 0      , 0      , 0      , 0      , 0      , 0.5    , 1.2    , 0      , 1.9    , 1      , 0.5    , 0.2    , 0.9    , 0      ,
         '6E11c', 0.8    , 0      , 0      , 0      , 0      , 0      , 0      , 1.1    , 0      , 0      , 0      , 0.7    , 0.7    , 0      , 0      , 0      , 0      , 0      , 0.4    , 0.4    , 0      , 0      , 0      , 1.2    , 0.4    , 0.7    , 0      , 0      , 0      , 1.5    , 1.4    , 1.9    , 0.8    , 2      , 2      , 0.7    , 0      ,
         '6E11d', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 18.2   , 8.7    , 5.5    , 8.3    , 0      , 0      , 0      , 7.1    , 4.3    , 6.4    , 0      , 0      , 16.8   , 25.2   , 0      , 1.5    ,
         '6E11e', 1.1    , 0.6    , 0      , 0      , 0.7    , 0      , 0.6    , 0.8    , 0      , 0.6    , 0      , 0.9    , 0      , 1.7    , 2.1    , 1      , 0      , 1.9    , 2.4    , 1.4    , 1.6    , 0      , 0      , 0      , 0      , 0      , 0      , 1.1    , 2.2    , 3.1    , 2.8    , 0.2    , 2.5    , 3.3    , 1.2    , 0.5    , 1.3    ,
         '6E11f', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0      , 4.6    , 7.9    , 6.1    , 1.2    , 3.3    , 5.3    , 11.2   , 12.6   , 6.3    , 1.7    , 4.3    , 4      , 0      , 0      , 20.4   ,
         '6E12a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 37.8   , 34.3   , 14.6   , 56.3   , 86.2   , 71.5   , 75.3   , 41.6   , 45.1   , 19.3   , 0      , 0      , 82.2   , 77.9   , 45.1   , 32.8   ,
         '6E12b', 19.7   , 20.7   , 24.2   , 28.5   , 24     , 31.1   , 31.5   , 26.4   , 27.1   , 29.7   , 33     , 24.7   , 34.5   , 30.9   , 32.6   , 34.7   , 34.7   , 33     , 31.8   , 32.4   , 33.5   , 38.7   , 39.4   , 38.3   , 39.5   , 35.4   , 26.1   , 34.3   , 34.2   , 36.2   , 34.5   , 38.3   , 29.6   , 25.2   , 22.6   , 26.2   , 22.1   ,
         '6E12c', 27.5   , 38.4   , 44.3   , 59.7   , 61.5   , 57.9   , 43.1   , 41.5   , 32.3   , 35.8   , 37.8   , 41.4   , 45.8   , 40.5   , 41.4   , 34.5   , 38.4   , 40.9   , 48.5   , 45.6   , 36.8   , 40.2   , 75.3   , 100    , 75.6   , 60.7   , 47.2   , 22.7   , 21.5   , 30.3   , 50     , 28.7   , 60.8   , 50     , 41     , 74.5   , 38.7   ,
         '6E13a', 0.8    , 0.4    , 1.7    , 0.5    , 0      , 1.1    , 1.5    , 1.6    , 1.4    , 1.8    , 2.5    , 2.6    , 0.5    , 2.1    , 1.6    , 3.3    , 0.8    , 2.8    , 2.7    , 2.8    , 2.5    , 4      , 8.5    , 7.3    , 3.5    , 1.3    , 4.5    , 7.9    , 2.8    , 3.2    , 3.8    , 1.7    , 3.6    , 3.2    , 2.4    , 1.1    , 0      ,
         '6E13b', 0      , 0      , 0      , 0      , 0      , 1.6    , 0      , 0      , 2.1    , 2.4    , 0      , 0      , 4.9    , 1.9    , 0      , 0      , 0      , 0      , 0      , 1.6    , 0      , 0      , 0      , 0      , 5.3    , 1.4    , 0      , 0      , 0      , 0      , 0.8    , 0      , 0      , 1.9    , 0      , 0      , 0      ,
         '6E13c', 3.2    , 2.7    , 3.2    , 4.1    , 3.2    , 4.6    , 5.1    , 4.5    , 2.1    , 1.9    , 2.1    , 3.1    , 3.3    , 2.7    , 5      , 3      , 4.3    , 5.2    , 2.8    , 4.2    , 3.4    , 3.1    , 1.3    , 2.2    , 1.5    , 5      , 3.9    , 3.5    , 1.1    , 0.9    , 6.5    , 2.8    , 3.5    , 2.4    , 7      , 4.1    , 2.3    ,
         '6E13d', 0      , 0      , 1.4    , 2.9    , 7      , 2.8    , 1.4    , 2.8    , 8.5    , 9.5    , 5.4    , 6.2    , 4.5    , 3.5    , 2.3    , 1.6    , 2.9    , 1.7    , 2      , 0      , 2.3    , 1.1    , 3.9    , 0      , 0      , 0      , 0      , 0      , 7.4    , 15.2   , 8.7    , 33.2   , 28.2   , 0      , 13.1   , 10.4   , 12.2   ,
         '6E13e', 0.7    , 0.5    , 1.9    , 0.8    , 1.3    , 1.4    , 2.1    , 2.4    , 2.5    , 4.5    , 3.6    , 2.4    , 3.1    , 2.9    , 3.3    , 3.9    , 3      , 4      , 5.7    , 8.1    , 6.4    , 7.9    , 9.7    , 6      , 6.7    , 11.3   , 14.9   , 11     , 8.8    , 10.6   , 7.7    , 9.6    , 8.5    , 14.8   , 15.1   , 13.3   , 15.7   ,
         '6E13f', 5.9    , 5.7    , 9.3    , 7.4    , 10.8   , 8.5    , 7.9    , 8.1    , 12.5   , 8.2    , 15.1   , 11.2   , 14.4   , 12.5   , 12.2   , 12.8   , 9.1    , 11.3   , 8.1    , 10.7   , 8.5    , 8.7    , 14.7   , 7.2    , 14.3   , 7.8    , 5.4    , 5.5    , 6.4    , 13.4   , 10.9   , 9.1    , 13.5   , 10.4   , 10.8   , 20     , 9.3    ,
         '6E13g', 0      , 0      , 0      , 0      , 0      , 3.6    , 3.7    , 2.8    , 0      , 0      , 0      , 0      , 3.1    , 4.3    , 0      , 0      , 0      , 3.5    , 3.4    , 0      , 0      , 4.7    , 3.3    , 2.8    , 4.7    , 1.8    , 0      , 0      , 4      , 4.8    , 4.8    , 3.3    , 8.9    , 11.6   , 3      , 0      , 0      ,
         '6E13h', 13.1   , 13.7   , 16.4   , 18.1   , 13.7   , 15.2   , 15.7   , 19.9   , 18.3   , 20.2   , 13.4   , 18.5   , 20.4   , 17.1   , 13     , 16     , 19     , 20.1   , 36.4   , 25     , 19.6   , 27.2   , 22     , 22.6   , 13.9   , 17.1   , 39.9   , 36.4   , 32.4   , 31.6   , 38.2   , 43.8   , 31.5   , 27.1   , 35.7   , 47     , 42.9   ,
         '6E13i', 3      , 3      , 4.9    , 5.9    , 4.9    , 5.2    , 1.2    , 2.3    , 1.3    , 2.8    , 4.7    , 6.7    , 4.3    , 1.4    , 4.8    , 1.8    , 3.3    , 6      , 4      , 2.3    , 2.4    , 6.6    , 4.4    , 7.2    , 28.2   , 7.1    , 11.2   , 8.4    , 7.1    , 10.1   , 6.8    , 13.2   , 15.1   , 10.3   , 15.2   , 18     , 16.2   ,
         '6E13j', 2.7    , 4.9    , 4      , 3.6    , 2.9    , 3.7    , 4.9    , 7.5    , 7.8    , 9.7    , 11.4   , 11.9   , 12     , 13.5   , 13.3   , 13.6   , 15.8   , 13.2   , 13.8   , 15.7   , 12.3   , 16.9   , 22     , 22.2   , 19.1   , 20.8   , 19.2   , 18.6   , 21.6   , 22.4   , 22.9   , 18.6   , 17     , 20.7   , 13.4   , 16.2   , 20.1   ,
         '6E14a', 21.2   , 28     , 27.7   , 27.8   , 24.5   , 19.8   , 27.9   , 28.9   , 28.8   , 37.4   , 32.1   , 25.3   , 28.1   , 30     , 25.7   , 35.3   , 41.4   , 24.7   , 28.9   , 35     , 30.4   , 33.4   , 45.1   , 35.6   , 35.8   , 32.1   , 53.5   , 25.7   , 48.4   , 34.4   , 25.1   , 38.7   , 61     , 22.5   , 45     , 26     , 46.9   ,
         '6E14b', 18.4   , 17.5   , 16.8   , 16.1   , 23.4   , 21.8   , 21.3   , 20.1   , 22.6   , 23.7   , 23     , 23     , 23.6   , 22.1   , 22.8   , 19.2   , 19.1   , 17.9   , 18.8   , 19.1   , 23     , 16.1   , 28.4   , 26.2   , 31.8   , 38.6   , 31.3   , 26.1   , 16.5   , 20.7   , 24.6   , 24.8   , 17     , 16.7   , 17.1   , 20.8   , 23.8   ,
         '6E15a', 7.1    , 5      , 7.2    , 7.4    , 11.2   , 7.1    , 11.8   , 10.9   , 15     , 14.5   , 16.7   , 11.9   , 13.6   , 17     , 23.1   , 21.7   , 19.1   , 17.9   , 17.5   , 18.3   , 16     , 9.5    , 10.3   , 35.6   , 20.7   , 23.3   , 25.7   , 41.5   , 22     , 21.8   , 18.4   , 35.4   , 48.8   , 33.7   , 32.1   , 34.6   , 37.2   ,
         '6E15b', 60.3   , 48.8   , 46.2   , 48.7   , 47.9   , 51.7   , 53.5   , 52.5   , 44.4   , 36.6   , 45.1   , 35.1   , 35.4   , 36.3   , 41.7   , 33.6   , 34.1   , 36.8   , 26.5   , 36.4   , 31.6   , 30.3   , 36.1   , 28.4   , 25.6   , 29.3   , 29.5   , 20.4   , 27.6   , 28.1   , 29.6   , 28.9   , 32     , 29.2   , 26.4   , 32.6   , 34.7   ,
         '6E15c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 28.9   , 30.4   , 29.1   , 23.5   , 26.2   , 31     , 31.7   , 27     , 23.8   , 29.9   , 35.2   , 41.1   , 34     , 29.8   , 34.7   , 33.1   ,
         '6E15d', 21.5   , 21     , 15.7   , 15     , 15     , 13.7   , 17.3   , 23.7   , 21.6   , 22.5   , 19.4   , 16.9   , 19.3   , 21.3   , 19.1   , 23.1   , 19.8   , 23.4   , 19.9   , 25.3   , 25.1   , 29.4   , 29.4   , 34.4   , 32.9   , 35.6   , 23.8   , 15.2   , 23.8   , 29.8   , 26.3   , 28.5   , 31.9   , 30.5   , 27.3   , 27.2   , 31     ,
         '6E15e', 4.7    , 6.5    , 5.2    , 8.4    , 9.7    , 7.7    , 8.8    , 8.5    , 7.1    , 8.3    , 6.4    , 5.3    , 13.5   , 13.5   , 9.7    , 9.3    , 11.3   , 8.6    , 12.4   , 11.3   , 16     , 9.3    , 15.8   , 7.9    , 3.2    , 8.6    , 5      , 8.6    , 10.5   , 11.5   , 13.2   , 13.4   , 12.3   , 9.9    , 10.7   , 15.4   , 18.9   ,
         '6E15f', 15.8   , 16.1   , 7.7    , 5.5    , 5.8    , 5.5    , 14.4   , 13.3   , 11.3   , 4.5    , 12.5   , 15.5   , 12.9   , 18     , 7.4    , 17.5   , 18.9   , 19.5   , 15.4   , 12.3   , 7.1    , 11.7   , 4.9    , 8.8    , 2.9    , 1.6    , 3.4    , 6.5    , 22.5   , 19.7   , 3.5    , 0      , 0      , 7      , 14.5   , 17.6   , 28.1   ,
         '6E16a', 44.5   , 44.9   , 55.1   , 62.6   , 49.7   , 45.1   , 53.7   , 54.8   , 48     , 48.8   , 46.4   , 40.9   , 43.7   , 43     , 48.9   , 45.9   , 43.3   , 38.6   , 41.2   , 41.9   , 46.8   , 49.6   , 45.8   , 57.9   , 51.4   , 32.9   , 36.5   , 28.9   , 43.7   , 36     , 39.8   , 53.8   , 36.9   , 38.1   , 94.9   , 88.6   , 64.4   ,
         '6E16b', 83     , 83.1   , 84     , 80.5   , 82.4   , 75.9   , 79     , 73.5   , 85.5   , 88.7   , 88.9   , 83.3   , 82.1   , 84.6   , 84.6   , 78.9   , 78.9   , 77.9   , 79.5   , 84.4   , 89.6   , 70.8   , 76.4   , 80.8   , 73.2   , 67.2   , 67.6   , 64.7   , 53.2   , 59.5   , 67.7   , 65.7   , 53.6   , 57.3   , 58.7   , 60     , 49.6   ,
         '6E16c', 68.6   , 69.6   , 62.2   , 60.6   , 50     , 41.8   , 43.8   , 62.3   , 55.2   , 56.1   , 61.6   , 68.9   , 71.9   , 65     , 66     , 61.4   , 69.7   , 68.1   , 63.2   , 62.1   , 62.4   , 72.6   , 75.1   , 42.7   , 42.5   , 52.2   , 60.9   , 74.2   , 80.7   , 73.9   , 82.9   , 93     , 68.6   , 54     , 54.8   , 78.9   , 68.1   ,
         '6E17a', 7.4    , 4.6    , 6.6    , 3.8    , 3.1    , 4.1    , 2.5    , 2.4    , 5.6    , 7.6    , 11     , 7.2    , 5.7    , 6.6    , 8.3    , 7      , 4.9    , 2.4    , 4.6    , 3.5    , 5.6    , 12     , 14.7   , 10.6   , 14.4   , 7.7    , 8.6    , 7.4    , 6.2    , 7.5    , 5.4    , 4.4    , 6.7    , 7.2    , 5.5    , 4.8    , 6.9    ,
         '6E18a', 1.4    , 0.9    , 1.2    , 0      , 0.4    , 1.2    , 1.9    , 1.5    , 0.3    , 2.6    , 0.8    , 1.2    , 2.1    , 2.4    , 1.6    , 1      , 0.2    , 0.8    , 0.8    , 1.2    , 0.4    , 0.8    , 0.2    , 1      , 0.7    , 2.6    , 2.1    , 1.6    , 1.6    , 0      , 0.3    , 2.6    , 2.4    , 2.2    , 3.4    , 4.7    , 2.3    ,
         '6E18b', 1      , 0.3    , 1.3    , 2.2    , 2.1    , 0.8    , 1.5    , 1.4    , 2.6    , 2.1    , 0.5    , 0.7    , 1.2    , 0.3    , 1.6    , 0.5    , 0.9    , 2.3    , 2.3    , 1.3    , 2.4    , 0.3    , 0      , 1.5    , 0.8    , 1.8    , 1      , 3.3    , 1.4    , 1.3    , 1.2    , 0      , 0      , 0.9    , 0      , 0.6    , 1.7    ,
         '6E18c', 3.7    , 2      , 2.6    , 0      , 0      , 3.5    , 2.7    , 3.4    , 3.1    , 0      , 2.6    , 0.9    , 0.8    , 6.8    , 7.5    , 5.2    , 0      , 1.8    , 4.2    , 0      , 6.2    , 0.4    , 3.2    , 0.6    , 4.9    , 9.4    , 18     , 9.6    , 3.3    , 2.7    , 7.6    , 7.1    , 6.1    , 2.7    , 7.2    , 4.5    , 5.9    ,
         '6E18d', 14.3   , 4.7    , 8.3    , 0      , 3.9    , 3.8    , 12.5   , 11.3   , 7.9    , 5.3    , 4.7    , 5.2    , 1.5    , 1.2    , 4.1    , 8.9    , 7.3    , 7.1    , 3.1    , 7.6    , 3.9    , 17.4   , 9.2    , 0      , 5.2    , 3.5    , 1.6    , 8.6    , 21.5   , 10.6   , 3.7    , 11.6   , 7.8    , 0      , 5.2    , 9.4    , 19.8   ,
         '6E19a', 3.1    , 0      , 0      , 0      , 0      , 2.9    , 0      , 0      , 0      , 0      , 2.2    , 1.8    , 3.9    , 0      , 0      , 2.2    , 2.5    , 0      , 0      , 0      , 2.6    , 0      , 0      , 0      , 0      , 0      , 0      , 16     , 13.3   , 11     , 11.3   , 2      , 0      , 0      , 0      , 0      , 4      ,
         '6E19b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 6.8    , 3.6    , 0      , 0      , 0      , 4      , 3.5    , 4.5    , 11.5   , 13.5   , 5.7    , 2.7    , 0      , 3.9    , 1.1    , 13.5   ,
         '6E19c', 38.9   , 30.5   , 34.8   , 50.9   , 53.3   , 35.8   , 51.4   , 59     , 70.9   , 71.4   , 63     , 55.6   , 49.3   , 62.5   , 56     , 64.2   , 62.9   , 65.1   , 60.2   , 61.4   , 65.4   , 59     , 47.2   , 43.1   , 52.7   , 70.6   , 82.3   , 76.8   , 53.1   , 61.2   , 46.8   , 50.6   , 62     , 68.1   , 89.3   , 55.5   , 42.8   ,
         '6E19d', 39.5   , 29     , 27.2   , 26.8   , 25.3   , 17.4   , 19.9   , 22.2   , 24.8   , 22.1   , 19.3   , 27.9   , 28     , 24.3   , 24.7   , 31.4   , 26.7   , 28.6   , 23.8   , 25.5   , 26.2   , 23.7   , 31.2   , 23.7   , 25.8   , 26.5   , 33.3   , 34.9   , 29.1   , 23.3   , 25.4   , 39.3   , 15.5   , 33.7   , 26.5   , 28.8   , 37.6   ,
         '6E21a', 1.6    , 1      , 1      , 1.4    , 2.8    , 2.3    , 2.2    , 0      , 1.1    , 1.8    , 2.2    , 2.4    , 3.8    , 4.8    , 2.6    , 3.8    , 2.9    , 3.9    , 3.8    , 5.4    , 5.5    , 7.9    , 7.6    , 5      , 4.1    , 11     , 7.6    , 4.7    , 5.3    , 6.7    , 6.4    , 6.4    , 4.4    , 6.9    , 5.9    , 4.7    , 4.9    ,
         '6E22a', 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0.9    , 2.7    , 1      ,
         '6E22b', 0      , 0      , 0.5    , 0      , 0      , 0      , 0      , 0.5    , 0.5    , 0.7    , 0      , 0      , 0.2    , 0      , 1      , 0.5    , 0.3    , 0.5    , 1.1    , 1.4    , 0.5    , 0      , 0      , 0.7    , 0.5    , 0.3    , 2      , 1.5    , 1.7    , 0.2    , 0.4    , 0.5    , 0      , 1.1    , 1.8    , 3      , 0      ,
         '6E23a', 0      , 0      , 0      , 0      , 0      , 0      , 0.2    , 0      , 0      , 0      , 0.2    , 0      , 0.1    , 0.1    , 0.5    , 0.5    , 0.6    , 0.7    , 0.3    , 0.4    , 0.4    , 0.2    , 1      , 1.4    , 0.5    , 0.6    , 1      , 0.8    , 0.7    , 1      , 0.9    , 0.8    , 0.7    , 0.5    , 1.1    , 0.4    , 0.4    ,
         '6E23b', 0      , 0      , 0      , 3.6    , 4.3    , 0      , 0      , 0      , 6.5    , 4.7    , 0      , 0      , 2.2    , 2.6    , 3.6    , 0      , 2.1    , 2.1    , 3.4    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 2.4    , 4.6    , 0      , 0      , 0      , 3.2    , 3.2    , 0      ,
         '6E23c', 0      , 0      , 0      , 0      , 1.3    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 1.7    , 2.3    , 1      , 1.2    , 1.4    , 0      , 1.1    , 1.1    , 0      , 0      , 0      , 2      , 3.1    , 0      , 0.2    , 0      , 0      , 0.8    , 2      , 0      , 0      , 0.9    , 1      , 0.2    ,
         '6E23d', 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0.3    , 0.4    , 0      , 0      , 0.4    , 0.8    , 0.9    , 1.2    , 0.2    , 0.7    , 0.6    , 0.5    , 0.3    , 0.4    , 0      , 0.1    , 0      , 0      , 0.1    , 0.4    , 0.1    , 0.7    , 1      , 0.5    , 0.7    , 0.3    , 0      , 0      , 0.1    , 0.5    ,
         '6E23e', 0.4    , 0      , 0      , 0      , 0      , 0.6    , 0.9    , 0      , 0.7    , 0.6    , 0.5    , 0.7    , 1.6    , 0.9    , 2.1    , 0.4    , 0.7    , 0.7    , 1.5    , 1.6    , 1.7    , 2.1    , 2.6    , 0.4    , 2.4    , 3.5    , 3.7    , 4.5    , 1.8    , 1.9    , 3.6    , 3.2    , 8.1    , 8.4    , 4.5    , 4.3    , 4.8    ,
         '6E23f', 0      , 0      , 0      , 0      , 0      , 1.4    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 1.3    , 1.3    , 1.6    , 0.9    , 1.6    , 0      , 0      , 3      , 1.7    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 5.9    , 0      , 0      , 4.2    , 5.6    , 0.3    , 2.4    ,
         '6E23g', 11.3   , 5.5    , 8.5    , 5.5    , 2.6    , 7.9    , 4.8    , 6.1    , 5.8    , 14     , 11     , 12.3   , 12.6   , 14.9   , 16.3   , 15.7   , 15.4   , 13.2   , 17.9   , 21.4   , 20.7   , 10.5   , 12.1   , 8.3    , 10.9   , 12.7   , 5.8    , 4.7    , 8.8    , 11.6   , 17.3   , 15.8   , 9.6    , 12.3   , 16     , 21.7   , 14.5   ,
         '6E24a', 0.4    , 1.4    , 0.7    , 0.3    , 0.5    , 0      , 0.3    , 0.4    , 0.3    , 0      , 0.4    , 1.2    , 0.7    , 0.8    , 0.3    , 0      , 0.6    , 1.2    , 1      , 1.1    , 0.4    , 1.4    , 0.6    , 0.3    , 0.6    , 2.1    , 0.5    , 0.6    , 2.2    , 0.4    , 0.7    , 1.7    , 1.6    , 0.7    , 3.4    , 6      , 0.3    ,
         '6E24b', 3.2    , 1.5    , 0      , 1.9    , 0      , 0      , 0      , 0      , 3.2    , 4.6    , 0      , 4.1    , 3.9    , 5.9    , 4.1    , 2.9    , 11.1   , 10.3   , 0      , 3.7    , 0      , 10.9   , 16.3   , 0      , 0      , 0      , 0      , 0      , 1.2    , 0      , 0      , 0      , 0      , 0      , 0      , 13.1   , 20.9   ,
         '6E24c', 0      , 0      , 0      , 0      , 0      , 2.6    , 2.1    , 0      , 0      , 0      , 1.2    , 0      , 0      , 0      , 1.3    , 2.4    , 1.5    , 1.7    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      ,
         '6E24d', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0      , 0      , 0      , 0      , 6.6    , 5.4    , 3      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      ,
         '6E25a', 0      , 0      , 0      , 0      , 0      , 0.7    , 0.8    , 0.8    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0.9    , 0      , 2      , 0      , 0      , 0      , 0      , 0.9    , 2      , 0      , 1.1    , 2      , 0      , 0      , 0      , 0      , 0      , 0      , 0      ,
         '6E25b', 0      , 0.4    , 0.5    , 1.1    , 0.7    , 1.3    , 0      , 0      , 0      , 1.4    , 0.7    , 1.6    , 1.2    , 0      , 0      , 0      , 0      , 1.5    , 0      , 0.6    , 0      , 0      , 0.8    , 1.4    , 1.8    , 0      , 0      , 2.3    , 2.5    , 1.8    , 0      , 0.3    , 1.2    , 0.7    , 0      , 0.5    , 0.8    ,
         '6E25c', 0      , 0.5    , 0      , 0      , 0.5    , 0      , 0.3    , 0.3    , 0.3    , 0.3    , 0      , 0.7    , 0.3    , 1.2    , 0.9    , 1.1    , 1      , 1.2    , 2.1    , 2.2    , 1.7    , 0.6    , 0.5    , 0.4    , 0.3    , 1      , 1.6    , 0.5    , 0.6    , 0.7    , 0.6    , 1.8    , 2      , 0.9    , 1.8    , 1      , 0.9    ,
         '6E25d', 0      , 0      , 0      , 2      , 0      , 0      , 0      , 3.5    , 1.7    , 1.5    , 1.7    , 3.9    , 4.4    , 3.8    , 4.7    , 4.9    , 3.6    , 3.2    , 5      , 3.1    , 3      , 0      , 2.4    , 3.6    , 9.8    , 10.1   , 3.4    , 0.2    , 1.7    , 0      , 0      , 0      , 7.7    , 6.1    , 12.5   , 2.8    , 1.9    ,
         '6E26a', 74.2   , 70.9   , 67.4   , 68.1   , 64.8   , 66.1   , 66.4   , 67.2   , 62.3   , 58.9   , 65.4   , 64.5   , 69.4   , 64.4   , 70.1   , 63.7   , 67.7   , 59.6   , 66     , 69     , 79.5   , 64.8   , 57.9   , 70     , 69.7   , 59.4   , 57.8   , 64.9   , 75.3   , 71.6   , 86.7   , 86.4   , 75.5   , 68.7   , 73.8   , 67     , 77.4   ,
         '6E27a', 0.8    , 1.2    , 0      , 1      , 0.7    , 0.6    , 1.2    , 1.9    , 2.9    , 1.4    , 3      , 1.3    , 1.2    , 2.2    , 2.5    , 3.1    , 5.3    , 3.8    , 1.7    , 0      , 1.6    , 0.3    , 2.1    , 2.2    , 0      , 0.2    , 0.3    , 2.9    , 2.1    , 4.6    , 8.4    , 7.9    , 4.5    , 3.6    , 4.9    , 4.9    , 1.5    ,
         '6E27b', 14.3   , 17.7   , 12.2   , 7.6    , 9      , 13     , 3.9    , 14.7   , 13.4   , 15.9   , 20.7   , 9.4    , 22.7   , 7.1    , 13.4   , 16     , 12.1   , 18.7   , 18.6   , 22.1   , 17.9   , 14.7   , 13.4   , 6.2    , 13.5   , 31.9   , 17     , 43.9   , 38.6   , 24     , 6.3    , 10.6   , 14.2   , 9      , 36.3   , 38.3   , 18     ,
         '6E27c', 2.2    , 5.3    , 2.9    , 2.1    , 2.2    , 3.7    , 3.8    , 3.6    , 1.9    , 2.1    , 2.4    , 2.3    , 2.3    , 4.1    , 2.9    , 4.2    , 3.1    , 2.6    , 4.2    , 3.3    , 5.2    , 7.9    , 9.4    , 12.7   , 12.3   , 9.3    , 14.3   , 13.6   , 16.3   , 8.7    , 8.6    , 11.6   , 14.9   , 11.9   , 11.9   , 13.9   , 12.3   ,
         '6E27d', 32.4   , 31.2   , 33.4   , 27.8   , 25.9   , 27.4   , 27.5   , 26.4   , 28.3   , 27     , 25.5   , 25.9   , 25.1   , 26.7   , 26.5   , 23.9   , 26.6   , 24.4   , 22.1   , 27.8   , 25.1   , 24.5   , 24.8   , 28.8   , 28.8   , 25.6   , 24.4   , 23.9   , 27.7   , 30.5   , 30.2   , 30.3   , 28.2   , 33     , 32.7   , 28.7   , 28.5   ,
         '6E28a', 4.4    , 16.4   , 21.3   , 17.8   , 24.7   , 31.9   , 38.2   , 20.7   , 29.3   , 27.3   , 36.3   , 19.9   , 12.4   , 19.3   , 17.9   , 30.1   , 13.2   , 18.6   , 31.2   , 52.4   , 44.3   , 42.6   , 34.9   , 55.5   , 55.8   , 57.4   , 68.1   , 0      , 12.4   , 43.6   , 21.6   , 54.6   , 79.1   , 65.7   , 50.7   , 73     , 88     ,
         '6E28b', 25.1   , 27.3   , 29.6   , 32.3   , 28.5   , 24.4   , 30.8   , 24.8   , 19.3   , 19.1   , 15.9   , 27.9   , 19.5   , 25     , 26.9   , 22.2   , 23.3   , 34     , 36.6   , 40.5   , 28.9   , 35.2   , 27.1   , 33.6   , 43.9   , 44.3   , 35.4   , 28.3   , 24.7   , 30.4   , 25.2   , 53.3   , 34.7   , 44.2   , 54.6   , 53     , 55.4   ,
         '6E28c', 16.9   , 32     , 20.6   , 20.3   , 23.7   , 32.5   , 31.3   , 24.4   , 36.1   , 31.1   , 22.2   , 25.4   , 34.7   , 54.9   , 42.8   , 25.7   , 27.9   , 28.4   , 31.8   , 37.4   , 39.6   , 22.3   , 18.1   , 23.7   , 21.3   , 34.8   , 32.9   , 26.4   , 44.2   , 29.3   , 19.6   , 38.7   , 40.1   , 21.7   , 23.7   , 28.6   , 52.4   ,
         '6E28d', 63     , 50.4   , 35.6   , 42.5   , 43.6   , 31.5   , 49.1   , 40.4   , 59.8   , 59.6   , 53.5   , 47.1   , 35.5   , 61     , 56.1   , 43.4   , 60.3   , 48     , 45.2   , 47.6   , 47.9   , 49.9   , 39.8   , 37.8   , 71.9   , 53.4   , 37.4   , 42.8   , 45.5   , 36.2   , 40.7   , 51.7   , 50.3   , 35.1   , 36.6   , 41.4   , 37.3   ,
         '6E31a', 0.3    , 0.4    , 0.1    , 0.6    , 0.4    , 0.4    , 0.1    , 0.1    , 0.3    , 0.2    , 0.7    , 0.3    , 0.6    , 0.7    , 0.5    , 0.5    , 0.9    , 0.8    , 0.9    , 1.4    , 0.6    , 0.9    , 0.8    , 1.5    , 1.9    , 2      , 1.6    , 1.8    , 1.7    , 1.9    , 2.3    , 2.7    , 1.7    , 2.8    , 3.2    , 2.5    , 2.5    ,
         '6E32a', 5.1    , 3.4    , 5.3    , 5.8    , 6.6    , 6.8    , 7      , 6.1    , 5.5    , 8.6    , 10.4   , 11.3   , 10.9   , 9      , 12     , 12.7   , 13.9   , 12.3   , 15.1   , 17.6   , 20     , 19.2   , 17.8   , 21.4   , 23.8   , 29.1   , 22.3   , 23.6   , 27.4   , 21.9   , 21     , 17.9   , 18     , 22     , 23     , 17.6   , 13.6   ,
         '6E33a', 3.6    , 10.5   , 0      , 7.8    , 3.9    , 4.8    , 7.6    , 5.6    , 11.6   , 13.2   , 14     , 26.1   , 22.3   , 26.2   , 21.7   , 18.8   , 18.1   , 31.8   , 22.7   , 33     , 27     , 18.3   , 11.8   , 9.3    , 19.3   , 27     , 34.1   , 26.2   , 36.5   , 34.3   , 31.7   , 34.6   , 21.7   , 26.8   , 22.2   , 23.8   , 25.5   ,
         '6E33b', 5.8    , 6.7    , 9.2    , 2      , 2.2    , 5.8    , 2.1    , 2.2    , 0      , 2.7    , 0      , 2      , 2.3    , 1.4    , 0      , 2.3    , 0      , 6.1    , 2.7    , 3.5    , 5.6    , 3.7    , 1.8    , 7.7    , 7.1    , 8.4    , 10.8   , 18.2   , 6.3    , 11.7   , 16.7   , 5.6    , 7.2    , 15.6   , 8.2    , 8.4    , 6.8    ,
         '6E34a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0      , 0      , 0      , 0      , 0      , 0      , 0      , 2.1    , 13.8   , 5      , 0      , 3.7    , 8.7    , 0      , 0      , 0      ,
         '6E34b', 3.7    , 3.7    , 0.8    , 1.4    , 0.6    , 1      , 1.8    , 2      , 2.2    , 2.5    , 3.4    , 2.3    , 4.2    , 1.4    , 3.8    , 2.8    , 1.5    , 0.5    , 0      , 1.1    , 1.8    , 0.9    , 0      , 0      , 1.2    , 0      , 0      , 1.7    , 3.4    , 3.1    , 0      , 0      , 1.6    , 0      , 0.8    , 2.2    , 0.6    ,
         '6E34c', 1.6    , 0      , 1.2    , 0      , 4.6    , 2.7    , 1.6    , 0      , 1.3    , 0      , 0      , 0      , 0      , 0      , 2.9    , 1.5    , 0      , 0      , 0      , 3.7    , 2.1    , 1.8    , 6.3    , 5.8    , 2.6    , 6.1    , 8.7    , 5.4    , 6.4    , 3.3    , 3.6    , 5.8    , 3.7    , 0.9    , 0.8    , 2.6    , 5.3    ,
         '6E35a', 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 2.8    , 0      , 0      , 2      , 3      , 4      , 3.9    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      ,
         '6E35b', 0      , 0      , 0      , 0      , 0      , 0      , 0      , 4.3    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 4.9    , 0      , 0      , 0      , 11.3   , 7.5    , 0      , 0      , 0      , 4.5    , 0      , 0      , 0      , 13.1   , 3.9    , 2.9    , 3.2    , 0      , 0      , 9      , 0      , 5.2    ,
         '6E36a', 3.6    , 7.6    , 5.8    , 3.9    , 6.2    , 4.1    , 4.7    , 6.6    , 4.7    , 5.5    , 6.2    , 4.4    , 4      , 2.1    , 3.9    , 3.9    , 3.3    , 6.1    , 4.6    , 2.8    , 5.4    , 11.8   , 2.9    , 6.2    , 3.4    , 6      , 11.8   , 14.4   , 13.6   , 13.2   , 16.2   , 8.1    , 6.4    , 3.9    , 7.3    , 15.6   , 9.9    ,
         '6E41a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 5.9    , 11.4   , 20.2   , 24.5   , 10.5   , 12.8   , 15.7   , 12.6   , 17.7   , 12.6   , 24.9   , 18.1   , 22     , 23.2   , 20.2   , 33     ,
         '6E41b', 0.4    , 0.4    , 0.4    , 0.5    , 0.5    , 1.4    , 1.5    , 1      , 0.6    , 1      , 1.1    , 3.8    , 1.5    , 1.1    , 0.8    , 2.1    , 1.5    , 3.1    , 2.1    , 1.9    , 1.1    , 1.9    , 1.7    , 0.3    , 0.1    , 1.9    , 2.8    , 3.6    , 1.5    , 0      , 0      , 0.1    , 0.4    , 1.6    , 1.4    , 0.8    , 0.6    ,
         '6E42a', 50.1   , 51     , 58.7   , 60.4   , 53.7   , 53.2   , 53.2   , 55.9   , 52.1   , 60     , 56.9   , 51.7   , 62.8   , 53.5   , 52.7   , 57     , 57.5   , 53.5   , 57.1   , 53.1   , 60.2   , 52.5   , 52.1   , 50.8   , 53.3   , 49.5   , 49.8   , 43.4   , 42.3   , 44     , 40.3   , 40.4   , 47     , 41.5   , 46.1   , 50.9   , 34.1   ,
         '6E43a', 20     , 21     , 18     , 12.8   , 19.1   , 18.7   , 22.5   , 16.9   , 21.9   , 18.7   , 17     , 17.9   , 35.5   , 34.6   , 35.3   , 22.6   , 31.5   , 35.1   , 25.4   , 31.2   , 31.7   , 31     , 29.1   , 28.1   , 39.4   , 33.5   , 22.8   , 38     , 25.4   , 33.2   , 33.5   , 27.1   , 27.4   , 31     , 24.8   , 36.7   , 36.4   ,
         '6E43b', 29.9   , 26     , 27.8   , 30     , 24.4   , 23.8   , 20.7   , 18     , 16.7   , 21.7   , 20.4   , 22.6   , 18.3   , 15.1   , 17.8   , 19.1   , 12.4   , 14.6   , 18.7   , 17.5   , 24.9   , 13.8   , 31.5   , 20.3   , 24.4   , 20.2   , 25.8   , 13.3   , 13.9   , 19.9   , 23.3   , 7.2    , 20.7   , 9.5    , 22.3   , 16.7   , 10.4   ,
         '6E43c', 29.9   , 31.2   , 29.1   , 29.9   , 30.2   , 25.4   , 28.2   , 29.1   , 36.7   , 39.2   , 33.8   , 30.6   , 33.4   , 33.6   , 31.1   , 30.9   , 28.7   , 28.3   , 29.3   , 28.5   , 32.4   , 30.7   , 27.1   , 24.7   , 26.5   , 25.9   , 25.2   , 24.6   , 22.7   , 28.3   , 28     , 28.2   , 29.4   , 24.9   , 28.7   , 26.6   , 24.4   ,
         '6E44a', 31.7   , 28.2   , 29.8   , 31.6   , 32.9   , 36.1   , 34.6   , 36.5   , 37.5   , 36.2   , 39.3   , 36.6   , 44.1   , 47.4   , 42.5   , 43.9   , 42.6   , 37.2   , 38.8   , 48.9   , 45.5   , 41     , 42     , 49.8   , 49.4   , 45.2   , 47.6   , 47.7   , 43.8   , 48.2   , 48.9   , 46.8   , 45.1   , 46.3   , 39.9   , 47.3   , 49.3   ,
         '6E44b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 56.9   , 46.9   , 58.9   , 55.9   , 58.6   , 64.1   , 61.4   , 50.6   , 44.8   , 56.6   , 52.9   , 51.1   , 44.7   , 44.1   , 47.8   , 45.3   ,
         '6E44c', 44.2   , 42.1   , 42.2   , 42.5   , 44.6   , 45     , 44.1   , 47.5   , 42.9   , 49.6   , 42.4   , 46     , 44.8   , 43     , 47     , 47.8   , 46.9   , 52     , 52.7   , 51.5   , 47.5   , 57.6   , 58.1   , 54.2   , 54.1   , 59     , 60.7   , 56.5   , 50     , 49.8   , 52.5   , 50.8   , 55.5   , 50.2   , 47.2   , 41.1   , 43.8   ,
         '6E44d', 20.6   , 21.3   , 18.2   , 22.6   , 22.4   , 24.7   , 20.5   , 17.8   , 23.7   , 30.6   , 26.1   , 26.3   , 22.9   , 24.5   , 20.6   , 29.3   , 25.2   , 25.5   , 27.2   , 27.9   , 21.1   , 14.1   , 21.3   , 27.4   , 28     , 21.4   , 23.6   , 21.4   , 22.2   , 15.8   , 25.4   , 27.8   , 16.4   , 28.9   , 17.8   , 18.1   , 28.7   ,
         '6E44e', 35.6   , 34     , 31.7   , 42     , 41.9   , 36.8   , 30.2   , 34.6   , 38.7   , 37.8   , 30.7   , 29.5   , 40.1   , 42.1   , 29.6   , 40.6   , 39.9   , 37.8   , 26     , 31.9   , 35.1   , 37.1   , 23.1   , 36.2   , 34.7   , 59.1   , 35     , 25.3   , 15.5   , 17.7   , 25.7   , 15.9   , 12.1   , 25.1   , 6.3    , 46.2   , 31     ,
         '6E45a', 81.6   , 82.9   , 79     , 76.9   , 77.6   , 79.6   , 79.8   , 78.5   , 79.5   , 78.6   , 77.5   , 77.2   , 76.3   , 76.7   , 70.6   , 72.9   , 73     , 74.3   , 71.2   , 68.9   , 73.8   , 68.6   , 73.5   , 77.8   , 78.1   , 76.3   , 59.4   , 73.9   , 73.2   , 70.7   , 68     , 68.4   , 67.7   , 65.9   , 59.1   , 58.8   , 67.6   ,
         '6E46a', 22.7   , 24.4   , 20.9   , 21.7   , 19.2   , 17.6   , 15.8   , 17.5   , 22.1   , 21.5   , 26     , 21.9   , 20.2   , 21.2   , 12.2   , 15.1   , 16.7   , 17.7   , 17.6   , 12.5   , 13.8   , 22     , 32     , 33.5   , 25.5   , 17.7   , 25.4   , 16.3   , 22.2   , 20     , 17.7   , 10.3   , 10.5   , 10.5   , 15.8   , 21.2   , 18.5   ,
         '6E46b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 45.8   , 50.2   , 53.5   , 43.8   , 46     , 73.1   , 85.2   , 45.8   , 41.5   , 28.9   , 33.1   , 37.8   , 48.2   , 33.1   , 27.9   , 41.4   ,
         '6E46c', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 24.6   , 17.5   , 15.5   , 14     , 7.4    , 2.4    , 13.6   , 14.4   , 11     , 10.9   , 14.1   , 12.2   , 13.1   , 7.8    , 4.8    , 4.8    ,
         '6E46d', 43.8   , 44     , 45.8   , 50.4   , 47.5   , 39.8   , 46.9   , 45.7   , 39.6   , 39.7   , 40.7   , 43     , 39.4   , 36.8   , 44.3   , 36.9   , 34.6   , 37.9   , 37.2   , 39.1   , 37.7   , 41.5   , 28.3   , 26.1   , 37.4   , 39.1   , 34     , 31.4   , 38.8   , 30.2   , 31.2   , 40     , 31.4   , 23.6   , 40     , 30.3   , 45.5   ,
         '6E51a', 16     , 15.9   , 15.1   , 13.1   , 12.8   , 13.6   , 14.1   , 14.5   , 17     , 17.8   , 15.4   , 16.5   , 15.4   , 15.3   , 15.3   , 14.4   , 17.1   , 16.6   , 15.5   , 14.7   , 16.1   , 19.5   , 19.6   , 18     , 18.2   , 18.5   , 19.6   , 18.5   , 17.6   , 18.8   , 18     , 18.4   , 18.2   , 18.7   , 20.7   , 19.1   , 19.2   ,
         '6E52a', 6      , 6      , 5.8    , 5.9    , 7.3    , 7.2    , 5.9    , 8.9    , 4.3    , 5      , 5.4    , 5.8    , 6.3    , 6.8    , 7.3    , 6.9    , 6.6    , 7.3    , 5.5    , 5.7    , 4.7    , 9.5    , 9.9    , 9.9    , 10     , 8.2    , 10.8   , 9.4    , 9.4    , 12.4   , 11.1   , 9.8    , 9      , 10.6   , 9      , 11.9   , 10.6   ,
         '6E53a', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0      , 0      , 0      , 7.8    , 0      , 0      , 0      , 11.8   , 4.9    , 0      , 0      , 0      , 0      , 0      , 0      , 0      ,
         '6E53b', 54     , 44.7   , 38.6   , 42.6   , 46.4   , 45     , 47.1   , 47.5   , 42.6   , 46.4   , 43.1   , 42.6   , 40.9   , 43.8   , 43.1   , 44.9   , 41.3   , 40.3   , 43.3   , 43.4   , 41.3   , 41.2   , 35.3   , 40.1   , 37.9   , 35.1   , 37.4   , 36.1   , 35.7   , 37.8   , 37.3   , 38.3   , 37.5   , 36.9   , 38.7   , 37.3   , 37.3   ,
         '6E61a', 0.5    , 0.2    , 0.2    , 0      , 0.5    , 0.2    , 0.7    , 0      , 0.2    , 0.3    , 0.3    , 0      , 0.3    , 0.7    , 1.6    , 1.7    , 1.5    , 0.6    , 0.7    , 0.4    , 0.6    , 0.9    , 0.8    , 0.1    , 0.5    , 0.2    , 1.2    , 0.6    , 0.3    , 0.9    , 0.5    , 2      , 0.9    , 0      , 1.1    , 1.4    , 0.3    ,
         '6E61b', 2.5    , 2.3    , 1.9    , 1.6    , 1.9    , 2.6    , 2.4    , 2.2    , 1.7    , 2.3    , 1.8    , 3.7    , 5.1    , 7.1    , 6.8    , 6.9    , 5.4    , 6.3    , 6.3    , 6.9    , 5.8    , 9      , 6.1    , 8.1    , 6.9    , 6.9    , 5.9    , 3.7    , 4.3    , 9.2    , 7.3    , 5.8    , 7.7    , 8      , 10.7   , 8.6    , 11.3   ,
         '6E62a', 2.5    , 2.2    , 2      , 0.7    , 1.2    , 0.3    , 0      , 1.4    , 2.5    , 2.9    , 2      , 2.3    , 2.5    , 3.2    , 2      , 3.6    , 2.6    , 2.7    , 4.2    , 2.3    , 1.5    , 6.6    , 3.8    , 2      , 0.3    , 2.9    , 1.8    , 1.7    , 4.8    , 4.9    , 1.5    , 4.6    , 4.5    , 4      , 2.9    , 3.5    , 2      ,
         '6E63a', 2.1    , 1.6    , 6.7    , 6.1    , 6.2    , 0.9    , 6      , 9.7    , 1.9    , 0.9    , 11.1   , 10.7   , 9.7    , 3.6    , 11.5   , 8.3    , 5.1    , 8.6    , 8.4    , 5.1    , 5.8    , 9.5    , 17.3   , 10.1   , 3.8    , 12.2   , 13.1   , 17.3   , 14.6   , 15.3   , 18.1   , 14.6   , 15.9   , 16     , 16.2   , 20.9   , 19.3   ,
         '6E64a', 66.4   , 69.3   , 69.7   , 69.1   , 69.7   , 68.1   , 69     , 65.4   , 73.4   , 74.9   , 75     , 69.4   , 73.1   , 70.3   , 68.7   , 69.5   , 70.1   , 71.7   , 71.2   , 67.9   , 67.6   , 70.2   , 69.1   , 64.4   , 67.8   , 68.7   , 68.6   , 69.9   , 71.9   , 72.3   , 69.3   , 66.6   , 68     , 69.3   , 70     , 67.1   , 67.4   ,
         '6E64b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 10.9   , 4.3    , 2.7    , 3.8    , 5      , 7.4    , 9.7    , 9.1    , 14.4   , 19.5   , 9.9    , 4.5    , 5.3    , 5.6    , 6.3    , 4.4    ,
         '6E65a', 52.7   , 53.3   , 48.6   , 53     , 53.8   , 48.9   , 47     , 54.9   , 53.7   , 49.2   , 52.4   , 60.1   , 65     , 66.6   , 58.2   , 60.6   , 58.2   , 60.1   , 49.2   , 52.9   , 52.2   , 49.3   , 53.7   , 56.9   , 47.8   , 46.7   , 53.5   , 48.3   , 40.7   , 50.3   , 44.6   , 45     , 51.8   , 52.1   , 43.6   , 49.1   , 52.5   ,
         '6E71a', 0.9    , 1      , 1.6    , 1.7    , 2.4    , 3.1    , 2.8    , 1.6    , 1.4    , 0.9    , 3.8    , 1.8    , 1      , 0.6    , 0.7    , 2      , 2.3    , 2.7    , 1.6    , 0.5    , 1.2    , 4.3    , 3.4    , 2.4    , 5.4    , 5.3    , 4.2    , 4.2    , 3.6    , 4.1    , 2.9    , 3.6    , 5.6    , 4.1    , 3.1    , 3.8    , 4.7    ,
         '6E71b', 0      , 2.4    , 1.4    , 3.8    , 2.6    , 2.6    , 2.6    , 2.4    , 2.3    , 0.8    , 3.1    , 1.3    , 0.5    , 0.6    , 0.5    , 0      , 0      , 0.6    , 1.1    , 2.6    , 2.1    , 3.6    , 3.1    , 0.4    , 0      , 2.6    , 5.2    , 1.5    , 3.7    , 2.4    , 2      , 2.9    , 5.7    , 4.2    , 4.4    , 1.8    , 3      ,
         '6E71c', 1.8    , 1.4    , 0.8    , 2      , 1.3    , 2.5    , 1.4    , 1.8    , 1.3    , 0.6    , 0.6    , 1      , 2.5    , 3.3    , 2      , 1.6    , 4.4    , 2.1    , 1.8    , 0.5    , 1.1    , 4.7    , 1.5    , 1.1    , 2.4    , 3.1    , 0.9    , 2.1    , 2.6    , 0.4    , 2.3    , 6.1    , 8.4    , 6.2    , 4.5    , 3.6    , 2.1    ,
         '6E71d', 0      , 1.1    , 3.4    , 0      , 2.6    , 2.8    , 2.3    , 0.9    , 1.9    , 1.1    , 2.1    , 1.4    , 4.7    , 2      , 0.7    , 0      , 0      , 0      , 0      , 1.6    , 0      , 5.6    , 2.9    , 2.1    , 0      , 2.5    , 1.2    , 0.7    , 1.7    , 0.1    , 0.7    , 4      , 3.8    , 4.4    , 5.6    , 5.2    , 4.8    ,
         '6E71e', 1.4    , 0.8    , 0.8    , 1.6    , 3.6    , 2.4    , 3.1    , 2.5    , 2.8    , 3.5    , 3.9    , 4.5    , 5.6    , 6.4    , 1.3    , 3.3    , 2.5    , 1.8    , 5.5    , 1.1    , 1.2    , 4      , 5.3    , 7.5    , 9.5    , 5.6    , 6.1    , 6.1    , 5.4    , 5      , 6.2    , 8      , 9.6    , 8.7    , 9.1    , 6.9    , 10.7   ,
         '6E71f', 0      , 0      , 2.1    , 3.9    , 5.7    , 5.7    , 7.1    , 5.2    , 5.2    , 0      , 2.2    , 5.6    , 6.8    , 3.1    , 7.2    , 4.9    , 7.5    , 10.1   , 6.1    , 4.1    , 0      , 1.3    , 7.9    , 7      , 8.8    , 2.1    , 4.7    , 8.5    , 3.2    , 1.9    , 2.4    , 3.3    , 3.5    , 9.3    , 6.2    , 11.1   , 15.5   ,
         '6E71g', 7.9    , 7.7    , 6.1    , 0      , 3.6    , 8.7    , 2.2    , 2      , 6.2    , 1.7    , 1.2    , 6      , 3      , 2.4    , 0      , 7.3    , 1.5    , 3.2    , 2.4    , 4.9    , 5.7    , 1.2    , 0      , 0      , 3.7    , 3.3    , 5      , 4.1    , 5.9    , 8.1    , 5      , 4.8    , 1.2    , 2.1    , 4      , 8      , 5.7    ,
         '6E72a', 4.4    , 0      , 0      , 0      , 0      , 3.1    , 0      , 8.3    , 0      , 0      , 0      , 10     , 4.7    , 0      , 5.1    , 3.9    , 0      , 0      , 5      , 6      , 0      , 0      , 0      , 4.8    , 16.2   , 0      , 5.4    , 4      , 0      , 4.8    , 0      , 0      , 3.9    , 17.1   , 3.6    , 0      , 11     ,
         '6E72b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0      , 0      , 0      , 2.9    , 15.9   , 12.6   , 2.3    , 0      , 0      , 0      , 0      , 0.9    , 3.9    , 7.5    , 0      , 3.7    ,
         '6E72c', 3.6    , 2      , 3.9    , 5.7    , 7.6    , 7.1    , 8.9    , 8      , 9.4    , 10.6   , 3.6    , 6.2    , 7.7    , 14.4   , 7.7    , 9.2    , 9.8    , 9.3    , 16.6   , 10.2   , 6.2    , 6      , 2.6    , 23.7   , 13.9   , 2.8    , 6.2    , 15     , 8.7    , 3.2    , 4.8    , 5      , 10.9   , 12.6   , 12     , 10.9   , 13.5   ,
         '6E73a', 39.1   , 48.2   , 48.1   , 54.1   , 43.9   , 42.2   , 35.8   , 46.2   , 46.7   , 47.2   , 40.3   , 44     , 39.6   , 38.8   , 45.6   , 43.8   , 58.4   , 61.4   , 48.2   , 48.7   , 52     , 69.6   , 55.2   , 54.2   , 64.9   , 60.5   , 53.6   , 60.1   , 69     , 80.4   , 82.8   , 74.2   , 78.9   , 81.1   , 70.8   , 76.5   , 90.5   ,
         '6E74a', 0      , 1.6    , 3.2    , 5.8    , 2      , 3      , 0      , 4.1    , 4.9    , 4.9    , 4.3    , 4.3    , 4      , 3.3    , 3      , 3.9    , 4.7    , 6.7    , 1.5    , 0      , 10.9   , 16.4   , 15.3   , 21.7   , 15.7   , 12     , 13.7   , 7.2    , 11.2   , 17.3   , 24.4   , 41.4   , 28     , 24.8   , 27.1   , 29.5   , 26.4   ,
         '6E74b', 0      , 8.4    , 0      , 0      , 0      , 0      , 0      , 0      , 3.6    , 0      , 16.8   , 8.8    , 6.6    , 9.5    , 9.3    , 8.7    , 0      , 0      , 0      , 0      , 0      , 40.2   , 31.8   , 41.7   , 0      , 0      , 0      , 0      , 4.4    , 17.1   , 13     , 2      , 11.7   , 3      , 20.6   , 25.3   , 5.1    ,
         '6E75a', 16.5   , 15     , 16.4   , 13.5   , 11.7   , 14.5   , 15.5   , 19.7   , 11.4   , 9.6    , 11.2   , 11.4   , 12.4   , 11.1   , 12.2   , 13.4   , 14.3   , 12.5   , 18.9   , 13.3   , 19.6   , 33.6   , 29.8   , 31.6   , 27.6   , 20.8   , 12.3   , 18.2   , 23.1   , 34.1   , 29.9   , 39.1   , 36     , 36.2   , 37.8   , 34.6   , 32.9   ,
         '6E75b', 16.9   , 12.4   , 10.2   , 13.6   , 16     , 17.4   , 20     , 12.9   , 7.3    , 8.4    , 4.4    , 10.8   , 10.5   , 8.4    , 8.1    , 7.1    , 11.8   , 5.8    , 12.6   , 12.7   , 13.4   , 15.2   , 15.8   , 16.5   , 25     , 20.1   , 27.4   , 10.1   , 7.3    , 8.1    , 10.1   , 15.3   , 12.1   , 13.3   , 14.1   , 27.8   , 17.3   ,
         '6E75c', 18.5   , 21.7   , 15.9   , 16.1   , 25.2   , 23.9   , 24.6   , 36     , 18     , 28.5   , 17.6   , 23.8   , 27.1   , 27.6   , 9.6    , 7.4    , 1.2    , 1.8    , 3.6    , 25     , 15.6   , 23.4   , 21.2   , 11.7   , 40.5   , 30.7   , 34.3   , 23.4   , 26.5   , 23.8   , 36.1   , 24.4   , 35.8   , 26.4   , 20.2   , 9.2    , 15.4   ,
         '6E75d', 30     , 24.3   , 15.6   , 0      , 19.6   , 18.5   , 22.9   , 23.3   , 26.5   , 11     , 16.8   , 26.2   , 39.4   , 13.9   , 18.9   , 36.1   , 0      , 22.8   , 24.6   , 40.7   , 19.8   , 43.9   , 51.4   , 31.9   , 37.3   , 15.6   , 37.8   , 31.1   , 34.2   , 17.8   , 23     , 29.4   , 29.5   , 32.1   , 26.1   , 24.4   , 24.3   ,
         '6E76a', 2.8    , 2.7    , 3.8    , 3.4    , 6.1    , 8.5    , 7.4    , 5.1    , 2.4    , 4.6    , 7.2    , 6      , 2.9    , 1.1    , 3.6    , 6      , 3.4    , 3.8    , 4.3    , 3      , 4.2    , 6      , 13.9   , 11.2   , 8.3    , 7      , 7.9    , 3.4    , 3.4    , 5      , 8.1    , 10.4   , 9.5    , 13     , 10.5   , 5.3    , 4.8    ,
         '6E76b', 3      , 3.4    , 0      , 0      , 0      , 0      , 0      , 4      , 4.5    , 8.5    , 6.4    , 0      , 0      , 0      , 0      , 0      , 0      , 3.4    , 3.2    , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 6.4    , 14.6   , 3.1    , 0      , 0      , 2.3    , 0.9    , 0      , 2.1    , 1.3    ,
         '6E76c', 0      , 6      , 4.6    , 4      , 3.1    , 3.4    , 14.3   , 12.9   , 4.1    , 4.1    , 6.5    , 6.6    , 0      , 4.2    , 2.7    , 1      , 6.4    , 1.3    , 0      , 3.8    , 6.5    , 0      , 19.6   , 19.5   , 16.4   , 5.6    , 14.3   , 11.8   , 3.1    , 13     , 16.5   , 4.5    , 4.7    , 14.4   , 13.4   , 14.4   , 15.9   ,
         '6E77a', 6.3    , 13.8   , 17.9   , 8.6    , 13.2   , 13.1   , 14     , 12.5   , 12.1   , 12.2   , 16.1   , 16.4   , 13.2   , 13.5   , 16     , 15.3   , 7.3    , 10.1   , 11.6   , 13.2   , 15.9   , 17.3   , 15.7   , 20.5   , 13.6   , 5.4    , 9.1    , 13.2   , 14.3   , 6.2    , 10     , 9.8    , 13.8   , 19.3   , 11     , 10.2   , 8.1    ,
         '6E77b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 18.6   , 14.4   , 0      , 0      , 0      , NA, 0      , 0      , 0      , 29.4   , 8.2    , 37.3   , 0      , 0      , 0      , 0      ,
         '6E77c', 6.5    , 10     , 8.8    , 8.2    , 8.8    , 7.5    , 6.6    , 8.4    , 5      , 7.4    , 5.8    , 3.8    , 8.1    , 6.9    , 5.3    , 10.4   , 8.3    , 16.2   , 14.7   , 12.9   , 11.7   , 8      , 7.1    , 3.9    , 11.5   , 4.6    , 11.2   , 10.4   , 7.5    , 7.3    , 8.7    , 10.6   , 12     , 11.9   , 7.6    , 11.5   , 10.8   ,
         '6E78a', 13.5   , 5.1    , 11.9   , 10.8   , 22     , 12.3   , 23.2   , 25.7   , 14.9   , 10.9   , 12.8   , 11     , 18.5   , 15.5   , 14.2   , 10.7   , 17.9   , 15.7   , 11.6   , 24.9   , 16     , 31.8   , 34.7   , 19.5   , 15.1   , 20.2   , 25.3   , 46.1   , 28.9   , 32.6   , 35.7   , 36.2   , 25.6   , 12.7   , 30.9   , 31.6   , 22.1   ,
         '6E78b', NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 24.8   , 31     , 16.3   , 12     , 10     , 15.6   , 14.2   , 12.5   , 31.5   , 41     , 42.4   , 32.2   , 15.2   , 14     , 41.9   , 48.1   ,
         '6E78c', 25.2   , 30.1   , 22.1   , 24.7   , 22.7   , 20.3   , 24.1   , 17.8   , 24.6   , 18     , 24.9   , 32.1   , 27.5   , 32.7   , 27.3   , 34.3   , 34.7   , 26.8   , 24.2   , 22.3   , 30.3   , 48.7   , 48.4   , 42.7   , 50.8   , 41.5   , 45.4   , 60     , 54.9   , 55.2   , 43.8   , 38.5   , 45.7   , 57.9   , 71.8   , 63.2   , 43.6   ,
         '6E78d', 15.3   , 16.5   , 25.9   , 19     , 22     , 20.6   , 18     , 16     , 16.3   , 21.2   , 26.8   , 13.8   , 14.4   , 18.5   , 19.8   , 23.2   , 6.7    , 14.4   , 5.2    , 24.3   , 22.2   , 24.5   , 5.6    , 5.9    , 34.3   , 27.5   , 18.6   , 28.1   , 26     , 36.6   , 35.4   , 32.1   , 45.9   , 34.9   , 30.9   , 42.4   , 37.1   ,
         '7K11a', 27.9   , 35.1   , 30.5   , 32.6   , 30.2   , 31.3   , 30.2   , 29.8   , 30.7   , 31.5   , 29.3   , 27.9   , 27.3   , 27.1   , 27.4   , 24.1   , 25.6   , 24.8   , 27.6   , 22.8   , 24.7   , 19.6   , 21.1   , 26.3   , 24.7   , 19.6   , 12.3   , 18.3   , 16.4   , 20.5   , 19.8   , 18.5   , 22.6   , 22.1   , 22     , 22.2   , 21     ,
         '7K11b', 39.1   , 36.1   , 40.2   , 40.6   , 32.7   , 35.1   , 38.8   , 37.1   , 37.1   , 37.4   , 34.6   , 35.7   , 36.8   , 34.4   , 36.9   , 37     , 32     , 31.9   , 19.7   , 38.4   , 44.5   , 20.3   , 23.5   , 19.8   , 16.1   , 24.2   , 27.3   , 12.3   , 20.7   , 29.2   , 30.1   , 27     , 31.7   , 24.3   , 23.1   , 28.1   , 31.9   ,
         '7K11c', 34     , 29.5   , 31.7   , 33.1   , 31.6   , 27.5   , 34.6   , 37.2   , 37.1   , 37.4   , 35     , 34.6   , 37.3   , 39.2   , 36.4   , 33.8   , 32.1   , 33.7   , 27.7   , 33.6   , 36.7   , 20.5   , 23.9   , 15.3   , 19.4   , 21.2   , 21     , 23     , 16     , 25     , 25.9   , 26.5   , 23.1   , 31.9   , 20.6   , 20.1   , 27.8   ,
         '7K11d', 33.6   , 38     , 35.2   , 36.4   , 32.4   , 38.5   , 32.3   , 35.6   , 34.2   , 34.6   , 35.4   , 30.9   , 35.3   , 34.8   , 31.8   , 33.8   , 31     , 33.3   , 30.1   , 29.8   , 28.1   , 22.2   , 23.7   , 26.1   , 17.7   , 24.5   , 32     , 25.1   , 20.2   , 16.7   , 20.7   , 21.1   , 26.3   , 28     , 27.5   , 29.5   , 25.9   ,
         '7K11e', 34.5   , 45.4   , 47.4   , 39.4   , 37.3   , 38.4   , 39.4   , 38     , 38.9   , 43.7   , 37.9   , 38.1   , 34     , 40.1   , 39.8   , 38.5   , 35.9   , 38.3   , 30.3   , 41.8   , 25.7   , 19.5   , 19.1   , 17.3   , 31.9   , 40.3   , 7.7    , 17.6   , 24.9   , 13.8   , 17.9   , 25.8   , 21.1   , 33.4   , 24.4   , 19.1   , 27.4   ,
         '7K11f', 35.8   , 36.5   , 38.1   , 37.4   , 36.9   , 37.2   , 37.5   , 35.7   , 34.4   , 34.7   , 35.2   , 37.4   , 33.6   , 32.2   , 33.1   , 33     , 33.3   , 31.8   , 30.6   , 31.9   , 31.9   , 20.7   , 19.5   , 19.6   , 20     , 23.5   , 24.6   , 26.2   , 23.4   , 12.9   , 27.8   , 28     , 26.2   , 24     , 24.6   , 23.2   , 21.2   ,
         '7K12a', 36.1   , 35.2   , 36.3   , 41.1   , 35.2   , 32.3   , 33.2   , 32.4   , 34.2   , 32.7   , 41.8   , 40.6   , 42.5   , 40.3   , 27.8   , 31.3   , 31.1   , 43     , 40.8   , 35.4   , 34.4   , 35.5   , 35.5   , 34.4   , 38     , 45.6   , 18.4   , 18.8   , 20.9   , 44.1   , 26.8   , 4.9    , 30.3   , 34     , 25.3   , 12.6   , 23.2   ,
         '7K12b', 21.1   , 18.7   , 33.9   , 24.2   , 39.4   , 43.3   , 44.6   , 40.4   , 48.1   , 32.6   , 29.6   , 37     , 45     , 50.5   , 60.9   , 36.9   , 26.1   , 15.1   , 51.9   , 38.7   , 27.2   , 100    , NA, 0      , 0      , NA, 100    , 100    , NA, 100    , 45.6   , 30.9   , 34.6   , 45.3   , 40.8   , 43.2   , 28.7   ,
         '7K12c', 26.9   , 27.1   , 25     , 21.1   , 34.3   , 39.1   , 36.7   , 32.3   , 31.9   , 35.4   , 33.2   , 26.2   , 28.8   , 35.9   , 40.5   , 38.9   , 46.8   , 40.4   , 37     , 33.6   , 33     , 14.2   , 29.6   , 2.6    , 4.3    , 11.5   , 30.2   , 36.2   , 42.5   , 36.1   , 29.6   , 27.1   , 24.1   , 19.8   , 37.5   , 23.4   , 29.5   ,
         '7K12d', 40.1   , 40.7   , 39.3   , 41.4   , 41.2   , 40.7   , 35.7   , 37.3   , 38.7   , 40     , 39.3   , 37.3   , 39.5   , 35.9   , 36.6   , 36.1   , 40.5   , 34.6   , 37.6   , 37.8   , 35.3   , 29.6   , 35.2   , 27.8   , 40.3   , 34.2   , 31.8   , 25.2   , 31.5   , 30.5   , 27.6   , 28     , 28.9   , 32.3   , 26.4   , 27.9   , 32.2   ,
         '7K12e', 40.3   , 43.5   , 27.4   , 42.5   , 42.1   , 44.9   , 36     , 37.4   , 52.6   , 58.2   , 40.7   , 47.9   , 43.9   , 22.1   , 51.9   , 31.9   , 52.2   , 23.8   , 53.5   , 58.4   , 42.2   , 0      , 0      , 12.4   , 30.9   , 100    , 82.1   , 47.2   , 43.7   , 32.4   , 38.8   , 19.9   , 90.2   , 78.4   , 80.4   , NA, 12.2   ,
         '7K12f', 40.7   , 40.7   , 41.6   , 39     , 38.2   , 35.9   , 39.2   , 37.6   , 39.1   , 39.3   , 41.3   , 41.3   , 38     , 38.3   , 37.8   , 36.1   , 33.8   , 35.9   , 35.6   , 38.6   , 36.4   , 32     , 39     , 56.1   , 35.3   , 25.2   , 41.5   , 29.7   , 18     , 14.4   , 28.5   , 34.2   , 26.6   , 37.4   , 16.8   , 21.1   , 11.9   ,
         '7K12g', 4.5    , 16.5   , 4.5    , 18.9   , 11.6   , 13.7   , 17.8   , 5.9    , 29.8   , 16.2   , 20.7   , 11.2   , 0      , 19.7   , 9.2    , 11.2   , 12.7   , 0      , 17.4   , 8.3    , 3.4    , 37.4   , 35.4   , 22     , 16.1   , 28.3   , 15.5   , 14     , 26     , 15.5   , 11.5   , 8.3    , 15.7   , 9.1    , 17.6   , 17.2   , 15.4   ,
         '7K12h', 7.1    , 10.5   , 9.9    , 5.9    , 12.5   , 7.6    , 6.6    , 5.7    , 6.4    , 5.5    , 4.6    , 7.6    , 8.7    , 4      , 8.1    , 11.2   , 5.4    , 12.3   , 3      , 5.6    , 4.2    , 2.9    , 15.6   , 2      , 4.3    , 8.4    , 23.4   , 19.6   , 1      , 16.5   , 6.8    , 4.8    , 0      , 0.2    , 0.5    , 1.9    , 7.4    ,
         '7K12i', 21.1   , 20.7   , 13.4   , 19.9   , 3.2    , 21.3   , 13.5   , 18.3   , 21.3   , 23.1   , 24     , 21.8   , 25.3   , 28.8   , 21.6   , 26     , 20.7   , 23.3   , 8.5    , 6.4    , 16.7   , 30.4   , 20.6   , 14.3   , 15.8   , 12.7   , 18.9   , 16.2   , 11.7   , 22.2   , 27.3   , 26.7   , 30.7   , 23.2   , 32.3   , 21.3   , 0      ,
         '7K13a', 40.1   , 41     , 44.1   , 43.2   , 44.8   , 37.4   , 39.2   , 38.4   , 43.2   , 38     , 46     , 51     , 46     , 50.6   , 44.5   , 43.2   , 43.2   , 43.8   , 45     , 38.3   , 43.1   , 44.2   , 47.3   , 30.8   , 29.9   , 33     , 41     , 41.4   , 35.8   , 35.7   , 37.4   , 32.1   , 20     , 22     , 24.9   , 23.6   , 23.2   ,
         '7K13b', 44.8   , 39.6   , 38.3   , 40.6   , 42     , 41     , 43.2   , 39.7   , 36.2   , 39.9   , 41.8   , 35.8   , 44.7   , 57.8   , 47.8   , 46.1   , 31.4   , 39.9   , 28.2   , 36.8   , 34.8   , 30.2   , 50.9   , 53     , 37.7   , 52.9   , 48.1   , 17.7   , 33.7   , 27.6   , 31.6   , 42.5   , 42.9   , 34.6   , 32.4   , 42.7   , 53.8   ,
         '7K13c', 29.7   , 34.6   , 29.8   , 29.1   , 32.9   , 32.6   , 37.1   , 42.9   , 37.4   , 44.6   , 43.3   , 47.5   , 47.4   , 47.5   , 48.6   , 52.4   , 38.6   , 43.9   , 48.5   , 40.6   , 43.7   , 45.2   , 45.1   , 50.2   , 40.4   , 37.5   , 31.6   , 35.9   , 32.8   , 33     , 33     , 33     , 41.7   , 37.8   , 31.3   , 33.3   , 28     ,
         '7K13d', 43.3   , 44     , 42.4   , 45.2   , 40.9   , 41.5   , 44     , 44.3   , 44.1   , 46.3   , 47.6   , 53.6   , 53.3   , 52.9   , 51.6   , 53.2   , 43     , 45.8   , 39.7   , 40.2   , 40.5   , 52.2   , 45.8   , 40.4   , 37.6   , 35.4   , 46.1   , 44.5   , 38.8   , 37.6   , 37.1   , 36.6   , 39.5   , 33.8   , 37.1   , 33.2   , 24.2   ,
         '7K13e', 51     , 49.8   , 54.5   , 50.2   , 55     , 35     , 35.9   , 38     , 30.4   , 52.5   , 50.7   , 54.7   , 43.7   , 48.2   , 57     , 47.4   , 35.1   , 46.3   , 51.3   , 71.6   , 70.7   , 46.5   , 46.4   , 48.4   , 45.7   , 36.4   , 36.6   , 42.7   , 48.5   , 46.9   , 46.7   , 44.7   , 43.4   , 52.9   , 53.4   , 41.8   , 36.2   ,
         '7K13f', 41.4   , 42.5   , 43.3   , 41.3   , 42.2   , 40.2   , 38.2   , 41.3   , 39.1   , 43     , 41.1   , 41.2   , 40.8   , 43.6   , 41.3   , 46.3   , 45.5   , 47.1   , 45.4   , 37.5   , 38.9   , 44     , 47.9   , 38.3   , 43.3   , 42.6   , 34.7   , 22.7   , 39.4   , 40.9   , 30.3   , 31     , 27.8   , 19.6   , 23.2   , 27.1   , 31     ,
         '7K20a', 4.8    , 0      , 1      , 2.8    , 4.4    , 3.4    , 5.1    , 4.9    , 0      , 2.1    , 0      , 2.5    , 0      , 0      , 0      , 0      , 0      , 2      , 1.8    , 5.5    , 3.6    , 1.1    , 1.2    , 1.3    , 7.1    , 5.1    , 0      , 0      , 0      , 3.5    , 3.6    , 0      , 0      , 0      , 0      , 0      , 2.6    ,
         '7K20b', 19.3   , 20     , 17.3   , 9.2    , 21.9   , 23.2   , 20.5   , 16.7   , 19.2   , 24.3   , 27.3   , 30.4   , 22.5   , 27.6   , 26.8   , 27     , 26.9   , 30.2   , 29.3   , 32.6   , 30     , 30.1   , 41.1   , 39.5   , 26.7   , 36.6   , 25.4   , 33.9   , 32.6   , 35.7   , 35.5   , 32.8   , 29.7   , 35.7   , 31.9   , 38.8   , 38     ,
         '7K20c', 26.6   , 23.5   , 26.2   , 31     , 35.5   , 38.6   , 34.6   , 33     , 31.8   , 36.1   , 35.8   , 38.4   , 33.8   , 36.6   , 35.2   , 37.1   , 36.6   , 43.7   , 47.6   , 42.3   , 42.4   , 36.8   , 50.7   , 44.4   , 46.6   , 45     , 52.6   , 43     , 41     , 43.6   , 40.9   , 40.6   , 35.4   , 40.7   , 42.1   , 53.8   , 42.8   ,
         '7K20d', 28.3   , 23.3   , 24.6   , 33.6   , 27.4   , 37.1   , 31.1   , 38.8   , 29.1   , 33     , 29.3   , 30.6   , 29.7   , 27.9   , 27.4   , 26.5   , 27.1   , 26.4   , 30.6   , 31.2   , 28.1   , 32.3   , 34.4   , 37.4   , 34.8   , 38.1   , 38.9   , 32.7   , 35.9   , 41.8   , 39.7   , 32.9   , 30.7   , 34.6   , 29.7   , 27.7   , 29     ,
         '7K20e', 34.9   , 16.8   , 13.3   , 12.9   , 14.9   , 17.5   , 13.5   , 13.5   , 16.9   , 18.6   , 17.5   , 17.2   , 16.5   , 9.6    , 20.1   , 23.7   , 19.2   , 16     , 15.3   , 17.7   , 20     , 20.9   , 21.6   , 24.7   , 27.3   , 32.1   , 27     , 25     , 22.3   , 22.4   , 23.2   , 20     , 22     , 20.9   , 19     , 18     , 21.9   ,
         '7K20f', 2.1    , 0      , 0      , 4      , 3.5    , 1.8    , 0      , 1.4    , 2.5    , 3.5    , 4.5    , 0      , 0      , 5.6    , 2      , 0      , 2.3    , 1.8    , 2.2    , 0      , 0      , 3.8    , 7.5    , 7.3    , 0.2    , 0      , 0.4    , 1.5    , 0.3    , 1.8    , 0      , 1.8    , 1.4    , 1.8    , 2.9    , 2.7    , 0      ,
         '7K20g', 16.6   , 22.4   , 20.6   , 13     , 18.6   , 13.2   , 11.6   , 10.8   , 11.3   , 16.5   , 15.8   , 15.6   , 15.2   , 6.9    , 16.5   , 23.2   , 25.8   , 20.4   , 13     , 13.9   , 16.2   , 11.8   , 15.4   , 6.3    , 16.1   , 10.9   , 8.6    , 19.3   , 6.3    , 19.6   , 17     , 6.1    , 13.9   , 16.5   , 10.9   , 7.3    , 3.1    
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



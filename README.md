
<!-- df_print: !expr print_tab <- function(x) kableExtra:::knit_print.kableExtra(kableExtra::kable_classic(kableExtra::kable(x), lightable_options = 'hover', full_width = FALSE, html_font = 'DejaVu Sans Condensed')) -->
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pcspp : PCS recodées pour comparaison public-privé

<!-- badges: start -->
<!-- badges: end -->

À partir du niveau détaillé de la [nomenclature des
PCS](https://www.nomenclature-pcs.fr/) de l’INSEE, ce package fournit
une nouvelle nomenclature destinée à faciliter la comparaison entre
salarié·es des administrations publiques et salarié·es des entreprises
en France.

## Installation

Installer pcspp à partir de github avec :

``` r
# install.packages(devtools)
devtools::install_github("BriceNocenti/pcspp")
```

## Usage

Pour ajouter les variables PcsPP dans une base de données, à partir de
la PCS « à quatre chiffre » (profession détaillée) et d’une variable
permettant de distinguer les administrations publiques des entreprises :

``` r
data <- data |> 
  pcspp::pcspp(profession = P, admin_ent = EMP_ADM_ENT, 
               nomenclaturePCS = "2003", sexeEE = 2018L)
```

Pour le détail du fonctionnement de cette fonction voir la documentation
:

``` r
?pcspp::pcspp
```

Cf. également la [table de passage entre nomenclature PCS et
PcsPP](https://github.com/BriceNocenti/pcspp/blob/main/resources/PcsPP_PCS_tab.xlsx),
au niveau des professions détaillées.

### `PPP1` : sept groupes socioprofessionnels agrégés

Le premier niveau des PcsPP, en sept catégories, est un peu différent
des six groupes socioprofessionnels classiques de la nomenclature PCS.

**Tableau 1. CSP recodée agrégée PPP1 en fonction du type d’employeur en
2018**

<div class="kable-table">

| PPP1                                                            | Administrations publiques | Entreprises | Indépendants | Total   |
|:----------------------------------------------------------------|:--------------------------|:------------|:-------------|:--------|
| 1-Chefs d’entreprise                                            | 0                         | 0           | 1 127        | 1 127   |
| 2-Cadres (et consultant·es libéra·les) ♂♀                       | 3 789                     | 18 766      | 947          | 23 502  |
| 3-Cols blancs subalternes ♂♀                                    | 4 381                     | 25 062      | 4 570        | 34 013  |
| 4-Professions organisées ♂♀                                     | 12 739                    | 6 368       | 4 543        | 23 650  |
| 5-Employées (dont artisanes des services, petites commerçantes) | 14 396                    | 30 098      | 7 367        | 51 861  |
| 6-Ouvriers (dont artisans)                                      | 2 479                     | 33 344      | 4 999        | 40 822  |
| 7-Agriculteurs et ouvriers agricoles                            | 42                        | 1 659       | 3 252        | 4 953   |
| NA                                                              | 41                        | 268         | 538          | 847     |
| Total                                                           | 37 867                    | 115 565     | 27 343       | 180 775 |

</div>

<font size=2> Source : INSEE, Enquête Emploi 2018. </font>

<font size=2> Champ : actifs occupés, France (hors Mayotte).</font>

Le niveau regroupé de la nomenclature des professions et catégories
socioprofessionnelles (PCS) s’avère ici peu adapté. Les « professions
intermédiaires » et les « cadres et professions supérieures » agrègent
des agent·es très inséré·es dans des organisations hiérarchisées, et des
professions organisées jouissant d’une forte autonomie collective
(médecins, enseignant·es, etc.) : les deux ont souvent des organisations
du travail éloignées, et leurs proportions s’avèrent très différentes
entre entreprises et administrations (en France il y a davantage de
professionnel·les reconnu·es dans le secteur public).

**Parmi les salariés**, nous utilisons donc ici les regroupements
suivants :

- **Cols-blancs** : il s’agit de l’ensemble des métiers qualifiés des
  entreprises et des administrations dévolus à des tâches
  d’organisation, de commandement, de gestion, de conception et de
  vente.

  - **Cadres** : le groupe des cadres au sens strict comprend les cols
    blancs du niveau de qualification supérieur. Son cœur est composé
    des CSP 33-Cadres de la fonction publique, 37-Cadres administratifs
    et commerciaux d’entreprise et 38-Ingénieurs et cadres techniques
    d’entreprise. Selon les recommandations du Conseil national de
    l’information statistique (Cnis) pour les « classes d’emploi », nous
    ajoutons plusieurs professions intermédiaires du public de catégorie
    A et apparentées du point du vue du diplôme et/ou du salaire :
    cadres de santé, cadres du social, cadres de l’armée (cf. AMOSSÉ T.,
    CHARDON O., EIDELMAN A. (2019), *La rénovation de la nomenclature
    socio-professionnelle*, Paris, Cnis).

  - **Cols blancs subalternes (CBS)** : ce sont les pendants des cadres
    au niveau de qualification inférieur : agents de maîtrise,
    techniciens, professions intermédiaires administratives et
    commerciales (CSP 45 à 48, anciens « cadres moyens » de la
    nomenclature de 1954).

- **Professions organisées** : elles désignent les métiers les plus
  reconnus et les plus encadrés juridiquement, généralement soumis à une
  stricte condition de diplôme : médecins, infirmières, enseignant·es ou
  encore journalistes (soit l’essentiel des CSP 31, 34, 35, 42 et 43).

- **Exécutant·es** : nous conservons ici les groupes socioprofessionnels
  habituels, **Ouvriers** et **Employées**.

De base les **consultants libéraux**, **professions libérales**,
**artisans des services**, **petits commerçants**, **artisans ouvriers**
sont classés dans les catégories desquelles ils sont les plus proches du
point de vue du revenu moyen, du niveau de diplôme et des trajectoires
professionnelles. Les indépendants sont ensuite distingués au niveau
`PPP2`, sauf parmi les professions organisées qui, dans la nomenclature
PCS, contiennent à la fois des salarié·es et des professions libérales.

Des analyses visant à comparer entreprises et administrations
commenceront donc souvent par **exclure les non salarié·es du champ**.

Les **Ouvriers agricoles** sont regroupés avec les **Agriculteurs**, de
manière à pouvoir les exclure du champ facilement.

### `FAPPP` : onze familles de métier comparables entre public et privé

Les professions des administrations publiques sont ventilées dans les
familles professionnelles du secteur marchand (nomenclature FAP), en
s’inspirant de la [nomenclature FaPFP des familles de métiers de la
fonction
publique](https://www.fonction-publique.gouv.fr/files/files/ArchivePortailFP/www.fonction-publique.gouv.fr/la-nomenclature-fapfp-de-familles-de-metiers-de-la-fonction-publique.html)
de la DGAFP.

La famille de métier forme la deuxième lettre du code PcsPP.

**Tableau 2. Onze filières professionnelles transversales**

<div class="kable-table">

| FAPPP                      | Administrations publiques | Entreprises | Indépendants | Total |
|:---------------------------|:--------------------------|:------------|:-------------|:------|
| A-Filière patronale        | 0%                        | 0%          | 4%           | 1%    |
| B-Filière commerciale      | 0%                        | 14%         | 16%          | 12%   |
| C-Filière financière       | 2%                        | 3%          | 0%           | 3%    |
| D-Filière administrative   | 21%                       | 18%         | 5%           | 17%   |
| E-Filière technique        | 10%                       | 44%         | 22%          | 34%   |
| F-Filière santé            | 18%                       | 5%          | 12%          | 9%    |
| G-Filière sécurité         | 8%                        | 1%          | 0%           | 2%    |
| H-Services à la personne   | 14%                       | 8%          | 23%          | 11%   |
| I-Filière éducation-social | 25%                       | 4%          | 2%           | 8%    |
| J-Autres professions intel | 1%                        | 1%          | 6%           | 2%    |
| K-Filière agricole         | 0%                        | 1%          | 10%          | 2%    |
| Total                      | 100%                      | 100%        | 100%         | 100%  |

</div>

<font size=2> Source : INSEE, Enquête Emploi 2018. </font>

<font size=2> Champ : actifs occupés, France (hors Mayotte).</font>

### `PPP2` : CSP détaillées transversales entre public et privé

Au deuxième niveau, la nomenclature des PCS (2 chiffres) distingue les
CSP du public, d’une manière qui rend difficile leur comparaison avec
les CSP des entreprises.

Le code `PPP2`, à trois chiffres (47 modalités), construit les
**catégories les plus détaillées et les plus homogènes possibles
regroupant salarié·es du public et salarié·es du privé**.

Il suffit alors de croiser `PPP2` avec une variable distinguant les
différents types d’employeurs pour effectuer une comparaison. Croisée
avec les filières professionnelles `FAPPP`, elle permet de comparer la
hiérarchie interne des métiers de chaque famille entre administrations
et entreprises.

**Tableau 3. Taux de féminisation par CSP recodée et employeur en 2018**

<div class="kable-table">

| PPP2                                  | CL         | État       | HP         | EntPub     | PME        | GE         |
|:--------------------------------------|:-----------|:-----------|:-----------|:-----------|:-----------|:-----------|
| Cadres commerciaux                    |            |            |            |            | 25%        | 25%        |
| CBS du commerce ♂♀                    |            |            |            | 51%        | 46%        | 54%        |
| Employées de commerce                 |            |            |            | 74%        | 77%        | 69%        |
| <b>TOTAL FILIÈRE COMMERCIALE</b>      | <b></b>    | <b></b>    | <b></b>    | <b>56%</b> | <b>56%</b> | <b>57%</b> |
| Inspecteurs/trices FiP, Cadres banque |            | 54%        |            |            | 50%        | 51%        |
| Contrôleurs/leuses FiP, CBS banque    |            | 59%        |            |            | 66%        | 68%        |
| Agentes adm. FiP, Employées banque    | 85%        | 64%        |            |            | 84%        | 76%        |
| <b>TOTAL FILIÈRE FINANCIÈRE</b>       | <b>87%</b> | <b>58%</b> | <b></b>    | <b>58%</b> | <b>64%</b> | <b>64%</b> |
| Cadres administratifs/tives           | 61%        | 53%        | 66%        | 50%        | 60%        | 50%        |
| CBS de bureau ♀                       | 70%        | 71%        | 82%        | 55%        | 73%        | 73%        |
| Employées de bureau                   | 81%        | 80%        | 87%        | 67%        | 88%        | 76%        |
| <b>TOTAL FILIÈRE ADMINISTRATIVE</b>   | <b>73%</b> | <b>67%</b> | <b>83%</b> | <b>60%</b> | <b>77%</b> | <b>66%</b> |
| Ingénieurs                            | 43%        | 39%        |            | 24%        | 21%        | 24%        |
| Agents de maîtrise                    |            |            |            | 18%        | 13%        | 15%        |
| Techniciens                           | 25%        | 35%        |            | 18%        | 15%        | 14%        |
| Ouvriers                              | 15%        |            | 27%        | 14%        | 19%        | 27%        |
| <b>TOTAL FILIÈRE TECHNIQUE</b>        | <b>19%</b> | <b>28%</b> | <b>32%</b> | <b>18%</b> | <b>18%</b> | <b>24%</b> |
| Cadres de santé ♀                     |            |            | 86%        |            | 91%        |            |
| Techniciennes médicales               |            |            | 76%        |            | 79%        |            |
| Médecins hospitalier·es               |            |            | 53%        |            |            |            |
| Médecins autres ♂♀                    |            |            |            |            | 67%        |            |
| Infirmières                           | 93%        | 95%        | 85%        | 94%        | 89%        | 88%        |
| Rééducatrices, pharma, psy…           | 77%        | 91%        | 88%        |            | 81%        | 86%        |
| Employées de santé                    | 96%        | 88%        | 89%        | 89%        | 85%        | 86%        |
| <b>TOTAL FILIÈRE SANTÉ</b>            | <b>94%</b> | <b>76%</b> | <b>82%</b> | <b>85%</b> | <b>83%</b> | <b>83%</b> |
| Policiers                             |            | 17%        |            |            |            |            |
| Militaires, gendarmes, pompiers       |            | 14%        |            |            |            |            |
| Agents de surveillance                |            |            |            |            | 15%        | 16%        |
| <b>TOTAL FILIÈRE SÉCURITÉ</b>         | <b>11%</b> | <b>15%</b> | <b></b>    | <b></b>    | <b>15%</b> | <b>16%</b> |
| Cadres hôtellerie restauration ♂      |            |            |            |            | 36%        |            |
| Maitrise hôtellerie restauration ♂♀   |            |            |            |            | 45%        | 36%        |
| Employées services à la personne      | 81%        | 73%        | 77%        | 70%        | 82%        | 81%        |
| <b>TOTAL SERVICES À LA PERSONNE</b>   | <b>81%</b> | <b>73%</b> | <b>77%</b> | <b>70%</b> | <b>79%</b> | <b>75%</b> |
| Proviseur·es et inspecteurs/trices EN |            | 36%        |            |            |            |            |
| Cadres du social ♂♀                   | 74%        |            |            |            | 53%        | 67%        |
| Formateurs/trices                     | 61%        |            |            |            | 50%        |            |
| Enseignant·es                         |            | 66%        |            |            | 69%        |            |
| Travailleuses sociales                | 84%        | 80%        | 82%        | 94%        | 72%        | 67%        |
| Animateurs/trices, AED, CPE, sport    | 72%        | 68%        |            |            | 54%        | 57%        |
| <b>TOTAL FILIÈRE ÉDUCATION-SOCIAL</b> | <b>74%</b> | <b>66%</b> | <b>78%</b> | <b>58%</b> | <b>61%</b> | <b>63%</b> |
| Professions artistiques ♂♀            | 58%        |            |            |            | 40%        |            |
| Journalistes, avocat·es, architectes… |            |            |            |            | 57%        |            |
| <b>TOTAL AUTRES PROFESSIONS INTEL</b> | <b>43%</b> | <b></b>    | <b></b>    | <b>50%</b> | <b>47%</b> | <b>36%</b> |
| Ouvriers agricoles                    |            |            |            |            | 29%        |            |
| <b>TOTAL FILIÈRE AGRICOLE</b>         | <b></b>    | <b></b>    | <b></b>    | <b></b>    | <b>29%</b> | <b></b>    |

</div>

<font size=2> Note : CL = collectivités locales ; HP = hôpitaux publics
; EntPub = entreprises publiques ; PME = petites et moyennes entreprises
; GE = grandes entreprises. FiP = Finances publiques ; CBS = cols blancs
subalternes ; sf = sages-femmes. </font>

<font size=2> Source : INSEE, Enquête Emploi 2018. </font>

<font size=2> Champ : salarié·es des organisations, France (hors
Mayotte).</font>

### `PPP2b` : la même chose, en distinguant les différentes catégories d’ouvriers

Dans `PPP2`, la comparaison avec les administrations publiques est
simplifiée par le regroupement des ouvriers en une seule catégorie (ils
sont aujourd’hui peu nombreux dans le public). `PPP2_det` fournit le
détail des différents catégories d’ouvriers, utile pour l’analyse du
secteur marchand.

### `PPP3` : regroupements de professions distincts entre public et privé

Le troisième niveau (4 chiffres) est situé entre les CSP et les
professions (178 modalités). Il permet au maximum de distinguer entre
des professions appartenant aux administrations publiques et des
professions appartenant au secteur marchand, selon des catégories un peu
plus large et donc plus facilement utilisables que celles des
professions détaillées. C’est le niveau de zoom utile maximal pour la
comparaison public-privé.

### `PPP4` : professions fusionnant les nomenclatures PCS de 1982 et 2003

Les professions détaillées recodées au niveau le plus fin (460
modalités) sont également au maximum séparées entre administrations
publiques et secteur marchand. Elles sont surtout utilisées pour
construire des professions homogènes dans les versions 1982 et 2003 de
la nomenclature des PCS : toutes les variables PcsPP permettent ainsi de
faire des comparaisons historiques sur la période 1982-2020.

## Féminisation des noms de professions

Pour rendre visible la place des femmes dans la structure sociale, la
règle de féminisation des noms de professions suivante est adoptée par
défaut : masculin s’il y a plus de deux tiers d’hommes dans une
profession ; féminin s’il y a plus de deux tiers de femmes ; forme
inclusive s’il y a entre 33% et 66% de femmes. La fonction `pcspp()`
permet de personnaliser l’apparence et les règles de calcul de cette
féminisation (cf. la documentation).

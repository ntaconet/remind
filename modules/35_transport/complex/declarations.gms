*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex/declarations.gms

Positive variables
vm_shUePeT(ttot,all_regi,all_te)             "share of the Uepet production from a certain LDV type in the total Uepet production. Unit: percent"
;

equations
q35_demFeTrans(ttot,all_regi,all_enty,all_emiMkt)       "Transportation final energy demand"
q35_limitCapUe(ttot,all_regi,all_enty,all_enty,all_te)  "capacity constraint for ES production"
q35_transFe2Ue(ttot,all_regi,all_enty,all_enty,all_te)  "energy tranformation fe to es"
q35_esm2macro(ttot,all_regi,all_in)                     "hand over amount of entyFe/entyUe from ESM(GENERIS) to the MACRO module"
q35_shUePeT(ttot,all_regi,all_te)             "calculate share of the Uepet production from a certain LDV type in the total Uepet production"
q35_shUePeTbal(ttot,all_regi)                 "shares sum must be equal to 100"
;

Parameter
p35_pass_FE_share_transp(all_regi)            "Share of 'non-LDV passenger FE' in 'total non-LDV FE. Unit: share [0..1]"
p35_pass_nonLDV_ES_efficiency(ttot,all_regi)  "Non-LDV passenger energy service per non-LDV FE. Unit: bn pkm/EJ"
p35_passLDV_ES_efficiency(ttot,all_regi)      "LDV passenger energy service per non-LDV FE. Only correct if applied to CES-input, as BEV and H2FCV have higher efficiencies. Unit: bn pkm/EJ"
p35_freight_ES_efficiency(ttot,all_regi)      "Freight energy service per freight FE. Unit: bn tkm/EJ"
pm_bunker_share_in_nonldv_fe(tall,all_regi)   "Share of bunkers in non-LDV transport - fedie"

p35_share_seliq_t(ttot,all_regi)                               "share of liquids used for transport sector (fedie + fepet). Unit 0..1"
p35_share_seh2_t(ttot,all_regi)                                "share of hydrogen used for transport sector  (feh2t). Unit 0..1"
p35_share_seel_t(ttot,all_regi)                                "Share of electricity used for transport sector (feelt). Unit 0..1"

$ifthen not "%cm_INNOPATHS_LDV_mkt_share%" == "off"
    new_bound(all_te,bound_type) / %cm_INNOPATHS_LDV_mkt_share% /
$endif    
;

*** EOF ./modules/35_transport/complex/declarations.gms

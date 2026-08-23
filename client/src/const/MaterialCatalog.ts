export type MaterialUnitKey =
  | 'units.piece'
  | 'units.meter'
  | 'units.pack'
  | 'units.tube'
  | 'units.bucket'
  | 'units.roll'
  | 'units.squareMeter'

export interface MaterialDefinition {
  key: string
  label: string
  unitKey: MaterialUnitKey
}

export const MATERIAL_CATALOG: MaterialDefinition[] = [
  {
    key: 'gutter_6m',
    label: 'Hängränna 6m',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_4m',
    label: 'Hängränna 4m',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_3m',
    label: 'Hängränna 3m',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_hook',
    label: 'Rännkrok',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_end',
    label: 'Ränngavel',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_joint',
    label: 'Rännskarv',
    unitKey: 'units.piece',
  },
  {
    key: 'outer_gutter_angle',
    label: 'Rännvinkel ytter',
    unitKey: 'units.piece',
  },
  {
    key: 'inner_gutter_angle',
    label: 'Rännvinkel inner',
    unitKey: 'units.piece',
  },
  {
    key: 'omvik',
    label: 'Omvik (omvikningskupa)',
    unitKey: 'units.piece',
  },
  {
    key: 'downpipe_2_5m',
    label: 'Stuprör 2.5m',
    unitKey: 'units.piece',
  },
  {
    key: 'downpipe_3m',
    label: 'Stuprör 3m',
    unitKey: 'units.piece',
  },
  {
    key: 'downpipe_4m',
    label: 'Stuprör 4m',
    unitKey: 'units.piece',
  },
  {
    key: 'downpipe_6m',
    label: 'Stuprör 6m',
    unitKey: 'units.piece',
  },
  {
    key: 'downpipe_clamp',
    label: 'Stuprörssvep',
    unitKey: 'units.piece',
  },
  {
    key: 'leaf_strainer',
    label: 'Lövsil',
    unitKey: 'units.piece',
  },
  {
    key: 'pipe_angle',
    label: 'Rörvinkel',
    unitKey: 'units.piece',
  },
  {
    key: 'outlet',
    label: 'Utkastare',
    unitKey: 'units.piece',
  },

  {
    key: 'windboard_22x170_3_6m',
    label: 'Ytterpanelbräda (vindskivor trä) 22x170 3.6m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x170_4_8m',
    label: 'Ytterpanelbräda (vindskivor trä) 22x170 4.8m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x170_4_2m',
    label: 'Ytterpanelbräda (vindskivor trä) 22x170 4.2m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x170_5_4m',
    label: 'Ytterpanelbräda (vindskivor trä) 22x170 5.4m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_wood',
    label: 'Ytterpanelbräda (vindskivor trä)',
    unitKey: 'units.meter',
  },
  {
    key: 'windboard_22x195_4_8m',
    label: 'Ytterpanelbräda (vindskivor trä) 22x195 4.8m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x195_5_4m',
    label: 'Ytterpanelbräda (vindskivor trä) 22x195 5.4m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x195_3_6m',
    label: 'Ytterpanelbräda (vindskivor trä) 22x195 3.6m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_mixed',
    label: 'Ytterpanelbräda (vindskivor trä) 22x170 22x120 22x195 22x145',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_metal',
    label: 'Vindskiveplåt',
    unitKey: 'units.piece',
  },

  {
    key: 'roof_ladder_step',
    label: 'Bärläktsteg',
    unitKey: 'units.piece',
  },
  {
    key: 'snow_guard',
    label: 'Glidskydd',
    unitKey: 'units.piece',
  },

  {
    key: 'roof_sheathing_23x540_3_6m',
    label: 'Råspontlucka 23x540 3.6m',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_23x540_4_2m',
    label: 'Råspontlucka 23x540 4.2m',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_20x540_3_6m',
    label: 'Råspontlucka 20x540 3.6m',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_20x540_4_2m',
    label: 'Råspontlucka 20x540 4.2m',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_20x540_4_8m',
    label: 'Råspontlucka 20x540 4.8m',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_17mm',
    label: 'Råspont 17mm single',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_19mm',
    label: 'Råspont 19mm single',
    unitKey: 'units.piece',
  },

  {
    key: 'silicone',
    label: 'Tek7 / Silicone',
    unitKey: 'units.tube',
  },
  {
    key: 'pistol_nails',
    label: 'Nails for pistol',
    unitKey: 'units.pack',
  },
  {
    key: 'screws_55mm',
    label: 'Screws 55mm',
    unitKey: 'units.piece',
  },
  {
    key: 'metal_screws_33mm',
    label: '33mm plåtskruv',
    unitKey: 'units.piece',
  },
  {
    key: 'screws_42mm',
    label: '42mm skruv',
    unitKey: 'units.piece',
  },
  {
    key: 'wood_screws_30mm',
    label: '30mm träskruv',
    unitKey: 'units.piece',
  },
  {
    key: 'screw_120mm',
    label: 'Skruv 120mm',
    unitKey: 'units.piece',
  },
  {
    key: 'screw_75_80mm',
    label: 'Skruv 75 eller 80mm',
    unitKey: 'units.piece',
  },
  {
    key: 'wind_screw',
    label: 'Vindskruva',
    unitKey: 'units.piece',
  },
  {
    key: 'farmers_screw',
    label: 'Farmarskruv',
    unitKey: 'units.piece',
  },
  {
    key: 'clips',
    label: 'Clips',
    unitKey: 'units.piece',
  },
  {
    key: 'ridge_band',
    label: 'Nockband',
    unitKey: 'units.meter',
  },
  {
    key: 'bird_band',
    label: 'Fågelband',
    unitKey: 'units.piece',
  },
  {
    key: 'eave_flashing_2m',
    label: 'Fotplåt 2m',
    unitKey: 'units.piece',
  },
  {
    key: 'batten_25x48',
    label: 'Läkt standard 25x48',
    unitKey: 'units.piece',
  },
  {
    key: 'batten_12x50',
    label: 'Läkt tunn 12x50',
    unitKey: 'units.piece',
  },
  {
    key: 'triangle_batten',
    label: 'Trekantsläkt',
    unitKey: 'units.meter',
  },
  {
    key: 'rafter',
    label: 'Regel',
    unitKey: 'units.meter',
  },
  {
    key: 'rafter_45x45_4_8m',
    label: 'Gran hyvlad regel O/S V 45x45 4,8 m',
    unitKey: 'units.piece',
  },
  {
    key: 'rafter_45x45_3_6m',
    label: 'Gran hyvlad regel O/S V 45x45 3,6 m',
    unitKey: 'units.piece',
  },
  {
    key: 'short_rafter_45x45_2_5m',
    label: 'Gran vilmaregel kortregel 45x45 2.5 m',
    unitKey: 'units.piece',
  },
  {
    key: 'trash_bags',
    label: 'Sopsäckar',
    unitKey: 'units.piece',
  },
  {
    key: 'paint',
    label: 'Färg',
    unitKey: 'units.bucket',
  },
  {
    key: 'tape',
    label: 'Tejp',
    unitKey: 'units.roll',
  },
]

export const MATERIAL_CATALOG_MAP = new Map(
  MATERIAL_CATALOG.map(material => [
    material.key,
    material,
  ]),
)

export function getMaterialDefinition(
  materialKey: string,
): MaterialDefinition | undefined {
  return MATERIAL_CATALOG_MAP.get(materialKey)
}

/*
export const MATERIAL_CATALOG=[
"hängränna 6m",
"hängränna 4m",
'hängränna 3m',
'rännkrok',
'ränngavel',
'rännskarv',
'rännvinkel ytter',
'rännvinkel inner',
'omvik (omvikningskupa)',
'stuprör 2.5m',
'stuprör 3m',
'stuprör 4m',
'stuprör 6m',
'stuprörssvep',
'lövsil',
'rörvinkel',
'utkastare',
'ytterpanelbräda (vindskivor trä) 22x170 3.6m',
'ytterpanelbräda (vindskivor trä) 22x170 4.8m',
'ytterpanelbräda (vindskivor trä) 22x170 4.2m',
'ytterpanelbräda (vindskivor trä) 22x170 5.4m',
'ytterpanelbräda (vindskivor trä)',
'ytterpanelbräda (vindskivor trä) 22x195 4.8m',
'ytterpanelbräda (vindskivor trä) 22x195 5.4m',
'ytterpanelbräda (vindskivor trä) 22x195 3.6m',
'ytterpanelbräda (vindskivor trä) 22x170 22x120 22x195 22x145',
'vindskiveplåt',
'bärläktsteg',
'glidskydd',
'råspontlucka 23X540 3.6m',
'råspontlucka 23X540 4.2m',
'råspontlucka 20X540 3.6m',
'råspontlucka 20X540 4.2m',
'råspontlucka 20X540 4.8m',
'råspont 17mm single',
'råspont 19mm single',
'tek7/silicone', 
'nails for pistol',
'screws 55mm',
'33mm plåt skruv',
'42mm skruv',
'30mm trä skruv',
'skruv 120mm',
'skruv 75 or 80mm',
'vindskruva',
'farmarskruv',
'clips',
'nokband',
'fågelband',
'fotplåt 2m',
'läkts standart 25x48',
'läkts thin 12x50',
'trekantsläkt',
'regel',
'GRAN HYVLAD REGEL O/S V 45X45 4,8 M',
'GRAN HYVLAD REGEL O/S V 45X45 3,6 M',
'GRAN VILMAREGEL KORTREGEL 45X45 2.5 M',
'trash bags',
'paint',
'tejp'
]
*/
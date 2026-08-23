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
  labelKey: string
  unitKey: MaterialUnitKey
}

export const MATERIAL_CATALOG: MaterialDefinition[] = [
  {
    key: 'gutter_6m',
    labelKey: 'materials.gutter_6m',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_4m',
    labelKey: 'materials.gutter_4m',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_3m',
    labelKey: 'materials.gutter_3m',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_hook',
    labelKey: 'materials.gutter_hook',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_end',
    labelKey: 'materials.gutter_end',
    unitKey: 'units.piece',
  },
  {
    key: 'gutter_joint',
    labelKey: 'materials.gutter_joint',
    unitKey: 'units.piece',
  },
  {
    key: 'outer_gutter_angle',
    labelKey: 'materials.outer_gutter_angle',
    unitKey: 'units.piece',
  },
  {
    key: 'inner_gutter_angle',
    labelKey: 'materials.inner_gutter_angle',
    unitKey: 'units.piece',
  },
  {
    key: 'omvik',
    labelKey: 'materials.omvik',
    unitKey: 'units.piece',
  },

  {
    key: 'downpipe_2_5m',
    labelKey: 'materials.downpipe_2_5m',
    unitKey: 'units.piece',
  },
  {
    key: 'downpipe_3m',
    labelKey: 'materials.downpipe_3m',
    unitKey: 'units.piece',
  },
  {
    key: 'downpipe_4m',
    labelKey: 'materials.downpipe_4m',
    unitKey: 'units.piece',
  },
  {
    key: 'downpipe_6m',
    labelKey: 'materials.downpipe_6m',
    unitKey: 'units.piece',
  },
  {
    key: 'downpipe_clamp',
    labelKey: 'materials.downpipe_clamp',
    unitKey: 'units.piece',
  },
  {
    key: 'leaf_strainer',
    labelKey: 'materials.leaf_strainer',
    unitKey: 'units.piece',
  },
  {
    key: 'pipe_angle',
    labelKey: 'materials.pipe_angle',
    unitKey: 'units.piece',
  },
  {
    key: 'outlet',
    labelKey: 'materials.outlet',
    unitKey: 'units.piece',
  },

  {
    key: 'windboard_22x170_3_6m',
    labelKey: 'materials.windboard_22x170_3_6m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x170_4_8m',
    labelKey: 'materials.windboard_22x170_4_8m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x170_4_2m',
    labelKey: 'materials.windboard_22x170_4_2m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x170_5_4m',
    labelKey: 'materials.windboard_22x170_5_4m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_wood',
    labelKey: 'materials.windboard_wood',
    unitKey: 'units.meter',
  },
  {
    key: 'windboard_22x195_4_8m',
    labelKey: 'materials.windboard_22x195_4_8m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x195_5_4m',
    labelKey: 'materials.windboard_22x195_5_4m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_22x195_3_6m',
    labelKey: 'materials.windboard_22x195_3_6m',
    unitKey: 'units.piece',
  },
  {
    key: 'windboard_mixed',
    labelKey: 'materials.windboard_mixed',
    unitKey: 'units.piece',
  },

  {
    key: 'windboard_metal',
    labelKey: 'materials.windboard_metal',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_ladder_step',
    labelKey: 'materials.roof_ladder_step',
    unitKey: 'units.piece',
  },
  {
    key: 'snow_guard',
    labelKey: 'materials.snow_guard',
    unitKey: 'units.piece',
  },

  {
    key: 'roof_sheathing_23x540_3_6m',
    labelKey: 'materials.roof_sheathing_23x540_3_6m',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_23x540_4_2m',
    labelKey: 'materials.roof_sheathing_23x540_4_2m',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_20x540_3_6m',
    labelKey: 'materials.roof_sheathing_20x540_3_6m',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_20x540_4_2m',
    labelKey: 'materials.roof_sheathing_20x540_4_2m',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_20x540_4_8m',
    labelKey: 'materials.roof_sheathing_20x540_4_8m',
    unitKey: 'units.piece',
  },

  {
    key: 'roof_sheathing_17mm',
    labelKey: 'materials.roof_sheathing_17mm',
    unitKey: 'units.piece',
  },
  {
    key: 'roof_sheathing_19mm',
    labelKey: 'materials.roof_sheathing_19mm',
    unitKey: 'units.piece',
  },

  {
    key: 'silicone',
    labelKey: 'materials.silicone',
    unitKey: 'units.tube',
  },
  {
    key: 'pistol_nails',
    labelKey: 'materials.pistol_nails',
    unitKey: 'units.pack',
  },
  {
    key: 'screws_55mm',
    labelKey: 'materials.screws_55mm',
    unitKey: 'units.piece',
  },
  {
    key: 'metal_screws_33mm',
    labelKey: 'materials.metal_screws_33mm',
    unitKey: 'units.piece',
  },
  {
    key: 'screws_42mm',
    labelKey: 'materials.screws_42mm',
    unitKey: 'units.piece',
  },
  {
    key: 'wood_screws_30mm',
    labelKey: 'materials.wood_screws_30mm',
    unitKey: 'units.piece',
  },
  {
    key: 'screw_120mm',
    labelKey: 'materials.screw_120mm',
    unitKey: 'units.piece',
  },
  {
    key: 'screw_75_80mm',
    labelKey: 'materials.screw_75_80mm',
    unitKey: 'units.piece',
  },
  {
    key: 'wind_screw',
    labelKey: 'materials.wind_screw',
    unitKey: 'units.piece',
  },
  {
    key: 'farmers_screw',
    labelKey: 'materials.farmers_screw',
    unitKey: 'units.piece',
  },
  {
    key: 'clips',
    labelKey: 'materials.clips',
    unitKey: 'units.piece',
  },

  {
    key: 'ridge_band',
    labelKey: 'materials.ridge_band',
    unitKey: 'units.meter',
  },
  {
    key: 'bird_band',
    labelKey: 'materials.bird_band',
    unitKey: 'units.piece',
  },
  {
    key: 'eave_flashing_2m',
    labelKey: 'materials.eave_flashing_2m',
    unitKey: 'units.piece',
  },

  {
    key: 'batten_25x48',
    labelKey: 'materials.batten_25x48',
    unitKey: 'units.piece',
  },
  {
    key: 'batten_12x50',
    labelKey: 'materials.batten_12x50',
    unitKey: 'units.piece',
  },
  {
    key: 'triangle_batten',
    labelKey: 'materials.triangle_batten',
    unitKey: 'units.meter',
  },
  {
    key: 'rafter',
    labelKey: 'materials.rafter',
    unitKey: 'units.meter',
  },

  {
    key: 'rafter_45x45_4_8m',
    labelKey: 'materials.rafter_45x45_4_8m',
    unitKey: 'units.piece',
  },
  {
    key: 'rafter_45x45_3_6m',
    labelKey: 'materials.rafter_45x45_3_6m',
    unitKey: 'units.piece',
  },
  {
    key: 'short_rafter_45x45_2_5m',
    labelKey: 'materials.short_rafter_45x45_2_5m',
    unitKey: 'units.piece',
  },

  {
    key: 'trash_bags',
    labelKey: 'materials.trash_bags',
    unitKey: 'units.piece',
  },
  {
    key: 'paint',
    labelKey: 'materials.paint',
    unitKey: 'units.bucket',
  },
  {
    key: 'tape',
    labelKey: 'materials.tape',
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
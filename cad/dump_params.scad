include <params.scad>
ps = [["mm_module_od",mm_module_od],["mm_module_h",mm_module_h],
      ["mm_recess_d",mm_recess_d],["module_top",module_top],
      ["water_min",water_min],["water_max",water_max],
      ["water_fill",water_fill],["water_refill",water_refill],
      ["fog_headspace",fog_headspace],["ch_inner",ch_inner],["ch_wall",ch_wall],
      ["ch_floor",ch_floor],["ch_inner_h",ch_inner_h],["ch_outer",ch_outer],
      ["fog_port_d",fog_port_d],["fog_port_z",fog_port_z],
      ["fog_boss_len",fog_boss_len],["lid_t",lid_t],["lid_spigot_h",lid_spigot_h],["lid_rim_seat",lid_rim_seat],
      ["lid_clear",lid_clear],["lid_fit",lid_fit],["lid_pos_xy",lid_pos_xy],["lid_pos_z",lid_pos_z],
      ["vent_d",vent_d],["vent_n",vent_n],["cable_notch_w",cable_notch_w],
      ["cable_notch_h",cable_notch_h],["mm_cable_od",mm_cable_od]];
for (p = ps) echo(str("PARAM ", p[0], "=", p[1]));

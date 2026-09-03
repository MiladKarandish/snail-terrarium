include <params.scad>
ps = [["mm_module_od",mm_module_od],["mm_module_h",mm_module_h],
 ["mm_recess_d",mm_recess_d],["mm_cable_od",mm_cable_od],
 ["water_start",water_start],["water_best_lo",water_best_lo],["water_best_hi",water_best_hi],["water_struggle",water_struggle],["water_hold",water_hold],["water_band",water_band],
 ["water_level",water_level],["fog_headspace",fog_headspace],
 ["ch_id",ch_id],["ch_od",ch_od],["ch_flange_od",ch_flange_od],["ch_wall",ch_wall],["ch_floor",ch_floor],
 ["ch_inner_h",ch_inner_h],["fog_port_d",fog_port_d],["fog_port_z",fog_port_z],["fog_boss_wall",fog_boss_wall],
 ["sp_bore",sp_bore],["sp_od",sp_od],["sp_offset",sp_offset],
 ["lid_t",lid_t],["lid_spigot_h",lid_spigot_h],["lid_fit",lid_fit],
 ["lid_rim_seat",lid_rim_seat],["lid_pos_z",lid_pos_z],
 ["vent_d",vent_d],["vent_n",vent_n],["vl_vent_d",vl_vent_d],["vl_vent_n",vl_vent_n],["plain_ml",plain_ml],["lip_h",lip_h],["cable_notch_w",cable_notch_w],
 ["bottle_ml",bottle_ml],["fan_z",fan_z],["nozzle_z",nozzle_z],["nozzle_d",nozzle_d],["feed_centre",feed_centre],["feed_od",feed_od],["feed_id",feed_id],["feed_port_d",feed_port_d],["ch_flange_h",ch_flange_h],["fan_pad",fan_pad],["fan_pad_t",fan_pad_t],["feed_top",feed_top],["vessel_od",vessel_od],["vessel_cut_h",vessel_cut_h],["skirt_slop",skirt_slop]];
for (p = ps) echo(str("PARAM ", p[0], "=", p[1]));

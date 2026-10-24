SL Survival - Spanked Overlays (3BA + UBE)

slavetats_spanked_1.0 (3BA hand-print marks, 3 variants) as SlaveTats entries in the "SL Survival" section, named
like SL Survival's own trauma textures ("Body - Spanked N (F) [Body]").
Used by "SL Survival - Integration Patch": a slap in "Survival Ass Slapping" leaves one of them on a female actor,
and it fades out with SLS's normal trauma timing (Trauma -> Fade settings in the SLS MCM).

Two texture sets, chosen per actor by SlaveTatsNG:
- slavetats\SL Survival Spanked\Body\      the 3BA originals, for every non-UBE body (3BA, CBBE, COtR)
- slavetats\UBE\SL Survival Spanked\Body\  the UBE conversion, used only for actors whose race EditorID contains "UBE"

2026-10-05: until now only the UBE conversion was installed, at the base path, so 3BA characters (e.g. a vanilla
Nord female on 3BA) got marks laid out for the UBE body. Fixed by moving the conversion under UBE\. The base path
first got the wrong files (work\backups\merge_2026-10-03\spanked_original turned out to be the first, colour-baked
UBE conversion, not the 3BA source); now it holds the real slavetats_spanked_1.0 spank01-03.dds (3BA), byte for byte.
Backups: work\backups\sls_spanked_routing_2026-10-05, work\backups\sls_spanked_3ba_fix_2026-10-05.
3BA source kept in work\UBE_tex_convert\source_3ba_spanked.

Source mod slavetats_spanked_1.0 is unchanged. UBE set converted with the UV geometry of Grognak's UBE Tex Conversion
Tool (body atlas, BC3): a baked UV map, then a straight resample, so colour and opacity match the 3BA original.
Requires SlaveTatsNG.

# Visual redesign — 23 September 2026

## Milestone 1

Generated using the built-in image-generation tool, not the CLI. Bundled assets: `apps/flutter/assets/worlds/{forest,meadow,alpine,explorer}.png`. Scenery is rendered low-poly artwork, not an interactive 3D engine or botanical identification photography. Explorer has an RGBA transparent background. Existing progression remains server-authoritative.

## Prompt set

### forest

Use case: stylized-concept. Asset type: final mobile botanical adventure game environment background, portrait 1024x1536. Create a breathtaking premium 3D low-poly European deciduous woodland, elevated isometric view looking down into a lovingly crafted miniature living world. Sculptural faceted broadleaf beech and oak canopies, mossy polygon rocks, warm shafts of sunlight, tiny ferns, fallen leaves, natural forest floor, rich emerald and jade with buttery golden light. Charming tactile matte materials, ambient occlusion, soft deep contact shadows, beautifully composed polished indie adventure-game diorama, sophisticated not childish clip art. Central open clearings winding vertically through the composition provide negative space for interactive level markers that will be drawn by the app; denser environmental detail toward margins. Continuous landscape fills frame, not a floating island, no sky-heavy horizon. Absolutely no text, no labels, no UI, no numbers, no characters, no logos, no watermark. Preserve visible faceted polygon geometry and dimensional depth; not flat vector art. This is game scenery, not scientific plant identification.

### meadow

Use case: stylized-concept. Asset type: final mobile botanical adventure game environment background, portrait 1024x1536. Premium 3D low-poly European wildflower meadow miniature world, elevated isometric view looking down through soft rolling hills. Sculpted faceted grass terraces, clusters of small purple sage-like flowers, white daisies and warm yellow flower heads, low polygon stones, sunlit grassy clearings winding vertically up the center, bushes at edges. Bright fresh pistachio greens, golden lime light, lilac and ivory blossoms, amber warm sun, sophisticated tactile matte material, ambient occlusion, crisp facets with soft deep contact shadows. Beautiful charming polished indie exploration-game art, not flat vector, not photorealistic, not childish clip art. Open central spaces must remain suitable for level node overlays in the app. Continuous landscape fills entire portrait, not floating island; little sky, view mostly terrain. No people, no text, no number markers, no UI, no logos, no watermark. Coherent stylized faceted 3D art direction with a botanical woodland adventure world.

### alpine

Use case: stylized-concept. Asset type: final mobile botanical adventure game environment background, portrait 1024x1536. Breathtaking 3D low-poly Alpine botanical exploration landscape, elevated isometric view down into a miniature mountain valley. Faceted limestone outcrops, angular glacier-gray rock faces, turquoise mountain stream, soft sage grass ledges and tiny lilac alpine flowers, distant peaks mostly near top edge with small snow caps, winding open terraces through the middle for interactive level nodes. Beautiful dimensional modeling, sophisticated handmade faceted matte surfaces, ambient occlusion, crisp polygon planes and soft cinematic daylight, misty blue atmospheric depth with warm light on grass. Premium polished indie adventure game environment. Continuous landscape edge to edge, no floating island, no text, no numbers or UI, no people, no logos, no watermark, no flat vector art. Botanical adventure mood, quiet wonder and exploration.

### explorer

Use case: stylized-concept. Asset type: transparent-background game player character sprite, square 1024x1024. One original friendly gender-neutral young adult nature explorer in exquisite 3D low-poly game art. Full body visible with comfortable empty margin, three-quarter view, standing in a gentle ready-to-walk pose facing slightly right, short dark brown hair, warm medium skin, moss-green outdoors jacket, cream undershirt, warm clay-orange backpack, dark charcoal trousers and sturdy tan hiking boots. Simple kind face with small dark eyes. Charming balanced compact proportions and very clear silhouette, sculptural visible faceted polygon planes, tactile matte materials, beautiful soft studio daylight and dimensional ambient occlusion. Match a premium low-poly woodland exploration game. Character only, no scene, no pedestal, no floor, no text, no watermark. Genuinely transparent alpha background, not a painted checkerboard or colored background. No tools, no weapon, no extra characters. This character will be a small map marker and larger profile avatar.

## Remaining milestones

### MEDIA-10 first slice — authored photos

`PlantPhotoGallery` now renders available plant photos in the pre-quiz notebook alongside the existing facts, with alt text, author and license. Images use contain rather than cropping diagnostic features. Empty/broken media has an explicitly labeled symbolic fallback. `HttpCatalogRepository` resolves root-relative CMS upload URLs against the configured API deployment before caching them. Analyzer passes; live authored-upload acceptance, source links, unified detail gallery and automatic provider resolution remain open. This is not completion of milestone 3.

### Update 2026-09-24 — milestone 2 implementation

- Home, login and profile now use the bundled scenery/explorer. Quiz questions use high-contrast question cards and lettered answer controls; correctness remains server-authoritative. Completion screen displays the explorer and the existing earned level star.
- Herbarium header and detail presentation updated; missing/broken observation photos have an explicit fallback. Raw identifiers and exact coordinates are no longer presented in the detail summary; private stored data is unchanged.
- Field capture has an expedition-style header; capture, confirmation and consent behavior are unchanged.
- Interrupted helper-agent edits were inspected and completed by the parent (duplicate argument, missing photo widget and unfinished list syntax corrected).
- Final `flutter analyze --no-pub lib`, `git diff --check` and Linux release build succeeded including field-header polish. Linux app started again on DISPLAY=:0 on 2026-09-24. No tests added or run. Full interactive visual/accessibility acceptance is still open, not implied by compilation.
- Photo lookup research: MediaWiki PageImages and Imageinfo APIs provide candidate filenames and image-specific attribution/license metadata. An IPv4 query for Fagus sylvatica returned a page image. No automatic lookup is implemented yet; taxon validation, license allowlist, source links, timeout/cache, authored-photo precedence and offline behavior remain required.

References: https://www.mediawiki.org/wiki/Extension:PageImages and https://www.mediawiki.org/wiki/API:Imageinfo

- Review the implemented pages in the running app, especially narrow windows and large text.
- Authored plant photos first, automatic licensed external-photo lookup second; attractive image-and-facts cards with attribution and honest unavailable states.
- No new tests requested. Preserve existing unrelated WIP tests.

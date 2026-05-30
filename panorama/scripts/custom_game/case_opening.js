"use strict";

(function () {

    // ──────────────────────────────────────────────────────────────────────────
    // Item pool – must mirror EventOpenCase.ITEM_POOL in event_open_case.lua
    // ──────────────────────────────────────────────────────────────────────────
    var ITEM_POOL = [
        // Grey
        { name: "item_clarity",        rarity: "common"    },
        { name: "item_faerie_fire",    rarity: "common"    },
        { name: "item_tango",          rarity: "common"    },
        { name: "item_enchanted_mango", rarity: "common"    },
        // Blue
        { name: "item_dragon_lance",   rarity: "rare"      },
        { name: "item_magic_wand",     rarity: "rare"      },
        { name: "item_yasha",          rarity: "rare"      },
        { name: "item_force_staff",    rarity: "rare"      },
        { name: "item_oblivion_staff", rarity: "rare"      },
        // Pink
        { name: "item_blink",          rarity: "epic"      },
        { name: "item_power_treads",   rarity: "epic"      },
        { name: "item_silver_edge",     rarity: "epic"      },
        { name: "item_blade_mail",     rarity: "epic"      },
        { name: "item_kaya",           rarity: "epic"      },
        // Gold
        { name: "item_octarine_core",  rarity: "legendary" },
        { name: "item_rapier",         rarity: "legendary" },
        { name: "item_heart",          rarity: "legendary" },
        { name: "item_butterfly",      rarity: "legendary" },
        { name: "item_abyssal_blade",  rarity: "legendary" },
    ];

    // ──────────────────────────────────────────────────────────────────────────
    // Layout constants
    // ──────────────────────────────────────────────────────────────────────────
    var CELL_STRIDE   = 112;    // 96px cell + 8px margin each side
    var NUM_CELLS     = 7;      // cells in the cycling reel
    var CYCLE_LEN     = NUM_CELLS * CELL_STRIDE;  // 784px – wrap period
    var WIN_CELL_IDX  = 5;      // at offset -4216, this cell lands at x=264 (window centre)
    var ANIM_DURATION = 6.0;

    // endOffset verified: ((WIN_CELL_IDX * CELL_STRIDE + endOffset) % CYCLE_LEN + CYCLE_LEN) % CYCLE_LEN = 264
    var END_OFFSET = -4216;

    // ──────────────────────────────────────────────────────────────────────────
    // DOM references
    // ──────────────────────────────────────────────────────────────────────────
    var Overlay   = $("#CaseOpeningOverlay");
    var ReelStrip = $("#CaseReelStrip");
    var MaskLeft  = $("#CaseMaskLeft");
    var MaskRight = $("#CaseMaskRight");

    // ──────────────────────────────────────────────────────────────────────────
    // State
    // ──────────────────────────────────────────────────────────────────────────
    var _cellPanels     = [];
    var _animHandle     = null;
    var _animStart      = 0;
    var _autoHideHandle = null;
    var _isVisible      = false;

    // ──────────────────────────────────────────────────────────────────────────
    // Server event listeners
    // ──────────────────────────────────────────────────────────────────────────
    GameEvents.Subscribe("case_opening_start", function (data) {
        var localId  = Game.GetLocalPlayerID();
        var targetId = parseInt(data.target_player_id);
        if (targetId != localId) return;
        _StartOpening(data.won_item, data.won_item_rarity);
    });

    GameEvents.Subscribe("case_opening_end", function () {
        if (!_isVisible) return;
        _HideOverlay();
    });

    // ──────────────────────────────────────────────────────────────────────────
    // Main entry
    // ──────────────────────────────────────────────────────────────────────────
    function _StartOpening(wonItemName, wonItemRarity) {
        _StopAnim();
        _CancelAutoHide();

        var wonItem = null;
        for (var i = 0; i < ITEM_POOL.length; i++) {
            if (ITEM_POOL[i].name === wonItemName) { wonItem = ITEM_POOL[i]; break; }
        }
        if (!wonItem) wonItem = { name: wonItemName, rarity: wonItemRarity || "common" };

        _BuildReel(wonItem);
        _SetCellPositions(0);   // initial position
        _ShowOverlay();

        $.Schedule(0.35, function () {
            _animStart = Game.GetGameTime();
            _AnimTick();
        });
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Cycling reel builder – exactly NUM_CELLS panels, positioned via transform
    // ──────────────────────────────────────────────────────────────────────────
    function _BuildReel(wonItem) {
        ReelStrip.RemoveAndDeleteChildren();
        _cellPanels = [];

        for (var i = 0; i < NUM_CELLS; i++) {
            var entry = (i === WIN_CELL_IDX) ? wonItem : ITEM_POOL[Math.floor(Math.random() * ITEM_POOL.length)];

            var cell = $.CreatePanel("Panel", ReelStrip, "cell_" + i);
            cell.AddClass("case-item-cell");
            cell.AddClass("rarity-" + entry.rarity);

            var img = $.CreatePanel("Image", cell, "img_" + i);
            img.AddClass("case-item-image");
            img.SetImage("file://{images}/items/" + entry.name.replace("item_", "") + ".png");

            _cellPanels.push(cell);
        }
    }

    // Place every cell allowing it to slide [-CELL_STRIDE, CYCLE_LEN).
    // A cell exits the left edge smoothly before wrapping to the right,
    // so items visibly slide behind the drum border instead of teleporting.
    function _SetCellPositions(offset) {
        for (var i = 0; i < _cellPanels.length; i++) {
            var x = i * CELL_STRIDE + offset;
            while (x < -CELL_STRIDE) x += CYCLE_LEN;
            while (x >= CYCLE_LEN)   x -= CYCLE_LEN;
            _cellPanels[i].style.transform = "translateX(" + x + "px)";
        }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Animation – easeOutExpo, fast start → dramatic slow-down
    // ──────────────────────────────────────────────────────────────────────────
    function _AnimTick() {
        var elapsed = Game.GetGameTime() - _animStart;
        var t = elapsed / ANIM_DURATION;

        if (t >= 1.0) {
            _SetCellPositions(END_OFFSET);
            _animHandle = null;
            _HideOverlay();
            return;
        }

        var eased  = 1.0 - Math.pow(2.0, -10.0 * t);
        var offset = END_OFFSET * eased;
        _SetCellPositions(offset);
        _animHandle = $.Schedule(0.016, _AnimTick);
    }

    function _StopAnim() {
        if (_animHandle !== null) { $.CancelScheduled(_animHandle); _animHandle = null; }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Overlay show / hide
    // ──────────────────────────────────────────────────────────────────────────
    function _ApplyMasks() {
        var screenW = Game.GetScreenWidth();
        if (!screenW || screenW < 640) screenW = Overlay.actuallayoutwidth;
        if (!screenW || screenW < 640) screenW = 1920;
        var maskW = Math.max(0, Math.floor((screenW - 640) / 2));
        MaskLeft.style.width  = maskW + "px";
        MaskRight.style.width = maskW + "px";
    }

    function _ShowOverlay() {
        _ApplyMasks();
        $.Schedule(0.05, _ApplyMasks);
        _isVisible = true;
        Overlay.AddClass("case-visible");
    }

    function _HideOverlay() {
        _isVisible = false;
        _StopAnim();
        _CancelAutoHide();
        Overlay.RemoveClass("case-visible");
    }

    function _CancelAutoHide() {
        if (_autoHideHandle !== null) { $.CancelScheduled(_autoHideHandle); _autoHideHandle = null; }
    }

})();

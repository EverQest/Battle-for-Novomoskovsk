"use strict";

(function () {
    // ── Panel references ──────────────────────────────────────────────────────
    var Container    = $("#RandomEventContainer");
    var NameLabel    = $("#EventName");
    var DescLabel    = $("#EventDescription");
    var TimerLabel   = $("#EventTimer");

    var _timeRemaining   = 0;
    var _countdownHandle = null;

    // ── Server → Client event: event started ─────────────────────────────────
    GameEvents.Subscribe("random_event_started", function (data) {
        NameLabel.text  = data.event_name;
        DescLabel.text  = data.event_description;

        Container.RemoveClass("event-hidden");
        Container.AddClass("event-visible");

        _StartCountdown(data.duration);
    });

    // ── Server → Client event: event ended ───────────────────────────────────
    GameEvents.Subscribe("random_event_ended", function () {
        _StopCountdown();

        Container.RemoveClass("event-visible");
        Container.AddClass("event-hidden");
    });

    // ── Countdown helpers ─────────────────────────────────────────────────────
    function _StartCountdown(duration) {
        _StopCountdown();
        _timeRemaining = duration;
        _UpdateTimerLabel();
        _ScheduleTick();
    }

    function _ScheduleTick() {
        _countdownHandle = $.Schedule(1.0, function () {
            _timeRemaining = Math.max(0, _timeRemaining - 1);
            _UpdateTimerLabel();

            if (_timeRemaining > 0) {
                _ScheduleTick();
            } else {
                _countdownHandle = null;
            }
        });
    }

    function _StopCountdown() {
        if (_countdownHandle !== null) {
            $.CancelScheduled(_countdownHandle);
            _countdownHandle = null;
        }
    }

    function _UpdateTimerLabel() {
        TimerLabel.text = String(_timeRemaining);

        // Flash red when under 10 seconds.
        if (_timeRemaining <= 10) {
            TimerLabel.AddClass("event-timer-urgent");
        } else {
            TimerLabel.RemoveClass("event-timer-urgent");
        }
    }

})();

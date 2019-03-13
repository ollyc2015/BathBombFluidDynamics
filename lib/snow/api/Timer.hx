package snow.api;

import haxe.PosInfos;
import haxe.Log;

@:allow(snow.Snow)
    class Timer {

        static var running_timers:Array<Timer> = [];

        @:noCompletion public var time:Float;
        @:noCompletion public var fire_at:Float;
        @:noCompletion public var running:Bool;

        public function new(_time:Float) {

            time = _time;
            running_timers.push( this );
            fire_at = Snow.timestamp + time;
            running = true;

        } //new

        public static function measure<T>( f : Void -> T, ?pos : PosInfos ) : T {
            var t0 = Snow.timestamp;
            var r = f();
            Log.trace((Snow.timestamp - t0) + "s", pos);
            return r;
        }

        // Set this with "run=..."
        dynamic public function run () { }

        public function stop ():Void {

            if (running) {
                running = false;
                running_timers.remove (this);
            }

        } //stop


        static function update() {

            var now = Snow.timestamp;

            for (timer in running_timers) {
                if(timer.running) {
                    if(timer.fire_at < now) {
                        timer.fire_at += timer.time;
                        timer.run();
                    } //now
                }
            } //all timers

        } //update

            //From std/haxe/Timer.hx
        public static function delay( _time:Float, _f:Void -> Void ) {

            var t = new Timer( _time );
            t.run = function() {
                t.stop();
                _f();
            };

            return t;

        } //delay

    } //Timer


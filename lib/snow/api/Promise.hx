package snow.api;

/**
The Promise interface represents a proxy for a value not necessarily
known when the promise is created. It allows you to associate handlers
to an asynchronous action's eventual success or failure. This lets asynchronous
methods return values like synchronous methods: instead of the final value,
the asynchronous method returns a promise of having a value at some point in the future.

A pending promise can become either fulfilled with a value, or
rejected with a reason. When either of these happens, the associated
handlers queued up by a promise's then method are called. (If the promise
has already been fulfilled or rejected when a corresponding handler is attached,
the handler will be called, so there is no race condition between an asynchronous
operation completing and its handlers being attached.)

As the Promise.prototype.then and Promise.prototype.error methods return promises,
they can be chained—an operation called composition.

Documentation provided mostly by MDN
licensed under CC-BY-SA 2.5. by Mozilla Contributors.
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise
*/
@:allow(snow.api.Promises)
class Promise {

        /** The state this promise is in. */
    var state : PromiseState;
        /** internal: The result of this promise */
    var result : Dynamic;
        /** internal: The reactions lists */
    var reject_reactions: Array<Dynamic>;
    var fulfill_reactions: Array<Dynamic>;
    var settle_reactions: Array<Dynamic>;

        /** internal: If the promise was handled by a reject reaction */
    var was_caught: Bool = false;

        /** Creates a new promise by providing a function with two callback arguments.
            Inside this function, invoking these callbacks controls the promise state.
            For example, if fetching a value async, and the operation fails, you would
            invoke the second callback with the reason/error. If the operation succeeded,
            you would invoke the first.
        */
    public function new<T>( func:T ) {

        state = pending;

        reject_reactions = [];
        fulfill_reactions = [];
        settle_reactions = [];

        Promises.queue(function() {

            #if hxpromise_catch_and_reject_on_promise_body
                try {
                    untyped func(onfulfill, onreject);
                } catch(err:Dynamic) {
                    onexception(err);
                }
            #else
                untyped func(onfulfill, onreject);
            #end //hxpromise_catch_and_reject_on_promise_body

            Promises.defer(Promises.next);
        });

    } //new

        /** The then function returns a Promise. It takes two arguments,
            both are callback functions for the success and failure cases of the Promise. */
    public function then<T,T1>( on_fulfilled:T, ?on_rejected:T ) : Promise {

        switch(state) {

            case pending: {
                add_fulfill(on_fulfilled);
                add_reject(on_rejected);
                return new_linked_promise();
            }

            case fulfilled: {
                Promises.defer(on_fulfilled, result);
                return Promise.resolve(result);
            }

            case rejected: {
                Promises.defer(on_rejected, result);
                return Promise.reject(result);
            }

        } //switch

    } //then

        /** The error function returns a Promise and deals with rejected cases only.
            It behaves the same as calling then(null, on_rejected).*/
    public function error<T>( on_rejected:T ) : Promise {

        switch(state) {

            case pending: {
                add_reject(on_rejected);
                return new_linked_resolve_empty();
            }

            case fulfilled: {
                return Promise.resolve(result);
            }

            case rejected: {
                Promises.defer(on_rejected, result);
                return Promise.reject(result);
            }

        } //switch

    } //error

        /** The Promise.all(iterable) function returns a promise that
            resolves when all of the promises in the iterable argument
            have resolved. The result is passed as an array of values
            from all the promises.
            If any of the passed in promises rejects, the all Promise
            immediately rejects with the value of the promise that rejected,
            discarding all the other promises whether or not they have resolved. */
    public static function all( list:Array<Promise> ) {

        #if debug
            for(item in list) {
                if(item == null) throw "Promise.all handed an array with null items within it";
            }
        #end

        return new Promise(function(ok, no) {

            var current = 0;
            var total = list.length;
            var fulfill_result = [];
            var reject_result = null;
            var all_state:PromiseState = pending;

            var single_ok = function(index, val) {

                if(all_state != pending) return;

                current++;
                fulfill_result[index] = val;

                if(total == current) {
                    all_state = fulfilled;
                    ok(fulfill_result);
                }

            } //single_ok

            var single_err = function(val) {

                if(all_state != pending) return;

                all_state = rejected;
                reject_result = val;
                no(reject_result);

            } //single_err

            var index = 0;
            for(promise in list) {
                promise.then(single_ok.bind(index,_)).error(single_err);
                index++;
            }

        }); //promise

    } //all

        /** The Promise.race function returns a promise that
            resolves or rejects as soon as one of the promises in the
            list resolves or rejects, with the value or reason from that promise. */
    public static function race( list:Array<Promise> ) {

        return new Promise(function(ok,no) {

            var settled = false;
            var single_ok = function(val) {
                if(settled) return;
                settled = true;
                ok(val);
            }

            var single_err = function(val) {
                if(settled) return;
                settled = true;
                no(val);
            }

            for(promise in list) {
                promise.then(single_ok).error(single_err);
            }
        });

    } //race

        /** The Promise.reject function returns a Promise object
            that is rejected with the optional reason. */
    public static function reject<T>( ?reason:T ) {

        return new Promise(function(ok, no){
            no(reason);
        });

    } //reject

        /** The static Promise.resolve function returns a Promise object
            that is resolved with the given value. */
    public static function resolve<T>( ?val:T ) {

        return new Promise(function(ok, no){
            ok(val);
        });

    } //resolve

//Debug

    function toString() {
        return 'Promise { state:${state_string()}, result:$result }';
    }

//Internal

        /** internal: Add a settle reaction unless
            this promise is already settled,
            if it is the call is deferred but happens "immediately" */
    function add_settle(f) {

        if(state == pending) {
            settle_reactions.push(f);
        } else {
            Promises.defer(f,result);
        }

    } //add_settle

        /** internal: Return a new linked promise that
            will wait on this, and settle it with this result */
    function new_linked_promise() {

        return new Promise(function(f, r) {
            add_settle(function(_){
                if(state == fulfilled){
                    f(result);
                } else {
                    r(result);
                }
            });
        }); //promise

    } //


        /** internal: Return a resolved promise that
            will wait on this, and fulfill with this result */
    function new_linked_resolve() {
        return new Promise(function (f,r) {
            add_settle(function(val) {
                f(val);
            });
        });
    } //

        /** internal: Return a rejected promise that
            will wait on this, and reject with this result */
    function new_linked_reject() {
        return new Promise(function (f,r) {
            add_settle(function(val){
                r(val);
            });
        });
    } //

        /** internal: Return an already resolved
            promise that will wait on this one
            but have no value fulfilled */
    function new_linked_resolve_empty() {
        return new Promise(function(f,r) {
            add_settle(function(_){
                f();
            });
        });
    } //

        /** internal: Return an already rejected
            promise that will wait on this one
            but have no value rejected */
    function new_linked_reject_empty() {
        return new Promise(function(f,r) {
            add_settle(function(_){
                r();
            });
        });
    } //


        /** internal: Add a fulfill reaction callback */
    function add_fulfill<T>(f:T) {
        if(f != null) {
            fulfill_reactions.push(f);
        }
    } //

        /** internal: Add a reject reaction callback */
    function add_reject<T>(f:T) {
        if(f != null) {
            was_caught = true;
            reject_reactions.push(f);
        }
    } //

//State shifts

        /** internal: Called if the promise is fulfilled. */
    function onfulfill<T>( val:T ) {

        // trace('resolve: to $val, with ${fulfill_reactions.length} reactions');

        state = fulfilled;
        result = val;

        while(fulfill_reactions.length > 0) {
            var fn = fulfill_reactions.shift();
            fn(result);
        }

        onsettle();

    } //onfulfill

        /** internal: Called if the promise is rejected. */
    function onreject<T>( reason:T ) {

        // trace('reject: to $reason, with ${reject_reactions.length} reactions');

        state = rejected;
        result = reason;

        while(reject_reactions.length > 0) {
            var fn = reject_reactions.shift();
            fn(result);
        }

        onsettle();

    } //onreject

        /** internal: Called when the promise is settled. */
    function onsettle() {

        while(settle_reactions.length > 0) {
            var fn = settle_reactions.shift();
            fn(result);
        }

    } //onsettle

        /** internal: Handle exceptions in the promise callback.
            This causes a rejection, and if no handlers are found will throw */
    function onexception<T>( err:T ) {

        #if !hxpromise_dont_throw_unhandled_rejection

        add_settle(function(_){
            if(!was_caught) {
                if(state == rejected) {
                    throw PromiseError.UnhandledPromiseRejection(this.toString());
                    return;
                }
            }
        });

        #end //hxpromise_throw_unhandled_rejection

            //state can't transition
            //and we shouldn't reject twice
            //so we only reject if pending
        if(state == pending) {
            onreject(err);
        }

    } //onexception

        /** internal: return a string for our state */
    function state_string() {
        return switch(state){
            case pending:'pending';
            case fulfilled:'fulfilled';
            case rejected:'rejected';
        }
    }

} //Promise


/**
Promises implementation. Use this to integrate the promises
into your code base. Call step at the end of a frame/microtask.
*/
@:allow(snow.api.Promise)
class Promises {

    static var calls: Array<Dynamic> = [];
    static var defers: Array<{f:Dynamic,a:Dynamic}> = [];

        /** Call this once when you want to propagate promises */
    public static function step() {

        next();

        while(defers.length > 0) {
            var defer = defers.shift();
                defer.f(defer.a);
        }

    } //

        /** Handle the next job in the queue if any */
    static function next() {
        if(calls.length > 0) (calls.shift())();
    } //

        /** Defer a call with an argument to the next step */
    static function defer<T,T1>(f:T, ?a:T1) {
        if(f == null) return;
        defers.push({f:f, a:a});
    } //

        /** Queue a job to be executed in order */
    static function queue<T>(f:T) {
        if(f == null) return;
        calls.push(f);
    } //

} //Promises

//Promise types

enum PromiseError {
    UnhandledPromiseRejection(err:Dynamic);
}

@:enum
abstract PromiseState(Int) from Int to Int {
        //initial state, not fulfilled or rejected
    var pending = 0;
        //successful operation
    var fulfilled = 1;
        //failed operation
    var rejected = 2;

} //

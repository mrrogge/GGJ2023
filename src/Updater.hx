using tink.CoreApi;

class Updater<T> {
    public var promise(get, never):Promise<T>;
    function get_promise():Promise<T> return promiseTrigger.asPromise();

    public var resolved(default, null) = false;

    var promiseTrigger:PromiseTrigger<T>;
    var cblink:CallbackLink;

    public static function staticIsNotResolved(updater:Updater<Any>):Bool {
        return !updater.resolved;
    }

    public function new() {
        promiseTrigger = Promise.trigger();
        cblink = promiseTrigger.handle(nullHandler);
    }

    function nullHandler(outcome:Outcome<T, Error>) {}

    // Triggers the promise. Call this from update() based on your custom logic.
    public function trigger(outcome:Outcome<T, Error>) {
        resolved = true;
        promiseTrigger.trigger(outcome);
    }

    public function resolve(outcome:T) {
        resolved = true;
        promiseTrigger.resolve(outcome);
    }

    public function reject(error:Error) {
        resolved = true;
        promiseTrigger.reject(error);
    }

    // Called on every update(). Customize this to your needs.
    public dynamic function onUpdate(dt:Float) {}

    public function update(dt:Float) {
        trace('updating $dt');
        onUpdate(dt);
    }
}

class TimedUpdater extends Updater<Float> {
    public var acc(default, null) = 0.;
    public var duration(default, null) = 0.;

    override public function new(duration:Float) {
        super();
        this.duration = duration;
    }

    override function update(dt:Float) {
        super.update(dt);
        acc += dt;
        if (acc >= duration) {
            resolve(acc-duration);
        }
    }
}

class UpdaterGroup {
    var updaters = new List<Updater<Any>>();

    public function new() {

    }

    public function add(updater:Updater<Any>) {
        updaters.add(updater);
    }

    public function update(dt:Float) {
        for (updater in updaters) {
            if (!updater.resolved) updater.update(dt);
        }
        cleanupResolved();
    }

    // Removes resolved updaters from the list starting from the front, allowing them to be GCed. The traversal stops at the first unresolved updater, so it may not clean up every resolved updater immediately, but performance will be better with large lists.
    function cleanupResolved() {
        while (true) {
            if (updaters.isEmpty()) break;
            if (updaters.first().resolved) {
                updaters.pop();
            }
            else break;
        }
    }
}
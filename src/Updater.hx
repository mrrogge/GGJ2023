using tink.CoreApi;

class UpdaterGroup {
    var updaters = new List<Updater>();

    public function new() {

    }

    public function add(updater:Updater) {
        updaters.add(updater);
    }

    public function update(dt:Float) {
        for (updater in updaters) {
            switch updater.state {
                case AWAITING: updater.update(dt);
                case INIT | RESOLVED | FAILED: {}
            }
        }
        cleanupResolved();
    }

    // Removes resolved updaters from the list starting from the front, allowing them to be GCed. The traversal stops at the first unresolved updater, so it may not clean up every resolved updater immediately, but performance will be better with large lists.
    function cleanupResolved() {
        while (true) {
            if (updaters.isEmpty()) break;
            switch updaters.first().state {
                case RESOLVED | FAILED: {
                    updaters.pop();
                }
                case INIT | AWAITING: break;
            }
        }
    }
}

class Updater {
    public var state(default, null):UpdaterState = INIT;
    var nextUpdater:Option<Updater> = None;

    public function new(group:UpdaterGroup) {
        group.add(this);
    }

    public function begin():Updater {
        state = AWAITING;
        return this;
    }

    public function update(dt:Float) {
        onUpdate(this, dt);
    }

    public dynamic function onUpdate(me:Updater, dt:Float) {}

    public function withOnUpdate(f:(me:Updater, dt:Float)->Void):Updater {
        this.onUpdate = f;
        return this;
    }

    public function resolve() {
        trace("resolve");
        state = RESOLVED;
        switch nextUpdater {
            case Some(nextUpdater): {
                nextUpdater.state = AWAITING;
            }
            case None: {}
        }
    }

    public function reject() {
        trace("reject");
        state = FAILED;
        switch nextUpdater {
            case Some(nextUpdater): {
                nextUpdater.reject();
            }
            case None: {}
        }
    }

    public function next(nextUpdater:Updater):Updater {
        this.nextUpdater = Some(nextUpdater);
        return nextUpdater;
    }
}

enum UpdaterState {
    INIT;
    AWAITING;
    RESOLVED;
    FAILED;
}

class TimedUpdater extends Updater {
    public var acc(default, null) = 0.;
    public var duration(default, null) = 0.;

    override public function new(group:UpdaterGroup, duration:Float) {
        super(group);
        this.duration = duration;
    }

    override function update(dt:Float) {
        super.update(dt);
        acc += dt;
        if (acc >= duration) {
            resolve();
        }
    }
}
namespace TurnBasedController {

    array<UnitLogic@> unitsAllies;
    array<UnitLogic@> unitsEnemies;

    uint curAllyUnitIndex = 0;
    uint curEnemyUnitIndex = 0;
    bool allyTeam = true;
    bool firstUnitAdded = false;

    Label @info_label;

    void startNextUnitTurn() {
        
        if(unitsAllies.length() == 0) {
            debug("Team 1 wins!");
        } else if(unitsEnemies.length() == 0) {
            debug("Team 0 wins!");
        } else {
            debug("Next unit turn");
            if (allyTeam) {
                
                if(unitsAllies.length() <= curAllyUnitIndex) {
                    curAllyUnitIndex = 0;
                }
                
                unitsAllies[curAllyUnitIndex].startTurn();
                
                allyTeam = false;
                curAllyUnitIndex++;
                curAllyUnitIndex = curAllyUnitIndex % unitsAllies.length();
            } else {
                
                if(unitsEnemies.length() <= curEnemyUnitIndex) {
                    curEnemyUnitIndex = 0;
                }
                
                unitsEnemies[curEnemyUnitIndex].startTurn();
                
                allyTeam = true;
                curEnemyUnitIndex++;
                curEnemyUnitIndex = curEnemyUnitIndex % unitsEnemies.length();
            }
        }
    }

    void updateGameInfo() {
        info_label.text = unitsAllies.length() + "Allies vs " + unitsEnemies.length() + " Enemies";
    }

};


class GameMode : Behaviour {

    Prefab @unitPrefab = null;
    Prefab @widgetPrefab = null;
    uint allyAmount = 4;
    uint enemyAmount = 4;
    private Scene @cur_scene = null;
    Actor @game_info = null;
    Actor @camera = null;
    Actor @base_widget = null;
    int timer = 10;

    // Use this to initialize behaviour
    void start() override {

        //@cur_scene = Engine::loadScene("Maps/main.map", true);
        //Label @info_label = cast<Label>(game_info.component("Label"));
        @TurnBasedController::info_label = cast<Label>(game_info.component("Label"));


        for(uint x = 0; x < allyAmount; x++) {
            Actor@ actorRef = null;
            UnitLogic@ unitLogicRef = null;
            @actorRef = instantiate(unitPrefab, Vector3(4.0f, 0, x * 2.0f - 3), Quaternion(Vector3(0, 90, 0)));
            @unitLogicRef = cast<UnitLogic>(getObject(cast<AngelBehaviour>(actorRef.component("AngelBehaviour"))));
            unitLogicRef.team = 0;
            TurnBasedController::unitsAllies.insertLast(unitLogicRef);
            @unitLogicRef.widgetRef = cast<Actor>(instantiate(widgetPrefab, Vector3(0.0f, 0.0f, 0.0f), Quaternion(Vector3(0.0f, 0.0f, 0.0f))));
            unitLogicRef.updateWidget();
            @unitLogicRef.baseWidgetRef = base_widget;
            Transform @t = unitLogicRef.widgetRef.transform();
            Camera @camera_component = Camera::current();
            //Camera @camera_component = cast<Camera>(camera.component("Camera"));
            //debug("Test" + Vector3(600.0f, x * -50.0f + 300.0f, 0.0f));
            //debug(12345);
            
            //t.position = camera_component.project(Vector3(0.0f, 0.0f, 0.0f), actorRef.transform().worldTransform() * camera_component.viewMatrix(), camera_component.projectionMatrix());
            Vector2 vc = Vector2();
            Matrix4 vm = camera_component.viewMatrix();
            Matrix4 pm = camera_component.projectionMatrix();
            //debug(pm[0] + " " + pm[1] + " " + pm[2]);
            Transform @at = actorRef.transform();
            vc = camera_component.project(at.position);
            //vc = camera_component.project(Vector3(10.0f, 10.0f, 0.0f), camera_component.viewMatrix(), camera_component.projectionMatrix());
            t.position = Vector3(vc.x * 100.0f, vc.y * 100.0f, 0.0f);
            debug(vc.x + " " + vc.y);
            //t.position = Vector3(-600.0f, x * -50.0f + 300.0f, 0.0f);
        }
        
        for(uint x = 0; x < enemyAmount; x++) {
            Actor@ actorRef = null;
            UnitLogic@ unitLogicRef = null;
            @actorRef = instantiate(unitPrefab, Vector3(-4.0f, 0, x * 2.0f - 3), Quaternion(Vector3(0, 270, 0)));
            @unitLogicRef = cast<UnitLogic>(getObject(cast<AngelBehaviour>(actorRef.component("AngelBehaviour"))));
            unitLogicRef.team = 1;
            TurnBasedController::unitsEnemies.insertLast(unitLogicRef);
            @unitLogicRef.widgetRef = cast<Actor>(instantiate(widgetPrefab, Vector3(0.0f, 0.0f, 0.0f), Quaternion(Vector3(0.0f, 0.0f, 0.0f))));
            unitLogicRef.updateWidget();
            @unitLogicRef.baseWidgetRef = base_widget;
            Transform @t = unitLogicRef.widgetRef.transform();
            t.position = Vector3(-600.0f, x * -50.0f + 300.0f, 0.0f);
        }

        TurnBasedController::updateGameInfo();
        TurnBasedController::startNextUnitTurn();
    }


    // Will be called each frame. Use this to write your game logic
    void update() override {
        timer = timer - 1;
        if(timer == 0) {
            Camera @camera_component = cast<Camera>(camera.component("Camera"));
            Vector3 vc = Vector3();
            Matrix4 vm = camera_component.viewMatrix();
            Matrix4 pm = camera_component.projectionMatrix();
            debug(pm[0] + " " + pm[1] + " " + pm[2]);
            //vc = camera_component.project(Vector3(10.0f, 10.0f, 0.0f), Matrix4(), Matrix4());
            //vc = Camera::project(Vector3(10.0f, 10.0f, 0.0f), vm, pm);
        }
    }
};